"use client";

import { useEffect, useState } from "react";
import { Panel, PanelGroup, PanelResizeHandle } from "react-resizable-panels";
import { Header } from "@/components/layout/Header";
import { Sidebar } from "@/components/layout/Sidebar";
import { ExerciseInstructions } from "@/components/exercise/ExerciseInstructions";
import { CodeEditor } from "@/components/exercise/CodeEditor";
import { OutputConsole } from "@/components/exercise/OutputConsole";
import { HintDialog } from "@/components/exercise/HintDialog";
import { AIChat } from "@/components/ai/AIChat";
import { useExerciseStore } from "@/lib/store/exerciseStore";
import { loadExercises } from "@/lib/exerciseLoader";
import { useAuth } from "@/lib/hooks/useAuth";
import { toast } from "sonner";
import { Sparkles, ChevronRight } from "lucide-react";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

export default function ExercisePage() {
  const [isHintOpen, setIsHintOpen] = useState(false);
  const [isAIChatOpen, setIsAIChatOpen] = useState(false);
  const [isSidebarOpen, setIsSidebarOpen] = useState(true);
  const { user } = useAuth();
  const {
    exercises,
    setExercises,
    setCurrentExercise,
    currentExerciseIndex,
    currentCode,
    setCompilationResult,
    setIsCompiling,
    resetExercise,
    updateExerciseStatus,
    getCurrentExercise,
    fetchProgress,
    loadExerciseProgress,
    markExerciseComplete,
    saveProgress,
  } = useExerciseStore();

  // Load exercises on mount - only run once
  useEffect(() => {
    let mounted = true;
    
    const init = async () => {
      if (!mounted) return;
      
      // Only load exercises if not already loaded
      if (exercises.length === 0) {
        const loadedExercises = await loadExercises();
        if (!mounted) return;
        
        setExercises(loadedExercises);
        
        // Only set to first exercise if no exercise is currently selected
        if (loadedExercises.length > 0 && currentExerciseIndex === -1) {
          setCurrentExercise(0);
        }
      }
      
      // Fetch user progress if authenticated (always refresh this)
      if (user && mounted) {
        await fetchProgress();
      }
    };
    init();
    
    // Pre-warm the compilation service on page load
    const warmupCompiler = async () => {
      try {
        await fetch('/api/compile/warmup', {
          method: 'GET',
          priority: 'low', // Don't block other requests
        });
      } catch {
        // Silently fail - warmup is optional
      }
    };
    
    // Warm up after a short delay to not block initial page load
    const warmupTimer = setTimeout(warmupCompiler, 2000);
    
    return () => {
      mounted = false;
      clearTimeout(warmupTimer);
    };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []); // Only run once on mount, ignore other deps to prevent resets

  // Load saved code when exercise changes
  useEffect(() => {
    const currentExercise = getCurrentExercise();
    if (currentExercise && user) {
      // Small delay to ensure progress is fetched
      setTimeout(() => {
        loadExerciseProgress(currentExercise.name);
      }, 100);
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [currentExerciseIndex, user]); // Only depend on index and user, not functions

  const handleRun = async () => {
    const currentExercise = getCurrentExercise();
    if (!currentExercise) return;

    setIsCompiling(true);
    setCompilationResult(null);

    try {
      // Call the real compilation API
      const response = await fetch("/api/compile", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          code: currentCode,
          mode: currentExercise.mode,
        }),
      });

      const result = await response.json();

      setCompilationResult(result);

      if (result.success) {
        updateExerciseStatus(currentExercise.name, "completed");
        
        // Save to backend if user is authenticated
        if (user) {
          await markExerciseComplete(currentExercise.name);
          toast.success("Great job! Your code works perfectly! 🎉");
        } else {
          toast.success("Great job! Your code works perfectly! 🎉", {
            description: "Sign in to save your progress permanently",
            action: {
              label: "Sign In",
              onClick: () => window.location.href = '/login',
            },
          });
        }
      } else {
        // Save progress even on failure (for authenticated users)
        if (user) {
          await saveProgress(currentExercise.name, {
            status: 'in_progress',
            last_code: currentCode,
          });
        }
        
        toast.error("Compilation failed! Check the console for details.");
      }
    } catch (error) {
      console.error("Compilation error:", error);
      setCompilationResult({
        success: false,
        output: "",
        errors: [`Failed to compile: ${(error as Error).message}`],
      });
      toast.error("Failed to compile. Please try again.");
    } finally {
      setIsCompiling(false);
    }
  };

  const handleReset = () => {
    resetExercise();
    setCompilationResult(null);
    toast.info("Exercise reset to initial state");
  };

  const handleShowHint = () => {
    setIsHintOpen(true);
  };

  if (exercises.length === 0) {
    return (
      <div className="h-screen flex flex-col overflow-hidden">
        <Header onRun={handleRun} onReset={handleReset} onShowHint={handleShowHint} />
        <div className="flex-1 flex items-center justify-center">
          <div className="text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto mb-4"></div>
            <p className="text-muted-foreground">Loading exercises...</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="h-screen flex flex-col overflow-hidden">
      <Header onRun={handleRun} onReset={handleReset} onShowHint={handleShowHint} />
      
      <div className="flex-1 flex overflow-hidden relative">
        {(!isSidebarOpen || isAIChatOpen) && (
          <Button
            variant="outline"
            size="icon"
            className="absolute left-0 top-16 z-50 h-10 w-10 rounded-r-lg rounded-l-none shadow-lg bg-background/95 backdrop-blur border-l-0 border-2 hover:bg-accent transition-all"
            onClick={() => {
              if (isAIChatOpen) {
                setIsAIChatOpen(false);
              }
              setIsSidebarOpen(true);
            }}
            title="Show sidebar"
          >
            <ChevronRight className="h-5 w-5" />
          </Button>
        )}
        
        <div 
          className={cn(
            "transition-all duration-300 ease-in-out overflow-hidden shrink-0",
            (isAIChatOpen || !isSidebarOpen) 
              ? "w-0 opacity-0 pointer-events-none" 
              : "w-64 opacity-100 pointer-events-auto"
          )}
        >
          <Sidebar onToggle={() => setIsSidebarOpen(false)} />
        </div>
        
        <main className={cn(
          "flex-1 overflow-hidden transition-all duration-300",
          (!isSidebarOpen && !isAIChatOpen) && "pl-0"
        )}>
          <PanelGroup direction="horizontal">
            {/* Left Panel - Exercise Instructions */}
            <Panel defaultSize={35} minSize={25} maxSize={50}>
              <ExerciseInstructions />
            </Panel>
            
            <PanelResizeHandle className="w-1 bg-border hover:bg-primary transition-colors" />
            
            {/* Middle Panel - Code Editor + Output Console */}
            <Panel defaultSize={40} minSize={30}>
              <PanelGroup direction="vertical">
                {/* Code Editor */}
                <Panel defaultSize={60} minSize={30}>
                  <CodeEditor />
                </Panel>
                
                <PanelResizeHandle className="h-1 bg-border hover:bg-primary transition-colors" />
                
                {/* Output Console */}
                <Panel defaultSize={40} minSize={20}>
                  <OutputConsole />
                </Panel>
              </PanelGroup>
            </Panel>

            {/* Right Panel - AI Chat (Conditional) */}
            {isAIChatOpen && (
              <>
                <PanelResizeHandle className="w-1 bg-border hover:bg-primary transition-colors" />
                <Panel defaultSize={25} minSize={20} maxSize={40}>
                  <AIChat onClose={() => setIsAIChatOpen(false)} />
                </Panel>
              </>
            )}
          </PanelGroup>
        </main>
      </div>

      {/* Floating AI Button (when chat is closed) */}
      {!isAIChatOpen && (
        <Button
          onClick={() => setIsAIChatOpen(true)}
          className="fixed bottom-6 right-6 h-14 w-14 rounded-full shadow-lg hover:shadow-xl transition-all z-50"
          size="icon"
        >
          <Sparkles className="w-6 h-6" />
        </Button>
      )}

      <HintDialog open={isHintOpen} onOpenChange={setIsHintOpen} />
    </div>
  );
}

