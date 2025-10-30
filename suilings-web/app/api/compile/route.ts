import { NextResponse } from "next/server";
import { promises as fs, accessSync } from "fs";
import path from "path";
import { exec } from "child_process";
import { promisify } from "util";

const execAsync = promisify(exec);

// Path to the parent suilings directory
const SUILINGS_ROOT = path.join(process.cwd(), "..");
const RUNNER_CRATE_PATH = path.join(SUILINGS_ROOT, "runner-crate");
const MAIN_MOVE_PATH = path.join(RUNNER_CRATE_PATH, "sources", "main.move");

// Check if we're in production (no sui CLI available or read-only filesystem)
function isProductionMode() {
  // Check if running on Vercel (VERCEL environment variable is set)
  if (process.env.VERCEL || process.env.VERCEL_ENV) {
    return true;
  }
  
  // Check if runner-crate directory exists and is writable
  try {
    accessSync(RUNNER_CRATE_PATH);
    // Try to test if filesystem is writable
    const testPath = path.join(RUNNER_CRATE_PATH, '.write-test');
    try {
      require('fs').writeFileSync(testPath, 'test');
      require('fs').unlinkSync(testPath);
      return false; // Development mode - can write
    } catch {
      return true; // Production mode - read-only filesystem
    }
  } catch {
    return true; // Production mode (no runner-crate)
  }
}

export async function POST(request: Request) {
  const startTime = Date.now();
  
  // Check if we're in production mode
  if (isProductionMode()) {
    // If backend service URL is configured, use it
    const backendUrl = process.env.COMPILATION_BACKEND_URL;
    
    if (backendUrl) {
      try {
        const body = await request.json();
        
        // Forward request to backend compilation service
        const response = await fetch(`${backendUrl}/api/compile`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify(body),
        });
        
        const data = await response.json();
        return NextResponse.json(data);
      } catch (error) {
        console.error('Backend compilation service error:', error);
        return NextResponse.json({
          success: false,
          output: "",
          errors: [`Failed to connect to compilation service: ${(error as Error).message}`],
          duration: Date.now() - startTime,
        });
      }
    }
    
    // No backend configured - show demo mode
    return NextResponse.json({
      success: false,
      output: "",
      errors: [
        "⚠️ DEMO MODE\n\n" +
        "Compilation is not available in the deployed version.\n\n" +
        "This demo showcases the UI and learning platform.\n" +
        "To use real compilation:\n" +
        "1. Clone the repository\n" +
        "2. Run locally with: npm run dev\n" +
        "3. Install Sui CLI for full functionality\n\n" +
        "Or wait for the backend deployment with full compilation support!"
      ],
      duration: Date.now() - startTime,
      isDemo: true,
    });
  }
  
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

