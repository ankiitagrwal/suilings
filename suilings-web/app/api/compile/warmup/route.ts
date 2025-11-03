import { NextResponse } from 'next/server';

// Warmup endpoint to pre-warm the compilation service
export async function GET() {
  const backendUrl = process.env.COMPILATION_BACKEND_URL;
  
  // In development (no backend URL), compilation is local - no warmup needed
  if (!backendUrl) {
    return NextResponse.json({ 
      status: 'local', 
      message: 'Local development mode - warmup not needed' 
    });
  }
  
  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 10000); // 10s timeout
    
    const response = await fetch(`${backendUrl}/api/ping`, {
      method: 'GET',
      headers: {
        'Connection': 'keep-alive',
      },
      signal: controller.signal,
      next: { revalidate: 0 }, // Don't cache
    });
    
    clearTimeout(timeoutId);
    
    if (response.ok) {
      const data = await response.json();
      return NextResponse.json({
        status: 'warm',
        duration: data.duration,
        mode: 'production',
      });
    }
    
    return NextResponse.json({ status: 'cold', mode: 'production' });
  } catch (error) {
    return NextResponse.json({ 
      status: 'error', 
      error: (error as Error).message,
      mode: 'production',
    });
  }
}

