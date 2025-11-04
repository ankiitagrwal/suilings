import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { SimpleHeader } from "@/components/layout/SimpleHeader";
import { 
  Rocket, 
  Zap, 
  Target, 
  BookOpen, 
  Code, 
  Trophy,
  Users,
  CheckCircle2,
  ArrowRight,
  Sparkles,
  TrendingUp,
  Clock,
  Award,
  Globe
} from "lucide-react";

export default function HomePage() {
  return (
    <div className="min-h-screen bg-linear-to-b from-background via-background to-muted/30">
      <SimpleHeader />

      {/* Hero Section */}
      <section className="relative container mx-auto px-4 py-16 md:py-24">
        <div className="absolute inset-0 -z-10 h-full w-full bg-[radial-gradient(circle_at_center,var(--tw-gradient-stops))] from-primary/5 via-transparent to-transparent"></div>
        
        <div className="max-w-5xl mx-auto text-center space-y-8">
          {/* Badge */}
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full border bg-card/50 backdrop-blur-sm animate-in fade-in slide-in-from-top-4 duration-700">
            <Sparkles className="h-4 w-4 text-primary" />
            <span className="text-sm font-medium">The Interactive Way to Learn Move on Sui</span>
            <Badge variant="secondary" className="text-xs">FREE</Badge>
          </div>
          
          {/* Main Headline */}
          <h1 className="text-4xl sm:text-5xl md:text-7xl font-bold tracking-tight leading-tight animate-in fade-in slide-in-from-top-6 duration-700 delay-100">
            Master Sui Blockchain
            <span className="block mt-2 bg-linear-to-r from-indigo-500 via-purple-500 to-pink-500 bg-clip-text text-transparent">
              Development in Hours
            </span>
            <span className="block mt-2">Not Months</span>
          </h1>
          
          {/* Subheadline */}
          <p className="text-lg md:text-xl text-muted-foreground max-w-3xl mx-auto leading-relaxed animate-in fade-in slide-in-from-top-8 duration-700 delay-200">
            The fastest way to learn Move programming. Build, compile, and deploy smart contracts directly in your browser. 
            <span className="block mt-2 font-semibold text-foreground">Zero setup. Real skills. Instant results.</span>
          </p>
          
          {/* CTA Buttons */}
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4 pt-4 animate-in fade-in slide-in-from-top-10 duration-700 delay-300">
            <Link href="/exercise" className="w-full sm:w-auto">
              <Button size="lg" className="gap-2 w-full sm:w-auto shadow-lg shadow-primary/20 hover:shadow-xl hover:shadow-primary/30 transition-all">
                <Rocket className="h-5 w-5" />
                Start Learning Free
                <ArrowRight className="h-5 w-5" />
              </Button>
            </Link>
            <Link href="/leaderboard" className="w-full sm:w-auto">
              <Button size="lg" variant="outline" className="gap-2 w-full sm:w-auto border-2">
                <Trophy className="h-5 w-5" />
                View Leaderboard
              </Button>
            </Link>
          </div>
          
          {/* Trust Indicators */}
          <div className="flex flex-wrap items-center justify-center gap-6 text-sm text-muted-foreground pt-4 animate-in fade-in duration-700 delay-500">
            <div className="flex items-center gap-2">
              <CheckCircle2 className="h-4 w-4 text-green-500" />
              <span>100% Free</span>
            </div>
            <div className="flex items-center gap-2">
              <CheckCircle2 className="h-4 w-4 text-green-500" />
              <span>27 Interactive Exercises</span>
            </div>
            <div className="flex items-center gap-2">
              <CheckCircle2 className="h-4 w-4 text-green-500" />
              <span>No Setup Required</span>
            </div>
            <div className="flex items-center gap-2">
              <CheckCircle2 className="h-4 w-4 text-green-500" />
              <span>Instant Access</span>
            </div>
          </div>
        </div>

        {/* Code Preview with Glassmorphism */}
        <div className="max-w-4xl mx-auto mt-16 animate-in fade-in slide-in-from-bottom-10 duration-1000 delay-500">
          <Card className="border-2 border-primary/20 bg-card/50 backdrop-blur-xl shadow-2xl">
            <CardHeader className="border-b bg-muted/30">
              <div className="flex items-center gap-2">
                <div className="flex gap-1.5">
                  <div className="w-3 h-3 rounded-full bg-red-500"></div>
                  <div className="w-3 h-3 rounded-full bg-yellow-500"></div>
                  <div className="w-3 h-3 rounded-full bg-green-500"></div>
                </div>
                <span className="text-sm text-muted-foreground ml-4">hello_world.move</span>
              </div>
            </CardHeader>
            <CardContent className="p-6">
              <pre className="text-left text-sm md:text-base leading-relaxed">
                <code className="language-move">
{`module suilings::hello_world {
    use std::string::{Self, String};

    public fun say_hello(): String {
        string::utf8(b"Hello, Sui!")
    }

    #[test]
    public fun test_hello() {
        assert!(say_hello() == string::utf8(b"Hello, Sui!"), 0);
    }
}`}
                </code>
              </pre>
            </CardContent>
          </Card>
        </div>
      </section>

      {/* Stats Section */}
      <section className="container mx-auto px-4 py-16">
        <div className="max-w-5xl mx-auto">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
            <Card className="text-center p-6 border-2 hover:border-primary/50 transition-colors">
              <div className="flex justify-center mb-3">
                <Users className="h-8 w-8 text-primary" />
              </div>
              <div className="text-3xl md:text-4xl font-bold mb-1">500+</div>
              <div className="text-sm text-muted-foreground">Active Learners</div>
            </Card>
            
            <Card className="text-center p-6 border-2 hover:border-primary/50 transition-colors">
              <div className="flex justify-center mb-3">
                <BookOpen className="h-8 w-8 text-primary" />
              </div>
              <div className="text-3xl md:text-4xl font-bold mb-1">27</div>
              <div className="text-sm text-muted-foreground">Exercises</div>
            </Card>
            
            <Card className="text-center p-6 border-2 hover:border-primary/50 transition-colors">
              <div className="flex justify-center mb-3">
                <TrendingUp className="h-8 w-8 text-primary" />
              </div>
              <div className="text-3xl md:text-4xl font-bold mb-1">92%</div>
              <div className="text-sm text-muted-foreground">Success Rate</div>
            </Card>
            
            <Card className="text-center p-6 border-2 hover:border-primary/50 transition-colors">
              <div className="flex justify-center mb-3">
                <Clock className="h-8 w-8 text-primary" />
              </div>
              <div className="text-3xl md:text-4xl font-bold mb-1">2hrs</div>
              <div className="text-sm text-muted-foreground">Avg. Completion</div>
            </Card>
          </div>
        </div>
      </section>

      {/* How It Works */}
      <section className="container mx-auto px-4 py-20">
        <div className="max-w-5xl mx-auto">
          <div className="text-center mb-16">
            <Badge className="mb-4">Simple Process</Badge>
            <h2 className="text-3xl md:text-4xl font-bold mb-4">Start Learning in 3 Steps</h2>
            <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
              No complicated setup. No local environment. Just open your browser and start coding.
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            <Card className="relative p-8 text-center border-2 hover:border-primary/50 hover:shadow-lg transition-all">
              <div className="absolute -top-4 left-1/2 -translate-x-1/2">
                <div className="bg-primary text-primary-foreground w-8 h-8 rounded-full flex items-center justify-center font-bold">1</div>
              </div>
              <Rocket className="h-12 w-12 text-primary mx-auto mb-4 mt-4" />
              <CardTitle className="mb-3">Choose Exercise</CardTitle>
              <CardDescription className="text-base">
                Pick from 27 curated exercises covering basics to advanced Move concepts
              </CardDescription>
            </Card>

            <Card className="relative p-8 text-center border-2 hover:border-primary/50 hover:shadow-lg transition-all">
              <div className="absolute -top-4 left-1/2 -translate-x-1/2">
                <div className="bg-primary text-primary-foreground w-8 h-8 rounded-full flex items-center justify-center font-bold">2</div>
              </div>
              <Code className="h-12 w-12 text-primary mx-auto mb-4 mt-4" />
              <CardTitle className="mb-3">Write Code</CardTitle>
              <CardDescription className="text-base">
                Code directly in your browser with syntax highlighting and real-time validation
              </CardDescription>
            </Card>

            <Card className="relative p-8 text-center border-2 hover:border-primary/50 hover:shadow-lg transition-all">
              <div className="absolute -top-4 left-1/2 -translate-x-1/2">
                <div className="bg-primary text-primary-foreground w-8 h-8 rounded-full flex items-center justify-center font-bold">3</div>
              </div>
              <Award className="h-12 w-12 text-primary mx-auto mb-4 mt-4" />
              <CardTitle className="mb-3">Get Results</CardTitle>
              <CardDescription className="text-base">
                Instant compilation feedback and track your progress on the leaderboard
              </CardDescription>
            </Card>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="container mx-auto px-4 py-20 bg-muted/20">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-16">
            <Badge className="mb-4">Platform Features</Badge>
            <h2 className="text-3xl md:text-4xl font-bold mb-4">Everything You Need to Succeed</h2>
            <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
              A complete learning platform designed for aspiring blockchain developers
            </p>
          </div>

          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            <Card className="p-6 hover:shadow-lg transition-shadow border-2">
              <div className="flex items-start gap-4">
                <div className="p-3 bg-primary/10 rounded-lg">
                  <Zap className="h-6 w-6 text-primary" />
                </div>
                <div>
                  <CardTitle className="text-lg mb-2">Zero Setup</CardTitle>
                  <CardDescription>
                    No installation required. Start coding in seconds without any dependencies
                  </CardDescription>
                </div>
              </div>
            </Card>

            <Card className="p-6 hover:shadow-lg transition-shadow border-2">
              <div className="flex items-start gap-4">
                <div className="p-3 bg-primary/10 rounded-lg">
                  <Target className="h-6 w-6 text-primary" />
                </div>
                <div>
                  <CardTitle className="text-lg mb-2">Real-Time Feedback</CardTitle>
                  <CardDescription>
                    Instant compilation results and test validation as you code
                  </CardDescription>
                </div>
              </div>
            </Card>

            <Card className="p-6 hover:shadow-lg transition-shadow border-2">
              <div className="flex items-start gap-4">
                <div className="p-3 bg-primary/10 rounded-lg">
                  <BookOpen className="h-6 w-6 text-primary" />
                </div>
                <div>
                  <CardTitle className="text-lg mb-2">Structured Curriculum</CardTitle>
                  <CardDescription>
                    Follow a proven learning path from beginner to advanced
                  </CardDescription>
                </div>
              </div>
            </Card>

            <Card className="p-6 hover:shadow-lg transition-shadow border-2">
              <div className="flex items-start gap-4">
                <div className="p-3 bg-primary/10 rounded-lg">
                  <Code className="h-6 w-6 text-primary" />
                </div>
                <div>
                  <CardTitle className="text-lg mb-2">Professional IDE</CardTitle>
                  <CardDescription>
                    Monaco editor with Move syntax highlighting and auto-completion
                  </CardDescription>
                </div>
              </div>
            </Card>

            <Card className="p-6 hover:shadow-lg transition-shadow border-2">
              <div className="flex items-start gap-4">
                <div className="p-3 bg-primary/10 rounded-lg">
                  <Trophy className="h-6 w-6 text-primary" />
                </div>
                <div>
                  <CardTitle className="text-lg mb-2">Gamified Learning</CardTitle>
                  <CardDescription>
                    Track progress, earn achievements, and compete on leaderboards
                  </CardDescription>
                </div>
              </div>
            </Card>

            <Card className="p-6 hover:shadow-lg transition-shadow border-2">
              <div className="flex items-start gap-4">
                <div className="p-3 bg-primary/10 rounded-lg">
                  <Globe className="h-6 w-6 text-primary" />
                </div>
                <div>
                  <CardTitle className="text-lg mb-2">Community Driven</CardTitle>
                  <CardDescription>
                    Join a growing community of Sui developers worldwide
                  </CardDescription>
                </div>
              </div>
            </Card>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="relative container mx-auto px-4 py-20">
        <div className="absolute inset-0 -z-10 bg-linear-to-r from-indigo-500/10 via-purple-500/10 to-pink-500/10"></div>
        <Card className="max-w-5xl mx-auto bg-linear-to-br from-primary/10 via-background to-primary/5 border-2 border-primary/20 shadow-2xl">
          <CardContent className="p-12 md:p-16 text-center">
            <Badge className="mb-6" variant="secondary">
              <Sparkles className="h-3 w-3 mr-1" />
              Limited Time Offer
            </Badge>
            <h2 className="text-3xl md:text-5xl font-bold mb-6">
              Start Building on Sui
              <span className="block mt-2 bg-linear-to-r from-indigo-500 to-purple-500 bg-clip-text text-transparent">
                Today, For Free
              </span>
            </h2>
            <p className="text-lg md:text-xl text-muted-foreground mb-8 max-w-2xl mx-auto">
              Join hundreds of developers already learning Move on Sui. Start coding in under 60 seconds.
            </p>
            <div className="flex flex-col sm:flex-row items-center justify-center gap-4 mb-8">
              <Link href="/exercise" className="w-full sm:w-auto">
                <Button size="lg" className="gap-2 w-full sm:w-auto shadow-lg">
                  <Rocket className="h-5 w-5" />
                  Begin Your Journey
                  <ArrowRight className="h-5 w-5" />
                </Button>
              </Link>
              <Link href="/leaderboard" className="w-full sm:w-auto">
                <Button size="lg" variant="outline" className="gap-2 w-full sm:w-auto">
                  <Trophy className="h-5 w-5" />
                  See Who&apos;s Learning
                </Button>
              </Link>
            </div>
            <div className="flex flex-wrap items-center justify-center gap-6 text-sm text-muted-foreground">
              <div className="flex items-center gap-2">
                <CheckCircle2 className="h-4 w-4 text-green-500" />
                <span>Forever Free</span>
              </div>
              <div className="flex items-center gap-2">
                <CheckCircle2 className="h-4 w-4 text-green-500" />
                <span>500+ Active Users</span>
              </div>
              <div className="flex items-center gap-2">
                <CheckCircle2 className="h-4 w-4 text-green-500" />
                <span>92% Success Rate</span>
              </div>
            </div>
          </CardContent>
        </Card>
      </section>

      {/* Footer */}
      <footer className="border-t border-border mt-20">
        <div className="container mx-auto px-4 py-8">
          <div className="flex flex-col md:flex-row items-center justify-between gap-4">
            <div className="text-sm text-muted-foreground">
              <p>Suilings © 2025 • Learn Move on Sui</p>
            </div>
            <div className="flex items-center gap-6">
              <Link href="https://move-book.com/" target="_blank" rel="noopener noreferrer" className="text-sm text-muted-foreground hover:text-foreground transition-colors">
                Move Book
              </Link>
              <Link href="https://docs.sui.io" target="_blank" rel="noopener noreferrer" className="text-sm text-muted-foreground hover:text-foreground transition-colors">
                Sui Docs
              </Link>
              <Link href="https://github.com/MystenLabs/sui" target="_blank" rel="noopener noreferrer" className="text-sm text-muted-foreground hover:text-foreground transition-colors">
                Sui GitHub
              </Link>
              <Link href="/exercise" className="text-sm text-muted-foreground hover:text-foreground transition-colors">
                Start Learning
              </Link>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
