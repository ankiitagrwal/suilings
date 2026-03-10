"use client";

import { useEffect, useState } from "react";
import { useParams } from "next/navigation";
import { CredentialCard } from "@/components/credential/CredentialCard";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { AlertCircle, CheckCircle2, Loader2, Home } from "lucide-react";
import Link from "next/link";
import { SimpleHeader } from "@/components/layout/SimpleHeader";
import { Footer } from "@/components/layout/Footer";
import { VerifyCredentialResponse } from "@/types/credential";

/**
 * Public Verification Page
 *
 * Allows anyone to verify a credential by:
 * - GitHub username (@username)
 * - Wallet address (0x...)
 * - SBT Object ID (0x...)
 *
 * Example URLs:
 * - /verify/@johndoe
 * - /verify/0x1234...
 */
export default function VerifyCredentialPage() {
  const params = useParams();
  const identifier = params.identifier as string;

  const [loading, setLoading] = useState(true);
  const [data, setData] = useState<VerifyCredentialResponse | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchCredential = async () => {
      if (!identifier) return;

      setLoading(true);
      setError(null);

      try {
        const response = await fetch(
          `/api/credential/verify/${encodeURIComponent(identifier)}`
        );

        if (!response.ok) {
          const errorData = await response.json();
          throw new Error(errorData.message || "Failed to verify credential");
        }

        const result = await response.json();
        setData(result);
      } catch (err) {
        console.error("Verification error:", err);
        setError(
          err instanceof Error ? err.message : "Failed to verify credential"
        );
      } finally {
        setLoading(false);
      }
    };

    fetchCredential();
  }, [identifier]);

  if (loading) {
    return (
      <>
        <SimpleHeader />
        <div className="min-h-screen bg-background flex items-center justify-center p-4">
          <Card className="w-full max-w-md">
            <CardContent className="flex flex-col items-center justify-center py-12 space-y-4">
              <Loader2 className="h-12 w-12 animate-spin text-primary" />
              <p className="text-muted-foreground">Verifying credential...</p>
            </CardContent>
          </Card>
        </div>
        <Footer />
      </>
    );
  }

  if (error || !data?.verified) {
    return (
      <>
        <SimpleHeader />
        <div className="min-h-screen bg-background flex items-center justify-center p-4">
          <Card className="w-full max-w-md border-destructive/50">
            <CardHeader>
              <div className="flex items-center justify-center mb-4">
                <div className="rounded-full bg-destructive/10 p-3">
                  <AlertCircle className="h-8 w-8 text-destructive" />
                </div>
              </div>
              <CardTitle className="text-center">Credential Not Found</CardTitle>
              <CardDescription className="text-center">
                {error || "No credential found for this identifier"}
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="bg-muted/50 p-4 rounded-lg">
                <p className="text-sm text-muted-foreground mb-2">Searched for:</p>
                <code className="text-sm bg-background px-3 py-1.5 rounded block break-all">
                  {identifier}
                </code>
              </div>
              <Button asChild className="w-full">
                <Link href="/">
                  <Home className="mr-2 h-4 w-4" />
                  Go to Homepage
                </Link>
              </Button>
            </CardContent>
          </Card>
        </div>
        <Footer />
      </>
    );
  }

  return (
    <>
      <SimpleHeader />
      <div className="min-h-screen bg-background">
        <main className="container max-w-4xl mx-auto px-4 py-12">
          <div className="space-y-8">
            {/* Verification Badge */}
            <div className="flex flex-col items-center text-center space-y-4">
              <div className="rounded-full bg-green-500/10 p-4">
                <CheckCircle2 className="h-12 w-12 text-green-500" />
              </div>
              <div className="space-y-2">
                <h1 className="text-3xl font-bold">Credential Verified ✓</h1>
                <p className="text-muted-foreground max-w-2xl">
                  This credential has been verified on the Sui blockchain. The holder has
                  successfully completed all Suilings exercises and earned this achievement.
                </p>
              </div>
            </div>

            {/* Credential Card */}
            {data.credential && (
              <div className="max-w-2xl mx-auto">
                <CredentialCard credential={data.credential} showActions={true} />
              </div>
            )}

            {/* About This Credential */}
            <Card className="max-w-2xl mx-auto">
              <CardHeader>
                <CardTitle className="text-lg">About This Credential</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3 text-sm">
                <div className="flex items-start gap-2">
                  <CheckCircle2 className="h-4 w-4 text-green-500 mt-0.5 shrink-0" />
                  <div>
                    <p className="font-medium">Blockchain Verified</p>
                    <p className="text-muted-foreground">
                      This credential is permanently stored on the Sui blockchain and
                      cannot be altered or faked.
                    </p>
                  </div>
                </div>
                <div className="flex items-start gap-2">
                  <CheckCircle2 className="h-4 w-4 text-green-500 mt-0.5 shrink-0" />
                  <div>
                    <p className="font-medium">Soulbound Token (SBT)</p>
                    <p className="text-muted-foreground">
                      This credential is non-transferable and permanently linked to the
                      recipient&apos;s wallet.
                    </p>
                  </div>
                </div>
                <div className="flex items-start gap-2">
                  <CheckCircle2 className="h-4 w-4 text-green-500 mt-0.5 shrink-0" />
                  <div>
                    <p className="font-medium">Proof of Completion</p>
                    <p className="text-muted-foreground">
                      The holder has completed all 82 Suilings exercises, demonstrating
                      proficiency in Sui Move programming.
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>

            {/* CTA */}
            <div className="text-center space-y-4">
              <p className="text-muted-foreground">Want to earn your own credential?</p>
              <Button size="lg" asChild>
                <Link href="/exercise">Start Learning</Link>
              </Button>
            </div>
          </div>
        </main>
      </div>
      <Footer />
    </>
  );
}
