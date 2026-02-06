"use client";

import { useEffect, useState, useMemo, useCallback } from "react";
import { Panel, PanelGroup, PanelResizeHandle } from "react-resizable-panels";
import { Header } from "@/components/layout/Header";
import { Sidebar } from "@/components/layout/Sidebar";
import { ExerciseInstructions } from "@/components/exercise/ExerciseInstructions";
import { CodeEditor } from "@/components/exercise/CodeEditor";
import { OutputConsole } from "@/components/exercise/OutputConsole";
import { HintDialog } from "@/components/exercise/HintDialog";
import { AIChat } from "@/components/ai/AIChat";
import { useExerciseStore } from "@/lib/store/exerciseStore";
import { useExerciseInit } from "@/lib/hooks/useExerciseInit";
import { useAuth } from "@/lib/hooks/useAuth";
import { toast } from "sonner";
import { Sparkles, ChevronRight } from "lucide-react";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { useDebounce } from "@/lib/hooks/useDebounce";
import { AchievementModal } from "@/components/AchievementModal";
import { useAchievementDetection } from "@/lib/hooks/useAchievementDetection";
import { CredentialMintModal } from "@/components/credential/CredentialMintModal";
import { REQUIRED_EXERCISES_FOR_CREDENTIAL } from "@/lib/config/credential-config";
import { CredentialTestButton } from "@/components/credential/CredentialTestButton";

