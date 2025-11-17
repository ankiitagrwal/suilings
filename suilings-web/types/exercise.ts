export type ExerciseMode = "build" | "test";

export type ExerciseStatus = "pending" | "completed" | "in-progress";

export type ExerciseDifficulty = "basic" | "advanced";

export interface Exercise {
  name: string;
  displayName?: string; // Clean display name for UI (e.g., "Hello World" instead of "intro1")
  path: string;
  mode: ExerciseMode;
  hint: string;
  difficulty?: ExerciseDifficulty;
  description?: string;
  initialCode?: string;
  status?: ExerciseStatus;
  moveBookUrl?: string; // Link to Move Book chapter
  suiDocsUrl?: string;  // Link to Sui documentation
  moveBookChapter?: string; // Chapter name/title
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

