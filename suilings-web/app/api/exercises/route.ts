import { NextResponse } from "next/server";
import { promises as fs, accessSync } from "fs";
import path from "path";
import toml from "@iarna/toml";

// Determine paths based on environment
// Dev: Read from parent directory
// Production: Read from bundled public folder
function getPaths() {
  const parentRoot = path.join(process.cwd(), "..");
  const publicRoot = path.join(process.cwd(), "public");
  
  // Check if parent directory has exercises (development)
  const parentInfoPath = path.join(parentRoot, "info.toml");
  const publicInfoPath = path.join(publicRoot, "info.toml");
  
  try {
    accessSync(parentInfoPath);
    // Parent directory exists - use it (development)
    return { root: parentRoot, isProduction: false };
  } catch {
    // Use public folder (production/build)
    return { root: publicRoot, isProduction: true };
  }
}

export async function GET() {
  try {
    const { root, isProduction } = getPaths();
    
    // Read info.toml
    const infoTomlPath = path.join(root, "info.toml");
    const tomlContent = await fs.readFile(infoTomlPath, "utf-8");
    const parsed = toml.parse(tomlContent) as {
      exercises: Array<{ name: string; path: string; mode: string; hint: string }>;
    };

    // Load each exercise's actual code
    const exercises = await Promise.all(
      parsed.exercises.map(async (ex) => {
        const exercisePath = path.join(root, ex.path);
        
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

