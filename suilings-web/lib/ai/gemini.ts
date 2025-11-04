// Google Gemini AI Client Setup (FREE!)

import { GoogleGenerativeAI } from "@google/generative-ai";

if (!process.env.GEMINI_API_KEY) {
  throw new Error("GEMINI_API_KEY environment variable is not set");
}

// Debug: Log that key is present (not the actual key for security)
console.log("Gemini API Key configured:", process.env.GEMINI_API_KEY ? "✓ Yes" : "✗ No");

// Initialize Gemini client
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// Use Gemini 2.5 Flash - Latest and fastest free model!
export const geminiModel = genAI.getGenerativeModel({
  model: "gemini-2.5-flash", // Latest stable model (FREE & FAST)
});

// Default configuration for coding assistance
export const AI_CONFIG = {
  model: "gemini-2.5-flash" as const,
  temperature: 0.7, // Balanced creativity
  maxOutputTokens: 1000, // Response length
  topP: 0.95,
  topK: 40,
};

// Rate limiting configuration (can be more generous since it's free!)
export const RATE_LIMITS = {
  free: {
    requestsPerDay: 50, // Increased since Gemini is free
    requestsPerHour: 20,
  },
  authenticated: {
    requestsPerDay: 150,
    requestsPerHour: 50,
  },
  premium: {
    requestsPerDay: 500,
    requestsPerHour: 150,
  },
};

