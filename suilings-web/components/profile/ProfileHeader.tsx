"use client";

import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Github, Twitter, Globe, MapPin, Calendar, Edit, Briefcase } from "lucide-react";
import { formatDistanceToNow } from "date-fns";
import Link from "next/link";

interface ProfileHeaderProps {
  profile: {
    username: string;
    displayName?: string | null;
    bio?: string | null;
    avatarUrl?: string | null;
    githubUsername?: string | null;
    twitterUsername?: string | null;
    websiteUrl?: string | null;
    location?: string | null;
    createdAt: string;
    openToWork?: boolean | null;
  };
  stats: {
    completedExercises: number;
  };
  isOwnProfile: boolean;
}

export function ProfileHeader({ profile, stats, isOwnProfile }: ProfileHeaderProps) {
  const initials = profile.displayName
    ? profile.displayName
        .split(" ")
        .map((n) => n[0])
        .join("")
        .toUpperCase()
    : profile.username.substring(0, 2).toUpperCase();

  return (
    <div className="border-b bg-card">
      <div className="container mx-auto px-4 py-8 max-w-6xl">
        <div className="flex flex-col md:flex-row gap-6">
          {/* Avatar */}
          <Avatar className="h-32 w-32">
            <AvatarImage src={profile.avatarUrl || undefined} />
            <AvatarFallback className="text-3xl">{initials}</AvatarFallback>
          </Avatar>

          {/* Info */}
          <div className="flex-1">
            <div className="flex items-start justify-between">
              <div>
                <div className="flex items-center gap-3 flex-wrap">
                  <h1 className="text-3xl font-bold">
                    {profile.displayName || profile.username}
                  </h1>
                  {profile.openToWork && (
                    <Badge className="bg-green-500/15 text-green-600 border-green-500/30 hover:bg-green-500/20 gap-1.5 font-medium">
                      <Briefcase className="h-3.5 w-3.5" />
                      Open to Work
                    </Badge>
                  )}
                </div>
                <p className="text-muted-foreground">@{profile.username}</p>
              </div>
              {isOwnProfile && (
                <Link href={`/u/${profile.username}/edit`}>
                  <Button variant="outline" size="sm" className="gap-2">
                    <Edit className="h-4 w-4" />
                    Edit Profile
                  </Button>
                </Link>
              )}
            </div>

            {/* Bio */}
            {profile.bio && (
              <p className="mt-4 text-sm text-muted-foreground max-w-2xl">
                {profile.bio}
              </p>
            )}

            {/* Meta Info */}
            <div className="flex flex-wrap gap-4 mt-4 text-sm text-muted-foreground">
              {profile.location && (
                <span className="flex items-center gap-1">
                  <MapPin className="h-4 w-4" />
                  {profile.location}
                </span>
              )}
              <span className="flex items-center gap-1">
                <Calendar className="h-4 w-4" />
                Joined {formatDistanceToNow(new Date(profile.createdAt), { addSuffix: true })}
              </span>
            </div>

            {/* Social Links */}
            <div className="flex flex-wrap gap-3 mt-4">
              {profile.githubUsername && (
                <a
                  href={`https://github.com/${profile.githubUsername}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center gap-1 text-sm hover:text-primary"
                >
                  <Github className="h-4 w-4" />
                  {profile.githubUsername}
                </a>
              )}
              {profile.twitterUsername && (
                <a
                  href={`https://twitter.com/${profile.twitterUsername}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center gap-1 text-sm hover:text-primary"
                >
                  <Twitter className="h-4 w-4" />
                  {profile.twitterUsername}
                </a>
              )}
              {profile.websiteUrl && (
                <a
                  href={profile.websiteUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center gap-1 text-sm hover:text-primary"
                >
                  <Globe className="h-4 w-4" />
                  Website
                </a>
              )}
            </div>

            {/* Stats */}
            <div className="flex gap-6 mt-6">
              <div>
                <span className="font-bold text-lg">{stats.completedExercises}</span>
                <span className="text-sm text-muted-foreground ml-1">Exercises Completed</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
