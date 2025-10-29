import { NextResponse } from "next/server";
import { promises as fs } from "fs";
import path from "path";
import toml from "@iarna/toml";

// Path to the parent suilings directory
const SUILINGS_ROOT = path.join(process.cwd(), "..");

export async function GET() {
  try {
    // Read info.toml
    const infoTomlPath = path.join(SUILINGS_ROOT, "info.toml");
    const tomlContent = await fs.readFile(infoTomlPath, "utf-8");
    const parsed = toml.parse(tomlContent) as {
      exercises: Array<{ name: string; path: string; mode: string; hint: string }>;
    };

    // Load each exercise's actual code
    const exercises = await Promise.all(
      parsed.exercises.map(async (ex) => {
        const exercisePath = path.join(SUILINGS_ROOT, ex.path);
        
        try {
          const code = await fs.readFile(exercisePath, "utf-8");
          
          // Extract description from comments (first few lines)
          const lines = code.split("\n");
          const commentLines = [];
          const cleanCodeLines = [];
          let inDescriptionBlock = true;
          
          for (const line of lines) {
            const trimmed = line.trim();
            
            // Skip "I AM NOT DONE" line and its comment entirely
            if (trimmed.includes("I AM NOT DONE") || trimmed === "// I AM NOT DONE") {
              continue;
            }
            
            // Collect description from top comments
            if (inDescriptionBlock && trimmed.startsWith("//")) {
              commentLines.push(line.replace(/^\/\/\s*/, ""));
            } else if (trimmed && !trimmed.startsWith("//")) {
              // First non-comment, non-empty line - stop description collection
              inDescriptionBlock = false;
              cleanCodeLines.push(line);
            } else if (!inDescriptionBlock) {
              // After description block, keep all lines (including blank lines)
              // But skip standalone empty comment lines that might have been markers
              if (trimmed !== "//" || cleanCodeLines.length > 0) {
                cleanCodeLines.push(line);
              }
            }
          }
          
          const description = commentLines.join("\n").trim();
          // Remove "I AM NOT DONE" and description comments from the code
          const cleanCode = cleanCodeLines.join("\n").trim();

          return {
            name: ex.name,
            path: ex.path,
            mode: ex.mode,
            hint: ex.hint,
            description: description || `Exercise: ${ex.name}`,
            initialCode: cleanCode,
            status: "pending",
          };
        } catch (error) {
          console.error(`Failed to load exercise ${ex.name}:`, error);
          return null;
        }
      })
    );

    // Filter out any failed exercises
    const validExercises = exercises.filter((ex) => ex !== null);

    return NextResponse.json({ exercises: validExercises });
  } catch (error) {
    console.error("Failed to load exercises:", error);
    return NextResponse.json(
      { error: "Failed to load exercises", details: (error as Error).message },
      { status: 500 }
    );
  }
}

