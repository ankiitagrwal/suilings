import { notFound } from "next/navigation";
import { SimpleHeader } from "@/components/layout/SimpleHeader";
import { ProfileHeader } from "@/components/profile/ProfileHeader";
import { ProfileStats } from "@/components/profile/ProfileStats";
import { SnippetCard, type SnippetData } from "@/components/playground/SnippetCard";
import { createClient } from "@/lib/supabase/server";

interface ProfilePageProps {
  params: Promise<{ username: string }>;
}

export default async function ProfilePage({ params }: ProfilePageProps) {
  const { username } = await params;
  const supabase = await createClient();

  let profile = null;
  let profileError = null;

  // Support lookup by UUID (e.g. from leaderboard when user has no username in profiles yet)
  const isUuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(username);
  if (isUuid) {
    const { data: profileById, error } = await supabase
      .from("profiles")
      .select("*")
      .eq("id", username)
      .maybeSingle();
    if (profileById) profile = profileById;
    else profileError = error;
  }

  if (!profile) {
    const { data: profileByUsername, error: error1 } = await supabase
      .from("profiles")
      .select("*")
      .eq("username", username)
      .maybeSingle();

    if (profileByUsername) {
      profile = profileByUsername;
    } else {
      const { data: profileByGithub, error: error2 } = await supabase
        .from("profiles")
        .select("*")
        .eq("github_username", username)
        .maybeSingle();

      if (profileByGithub) {
        profile = profileByGithub;
      } else {
        profileError = error1 || error2;
      }
    }
  }

  if (profileError || !profile) {
    notFound();
  }

  // Get exercise progress stats
  const { data: progress } = await supabase
    .from("exercise_progress")
    .select("*")
    .eq("user_id", profile.user_id || profile.id);

  const completedExercises = progress?.filter(
    (p) => p.completed === true || p.is_completed === true || p.status === "completed"
  ).length || 0;

  // Get SBT credential
  const { data: credential } = await supabase
    .from("sbt_credentials")
    .select("*")
    .eq("user_id", profile.user_id || profile.id)
    .single();

  // Map credential; hide for test users (HIDE_SBT_FOR_USERNAMES)
  const profileUsername = (profile.username || "").toLowerCase();
  const profileGithub = (profile.github_username || "").toLowerCase();
  const { HIDE_SBT_FOR_USERNAMES } = await import("@/lib/config/credential-config");
  const hideSbt = HIDE_SBT_FOR_USERNAMES.some(
    (u) => u.toLowerCase() === profileUsername || u.toLowerCase() === profileGithub
  );
  const mappedCredential =
    credential && !hideSbt
      ? {
          id: credential.id,
          mintedAt: credential.completion_date || credential.created_at,
          transactionDigest: credential.mint_transaction_digest,
          objectId: credential.sbt_object_id,
        }
      : null;

  // Get public snippets
  const { data: snippets } = await supabase
    .from("playground_snippets")
    .select("id, title, description, view_count, fork_count, created_at, tags, user_id")
    .eq("user_id", profile.user_id || profile.id)
    .eq("is_public", true)
    .order("created_at", { ascending: false })
    .limit(12);

  // Prepare data with proper camelCase mapping
  const data = {
    profile: {
      username: profile.username,
      displayName: profile.full_name || profile.display_name,
      bio: profile.bio,
      avatarUrl: profile.avatar_url,
      githubUsername: profile.github_username || profile.username,
      location: profile.location,
      createdAt: profile.created_at,
    },
    stats: {
      completedExercises,
      totalExercises: 82,
      completionRate: Math.round((completedExercises / 82) * 100),
    },
    credential: mappedCredential,
    snippets: (snippets || []).map(s => ({
      id: s.id,
      title: s.title,
      description: s.description,
      viewCount: s.view_count,
      forkCount: s.fork_count,
      createdAt: s.created_at,
      tags: s.tags || [],
      author: {
        id: profile.id,
        username: profile.username,
        avatarUrl: profile.avatar_url,
      },
    })),
    activity: [],
  };
  
  // Check if viewing own profile
  const { data: { user } } = await supabase.auth.getUser();
  const isOwnProfile = user && (profile.user_id === user.id || profile.id === user.id);

  return (
    <>
      <SimpleHeader />
      <div className="min-h-screen bg-background">
        {/* Profile Header */}
        <ProfileHeader
          profile={data.profile}
          stats={data.stats}
          isOwnProfile={!!isOwnProfile}
        />

        {/* Content */}
        <div className="container mx-auto px-4 py-8 max-w-6xl">
          {/* Stats Cards */}
          <ProfileStats 
            stats={data.stats} 
            credential={data.credential}
            suiNetwork={process.env.NEXT_PUBLIC_SUI_NETWORK || 'testnet'}
          />

          {/* Public Snippets */}
          {data.snippets.length > 0 && (
            <div className="mt-12">
              <h2 className="text-2xl font-bold mb-6">Public Snippets</h2>
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {data.snippets.map((snippet: SnippetData) => (
                  <SnippetCard key={snippet.id} snippet={snippet} />
                ))}
              </div>
            </div>
          )}

          {/* Recent Activity */}
          {data.activity.length > 0 && (
            <div className="mt-12">
              <h2 className="text-2xl font-bold mb-6">Recent Activity</h2>
              <div className="space-y-3">
                {data.activity.map((activity: any) => (
                  <div
                    key={activity.id}
                    className="p-4 border rounded-lg bg-card text-sm"
                  >
                    <span className="text-muted-foreground">
                      {formatActivity(activity)}
                    </span>
                    <span className="text-xs text-muted-foreground ml-2">
                      {new Date(activity.created_at).toLocaleDateString()}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Empty State */}
          {data.snippets.length === 0 && data.activity.length === 0 && (
            <div className="mt-12 text-center text-muted-foreground">
              <p>No public activity yet</p>
            </div>
          )}
        </div>
      </div>
    </>
  );
}

function formatActivity(activity: any): string {
  switch (activity.activity_type) {
    case "exercise_completed":
      return `Completed exercise: ${activity.metadata.exercise_name}`;
    case "snippet_created":
      return `Created snippet: ${activity.metadata.snippet_title}`;
    case "snippet_forked":
      return `Forked a snippet`;
    case "achievement_earned":
      return `Earned achievement: ${activity.metadata.achievement_name}`;
    case "credential_minted":
      return `Minted SBT Credential! 🎓`;
    default:
      return "Activity";
  }
}
