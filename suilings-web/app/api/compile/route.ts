import { NextResponse } from "next/server";
import { promises as fs, accessSync } from "fs";
import path from "path";
import { exec } from "child_process";
import { promisify } from "util";
import os from "os";

const execAsync = promisify(exec);

// Path to the parent suilings directory
const SUILINGS_ROOT = path.join(process.cwd(), "..");
const RUNNER_CRATE_PATH = path.join(SUILINGS_ROOT, "runner-crate");
const MAIN_MOVE_PATH = path.join(RUNNER_CRATE_PATH, "sources", "main.move");

// Find sui binary path
async function findSuiPath(): Promise<string> {
  const homeDir = os.homedir();
  const localBinPath = path.join(homeDir, ".local", "bin", "sui");
  
  try {
    await fs.access(localBinPath);
    return localBinPath;
  } catch {
    // Fall back to "sui" and let it use PATH
    return "sui";
  }
}

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
        
        // Forward request to backend compilation service with optimizations
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 45000); // 45s timeout
        
        const response = await fetch(`${backendUrl}/api/compile`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Connection': 'keep-alive',
          },
          body: JSON.stringify(body),
          signal: controller.signal,
          keepalive: true,
        });
        
        clearTimeout(timeoutId);
        const data = await response.json();
        return NextResponse.json(data);
      } catch (error) {
        const err = error as Error;
        if (err.name === 'AbortError') {
          return NextResponse.json({
            success: false,
            output: "",
            errors: ["Compilation timeout (45s). The code may be too complex or the service is cold-starting. Please try again."],
            duration: Date.now() - startTime,
          });
        }
        return NextResponse.json({
          success: false,
          output: "",
          errors: [`Failed to connect to compilation service: ${err.message}`],
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

    // Step 2: Find sui binary and run sui move build or test
    const suiPath = await findSuiPath();
    const homeDir = os.homedir();
    const localBinPath = path.join(homeDir, ".local", "bin");
    
    // Set PATH to include ~/.local/bin if it exists
    const env = { ...process.env };
    if (localBinPath && !env.PATH?.includes(localBinPath)) {
      env.PATH = `${localBinPath}:${env.PATH || ""}`;
    }
    
    const command =
      mode === "test"
        ? `${suiPath} move test --path ${RUNNER_CRATE_PATH} --skip-fetch-latest-git-deps`
        : `${suiPath} move build --path ${RUNNER_CRATE_PATH} --skip-fetch-latest-git-deps`;

    try {
      const { stdout, stderr } = await execAsync(command, {
        cwd: RUNNER_CRATE_PATH,
        env,
        timeout: 30000, // 30 second timeout
      });

      const duration = Date.now() - startTime;
      const combinedOutput = stdout || stderr || "Compilation successful!";
      
      // Filter out [note] messages - they're informational, not errors
      const filteredOutput = combinedOutput
        .split('\n')
        .filter(line => !line.trim().startsWith('[note]'))
        .join('\n')
        .trim();

      // Success case
      return NextResponse.json({
        success: true,
        output: filteredOutput || "Compilation successful!",
        errors: [],
        duration,
      });
    } catch (error) {
      // Compilation failed
      const duration = Date.now() - startTime;
      const err = error as { stderr?: string; stdout?: string; message: string };
      
      // Combine stdout and stderr (test failures are in stdout, notes in stderr)
      const stderr = err.stderr || "";
      const stdout = err.stdout || "";
      const combined = stdout + "\n" + stderr;
      const errorOutput = combined.trim() || err.message;
      
      // Filter out [note] messages from errors
      const filteredErrors = errorOutput
        .split('\n')
        .filter(line => !line.trim().startsWith('[note]'))
        .join('\n')
        .trim();

      return NextResponse.json({
        success: false,
        output: "",
        errors: filteredErrors ? [filteredErrors] : ["Compilation failed. Please check your code."],
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

