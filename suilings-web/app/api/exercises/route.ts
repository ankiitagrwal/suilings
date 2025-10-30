import { NextResponse } from "next/server";
import { promises as fs } from "fs";
import path from "path";

export async function GET() {
  try {
    // Read the pre-generated exercises JSON file
    const jsonPath = path.join(process.cwd(), "lib", "exercises-data.json");
    const fileContent = await fs.readFile(jsonPath, "utf-8");
    const exercisesData = JSON.parse(fileContent);
    
    return NextResponse.json({ exercises: exercisesData.exercises || [] });
  } catch (error) {
    console.error("Failed to load exercises:", error);
    const err = error as Error;
    return NextResponse.json(
      { 
        error: "Failed to load exercises", 
        details: err.message,
        cwd: process.cwd()
      },
      { status: 500 }
    );
  }
}
