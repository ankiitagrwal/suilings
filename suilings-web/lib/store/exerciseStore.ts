import { create } from "zustand";
import { persist } from "zustand/middleware";
import type { Exercise, ExerciseStatus, CompilationResult } from "@/types/exercise";

interface UserProgress {
  id: string;
  user_id: string;
  exercise_id: string;
  status: 'not_started' | 'in_progress' | 'completed';
  last_code: string | null;
  attempts_count: number;
  completed_at: string | null;
  created_at: string;
  updated_at: string;
}

interface ExerciseStore {
  exercises: Exercise[];
  currentExerciseIndex: number;
  currentCode: string;
  compilationResult: CompilationResult | null;
  isCompiling: boolean;
  isSyncing: boolean;
  userProgress: Map<string, UserProgress>;
  
  // Actions
  setExercises: (exercises: Exercise[]) => void;
  setCurrentExercise: (index: number) => void;
  setCurrentCode: (code: string) => void;
  updateExerciseStatus: (name: string, status: ExerciseStatus) => void;
  setCompilationResult: (result: CompilationResult | null) => void;
  setIsCompiling: (isCompiling: boolean) => void;
  nextExercise: () => void;
  previousExercise: () => void;
  getCurrentExercise: () => Exercise | null;
  resetExercise: () => void;
  
  // Backend sync actions
  fetchProgress: () => Promise<void>;
  saveProgress: (exerciseId: string, data: { status?: string; last_code?: string; completed?: boolean }) => Promise<void>;
  loadExerciseProgress: (exerciseId: string) => Promise<void>;
  markExerciseComplete: (exerciseName: string) => Promise<void>;
}

export const useExerciseStore = create<ExerciseStore>()(
  persist(
    (set, get) => ({
      exercises: [],
      currentExerciseIndex: 0,
      currentCode: "",
      compilationResult: null,
      isCompiling: false,
      isSyncing: false,
      userProgress: new Map(),

      setExercises: (exercises) => set({ exercises }),

      setCurrentExercise: (index) => {
        const exercises = get().exercises;
        if (index >= 0 && index < exercises.length) {
          const exercise = exercises[index];
          set({
            currentExerciseIndex: index,
            compilationResult: null,
          });
          
          // Load saved code after setting the exercise
          const savedProgress = get().userProgress.get(exercise.name);
          if (savedProgress?.last_code) {
            set({ currentCode: savedProgress.last_code });
          } else {
            set({ currentCode: exercise.initialCode || "" });
          }
        }
      },

      setCurrentCode: (code) => set({ currentCode: code }),

      updateExerciseStatus: (name, status) =>
        set((state) => ({
          exercises: state.exercises.map((ex) =>
            ex.name === name ? { ...ex, status } : ex
          ),
        })),

      setCompilationResult: (result) => set({ compilationResult: result }),

      setIsCompiling: (isCompiling) => set({ isCompiling }),

      nextExercise: () => {
        const { currentExerciseIndex, exercises } = get();
        if (currentExerciseIndex < exercises.length - 1) {
          get().setCurrentExercise(currentExerciseIndex + 1);
        }
      },

      previousExercise: () => {
        const { currentExerciseIndex } = get();
        if (currentExerciseIndex > 0) {
          get().setCurrentExercise(currentExerciseIndex - 1);
        }
      },

      getCurrentExercise: () => {
        const { exercises, currentExerciseIndex } = get();
        return exercises[currentExerciseIndex] || null;
      },

      resetExercise: () => {
        const currentExercise = get().getCurrentExercise();
        if (currentExercise?.initialCode) {
          set({ currentCode: currentExercise.initialCode, compilationResult: null });
        }
      },

      // Backend sync methods
      fetchProgress: async () => {
        try {
          set({ isSyncing: true });
          const response = await fetch('/api/progress');
          
          if (response.ok) {
            const data = await response.json();
            const progressMap = new Map<string, UserProgress>();
            
            data.progress?.forEach((p: UserProgress) => {
              progressMap.set(p.exercise_id, p);
            });
            
            set({ userProgress: progressMap });
            
            // Update exercise statuses based on progress
            const exercises = get().exercises;
            const updatedExercises = exercises.map(ex => {
              const progress = progressMap.get(ex.name); // Assuming exercise.name matches exercise_id
              if (progress) {
                return {
                  ...ex,
                  status: progress.status as ExerciseStatus,
                };
              }
              return ex;
            });
            
            set({ exercises: updatedExercises });
          }
        } catch (error) {
          console.error('Failed to fetch progress:', error);
        } finally {
          set({ isSyncing: false });
        }
      },

      saveProgress: async (exerciseId: string, data: { status?: string; last_code?: string; completed?: boolean }) => {
        try {
          const response = await fetch(`/api/progress/${exerciseId}`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify(data),
          });

          if (response.ok) {
            const result = await response.json();
            const progressMap = new Map(get().userProgress);
            progressMap.set(exerciseId, result.progress);
            set({ userProgress: progressMap });
          }
        } catch (error) {
          console.error('Failed to save progress:', error);
        }
      },

      loadExerciseProgress: async (exerciseId: string) => {
        try {
          const response = await fetch(`/api/progress/${exerciseId}`);
          
          if (response.ok) {
            const data = await response.json();
            if (data.progress?.last_code) {
              set({ currentCode: data.progress.last_code });
            }
          }
        } catch (error) {
          console.error('Failed to load exercise progress:', error);
        }
      },

      markExerciseComplete: async (exerciseName: string) => {
        try {
          const currentCode = get().currentCode;
          
          // Update local state immediately
          get().updateExerciseStatus(exerciseName, 'completed');
          
          // Save to backend
          await get().saveProgress(exerciseName, {
            status: 'completed',
            last_code: currentCode,
            completed: true,
          });
        } catch (error) {
          console.error('Failed to mark exercise complete:', error);
        }
      },
    }),
    {
      name: "suilings-exercise-storage",
      version: 3, // Increment to clear old cached data
      partialize: (state) => ({
        currentExerciseIndex: state.currentExerciseIndex,
        // Don't persist exercises or progress - always load fresh from API
      }),
    }
  )
);

