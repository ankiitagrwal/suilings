// AI Chat API Route

import { NextRequest, NextResponse } from "next/server";
import { openai, AI_CONFIG } from "@/lib/ai/openai";
import {
  buildSystemPrompt,
  buildHintPrompt,
  buildErrorExplanationPrompt,
  buildCodeReviewPrompt,
  COMMON_RESPONSES,
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

    // Prepare messages for OpenAI
    const messages: Array<{ role: "system" | "user" | "assistant"; content: string }> = [
      { role: "system", content: systemPrompt },
    ];

    // Add conversation history (last 5 messages to keep context manageable)
    const recentHistory = conversationHistory.slice(-5);
    for (const msg of recentHistory) {
      if (msg.role === "user" || msg.role === "assistant") {
        messages.push({
          role: msg.role,
          content: msg.content,
        });
      }
    }

    // Add current message
    messages.push({
      role: "user",
      content: userPrompt,
    });

    // Call OpenAI API
    const completion = await openai.chat.completions.create({
      model: AI_CONFIG.model,
      messages,
      temperature: AI_CONFIG.temperature,
      max_tokens: AI_CONFIG.maxTokens,
      presence_penalty: AI_CONFIG.presencePenalty,
      frequency_penalty: AI_CONFIG.frequencyPenalty,
    });

    const assistantMessage = completion.choices[0].message;
    const usage = completion.usage;

    // Create response message
    const responseMessage: AIChatMessage = {
      id: `ai-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      role: "assistant",
      content: assistantMessage.content || "I'm sorry, I couldn't generate a response.",
      timestamp: Date.now(),
      metadata: {
        exerciseId: context.exerciseId,
      },
    };

    const response: AIChatResponse = {
      success: true,
      message: responseMessage,
      usage: usage
        ? {
            promptTokens: usage.prompt_tokens,
            completionTokens: usage.completion_tokens,
            totalTokens: usage.total_tokens,
          }
        : undefined,
    };

    return NextResponse.json(response);
  } catch (error: any) {
    console.error("AI Chat API Error:", error);

    // Handle specific OpenAI errors
    if (error?.status === 429) {
      return NextResponse.json(
        {
          success: false,
          error: "OpenAI rate limit reached. Please try again in a moment.",
        },
        { status: 429 }
      );
    }

    if (error?.status === 401) {
      return NextResponse.json(
        {
          success: false,
          error: "OpenAI API key is invalid. Please contact support.",
        },
        { status: 500 }
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
    model: AI_CONFIG.model,
    enabled: true,
  });
}

