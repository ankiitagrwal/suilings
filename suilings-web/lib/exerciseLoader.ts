import type { Exercise } from "@/types/exercise";

// Load exercises from the API (which reads from the actual files)
export async function loadExercises(): Promise<Exercise[]> {
  try {
    // Use relative URL for client-side fetches, Next.js handles it properly
    const baseUrl = typeof window !== "undefined" ? "" : "http://localhost:3000";
    const response = await fetch(`${baseUrl}/api/exercises`, {
      cache: "no-store", // Always get fresh data
    });

    if (!response.ok) {
      throw new Error(`Failed to load exercises: ${response.statusText}`);
    }

    const data = await response.json();
    return data.exercises || [];
  } catch (error) {
    console.error("Failed to load exercises:", error);
    
    // Fallback to empty array if API fails
    // In production, you might want to show an error message
    return [];
  }
}

// Group exercises by category (extracted from path)
export function groupExercisesByCategory(exercises: Exercise[]) {
  const grouped: Record<string, Exercise[]> = {};
  
  exercises.forEach((exercise) => {
    // Extract category from path (e.g., "exercises/intro/intro1.move" -> "intro")
    const parts = exercise.path.split("/");
    const category = parts[1] || "other";
    
    if (!grouped[category]) {
      grouped[category] = [];
    }
    grouped[category].push(exercise);
  });
  
  return grouped;
}

// Calculate progress
export function calculateProgress(exercises: Exercise[]) {
  const completed = exercises.filter((ex) => ex.status === "completed").length;
  const total = exercises.length;
  const percentage = total > 0 ? Math.round((completed / total) * 100) : 0;
  
  return { completed, total, percentage };
}

