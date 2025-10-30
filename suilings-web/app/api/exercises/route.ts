import { NextResponse } from "next/server";
// Import the exercises data generated at build time
import exercisesData from "@/lib/exercises-data.json";

export async function GET() {
  try {
    // Return the pre-generated exercises data
    return NextResponse.json({ exercises: exercisesData.exercises || [] });
  } catch (error) {
    console.error("Failed to load exercises:", error);
    const err = error as Error;
    return NextResponse.json(
      { 
        error: "Failed to load exercises", 
        details: err.message,
      },
      { status: 500 }
    );
  }
}
