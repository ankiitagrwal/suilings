"use client";

import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";
import { Trophy, Target, Award, Flame } from "lucide-react";

interface ProfileStatsProps {
  stats: {
    completedExercises: number;
    totalExercises: number;
    completionRate: number;
  };
  credential?: {
    id: string;
    mintedAt: string;
    transactionDigest: string;
    objectId: string;
  } | null;
  suiNetwork?: string;
}

export function ProfileStats({ stats, credential, suiNetwork = 'testnet' }: ProfileStatsProps) {
  const explorerBaseUrl = suiNetwork === 'mainnet' 
    ? 'https://suiscan.xyz' 
    : 'https://suiscan.xyz/testnet';

  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
      {/* Progress Card */}
      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">Exercise Progress</CardTitle>
          <Target className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="text-2xl font-bold">
            {stats.completedExercises}/{stats.totalExercises}
          </div>
          <Progress value={stats.completionRate} className="mt-2" />
          <p className="text-xs text-muted-foreground mt-2">
            {stats.completionRate}% complete
          </p>
        </CardContent>
      </Card>

      {/* Credential Card */}
      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">Soulbound Token</CardTitle>
          <Award className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          {credential ? (
            <>
              <div className="text-2xl font-bold text-green-500">✓ Earned</div>
              <p className="text-xs text-muted-foreground mt-2">
                Minted {new Date(credential.mintedAt).toLocaleDateString()}
              </p>
              <a
                href={`${explorerBaseUrl}/object/${credential.objectId}`}
                target="_blank"
                rel="noopener noreferrer"
                className="text-xs text-primary hover:underline mt-2 block"
              >
                View on Explorer →
              </a>
            </>
          ) : (
            <>
              <div className="text-2xl font-bold text-muted-foreground">Not Yet</div>
              <p className="text-xs text-muted-foreground mt-2">
                Complete all {stats.totalExercises} exercises to earn
              </p>
            </>
          )}
        </CardContent>
      </Card>

      {/* Achievements Card */}
      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle className="text-sm font-medium">Achievements</CardTitle>
          <Trophy className="h-4 w-4 text-muted-foreground" />
        </CardHeader>
        <CardContent>
          <div className="flex gap-2 flex-wrap mt-2">
            {stats.completedExercises >= 10 && (
              <div className="text-2xl" title="Completed 10 exercises">
                🎯
              </div>
            )}
            {stats.completedExercises >= 50 && (
              <div className="text-2xl" title="Completed 50 exercises">
                🏆
              </div>
            )}
            {stats.completedExercises >= 82 && (
              <div className="text-2xl" title="Completed all exercises">
                🎓
              </div>
            )}
            {credential && (
              <div className="text-2xl" title="Earned SBT Credential">
                💎
              </div>
            )}
            {stats.completedExercises === 0 && (
              <p className="text-sm text-muted-foreground">
                Complete exercises to unlock achievements
              </p>
            )}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
