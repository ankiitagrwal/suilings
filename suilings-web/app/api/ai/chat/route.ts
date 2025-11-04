// AI Chat API Route (Using Google Gemini - FREE!)

import { NextRequest, NextResponse } from "next/server";
import { geminiModel, AI_CONFIG } from "@/lib/ai/gemini";
import {
  buildSystemPrompt,
  buildHintPrompt,
  buildErrorExplanationPrompt,
  buildCodeReviewPrompt,
} from "@/lib/ai/prompts";
import type { AIChatRequest, AIChatResponse, AIChatMessage } from "@/types/ai";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

// Simple in-memory rate limiting (for MVP - use Redis in production)
const rateLimitMap = new Map<string, { count: number; resetAt: number }>();

function checkRateLimit(userId: string): boolean {
  const now = Date.now();
  const limit = rateLimitMap.get(userId);

  if (!limit || now > limit.resetAt) {
    // Reset or create new limit (5 requests per minute for MVP)
    rateLimitMap.set(userId, {
      count: 1,
      resetAt: now + 60000, // 1 minute
    });
    return true;
  }

  if (limit.count >= 5) {
    return false; // Rate limit exceeded
  }

  limit.count++;
  return true;
}

export async function POST(req: NextRequest) {
  try {
    // Get user IP for rate limiting (in MVP - use user ID in production)
    const userId = req.headers.get("x-forwarded-for") || "anonymous";

    // Check rate limit
    if (!checkRateLimit(userId)) {
      return NextResponse.json(
        {
          success: false,
          error: "Rate limit exceeded. Please wait a moment before sending another message.",
        },
        { status: 429 }
      );
    }

    const body: AIChatRequest = await req.json();
    const { message, context, conversationHistory, action = "chat" } = body;

    // Validate request
    if (!message || !context) {
      return NextResponse.json(
        {
          success: false,
          error: "Missing required fields: message and context",
        },
        { status: 400 }
      );
    }

    // Build system prompt with context
    const systemPrompt = buildSystemPrompt(context);

    // Build user prompt based on action
    let userPrompt = message;
    if (action === "hint") {
      userPrompt = buildHintPrompt(context) + "\n\nUser's question: " + message;
    } else if (action === "explain_error") {
      userPrompt = buildErrorExplanationPrompt(context);
    } else if (action === "review_code") {
      userPrompt = buildCodeReviewPrompt(context);
    }

    // Build conversation history for Gemini
    const conversationText = conversationHistory
      .slice(-5) // Keep last 5 messages for context
      .map((msg) => {
        const role = msg.role === "assistant" ? "AI Assistant" : "User";
        return `${role}: ${msg.content}`;
      })
      .join("\n\n");

    // Combine system prompt, history, and current message for Gemini
    const fullPrompt = `${systemPrompt}

${conversationText ? `## Previous Conversation:\n${conversationText}\n\n` : ""}## Current User Message:
${userPrompt}

Please provide a helpful, concise response focused on Move programming and Sui blockchain.`;

    // Call Gemini API (FREE!)
    const result = await geminiModel.generateContent({
      contents: [{ role: "user", parts: [{ text: fullPrompt }] }],
      generationConfig: {
        temperature: AI_CONFIG.temperature,
        maxOutputTokens: AI_CONFIG.maxOutputTokens,
        topP: AI_CONFIG.topP,
        topK: AI_CONFIG.topK,
      },
    });

    const response = await result.response;
    const assistantMessageText = response.text();

    // Estimate token usage (Gemini doesn't provide exact counts in responses)
    const estimatedPromptTokens = Math.ceil(fullPrompt.length / 4);
    const estimatedCompletionTokens = Math.ceil(assistantMessageText.length / 4);

    // Create response message
    const responseMessage: AIChatMessage = {
      id: `ai-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      role: "assistant",
      content: assistantMessageText || "I'm sorry, I couldn't generate a response.",
      timestamp: Date.now(),
      metadata: {
        exerciseId: context.exerciseId,
      },
    };

    const apiResponse: AIChatResponse = {
      success: true,
      message: responseMessage,
      usage: {
        promptTokens: estimatedPromptTokens,
        completionTokens: estimatedCompletionTokens,
        totalTokens: estimatedPromptTokens + estimatedCompletionTokens,
      },
    };

    return NextResponse.json(apiResponse);
  } catch (error: unknown) {
    console.error("AI Chat API Error:", error);
    
    const errorMessage = error instanceof Error ? error.message : String(error);

    // Handle specific Gemini errors
    if (errorMessage.includes("quota") || errorMessage.includes("RESOURCE_EXHAUSTED")) {
      return NextResponse.json(
        {
          success: false,
          error: "API quota exceeded. Please try again in a moment.",
        },
        { status: 429 }
      );
    }

    if (errorMessage.includes("API_KEY") || errorMessage.includes("invalid")) {
      return NextResponse.json(
        {
          success: false,
          error: "Invalid API key. Please check your GEMINI_API_KEY.",
        },
        { status: 500 }
      );
    }

    if (errorMessage.includes("SAFETY")) {
      return NextResponse.json(
        {
          success: false,
          error: "Content blocked by safety filters. Please rephrase your question.",
        },
        { status: 400 }
      );
    }

    return NextResponse.json(
      {
        success: false,
        error: "Failed to get AI response. Please try again.",
      },
      { status: 500 }
    );
  }
}

// Health check endpoint
export async function GET() {
  return NextResponse.json({
    status: "ok",
    provider: "google-gemini",
    model: AI_CONFIG.model,
    package: "@google/generative-ai",
    enabled: true,
    cost: "FREE! 🎉",
  });
}

