"use client";

import { AIChatMessage as Message } from "@/types/ai";
import { Copy, Check } from "lucide-react";
import { useState } from "react";
import ReactMarkdown from "react-markdown";
import { Prism as SyntaxHighlighter } from "react-syntax-highlighter";
import { vscDarkPlus } from "react-syntax-highlighter/dist/esm/styles/prism";

interface Props {
  message: Message;
}

export function AIChatMessage({ message }: Props) {
  const [copied, setCopied] = useState(false);

  const handleCopyCode = (code: string) => {
    navigator.clipboard.writeText(code);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const isUser = message.role === "user";

  return (
    <div
      className={`flex gap-3 p-4 ${
        isUser ? "bg-muted/50" : "bg-background"
      } rounded-lg`}
    >
      {/* Avatar */}
      <div
        className={`flex-shrink-0 w-8 h-8 rounded-full flex items-center justify-center text-sm font-medium ${
          isUser
            ? "bg-primary text-primary-foreground"
            : "bg-gradient-to-br from-purple-500 to-pink-500 text-white"
        }`}
      >
        {isUser ? "You" : "🤖"}
      </div>

      {/* Content */}
      <div className="flex-1 space-y-2 overflow-hidden">
        {/* Role Label */}
        <div className="text-xs text-muted-foreground font-medium">
          {isUser ? "You" : "AI Assistant"}
        </div>

        {/* Message Content */}
        <div className="prose prose-sm dark:prose-invert max-w-none">
          {isUser ? (
            <p className="text-sm whitespace-pre-wrap">{message.content}</p>
          ) : (
            <ReactMarkdown
              components={{
                code({ node, inline, className, children, ...props }) {
                  const match = /language-(\w+)/.exec(className || "");
                  const codeString = String(children).replace(/\n$/, "");

                  return !inline && match ? (
                    <div className="relative group">
                      <button
                        onClick={() => handleCopyCode(codeString)}
                        className="absolute right-2 top-2 p-2 rounded-md bg-muted hover:bg-muted/80 opacity-0 group-hover:opacity-100 transition-opacity"
                        title="Copy code"
                      >
                        {copied ? (
                          <Check className="w-4 h-4 text-green-500" />
                        ) : (
                          <Copy className="w-4 h-4" />
                        )}
                      </button>
                      <SyntaxHighlighter
                        style={vscDarkPlus}
                        language={match[1]}
                        PreTag="div"
                        {...props}
                      >
                        {codeString}
                      </SyntaxHighlighter>
                    </div>
                  ) : (
                    <code className={className} {...props}>
                      {children}
                    </code>
                  );
                },
              }}
            >
              {message.content}
            </ReactMarkdown>
          )}
        </div>

        {/* Timestamp */}
        <div className="text-xs text-muted-foreground">
          {new Date(message.timestamp).toLocaleTimeString()}
        </div>
      </div>
    </div>
  );
}

