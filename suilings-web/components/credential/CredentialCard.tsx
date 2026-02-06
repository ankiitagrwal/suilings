"use client";

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Award, Calendar, ExternalLink, Github, TrendingUp, Clock } from "lucide-react";
import { SBTCredential } from "@/types/credential";

interface CredentialCardProps {
  credential: SBTCredential;
  showActions?: boolean;
}

/**
 * CredentialCard - Display user's SBT credential
 * 
 * Shows:
 * - GitHub username
 * - Completion date
 * - Exercise count
 * - Streak days
 * - Link to blockchain explorer
 */
export function CredentialCard({ credential, showActions = true }: CredentialCardProps) {
  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString("en-US", {
      year: "numeric",
      month: "long",
      day: "numeric",
    });
  };

  const getExplorerUrl = () => {
    const network = credential.blockchain_network || "testnet";
    const baseUrls: Record<string, string> = {
      mainnet: "https://suivision.xyz",
      testnet: "https://testnet.suivision.xyz",
      devnet: "https://devnet.suivision.xyz",
      localnet: "http://localhost:3000",
    };
    return `${baseUrls[network]}/object/${credential.sbt_object_id}`;
  };

  const getTransactionUrl = () => {
    const network = credential.blockchain_network || "testnet";
    const baseUrls: Record<string, string> = {
      mainnet: "https://suivision.xyz",
      testnet: "https://testnet.suivision.xyz",
      devnet: "https://devnet.suivision.xyz",
      localnet: "http://localhost:3000",
    };
    return `${baseUrls[network]}/txblock/${credential.mint_transaction_digest}`;
  };

  return (
    <Card className="overflow-hidden border-2 border-primary/20 bg-gradient-to-br from-background to-muted/20">
      <CardHeader className="space-y-1 pb-4">
        <div className="flex items-start justify-between">
          <div className="space-y-1">
            <CardTitle className="flex items-center gap-2">
              <Award className="h-5 w-5 text-primary" />
              Suilings Completion Credential
            </CardTitle>
            <CardDescription>
              Blockchain-verified proof of mastery
            </CardDescription>
          </div>
          <Badge
            variant={credential.mint_status === "confirmed" ? "default" : "secondary"}
            className="shrink-0"
          >
            {credential.mint_status === "confirmed" ? "Verified" : credential.mint_status}
          </Badge>
        </div>
      </CardHeader>

      <CardContent className="space-y-4">
        {/* GitHub Username */}
        <div className="flex items-center gap-3 p-3 bg-muted/50 rounded-lg">
          <Github className="h-5 w-5 text-muted-foreground" />
          <div className="flex-1">
            <div className="text-sm text-muted-foreground">GitHub</div>
            <div className="font-medium">@{credential.github_username}</div>
          </div>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-2 gap-3">
          <div className="flex items-center gap-2 p-3 bg-muted/50 rounded-lg">
            <Award className="h-4 w-4 text-primary" />
            <div>
              <div className="text-xs text-muted-foreground">Exercises</div>
              <div className="font-bold">{credential.completed_exercises}/82</div>
            </div>
          </div>

          <div className="flex items-center gap-2 p-3 bg-muted/50 rounded-lg">
            <TrendingUp className="h-4 w-4 text-green-500" />
            <div>
              <div className="text-xs text-muted-foreground">Streak</div>
              <div className="font-bold">{credential.streak_days} days</div>
            </div>
          </div>

          <div className="flex items-center gap-2 p-3 bg-muted/50 rounded-lg">
            <Calendar className="h-4 w-4 text-blue-500" />
            <div>
              <div className="text-xs text-muted-foreground">Completed</div>
              <div className="text-sm font-medium">
                {formatDate(credential.completion_date)}
              </div>
            </div>
          </div>

          {credential.total_time_minutes && credential.total_time_minutes > 0 && (
            <div className="flex items-center gap-2 p-3 bg-muted/50 rounded-lg">
              <Clock className="h-4 w-4 text-purple-500" />
              <div>
                <div className="text-xs text-muted-foreground">Time Invested</div>
                <div className="text-sm font-medium">
                  {Math.round(credential.total_time_minutes / 60)}h
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Blockchain Info */}
        <div className="space-y-2 pt-2 border-t">
          <div className="flex items-center justify-between text-xs">
            <span className="text-muted-foreground">Network:</span>
            <Badge variant="outline" className="text-xs">
              {credential.blockchain_network}
            </Badge>
          </div>
          <div className="flex items-center justify-between text-xs">
            <span className="text-muted-foreground">Object ID:</span>
            <code className="text-xs bg-muted px-2 py-0.5 rounded">
              {credential.sbt_object_id.slice(0, 8)}...{credential.sbt_object_id.slice(-6)}
            </code>
          </div>
        </div>

        {/* Actions */}
        {showActions && (
          <div className="flex gap-2 pt-2">
            <Button
              variant="outline"
              size="sm"
              className="flex-1"
              onClick={() => window.open(getExplorerUrl(), "_blank")}
            >
              <ExternalLink className="h-4 w-4 mr-2" />
              View on Explorer
            </Button>
            <Button
              variant="outline"
              size="sm"
              className="flex-1"
              onClick={() => window.open(getTransactionUrl(), "_blank")}
            >
              Transaction
            </Button>
          </div>
        )}
      </CardContent>
    </Card>
  );
}

