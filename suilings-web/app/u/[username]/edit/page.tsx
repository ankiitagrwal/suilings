import { redirect, notFound } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { ProfileEditForm } from "@/components/profile/ProfileEditForm";
import { SimpleHeader } from "@/components/layout/SimpleHeader";
import { Footer } from "@/components/layout/Footer";

interface EditProfilePageProps {
  params: Promise<{ username: string }>;
}

export default async function EditProfilePage({ params }: EditProfilePageProps) {
  const { username } = await params;
  const supabase = await createClient();

  // Get current user
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    redirect("/login");
  }

  // Fetch profile from existing profiles table
  const { data: profile, error } = await supabase
    .from("profiles")
    .select("*")
    .eq("username", username)
    .single();

  if (error || !profile) {
    notFound();
  }

  // Check if user owns this profile
  if (profile.id !== user.id) {
    redirect(`/u/${username}`);
  }

  // Map profile data to form structure
  const initialData = {
    displayName: profile.full_name || profile.display_name || "",
    bio: profile.bio || "",
    location: profile.location || "",
    websiteUrl: profile.website || "",
    githubUsername: profile.github_username || "",
    twitterUsername: profile.twitter_username || "",
    openToWork: profile.open_to_work ?? false,
    skillsSummary: profile.skills_summary || "",
    availableRoles: profile.available_roles || [],
  };

  return (
    <>
      <SimpleHeader />
      <div className="min-h-screen bg-background">
        <div className="container mx-auto px-4 py-8 max-w-4xl">
          <div className="mb-8">
            <h1 className="text-3xl font-bold mb-2">Edit Profile</h1>
            <p className="text-muted-foreground">
              Update your profile information and preferences
            </p>
          </div>

          <ProfileEditForm
            username={username}
            initialData={initialData}
          />
        </div>
      </div>
      <Footer />
    </>
  );
}
