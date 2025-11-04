"use client";

import { ScrollArea } from "@/components/ui/scroll-area";
import { Button } from "@/components/ui/button";
import { useExerciseStore } from "@/lib/store/exerciseStore";
import { Terminal, CheckCircle2, XCircle, Trash2 } from "lucide-react";
import { cn } from "@/lib/utils";

export function OutputConsole() {
  const { compilationResult, setCompilationResult } = useExerciseStore();

  const clearConsole = () => {
    setCompilationResult(null);
  };

  return (
    <div className="h-full flex flex-col bg-muted/20 border-t border-border overflow-hidden">
      {/* Console Header */}
      <div className="flex items-center justify-between px-4 py-2 border-b border-border/50 shrink-0 bg-background/50">
        <div className="flex items-center gap-2">
          <Terminal className="h-4 w-4 text-muted-foreground" />
          <span className="text-sm font-medium text-foreground">Output Console</span>
        </div>
        {compilationResult && (
          <Button
            variant="ghost"
            size="sm"
            onClick={clearConsole}
            className="h-7 text-xs"
          >
            <Trash2 className="h-3 w-3 mr-1" />
            Clear
          </Button>
        )}
      </div>

      {/* Console Content */}
      <ScrollArea className="flex-1 overflow-y-auto">
        <div className="p-4 font-mono text-sm pb-8">
          {!compilationResult ? (
            <div className="text-muted-foreground/50 text-center py-8">
              Run your code to see output here...
            </div>
          ) : (
            <div className="space-y-3">
              {/* Success/Error Header */}
              <div
                className={cn(
                  "flex items-center gap-2 font-semibold",
                  compilationResult.success
                    ? "text-green-600 dark:text-green-500"
                    : "text-red-600 dark:text-red-500"
                )}
              >
                {compilationResult.success ? (
                  <>
                    <CheckCircle2 className="h-5 w-5" />
                    <span>Success!</span>
                  </>
                ) : (
                  <>
                    <XCircle className="h-5 w-5" />
                    <span>Compilation Failed</span>
                  </>
                )}
              </div>

              {/* Duration */}
              {compilationResult.duration && (
                <div className="text-muted-foreground text-xs">
                  Completed in {compilationResult.duration}ms
                </div>
              )}

              {/* Output */}
              {compilationResult.output && (
                <div className="bg-background/50 rounded-md p-3 border border-border/50">
                  <pre className="text-xs text-foreground whitespace-pre-wrap">
                    {compilationResult.output}
                  </pre>
                </div>
              )}

              {/* Errors */}
              {compilationResult.errors && compilationResult.errors.length > 0 && (
                <div className="space-y-2">
                  <div className="text-red-600 dark:text-red-400 font-semibold text-xs">Errors:</div>
                  {compilationResult.errors.map((error, index) => (
                    <div
                      key={index}
                      className="bg-red-50 dark:bg-red-950/30 border border-red-200 dark:border-red-800/30 rounded-md p-3"
                    >
                      <pre className="text-xs text-red-800 dark:text-red-300 whitespace-pre-wrap">
                        {error}
                      </pre>
                    </div>
                  ))}
                </div>
              )}

              {/* Success Message */}
              {compilationResult.success && (
                <div className="bg-green-50 dark:bg-green-950/30 border border-green-200 dark:border-green-800/30 rounded-md p-4 mt-4">
                  <div className="flex items-start gap-3">
                    <span className="text-2xl">🎉</span>
                    <div className="flex-1">
                      <div className="text-green-700 dark:text-green-400 font-semibold mb-1">
                        Congratulations!
                      </div>
                      <div className="text-green-600 dark:text-green-300/80 text-xs">
                        Your code compiled and ran successfully! You can now move on to
                        the next exercise.
                      </div>
                    </div>
                  </div>
                </div>
              )}
            </div>
          )}
        </div>
      </ScrollArea>
    </div>
  );
}

