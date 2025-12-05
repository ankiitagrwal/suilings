import { NextResponse } from 'next/server';
import { createClient } from '@/lib/supabase/server';

export async function POST(request: Request) {
  try {
    const { name, email, type, message } = await request.json();

    // Validate required field
    const trimmedMessage = message?.trim();
    if (!trimmedMessage) {
      return NextResponse.json(
        { error: 'Message is required' },
        { status: 400 }
      );
    }

    // Insert feedback into database
    const supabase = await createClient();
    const { error } = await supabase
      .from('feedback')
      .insert({
        name: name?.trim() || null,
        email: email?.trim() || null,
        type: type || 'General Feedback',
        message: trimmedMessage,
      });

    if (error) {
      console.error('Database error:', error);
      return NextResponse.json(
        { error: 'Failed to save feedback' },
        { status: 500 }
      );
    }

    return NextResponse.json({ 
      success: true,
      message: 'Thank you for your feedback!' 
    });

  } catch (error) {
    console.error('Feedback submission error:', error);
    return NextResponse.json(
      { error: 'Failed to submit feedback' },
      { status: 500 }
    );
  }
}
