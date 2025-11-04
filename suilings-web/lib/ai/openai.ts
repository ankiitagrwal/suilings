// OpenAI Client Setup

import OpenAI from "openai";

if (!process.env.OPENAI_API_KEY) {
  throw new Error("OPENAI_API_KEY environment variable is not set");
}

export const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// Default configuration
export const AI_CONFIG = {
  model: "gpt-4o-mini" as const, // Start with cheaper model for MVP
  temperature: 0.7, // Balanced creativity
  maxTokens: 800, // Reasonable response length
  presencePenalty: 0.1,
  frequencyPenalty: 0.1,
};

// Rate limiting configuration
export const RATE_LIMITS = {
  free: {
    requestsPerDay: 10,
    requestsPerHour: 5,
  },
  authenticated: {
    requestsPerDay: 50,
    requestsPerHour: 20,
  },
  premium: {
    requestsPerDay: 200,
    requestsPerHour: 100,
  },
};

