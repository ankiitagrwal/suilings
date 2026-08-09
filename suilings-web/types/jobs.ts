export type JobType = "full-time" | "part-time" | "contract";
export type LocationType = "remote" | "onsite" | "hybrid";
export type JobStatus = "open" | "closed";
export type ApplicationStatus = "pending" | "reviewed" | "shortlisted" | "rejected" | "hired";

export interface Company {
  id: string;
  name: string;
  slug: string;
  description: string | null;
  website: string | null;
  logo_url: string | null;
  contact_email: string | null;
  verified: boolean;
  admin_user_id: string | null;
  created_at: string;
  updated_at: string;
}

export interface JobListing {
  id: string;
  company_id: string;
  title: string;
  description: string;
  type: JobType;
  location_type: LocationType;
  location: string | null;
  salary_min: number | null;
  salary_max: number | null;
  currency: string;
  min_exercises_required: number;
  requires_credential: boolean;
  tags: string[];
  status: JobStatus;
  expires_at: string | null;
  created_at: string;
  updated_at: string;
  company?: Company;
}

export interface JobApplication {
  id: string;
  job_id: string;
  user_id: string;
  status: ApplicationStatus;
  cover_note: string | null;
  applied_at: string;
  job?: JobListing;
  applicant?: {
    id: string;
    username: string;
    full_name: string | null;
    avatar_url: string | null;
    location: string | null;
    github_username: string | null;
    completed_exercises: number;
    has_credential: boolean;
    profile_url: string;
  };
}

export interface CreateCompanyPayload {
  name: string;
  slug: string;
  description?: string;
  website?: string;
  logo_url?: string;
  contact_email?: string;
}

export interface CreateJobPayload {
  title: string;
  description: string;
  type: JobType;
  location_type: LocationType;
  location?: string;
  salary_min?: number;
  salary_max?: number;
  currency?: string;
  min_exercises_required?: number;
  requires_credential?: boolean;
  tags?: string[];
  expires_at?: string;
}

export interface ApplyJobPayload {
  cover_note?: string;
}
