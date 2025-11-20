"use client";

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { SimpleHeader } from "@/components/layout/SimpleHeader";
import { 
  MessageSquare, 
  Bug, 
  Lightbulb,
  Heart,
  ExternalLink
} from "lucide-react";

// Fetch Google Form URL from environment variable
const GOOGLE_FORM_URL = process.env.NEXT_PUBLIC_GOOGLE_FORM_URL || "https://forms.gle/JtpbZjhPipNJAEU26";

export default function FeedbackPage() {
  const feedbackTypes = [
    { 
      label: "General Feedback", 
      icon: MessageSquare,
      color: "bg-blue-500",
      description: "Share your thoughts and suggestions"
    },
    { 
      label: "Report a Bug", 
      icon: Bug,
      color: "bg-red-500",
      description: "Help us fix issues you've found"
    },
    { 
      label: "Feature Request", 
      icon: Lightbulb,
      color: "bg-yellow-500",
      description: "Suggest new features"
    },
    { 
      label: "Show Some Love", 
      icon: Heart,
      color: "bg-pink-500",
      description: "Tell us what you love!"
    },
  ];

  return (
    <div className="min-h-screen bg-background">
      <SimpleHeader />
      
      <div className="container mx-auto px-4 py-12 md:py-16">
        <div className="max-w-4xl mx-auto">
          {/* Header */}
          <div className="text-center mb-12">
            <Badge className="mb-4">We&apos;re Listening</Badge>
            <h1 className="text-4xl md:text-5xl font-bold mb-4">
              Share Your Feedback
            </h1>
            <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
              Your feedback helps us make Suilings better for everyone. Found a bug? Have an idea? Just want to say hi? We&apos;d love to hear from you!
            </p>
          </div>

          {/* Feedback Types Grid */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
            {feedbackTypes.map(({ label, icon: Icon, color, description }) => (
              <Card key={label} className="p-4 text-center border-2 hover:border-primary/50 transition-colors">
                <div className={`w-12 h-12 ${color} rounded-lg flex items-center justify-center mx-auto mb-3`}>
                  <Icon className="h-6 w-6 text-white" />
                </div>
                <div className="text-sm font-semibold mb-1">{label}</div>
                <div className="text-xs text-muted-foreground">{description}</div>
              </Card>
            ))}
          </div>

          {/* Main CTA Card */}
          <Card className="border-2 border-primary/20 bg-linear-to-br from-primary/5 to-background">
            <CardHeader className="text-center pb-4">
              <CardTitle className="text-2xl">Ready to Share Your Thoughts?</CardTitle>
              <CardDescription className="text-base">
                Click the button below to open our feedback form. It only takes a minute!
              </CardDescription>
            </CardHeader>
            <CardContent className="text-center pb-8">
              <a 
                href={GOOGLE_FORM_URL} 
                target="_blank" 
                rel="noopener noreferrer"
                className="inline-block"
              >
                <Button size="lg" className="gap-2 text-lg px-8 py-6">
                  <MessageSquare className="h-6 w-6" />
                  Open Feedback Form
                  <ExternalLink className="h-5 w-5" />
                </Button>
              </a>
              <p className="text-sm text-muted-foreground mt-4">
                Opens in a new tab • Takes ~2 minutes
              </p>
            </CardContent>
          </Card>

          {/* Alternative Channels */}
          <div className="mt-12">
            <h3 className="text-xl font-semibold text-center mb-6">Other Ways to Connect</h3>
            <div className="grid md:grid-cols-2 gap-4 max-w-2xl mx-auto">
              <Card className="p-6 text-center border-2 hover:border-primary/50 transition-colors">
                <div className="text-3xl mb-2">🐦</div>
                <h4 className="font-semibold mb-2">Twitter/X</h4>
                <p className="text-sm text-muted-foreground mb-4">
                  Follow us for updates and announcements
                </p>
                <a 
                  href="https://x.com/suiilings" 
                  target="_blank" 
                  rel="noopener noreferrer"
                >
                  <Button variant="outline" className="w-full">
                    Follow on X
                  </Button>
                </a>
              </Card>

              <Card className="p-6 text-center border-2 hover:border-primary/50 transition-colors">
                <div className="text-3xl mb-2">📧</div>
                <h4 className="font-semibold mb-2">Email Us</h4>
                <p className="text-sm text-muted-foreground mb-4">
                  Have a question? Send us an email
                </p>
                <a 
                  href="mailto:suilings0411@gmail.com"
                >
                  <Button variant="outline" className="w-full">
                    Send Email
                  </Button>
                </a>
              </Card>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

