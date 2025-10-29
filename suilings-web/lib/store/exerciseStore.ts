import { create } from "zustand";
import { persist } from "zustand/middleware";
import type { Exercise, ExerciseStatus, CompilationResult } from "@/types/exercise";

interface ExerciseStore {
  exercises: Exercise[];
  currentExerciseIndex: number;
  currentCode: string;
  compilationResult: CompilationResult | null;
  isCompiling: boolean;
  
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
}

export const useExerciseStore = create<ExerciseStore>()(
  persist(
    (set, get) => ({
      exercises: [],
      currentExerciseIndex: 0,
      currentCode: "",
      compilationResult: null,
      isCompiling: false,

      setExercises: (exercises) => set({ exercises }),

      setCurrentExercise: (index) => {
        const exercises = get().exercises;
        if (index >= 0 && index < exercises.length) {
          const exercise = exercises[index];
          set({
            currentExerciseIndex: index,
            currentCode: exercise.initialCode || "",
            compilationResult: null,
          });
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
    }),
    {
      name: "suilings-exercise-storage",
      version: 2, // Increment to clear old cached data
      partialize: (state) => ({
        currentExerciseIndex: state.currentExerciseIndex,
        // Don't persist exercises - always load fresh from API
      }),
    }
  )
);

