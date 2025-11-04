// AI Chat Types

export interface AIChatMessage {
  id: string;
  role: "user" | "assistant" | "system";
  content: string;
  timestamp: number;
  metadata?: {
    exerciseId?: string;
    hasCode?: boolean;
    sources?: Array<{
      title: string;
      url: string;
    }>;
  };
}

export interface AIChatContext {
  exerciseId: string;
  exerciseName: string;
  exerciseDescription?: string;
  currentCode: string;
  compilationError?: string;
  exerciseMode: "build" | "test";
  userProgress?: {
    completedExercises: string[];
    currentAttempts: number;
  };
}

export interface AIChatRequest {
  message: string;
  context: AIChatContext;
  conversationHistory: AIChatMessage[];
  action?: "chat" | "hint" | "explain_error" | "review_code";
}

export interface AIChatResponse {
  success: boolean;
  message: AIChatMessage;
  usage?: {
    promptTokens: number;
    completionTokens: number;
    totalTokens: number;
  };
  error?: string;
}

export interface AISettings {
  model: "gpt-4o" | "gpt-4o-mini" | "gpt-3.5-turbo";
  temperature: number;
  maxTokens: number;
  enabled: boolean;
}

