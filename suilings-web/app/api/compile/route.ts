import { NextResponse } from "next/server";
import { promises as fs } from "fs";
import path from "path";
import { exec } from "child_process";
import { promisify } from "util";

const execAsync = promisify(exec);

// Path to the parent suilings directory
const SUILINGS_ROOT = path.join(process.cwd(), "..");
const RUNNER_CRATE_PATH = path.join(SUILINGS_ROOT, "runner-crate");
const MAIN_MOVE_PATH = path.join(RUNNER_CRATE_PATH, "sources", "main.move");

export async function POST(request: Request) {
  const startTime = Date.now();
  
  try {
    const body = await request.json();
    const { code, mode } = body as { code: string; mode: "build" | "test" };

    if (!code || !mode) {
      return NextResponse.json(
        { error: "Missing code or mode" },
        { status: 400 }
      );
    }

    // Step 1: Write user's code to runner-crate/sources/main.move
    await fs.writeFile(MAIN_MOVE_PATH, code, "utf-8");

    // Step 2: Run sui move build or test
    const command =
      mode === "test"
        ? `sui move test --path ${RUNNER_CRATE_PATH}`
        : `sui move build --path ${RUNNER_CRATE_PATH}`;

    try {
      const { stdout, stderr } = await execAsync(command, {
        cwd: RUNNER_CRATE_PATH,
        timeout: 30000, // 30 second timeout
      });

      const duration = Date.now() - startTime;

      // Success case
      return NextResponse.json({
        success: true,
        output: stdout || stderr || "Compilation successful!",
        errors: [],
        duration,
      });
    } catch (error) {
      // Compilation failed
      const duration = Date.now() - startTime;
      const err = error as { stderr?: string; stdout?: string; message: string };
      const errorOutput = err.stderr || err.stdout || err.message;

      return NextResponse.json({
        success: false,
        output: "",
        errors: [errorOutput],
        duration,
      });
    }
  } catch (error) {
    console.error("Compilation error:", error);
    const err = error as Error;
    return NextResponse.json(
      {
        success: false,
        output: "",
        errors: [`Internal server error: ${err.message}`],
        duration: Date.now() - startTime,
      },
      { status: 500 }
    );
  }
}