export default function ExercisePage() {
  const [isHintOpen, setIsHintOpen] = useState(false);
  const [isAIChatOpen, setIsAIChatOpen] = useState(false);
  const [isMobile, setIsMobile] = useState(false);
  const [isSidebarOpen, setIsSidebarOpen] = useState(false); // Default closed on mobile
  const [streakDays, setStreakDays] = useState(0);
  const [rank, setRank] = useState<number | null>(null);
  const [showCredentialModal, setShowCredentialModal] = useState(false);
  const { user } = useAuth();

  // Initialize exercises and progress using shared hook
  const { exercises } = useExerciseInit({ autoSelectFirst: true });

  // Detect mobile on mount
  useEffect(() => {
    const checkMobile = () => {
      const mobile = window.innerWidth < 768;
      setIsMobile(mobile);
      if (!mobile && !isSidebarOpen) {
        setIsSidebarOpen(true); // Auto-open sidebar on desktop
      }
    };
    
    checkMobile();
    window.addEventListener('resize', checkMobile);
    return () => window.removeEventListener('resize', checkMobile);
  }, [isSidebarOpen]);
  
  const {
    currentExerciseIndex,
    currentCode,
    setCompilationResult,
    setIsCompiling,
    resetExercise,
    updateExerciseStatus,
    getCurrentExercise,
    loadExerciseProgress,
    markExerciseComplete,
    saveProgress,
  } = useExerciseStore();


  const completedCount = useMemo(() => {
    return exercises.filter(e => e.status === 'completed').length;
  }, [exercises]);


  const { currentAchievement, closeAchievement } = useAchievementDetection({
    completedCount,
    streakDays,
    rank,
  });

  // Check if user is eligible for credential after completing required exercises
  useEffect(() => {
    if (user && completedCount >= REQUIRED_EXERCISES_FOR_CREDENTIAL) {
      // Check if user already has a credential
      const checkEligibility = async () => {
        try {
          const response = await fetch('/api/credential/check-eligibility');
          if (response.ok) {
            const data = await response.json();
            // Show modal if eligible (has all exercises but hasn't minted yet)
            if (data.eligible || (data.completed_exercises >= REQUIRED_EXERCISES_FOR_CREDENTIAL && !data.already_minted)) {
              setShowCredentialModal(true);
            }
          }
        } catch (error) {
          console.error('Failed to check credential eligibility:', error);
        }
      };
      
      checkEligibility();
    }
  }, [completedCount, user]);

  // Auto-save progress every 30 seconds if user is logged in
  const autoSaveProgress = useCallback(async () => {
    const currentExercise = getCurrentExercise();
    if (user && currentExercise && currentCode) {
      try {
        await saveProgress(currentExercise.name, {
          status: 'in-progress',
          last_code: currentCode,
        });
      } catch (error) {
        console.error('Auto-save failed:', error);
      }
    }
  }, [user, currentCode, getCurrentExercise, saveProgress]);

  const debouncedAutoSave = useDebounce(autoSaveProgress, 30000); // 30 seconds

  // Trigger auto-save when code changes
  useEffect(() => {
    if (user && currentCode) {
      debouncedAutoSave();
    }
  }, [currentCode, user, debouncedAutoSave]);


  useEffect(() => {
    const fetchStats = async () => {
      try {
        const statsResponse = await fetch('/api/stats');
        if (statsResponse.ok) {
          const data = await statsResponse.json();
          setStreakDays(data.stats?.streakDays || 0);
        }

        const leaderboardResponse = await fetch('/api/leaderboard?period=all-time');
        if (leaderboardResponse.ok) {
          const data = await leaderboardResponse.json();
          setRank(data.userPosition);
        }
      } catch (error) {
        console.error('Failed to fetch stats:', error);
      }
    };
    
    if (user && exercises.length > 0) {
      fetchStats();
    }
  }, [user, exercises.length]);


  // Warmup compiler in background after initial load
  useEffect(() => {
    if (exercises.length === 0) return;
    
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
    
    // Delay warmup to not compete with initial load
    const warmupTimer = setTimeout(warmupCompiler, 2000);
    
    return () => {
      clearTimeout(warmupTimer);
    };
  }, [exercises.length]);

  useEffect(() => {
    const currentExercise = getCurrentExercise();
    if (currentExercise && user) {

      setTimeout(() => {
        loadExerciseProgress(currentExercise.name);
      }, 100);
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [currentExerciseIndex, user]); 

  const handleRun = async () => {
    const currentExercise = getCurrentExercise();
    if (!currentExercise) return;

    setIsCompiling(true);
    setCompilationResult(null);

    try {

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
        if (user) {
          await saveProgress(currentExercise.name, {
            status: 'in-progress',
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

      <AchievementModal 
        achievement={currentAchievement} 
        onClose={closeAchievement}
      />
      
      <div className="flex-1 flex overflow-hidden relative">
        {/* Mobile sidebar overlay */}
        {isMobile && isSidebarOpen && (
          <div 
            className="fixed inset-0 bg-black/50 z-40"
            onClick={() => setIsSidebarOpen(false)}
          />
        )}
        
        {/* Toggle sidebar button */}
        {(!isSidebarOpen || isAIChatOpen) && (
          <Button
            variant="outline"
            size="icon"
            className="absolute left-0 top-4 md:top-16 z-50 h-10 w-10 rounded-r-lg rounded-l-none shadow-lg bg-background/95 backdrop-blur border-l-0 border-2 hover:bg-accent transition-all"
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
        
        {/* Sidebar - Fixed on mobile, relative on desktop */}
        <div 
          className={cn(
            "transition-all duration-300 ease-in-out overflow-hidden shrink-0",
            isMobile ? "fixed left-0 top-0 h-full z-50" : "relative",
            (isAIChatOpen || !isSidebarOpen) 
              ? "w-0 opacity-0 pointer-events-none" 
              : isMobile 
                ? "w-64 opacity-100 pointer-events-auto"
                : "w-64 opacity-100 pointer-events-auto"
          )}
        >
          <Sidebar onToggle={() => setIsSidebarOpen(false)} />
        </div>
        
        {/* Main content area */}
        <main className={cn(
          "flex-1 overflow-hidden transition-all duration-300",
          (!isSidebarOpen && !isAIChatOpen) && "pl-0"
        )}>
          {/* Mobile: Stack vertically, Desktop: Horizontal panels */}
          {isMobile ? (
            <div className="h-full flex flex-col">
              {/* Instructions - collapsed by default on mobile */}
              <div className="border-b border-border">
                <ExerciseInstructions />
              </div>
              
              {/* Code Editor */}
              <div className="flex-1 min-h-[300px]">
                <CodeEditor />
              </div>
              
              {/* Output Console */}
              <div className="h-48 border-t border-border">
                <OutputConsole />
              </div>
            </div>
          ) : (
            <PanelGroup direction="horizontal">
              <Panel defaultSize={35} minSize={25} maxSize={50}>
                <ExerciseInstructions />
              </Panel>
              
              <PanelResizeHandle className="w-1 bg-border hover:bg-primary transition-colors" />
              
              <Panel defaultSize={40} minSize={30}>
                <PanelGroup direction="vertical">
                  {/* Code Editor */}
                  <Panel defaultSize={60} minSize={30}>
                    <CodeEditor />
                  </Panel>
                  
                  <PanelResizeHandle className="h-1 bg-border hover:bg-primary transition-colors" />
                  
                  <Panel defaultSize={40} minSize={20}>
                    <OutputConsole />
                  </Panel>
                </PanelGroup>
              </Panel>

              {isAIChatOpen && (
                <>
                  <PanelResizeHandle className="w-1 bg-border hover:bg-primary transition-colors" />
                  <Panel defaultSize={25} minSize={20} maxSize={40}>
                    <AIChat onClose={() => setIsAIChatOpen(false)} />
                  </Panel>
                </>
              )}
            </PanelGroup>
          )}
        </main>
      </div>

      {!isAIChatOpen && !isMobile && (
        <Button
          onClick={() => setIsAIChatOpen(true)}
          className="fixed bottom-6 right-6 h-14 w-14 rounded-full shadow-lg hover:shadow-xl transition-all z-50"
          size="icon"
        >
          <Sparkles className="w-6 h-6" />
        </Button>
      )}

      {/* Test Button for Credential Modal (Remove after testing) */}
      {user && process.env.NODE_ENV === 'development' && (
        <CredentialTestButton
          completedCount={completedCount}
          onTriggerModal={() => setShowCredentialModal(true)}
        />
      )}

      <HintDialog open={isHintOpen} onOpenChange={setIsHintOpen} />
      
      {/* Achievement Modal */}
      <AchievementModal
        achievement={currentAchievement}
        onClose={closeAchievement}
      />
      
      {/* Credential Mint Modal */}
      {user && (
        <CredentialMintModal
          open={showCredentialModal}
          onOpenChange={setShowCredentialModal}
          completedExercises={completedCount}
          githubUsername={user.user_metadata?.user_name || user.user_metadata?.preferred_username || ''}
          streakDays={streakDays}
        />
      )}
    </div>
  );
}

