"use client";

import { useState, useRef, useEffect } from "react";
import { Send, Loader2, Sparkles, X} from "lucide-react";
import { Button } from "@/components/ui/button";
import { AIChatMessage } from "./AIChatMessage";
import { useExerciseStore } from "@/lib/store/exerciseStore";
import type { AIChatMessage as Message, AIChatContext } from "@/types/ai";
import { toast } from "sonner";

interface Props {
  onClose?: () => void;
  initialAction?: "chat" | "hint" | "explain_error";
}

export function AIChat({ onClose, initialAction }: Props) {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLTextAreaElement>(null);

  const { getCurrentExercise, currentCode, compilationResult } =
    useExerciseStore();

  // Auto-scroll to bottom when new messages arrive
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  // Handle initial action (like explain_error)
  useEffect(() => {
    if (initialAction && messages.length === 0) {
      if (initialAction === "hint") {
        handleQuickAction("hint", "Can you give me a hint for this exercise?");
      } else if (initialAction === "explain_error") {
        handleQuickAction("explain_error", "Can you explain this error?");
      }
    }
  }, [initialAction]);

  const buildContext = (): AIChatContext => {
    const exercise = getCurrentExercise();
    return {
      exerciseId: exercise?.name || "unknown",
      exerciseName: exercise?.name || "Unknown Exercise",
      exerciseDescription: exercise?.hint || exercise?.description,
      currentCode: currentCode,
      compilationError: compilationResult?.success
        ? undefined
        : compilationResult?.errors?.join("\n"),
      exerciseMode: exercise?.mode || "build",
    };
  };

  const sendMessage = async (
    messageText: string,
    action: "chat" | "hint" | "explain_error" | "review_code" = "chat"
  ) => {
    if (!messageText.trim() || isLoading) return;

    // Add user message
    const userMessage: Message = {
      id: `user-${Date.now()}`,
      role: "user",
      content: messageText,
      timestamp: Date.now(),
    };

    setMessages((prev) => [...prev, userMessage]);
    setInput("");
    setIsLoading(true);

    try {
      const response = await fetch("/api/ai/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          message: messageText,
          context: buildContext(),
          conversationHistory: messages,
          action,
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || "Failed to get AI response");
      }

      if (data.success) {
        setMessages((prev) => [...prev, data.message]);
      } else {
        throw new Error(data.error || "AI request failed");
      }
    } catch (error: any) {
      console.error("AI Chat Error:", error);
      toast.error(error.message || "Failed to get AI response");

      // Add error message
      const errorMessage: Message = {
        id: `error-${Date.now()}`,
        role: "assistant",
        content: `I'm sorry, I encountered an error: ${error.message}. Please try again.`,
        timestamp: Date.now(),
      };
      setMessages((prev) => [...prev, errorMessage]);
    } finally {
      setIsLoading(false);
    }
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    sendMessage(input);
  };

  const handleQuickAction = (
    action: "hint" | "explain_error" | "review_code",
    message: string
  ) => {
    sendMessage(message, action);
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      handleSubmit(e);
    }
  };

  return (
    <div className="flex flex-col h-full bg-background border-l">
      {/* Header */}
      <div className="flex items-center justify-between p-4 border-b bg-muted/30">
        <div className="flex items-center gap-2">
          <Sparkles className="w-5 h-5 text-purple-500" />
          <h3 className="font-semibold text-sm">AI</h3>
        </div>
        <div className="flex items-center gap-1">
          {onClose && (
            <Button
              variant="ghost"
              size="icon"
              className="h-8 w-8"
              onClick={onClose}
            >
              <X className="w-4 h-4" />
            </Button>
          )}
        </div>
      </div>

      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {messages.length === 0 && (
          <div className="flex flex-col items-center justify-center h-full text-center p-8">
            <Sparkles className="w-12 h-12 text-purple-500 mb-4" />
            <h4 className="font-semibold mb-2">Hi! I'm your AI tutor</h4>
            <p className="text-sm text-muted-foreground mb-4">
              Ask me anything about Move programming, get hints, or request
              error explanations.
            </p>
            <div className="flex flex-wrap gap-2 justify-center">
              <Button
                variant="outline"
                size="sm"
                onClick={() =>
                  handleQuickAction("hint", "Can you give me a hint?")
                }
              >
                Get Hint
              </Button>
              {compilationResult && !compilationResult.success && (
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() =>
                    handleQuickAction(
                      "explain_error",
                      "Can you explain this error?"
                    )
                  }
                >
                  Explain Error
                </Button>
              )}
            </div>
          </div>
        )}

        {messages.map((message) => (
          <AIChatMessage key={message.id} message={message} />
        ))}

        {isLoading && (
          <div className="flex items-center gap-2 p-4 bg-muted/30 rounded-lg">
            <Loader2 className="w-4 h-4 animate-spin" />
            <span className="text-sm text-muted-foreground">
              AI is thinking...
            </span>
          </div>
        )}

        <div ref={messagesEndRef} />
      </div>

      <div className="p-4 border-t">
        <form onSubmit={handleSubmit} className="space-y-2">
          <div className="flex gap-2">
            <textarea
              ref={inputRef}
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={handleKeyDown}
              placeholder="Ask me anything about Move..."
              className="flex-1 min-h-[60px] max-h-[120px] p-3 rounded-lg border bg-background resize-none focus:outline-none focus:ring-2 focus:ring-primary"
              disabled={isLoading}
            />
            <Button
              type="submit"
              size="icon"
              disabled={!input.trim() || isLoading}
              className="h-[60px] w-[60px]"
            >
              {isLoading ? (
                <Loader2 className="w-5 h-5 animate-spin" />
              ) : (
                <Send className="w-5 h-5" />
              )}
            </Button>
          </div>

          {/* Quick Actions */}
          <div className="flex gap-2 flex-wrap">
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={() =>
                handleQuickAction("hint", "Can you give me a hint?")
              }
              disabled={isLoading}
            >
              💡 Get Hint
            </Button>
            {compilationResult && !compilationResult.success && (
              <Button
                type="button"
                variant="outline"
                size="sm"
                onClick={() =>
                  handleQuickAction(
                    "explain_error",
                    "Can you explain this error?"
                  )
                }
                disabled={isLoading}
              >
                🔍 Explain Error
              </Button>
            )}
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={() =>
                handleQuickAction("review_code", "Can you review my code?")
              }
              disabled={isLoading || !currentCode}
            >
              ✅ Review Code
            </Button>
          </div>
        </form>

        <p className="text-xs text-muted-foreground mt-2 text-center">
          Press Enter to send, Shift+Enter for new line
        </p>
      </div>
    </div>
  );
}
