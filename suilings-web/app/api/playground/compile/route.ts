import { NextRequest, NextResponse } from "next/server";

/**
 * POST /api/playground/compile
 * 
 * Compiles and tests Move code from the playground
 */
export async function POST(request: NextRequest) {
  try {
    const { code } = await request.json();
    
    if (!code || typeof code !== 'string') {
      return NextResponse.json(
        { error: "No code provided" },
        { status: 400 }
      );
    }

    // Validate code length (prevent abuse)
    if (code.length > 100000) { // 100KB limit
      return NextResponse.json(
        { error: "Code too large. Maximum size is 100KB" },
        { status: 400 }
      );
    }

    const compilationBackendUrl = process.env.COMPILATION_BACKEND_URL;
    
    if (!compilationBackendUrl) {
      console.error("COMPILATION_BACKEND_URL not configured");
      return NextResponse.json(
        { error: "Compilation service not configured" },
        { status: 500 }
      );
    }

    // Use existing compilation service
    const compileResponse = await fetch(
      `${compilationBackendUrl}/api/compile`,
      {
        method: "POST",
        headers: { 
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          code,
          mode: "test", // Run tests by default
        }),
        signal: AbortSignal.timeout(45000), // 45s timeout
      }
    );

    if (!compileResponse.ok) {
      const errorText = await compileResponse.text();
      console.error("Compilation service error:", errorText);
      return NextResponse.json(
        { 
          success: false,
          output: "",
          error: "Compilation service unavailable",
        },
        { status: 503 }
      );
    }

    const result = await compileResponse.json();

    return NextResponse.json({
      success: result.success || false,
      output: result.output || (result.errors && result.errors.length > 0 ? result.errors.join("\n") : ""),
      error: result.errors && result.errors.length > 0 ? result.errors.join("\n") : null,
      compiledAt: new Date().toISOString(),
    });

  } catch (error) {
    console.error("Playground compilation error:", error);
    return NextResponse.json(
      { 
        error: "Compilation failed",
        message: error instanceof Error ? error.message : "Unknown error"
      },
      { status: 500 }
    );
  }
}
