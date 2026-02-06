"use client";

import { useState } from "react";
import { useCurrentAccount, ConnectButton } from "@mysten/dapp-kit";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Award, CheckCircle2, ExternalLink, Loader2, Trophy, Wallet } from "lucide-react";
import { toast } from "sonner";
import { useWalletVerification } from "@/components/wallet/WalletConnect";

interface CredentialMintModalProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  completedExercises: number;
  githubUsername: string;
  streakDays?: number;
}

/**
 * CredentialMintModal - Modal for claiming SBT credential after completion
 * 
 * Flow:
 * 1. User completes all 82 exercises
 * 2. Modal opens automatically
 * 3. User connects wallet (if not connected)
 * 4. User signs message to link wallet
 * 5. Backend mints SBT
 * 6. Success! Show explorer link
 */
export function CredentialMintModal({
  open,
  onOpenChange,
  completedExercises,
  githubUsername,
  streakDays = 0,
}: CredentialMintModalProps) {
  const account = useCurrentAccount();
  const { signForVerification } = useWalletVerification();
  const [step, setStep] = useState<"intro" | "linking" | "minting" | "success">("intro");
  const [isLoading, setIsLoading] = useState(false);
  const [credentialData, setCredentialData] = useState<{
    sbtObjectId?: string;
    transactionDigest?: string;
    explorerUrl?: string;
  }>({});

  const handleLinkWallet = async () => {
    if (!account?.address) {
      toast.error("Please connect your wallet first");
      return;
    }

    setIsLoading(true);
    setStep("linking");

    try {
      // Sign message to prove wallet ownership
      const { signature, message, walletAddress } = await signForVerification(githubUsername);

      // Link wallet to user account
      const response = await fetch("/api/wallet/link", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          wallet_address: walletAddress,
          signature,
          message,
        }),
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.message || "Failed to link wallet");
      }

      toast.success("Wallet linked successfully!");
      setStep("minting");
      
      // Automatically proceed to minting
      await handleMintCredential(walletAddress);
    } catch (error) {
      console.error("Failed to link wallet:", error);
      toast.error(error instanceof Error ? error.message : "Failed to link wallet");
      setStep("intro");
    } finally {
      setIsLoading(false);
    }
  };

  const handleMintCredential = async (walletAddress: string) => {
    setIsLoading(true);

    try {
      // Trigger backend to mint SBT
      const response = await fetch("/api/credential/mint", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          wallet_address: walletAddress,
        }),
      });

      if (!response.ok) {
        const error = await response.json();
        throw new Error(error.message || "Failed to mint credential");
      }

      const data = await response.json();
      
      setCredentialData({
        sbtObjectId: data.sbt_object_id,
        transactionDigest: data.transaction_digest,
        explorerUrl: data.explorer_url,
      });

      setStep("success");
      toast.success("Credential minted successfully! 🎉");
    } catch (error) {
      console.error("Failed to mint credential:", error);
      toast.error(error instanceof Error ? error.message : "Failed to mint credential");
      setStep("intro");
    } finally {
      setIsLoading(false);
    }
  };

  const handleShare = (platform: "twitter" | "linkedin") => {
    const text = `I just completed all 82 exercises on Suilings and earned my blockchain-verified credential! 🎓\n\nVerify it on-chain: ${window.location.origin}/verify/${githubUsername}`;
    
    const urls = {
      twitter: `https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}`,
      linkedin: `https://www.linkedin.com/sharing/share-offsite/?url=${encodeURIComponent(window.location.origin)}&summary=${encodeURIComponent(text)}`,
    };

    window.open(urls[platform], "_blank", "width=600,height=400");
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[500px]">
        {step === "intro" && (
          <>
            <DialogHeader>
              <div className="flex items-center justify-center mb-4">
                <div className="rounded-full bg-gradient-to-r from-indigo-500 to-purple-500 p-3">
                  <Trophy className="h-8 w-8 text-white" />
                </div>
              </div>
              <DialogTitle className="text-center text-2xl">
                Congratulations! 🎉
              </DialogTitle>
              <DialogDescription className="text-center space-y-2">
                <p>You&apos;ve completed all {completedExercises} exercises!</p>
                <p className="text-base font-medium">
                  Claim your blockchain-verified completion credential
                </p>
              </DialogDescription>
            </DialogHeader>

            <div className="space-y-4 py-4">
              <div className="grid grid-cols-3 gap-4 text-center">
                <div className="space-y-1">
                  <div className="text-2xl font-bold text-primary">{completedExercises}</div>
                  <div className="text-xs text-muted-foreground">Exercises</div>
                </div>
                <div className="space-y-1">
                  <div className="text-2xl font-bold text-primary">{streakDays}</div>
                  <div className="text-xs text-muted-foreground">Day Streak</div>
                </div>
                <div className="space-y-1">
                  <div className="text-2xl font-bold text-primary">1</div>
                  <div className="text-xs text-muted-foreground">Credential</div>
                </div>
              </div>

              <div className="space-y-2 bg-muted/50 p-4 rounded-lg">
                <div className="flex items-start gap-2">
                  <CheckCircle2 className="h-4 w-4 text-green-500 mt-0.5 shrink-0" />
                  <span className="text-sm">Non-transferable (Soulbound)</span>
                </div>
                <div className="flex items-start gap-2">
                  <CheckCircle2 className="h-4 w-4 text-green-500 mt-0.5 shrink-0" />
                  <span className="text-sm">Linked to your GitHub identity</span>
                </div>
                <div className="flex items-start gap-2">
                  <CheckCircle2 className="h-4 w-4 text-green-500 mt-0.5 shrink-0" />
                  <span className="text-sm">Verifiable by employers on-chain</span>
                </div>
                <div className="flex items-start gap-2">
                  <CheckCircle2 className="h-4 w-4 text-green-500 mt-0.5 shrink-0" />
                  <span className="text-sm">Permanent proof of achievement</span>
                </div>
              </div>
            </div>

            <DialogFooter className="flex-col sm:flex-row gap-2">
              <Button variant="outline" onClick={() => onOpenChange(false)} className="w-full sm:w-auto">
                Maybe Later
              </Button>
              {!account ? (
                <ConnectButton
                  className="bg-primary text-primary-foreground hover:bg-primary/90 px-4 py-2 rounded-md font-medium transition-colors w-full sm:w-auto flex items-center justify-center gap-2"
                  connectText={
                    <>
                      <Wallet className="h-4 w-4" />
                      Connect Wallet First
                    </>
                  }
                />
              ) : (
                <Button onClick={handleLinkWallet} disabled={isLoading} className="w-full sm:w-auto">
                  <Award className="mr-2 h-4 w-4" />
                  Claim Credential
                </Button>
              )}
            </DialogFooter>
          </>
        )}

        {(step === "linking" || step === "minting") && (
          <>
            <DialogHeader>
              <DialogTitle className="text-center">
                {step === "linking" ? "Linking Wallet..." : "Minting Credential..."}
              </DialogTitle>
              <DialogDescription className="text-center">
                {step === "linking" 
                  ? "Please sign the message in your wallet to verify ownership"
                  : "Creating your blockchain credential on Sui"}
              </DialogDescription>
            </DialogHeader>

            <div className="flex flex-col items-center justify-center py-8 space-y-4">
              <Loader2 className="h-12 w-12 animate-spin text-primary" />
              <p className="text-sm text-muted-foreground">
                {step === "linking" ? "Waiting for signature..." : "Transaction in progress..."}
              </p>
            </div>
          </>
        )}

        {step === "success" && (
          <>
            <DialogHeader>
              <div className="flex items-center justify-center mb-4">
                <div className="rounded-full bg-green-500 p-3">
                  <CheckCircle2 className="h-8 w-8 text-white" />
                </div>
              </div>
              <DialogTitle className="text-center text-2xl">
                Credential Minted! 🎉
              </DialogTitle>
              <DialogDescription className="text-center">
                Your achievement is now permanently recorded on the Sui blockchain
              </DialogDescription>
            </DialogHeader>

            <div className="space-y-4 py-4">
              <div className="bg-muted/50 p-4 rounded-lg space-y-2">
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">GitHub:</span>
                  <Badge variant="secondary">@{githubUsername}</Badge>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-muted-foreground">Exercises:</span>
                  <span className="font-medium">{completedExercises}/82</span>
                </div>
                {credentialData.transactionDigest && (
                  <div className="flex justify-between text-sm">
                    <span className="text-muted-foreground">Transaction:</span>
                    <a
                      href={credentialData.explorerUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-primary hover:underline flex items-center gap-1"
                    >
                      View <ExternalLink className="h-3 w-3" />
                    </a>
                  </div>
                )}
              </div>

              <div className="space-y-2">
                <p className="text-sm font-medium">Share your achievement:</p>
                <div className="flex gap-2">
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => handleShare("twitter")}
                    className="flex-1"
                  >
                    Share on Twitter
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => handleShare("linkedin")}
                    className="flex-1"
                  >
                    Share on LinkedIn
                  </Button>
                </div>
              </div>
            </div>

            <DialogFooter>
              <Button onClick={() => onOpenChange(false)} className="w-full">
                Done
              </Button>
            </DialogFooter>
          </>
        )}
      </DialogContent>
    </Dialog>
  );
}

