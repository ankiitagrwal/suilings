import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { SimpleHeader } from "@/components/layout/SimpleHeader";
import { TOTAL_EXERCISES } from "@/lib/exerciseConfig";
import { 
  Rocket, 
  Zap, 
  Target, 
  BookOpen, 
  Code, 
  Trophy,
  CheckCircle2,
  ArrowRight,
  Sparkles,
  Award,
  Globe,
  BookMarked
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
            <span className="text-sm font-medium">Practice Exercises from the Move Book</span>
            <Badge variant="secondary" className="text-xs">FREE</Badge>
          </div>
          
          {/* Main Headline */}
          <h1 className="text-4xl sm:text-5xl md:text-7xl font-bold tracking-tight leading-tight animate-in fade-in slide-in-from-top-6 duration-700 delay-100">
            Practice Move Programming
            <span className="block mt-2 bg-linear-to-r from-indigo-500 via-purple-500 to-pink-500 bg-clip-text text-transparent">
              From the Move Book
            </span>
          </h1>
          
          {/* Subheadline */}
          <p className="text-lg md:text-xl text-muted-foreground max-w-3xl mx-auto leading-relaxed animate-in fade-in slide-in-from-top-8 duration-700 delay-200">
            Interactive exercises based on the Move Book. Learn the concepts, then practice them here. 
            <span className="block mt-2 font-semibold text-foreground">Read the Move Book → Practice with Suilings → Master Move</span>
          </p>
          
          {/* CTA Buttons */}
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4 pt-4 animate-in fade-in slide-in-from-top-10 duration-700 delay-300">
            <Link href="https://move-book.com" target="_blank" rel="noopener noreferrer" className="w-full sm:w-auto">
              <Button size="lg" variant="default" className="gap-2 w-full sm:w-auto shadow-lg shadow-indigo-500/20 hover:shadow-xl hover:shadow-indigo-500/30 transition-all bg-indigo-600 hover:bg-indigo-700">
                <BookOpen className="h-5 w-5" />
                Read the Move Book First
                <ArrowRight className="h-5 w-5" />
              </Button>
            </Link>
            <Link href="/exercise" className="w-full sm:w-auto">
              <Button size="lg" variant="outline" className="gap-2 w-full sm:w-auto border-2">
                <Rocket className="h-5 w-5" />
                Start Practicing
              </Button>
            </Link>
          </div>
          
          {/* Trust Indicators */}
          <div className="flex flex-wrap items-center justify-center gap-6 text-sm text-muted-foreground pt-4 animate-in fade-in duration-700 delay-500">
            <div className="flex items-center gap-2">
              <CheckCircle2 className="h-4 w-4 text-green-500" />
              <span>Based on Move Book</span>
            </div>
            <div className="flex items-center gap-2">
              <CheckCircle2 className="h-4 w-4 text-green-500" />
              <span>{TOTAL_EXERCISES} Practice Exercises</span>
            </div>
            <div className="flex items-center gap-2">
              <CheckCircle2 className="h-4 w-4 text-green-500" />
              <span>100% Free</span>
            </div>
            <div className="flex items-center gap-2">
              <CheckCircle2 className="h-4 w-4 text-green-500" />
              <span>No Setup Required</span>
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
                <span className="text-sm text-muted-foreground ml-4">coin_balance.move</span>
              </div>
            </CardHeader>
            <CardContent className="p-6">
              <pre className="text-left text-sm md:text-base leading-relaxed">
                <code className="language-move">
{`module suilings::coin_balance;

use sui::coin::{Self, Coin};
use sui::sui::SUI;

/// Returns the balance of a SUI coin
public fun get_balance(coin: &Coin<SUI>): u64 {
    coin.value()
}

#[test]
fun test_balance() {
    let coin = coin::mint_for_testing<SUI>(1000);
    assert!(get_balance(&coin) == 1000);
    coin::burn_for_testing(coin);
}`}
                </code>
              </pre>
            </CardContent>
          </Card>
        </div>
      </section>

      {/* Move Book Connection Section - NEW */}
      <section className="container mx-auto px-4 py-16 bg-linear-to-br from-indigo-500/10 to-purple-500/10">
        <div className="max-w-5xl mx-auto">
          <Card className="border-2 border-indigo-500/30 shadow-2xl">
            <CardContent className="p-12">
              <div className="text-center space-y-6">
                <div className="flex items-center justify-center gap-4">
                  <BookOpen className="h-16 w-16 text-indigo-600" />
                  <div className="text-4xl font-bold text-muted-foreground">+</div>
                  <Code className="h-16 w-16 text-purple-600" />
                </div>
                <h3 className="text-3xl font-bold">
                  Suilings ❤️ Move Book
                </h3>
                <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
                  Every exercise on Suilings is designed to complement the Move Book. We link directly to the relevant chapters, 
                  so you can learn the theory and practice immediately. No separate content, no deviation—just pure practice.
                </p>
                <div className="flex flex-col sm:flex-row items-center justify-center gap-4 pt-4">
                  <a href="https://move-book.com" target="_blank" rel="noopener noreferrer">
                    <Button size="lg" className="gap-2 bg-indigo-600 hover:bg-indigo-700">
                      <BookOpen className="h-5 w-5" />
                      Visit Move Book
                    </Button>
                  </a>
                  <a href="https://docs.sui.io" target="_blank" rel="noopener noreferrer">
                    <Button size="lg" variant="outline" className="gap-2 border-2">
                      <BookOpen className="h-5 w-5" />
                      Sui Documentation
                    </Button>
                  </a>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </section>

      {/* Real Value Props Section */}
      <section className="container mx-auto px-4 py-16">
        <div className="max-w-5xl mx-auto">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
            <Card className="text-center p-6 border-2 hover:border-primary/50 transition-colors">
              <div className="flex justify-center mb-3">
                <BookOpen className="h-8 w-8 text-primary" />
              </div>
              <div className="text-3xl md:text-4xl font-bold mb-1">{TOTAL_EXERCISES}</div>
              <div className="text-sm text-muted-foreground">Practice Exercises</div>
            </Card>
            
            <Card className="text-center p-6 border-2 hover:border-primary/50 transition-colors">
              <div className="flex justify-center mb-3">
                <CheckCircle2 className="h-8 w-8 text-primary" />
              </div>
              <div className="text-3xl md:text-4xl font-bold mb-1">100%</div>
              <div className="text-sm text-muted-foreground">Free Forever</div>
            </Card>
            
            <Card className="text-center p-6 border-2 hover:border-primary/50 transition-colors">
              <div className="flex justify-center mb-3">
                <Zap className="h-8 w-8 text-primary" />
              </div>
              <div className="text-3xl md:text-4xl font-bold mb-1">0</div>
              <div className="text-sm text-muted-foreground">Setup Required</div>
            </Card>
            
            <Card className="text-center p-6 border-2 hover:border-primary/50 transition-colors">
              <div className="flex justify-center mb-3">
                <BookMarked className="h-8 w-8 text-primary" />
              </div>
              <div className="text-3xl md:text-4xl font-bold mb-1">Move</div>
              <div className="text-sm text-muted-foreground">Book Aligned</div>
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
                Pick from {TOTAL_EXERCISES} curated exercises covering basics to advanced Move concepts
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
                  <CardTitle className="text-lg mb-2">Move Book Aligned</CardTitle>
                  <CardDescription>
                    Every exercise links to the Move Book chapter—learn theory, practice immediately
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
              Master Move programming through hands-on practice. Start coding in under 60 seconds.
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
                <span>100% Free Forever</span>
              </div>
              <div className="flex items-center gap-2">
                <CheckCircle2 className="h-4 w-4 text-green-500" />
                <span>{TOTAL_EXERCISES} Exercises</span>
              </div>
              <div className="flex items-center gap-2">
                <CheckCircle2 className="h-4 w-4 text-green-500" />
                <span>No Setup Required</span>
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
              <p>Suilings © 2025 • Practice companion to the Move Book</p>
              <p className="mt-1 text-xs">All exercises based on <a href="https://move-book.com" target="_blank" rel="noopener noreferrer" className="text-indigo-600 hover:underline">move-book.com</a></p>
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
              <Link href="/feedback" className="text-sm text-muted-foreground hover:text-foreground transition-colors">
                Feedback
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
