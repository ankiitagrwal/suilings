export type ExerciseMode = "build" | "test";

export type ExerciseStatus = "pending" | "completed" | "in-progress";

export type ExerciseDifficulty = "basic" | "advanced";

export interface Exercise {
  name: string;
  path: string;
  mode: ExerciseMode;
  hint: string;
  difficulty?: ExerciseDifficulty; // New field
  description?: string;
  initialCode?: string;
  status?: ExerciseStatus;
}

export interface ExerciseList {
  exercises: Exercise[];
}

export interface CompilationResult {
  success: boolean;
  output: string;
  errors?: string[];
  duration?: number;
}

