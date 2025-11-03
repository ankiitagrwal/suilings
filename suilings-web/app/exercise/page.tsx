"use client";

import { useEffect, useState } from "react";
import { Panel, PanelGroup, PanelResizeHandle } from "react-resizable-panels";
import { Header } from "@/components/layout/Header";
import { Sidebar } from "@/components/layout/Sidebar";
import { ExerciseInstructions } from "@/components/exercise/ExerciseInstructions";
import { CodeEditor } from "@/components/exercise/CodeEditor";
import { OutputConsole } from "@/components/exercise/OutputConsole";
import { HintDialog } from "@/components/exercise/HintDialog";
import { useExerciseStore } from "@/lib/store/exerciseStore";
import { loadExercises } from "@/lib/exerciseLoader";
import { useAuth } from "@/lib/hooks/useAuth";
import { toast } from "sonner";

export default function ExercisePage() {
  const [isHintOpen, setIsHintOpen] = useState(false);
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

  // Load exercises on mount
  useEffect(() => {
    const init = async () => {
      const loadedExercises = await loadExercises();
      setExercises(loadedExercises);
      
      // Fetch user progress if authenticated
      if (user) {
        await fetchProgress();
      }
      
      if (loadedExercises.length > 0) {
        setCurrentExercise(0);
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
    return () => clearTimeout(warmupTimer);
  }, [setExercises, setCurrentExercise, fetchProgress, user]);

  // Load saved code when exercise changes
  useEffect(() => {
    const currentExercise = getCurrentExercise();
    if (currentExercise && user) {
      // Small delay to ensure progress is fetched
      setTimeout(() => {
        loadExerciseProgress(currentExercise.name);
      }, 100);
    }
  }, [currentExerciseIndex, user]); // Changed dependency to currentExerciseIndex

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
      <div className="h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto mb-4"></div>
          <p className="text-muted-foreground">Loading exercises...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="h-screen flex flex-col overflow-hidden">
      <Header onRun={handleRun} onReset={handleReset} onShowHint={handleShowHint} />
      
      <div className="flex-1 flex overflow-hidden">
        <Sidebar />
        
        <main className="flex-1 overflow-hidden">
          <PanelGroup direction="horizontal">
            {/* Left Panel - Exercise Instructions */}
            <Panel defaultSize={40} minSize={30} maxSize={50}>
              <ExerciseInstructions />
            </Panel>
            
            <PanelResizeHandle className="w-1 bg-border hover:bg-primary transition-colors" />
            
            {/* Right Panel - Code Editor + Output Console */}
            <Panel defaultSize={60} minSize={50}>
              <PanelGroup direction="vertical">
                {/* Code Editor */}
                <Panel defaultSize={60} minSize={30}>
                  <CodeEditor />
                </Panel>
                
                <PanelResizeHandle className="h-1 bg-border hover:bg-primary transition-colors" />
                
                {/* Output Console */}
                <Panel defaultSize={30} minSize={20}>
                  <OutputConsole />
                </Panel>
              </PanelGroup>
            </Panel>
          </PanelGroup>
        </main>
      </div>

      <HintDialog open={isHintOpen} onOpenChange={setIsHintOpen} />
    </div>
  );
}

