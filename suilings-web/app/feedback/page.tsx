"use client";

import { useState, useCallback } from "react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { SimpleHeader } from "@/components/layout/SimpleHeader";
import { Footer } from "@/components/layout/Footer";
import { MessageSquare, Bug, Lightbulb, Heart, Send, CheckCircle2 } from "lucide-react";
import { toast } from "sonner";

const FEEDBACK_TYPES = [
  { label: "General Feedback", icon: MessageSquare, color: "bg-blue-500", description: "Share your thoughts" },
  { label: "Report a Bug", icon: Bug, color: "bg-red-500", description: "Help us fix issues" },
  { label: "Feature Request", icon: Lightbulb, color: "bg-yellow-500", description: "Suggest features" },
  { label: "Show Some Love", icon: Heart, color: "bg-pink-500", description: "Share what you love" },
] as const;

const INITIAL_FORM_STATE = {
  name: "",
  email: "",
  type: "General Feedback",
  message: "",
};

export default function FeedbackPage() {
  const [formData, setFormData] = useState(INITIAL_FORM_STATE);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSubmitted, setIsSubmitted] = useState(false);

  const handleSubmit = useCallback(async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!formData.message.trim()) {
      toast.error("Please enter your feedback message");
      return;
    }

    setIsSubmitting(true);

    try {
      const response = await fetch("/api/feedback", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(formData),
      });

      const data = await response.json();

      if (response.ok) {
        setIsSubmitted(true);
        toast.success("Thank you! Your feedback has been submitted.");
        setTimeout(() => {
          setFormData(INITIAL_FORM_STATE);
          setIsSubmitted(false);
        }, 2000);
      } else {
        toast.error(data.error || "Failed to submit. Please try again.");
      }
    } catch (error) {
      console.error("Submission error:", error);
      toast.error("Something went wrong. Please email us directly.");
    } finally {
      setIsSubmitting(false);
    }
  }, [formData]);

  const updateField = useCallback((field: keyof typeof formData) => 
    (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
      setFormData(prev => ({ ...prev, [field]: e.target.value }));
    }, 
  []);

  if (isSubmitted) {
    return (
      <div className="min-h-screen bg-background">
        <SimpleHeader />
        <div className="container mx-auto px-4 py-12 md:py-16">
          <div className="max-w-2xl mx-auto text-center">
            <Card className="border-2 border-green-500/20 bg-green-500/5">
              <CardContent className="py-16">
                <div className="w-20 h-20 bg-green-500 rounded-full flex items-center justify-center mx-auto mb-6">
                  <CheckCircle2 className="h-12 w-12 text-white" />
                </div>
                <h2 className="text-3xl font-bold mb-4">Thank You!</h2>
                <p className="text-lg text-muted-foreground mb-6">
                  Your feedback has been submitted successfully. We really appreciate you taking the time!
                </p>
                <p className="text-sm text-muted-foreground">Returning to form...</p>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      <SimpleHeader />
      
      <div className="container mx-auto px-4 py-12 md:py-16">
        <div className="max-w-4xl mx-auto">
          <div className="text-center mb-12">
            <Badge className="mb-4">We&apos;re Listening</Badge>
            <h1 className="text-4xl md:text-5xl font-bold mb-4">Share Your Feedback</h1>
            <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
              Your feedback helps us make Suilings better. Found a bug? Have an idea? We&apos;d love to hear from you!
            </p>
          </div>

          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
            {FEEDBACK_TYPES.map(({ label, icon: Icon, color, description }) => (
              <Card 
                key={label} 
                className={`p-4 text-center border-2 transition-all cursor-pointer ${
                  formData.type === label ? "border-primary shadow-md scale-105" : "hover:border-primary/50"
                }`}
                onClick={() => setFormData(prev => ({ ...prev, type: label }))}
              >
                <div className={`w-12 h-12 ${color} rounded-lg flex items-center justify-center mx-auto mb-3`}>
                  <Icon className="h-6 w-6 text-white" />
                </div>
                <div className="text-sm font-semibold mb-1">{label}</div>
                <div className="text-xs text-muted-foreground">{description}</div>
              </Card>
            ))}
          </div>

          <Card className="border-2 border-primary/20">
            <CardHeader>
              <CardTitle>Submit Your Feedback</CardTitle>
              <CardDescription>Fill out the form below and we&apos;ll get back to you</CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleSubmit} className="space-y-6">
                <div className="grid md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="name">Name (optional)</Label>
                    <Input id="name" placeholder="Your name" value={formData.name} onChange={updateField("name")} />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="email">Email (optional)</Label>
                    <Input id="email" type="email" placeholder="your@email.com" value={formData.email} onChange={updateField("email")} />
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="type">Feedback Type</Label>
                  <select
                    id="type"
                    value={formData.type}
                    onChange={updateField("type")}
                    className="w-full px-3 py-2 bg-background border border-input rounded-md focus:outline-none focus:ring-2 focus:ring-ring"
                  >
                    {FEEDBACK_TYPES.map(({ label }) => (
                      <option key={label} value={label}>{label}</option>
                    ))}
                  </select>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="message">Message *</Label>
                  <Textarea
                    id="message"
                    placeholder="Tell us your thoughts..."
                    rows={6}
                    value={formData.message}
                    onChange={updateField("message")}
                    required
                    className="resize-none"
                    maxLength={1000}
                  />
                  <p className="text-xs text-muted-foreground">{formData.message.length} / 1000 characters</p>
                </div>

                <Button type="submit" size="lg" className="w-full gap-2" disabled={isSubmitting}>
                  {isSubmitting ? (
                    <>
                      <span className="animate-spin">⏳</span>
                      Submitting...
                    </>
                  ) : (
                    <>
                      <Send className="h-5 w-5" />
                      Submit Feedback
                    </>
                  )}
                </Button>
              </form>
            </CardContent>
          </Card>

          <div className="mt-12">
            <h3 className="text-xl font-semibold text-center mb-6">Other Ways to Connect</h3>
            <div className="grid md:grid-cols-2 gap-4 max-w-2xl mx-auto">
              <Card className="p-6 text-center border-2 hover:border-primary/50 transition-colors">
                <div className="text-3xl mb-2">🐦</div>
                <h4 className="font-semibold mb-2">Twitter/X</h4>
                <p className="text-sm text-muted-foreground mb-4">Follow us for updates</p>
                <a href="https://x.com/suiilings" target="_blank" rel="noopener noreferrer">
                  <Button variant="outline" className="w-full">Follow on X</Button>
                </a>
              </Card>

              <Card className="p-6 text-center border-2 hover:border-primary/50 transition-colors">
                <div className="text-3xl mb-2">📧</div>
                <h4 className="font-semibold mb-2">Email Us</h4>
                <p className="text-sm text-muted-foreground mb-4">Send us an email</p>
                <a href="mailto:suilings0411@gmail.com">
                  <Button variant="outline" className="w-full">Send Email</Button>
                </a>
              </Card>
            </div>
          </div>
        </div>
      </div>

      <Footer />
    </div>
  );
}
