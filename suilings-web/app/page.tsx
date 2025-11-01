import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { ThemeToggle } from "@/components/theme-toggle";
import { Rocket, Zap, Target, BookOpen, Code, Trophy } from "lucide-react";

export default function HomePage() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-background to-muted/20">
      {/* Header */}
      <header className="container mx-auto px-4 py-6">
        <nav className="flex items-center justify-between">
          <div className="text-2xl font-bold bg-gradient-to-r from-indigo-500 to-purple-500 bg-clip-text text-transparent">
            Suilings
          </div>
          <div className="flex items-center gap-3">
            <Link href="/dashboard">
              <Button variant="ghost">Dashboard</Button>
            </Link>
            <Link href="/leaderboard">
              <Button variant="ghost">Leaderboard</Button>
            </Link>
            <ThemeToggle />
            <Link href="/exercise">
              <Button>Get Started</Button>
            </Link>
          </div>
        </nav>
      </header>

      {/* Hero Section */}
      <section className="container mx-auto px-4 py-20 text-center">
        <div className="max-w-3xl mx-auto space-y-6">
          <div className="inline-block">
            <span className="px-4 py-1.5 text-sm font-medium bg-primary/10 text-primary rounded-full border border-primary/20">
              Learn Move on Sui
            </span>
          </div>
          
          <h1 className="text-5xl md:text-6xl font-bold tracking-tight">
            Master Smart Contract Development
            <span className="block mt-2 bg-gradient-to-r from-indigo-500 to-purple-500 bg-clip-text text-transparent">
              In Your Browser
            </span>
          </h1>
          
          <p className="text-xl text-muted-foreground max-w-2xl mx-auto">
            Learn Move programming for the Sui blockchain with interactive exercises.
            No installation required. Start coding in seconds.
          </p>
          
          <div className="flex items-center justify-center gap-4 pt-4">
            <Link href="/exercise">
              <Button size="lg" className="gap-2">
                <Rocket className="h-5 w-5" />
                Start Learning
              </Button>
            </Link>
            <Link href="/dashboard">
              <Button size="lg" variant="outline" className="gap-2">
                <Target className="h-5 w-5" />
                View Dashboard
              </Button>
            </Link>
          </div>
        </div>

        {/* Code Preview */}
        <div className="max-w-3xl mx-auto mt-16">
          <Card className="border-2">
            <CardContent className="p-6">
              <pre className="text-left text-sm">
                <code className="language-move">
{`module suilings::hello_world {
    public fun say_hello(): vector<u8> {
        b"Hello, Sui!"
    }
}`}
                </code>
              </pre>
            </CardContent>
          </Card>
        </div>
      </section>

      {/* Features Section */}
      <section className="container mx-auto px-4 py-20">
        <div className="text-center mb-12">
          <h2 className="text-3xl font-bold mb-4">Why Suilings?</h2>
          <p className="text-muted-foreground">Everything you need to master Move development</p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6 max-w-6xl mx-auto">
          <Card>
            <CardHeader>
              <Zap className="h-10 w-10 text-primary mb-2" />
              <CardTitle>No Setup Required</CardTitle>
              <CardDescription>
                Start coding immediately. No need to install Rust, Sui CLI, or any local tooling.
              </CardDescription>
            </CardHeader>
          </Card>

          <Card>
            <CardHeader>
              <Target className="h-10 w-10 text-primary mb-2" />
              <CardTitle>Instant Feedback</CardTitle>
              <CardDescription>
                Get real-time compilation results and test feedback as you code.
              </CardDescription>
            </CardHeader>
          </Card>

          <Card>
            <CardHeader>
              <BookOpen className="h-10 w-10 text-primary mb-2" />
              <CardTitle>Guided Learning</CardTitle>
              <CardDescription>
                Follow a structured curriculum with clear instructions and helpful hints.
              </CardDescription>
            </CardHeader>
          </Card>

          <Card>
            <CardHeader>
              <Code className="h-10 w-10 text-primary mb-2" />
              <CardTitle>Interactive Editor</CardTitle>
              <CardDescription>
                Professional code editor with Move syntax highlighting and auto-completion.
              </CardDescription>
            </CardHeader>
          </Card>

          <Card>
            <CardHeader>
              <Trophy className="h-10 w-10 text-primary mb-2" />
              <CardTitle>Track Progress</CardTitle>
              <CardDescription>
                Monitor your learning journey and celebrate your achievements.
              </CardDescription>
            </CardHeader>
          </Card>

          <Card>
            <CardHeader>
              <Rocket className="h-10 w-10 text-primary mb-2" />
              <CardTitle>Build Real Skills</CardTitle>
              <CardDescription>
                Work with real Move code and learn practical smart contract development.
              </CardDescription>
            </CardHeader>
          </Card>
        </div>
      </section>

      {/* CTA Section */}
      <section className="container mx-auto px-4 py-20">
        <Card className="max-w-4xl mx-auto bg-gradient-to-r from-indigo-500/10 to-purple-500/10 border-primary/20">
          <CardContent className="text-center p-12">
            <h2 className="text-3xl font-bold mb-4">Ready to Start Your Journey?</h2>
            <p className="text-lg text-muted-foreground mb-8">
              Join developers learning Move on Sui through hands-on exercises
            </p>
            <Link href="/exercise">
              <Button size="lg" className="gap-2">
                <Rocket className="h-5 w-5" />
                Begin Learning Now
              </Button>
            </Link>
          </CardContent>
        </Card>
      </section>

      {/* Footer */}
      <footer className="border-t border-border mt-20">
        <div className="container mx-auto px-4 py-8">
          <div className="text-center text-sm text-muted-foreground">
            <p>Suilings © 2025 • Learn Move on Sui</p>
            <div className="flex items-center justify-center gap-6 mt-4">
              <a href="https://github.com" className="hover:text-foreground transition-colors">
                GitHub
              </a>
              <a href="#" className="hover:text-foreground transition-colors">
                Discord
              </a>
              <a href="#" className="hover:text-foreground transition-colors">
                Docs
              </a>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
