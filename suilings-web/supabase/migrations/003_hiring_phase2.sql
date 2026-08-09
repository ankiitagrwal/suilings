-- Migration 003: Hiring Platform Phase 2
-- Adds companies, job_listings, and job_applications tables

-- ---------------------------------------------------------------------------
-- 1. COMPANIES
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS companies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  description TEXT,
  website TEXT,
  logo_url TEXT,
  contact_email TEXT,
  verified BOOLEAN DEFAULT false,
  admin_user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_companies_slug ON companies(slug);
CREATE INDEX IF NOT EXISTS idx_companies_admin ON companies(admin_user_id);

ALTER TABLE companies ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Companies are viewable by everyone" ON companies;
CREATE POLICY "Companies are viewable by everyone"
  ON companies FOR SELECT USING (true);

DROP POLICY IF EXISTS "Admin can insert own company" ON companies;
CREATE POLICY "Admin can insert own company"
  ON companies FOR INSERT WITH CHECK (auth.uid() = admin_user_id);

DROP POLICY IF EXISTS "Admin can update own company" ON companies;
CREATE POLICY "Admin can update own company"
  ON companies FOR UPDATE USING (auth.uid() = admin_user_id);

CREATE OR REPLACE FUNCTION update_companies_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_companies_updated_at ON companies;
CREATE TRIGGER set_companies_updated_at
  BEFORE UPDATE ON companies
  FOR EACH ROW
  EXECUTE FUNCTION update_companies_updated_at();

-- ---------------------------------------------------------------------------
-- 2. JOB_LISTINGS
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS job_listings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'full-time' CHECK (type IN ('full-time', 'part-time', 'contract')),
  location_type TEXT NOT NULL DEFAULT 'remote' CHECK (location_type IN ('remote', 'onsite', 'hybrid')),
  location TEXT,
  salary_min INT,
  salary_max INT,
  currency TEXT DEFAULT 'USD',
  min_exercises_required INT DEFAULT 0,
  requires_credential BOOLEAN DEFAULT false,
  tags TEXT[] DEFAULT '{}',
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'closed')),
  expires_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_job_listings_company ON job_listings(company_id);
CREATE INDEX IF NOT EXISTS idx_job_listings_status ON job_listings(status);
CREATE INDEX IF NOT EXISTS idx_job_listings_created ON job_listings(created_at DESC);

ALTER TABLE job_listings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Open job listings are viewable by everyone" ON job_listings;
CREATE POLICY "Open job listings are viewable by everyone"
  ON job_listings FOR SELECT USING (true);

DROP POLICY IF EXISTS "Company admin can insert listings" ON job_listings;
CREATE POLICY "Company admin can insert listings"
  ON job_listings FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM companies
      WHERE id = company_id AND admin_user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Company admin can update listings" ON job_listings;
CREATE POLICY "Company admin can update listings"
  ON job_listings FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM companies
      WHERE id = company_id AND admin_user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Company admin can delete listings" ON job_listings;
CREATE POLICY "Company admin can delete listings"
  ON job_listings FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM companies
      WHERE id = company_id AND admin_user_id = auth.uid()
    )
  );

CREATE OR REPLACE FUNCTION update_job_listings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_job_listings_updated_at ON job_listings;
CREATE TRIGGER set_job_listings_updated_at
  BEFORE UPDATE ON job_listings
  FOR EACH ROW
  EXECUTE FUNCTION update_job_listings_updated_at();

-- ---------------------------------------------------------------------------
-- 3. JOB_APPLICATIONS
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS job_applications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id UUID NOT NULL REFERENCES job_listings(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'shortlisted', 'rejected', 'hired')),
  cover_note TEXT,
  applied_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(job_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_job_applications_job ON job_applications(job_id);
CREATE INDEX IF NOT EXISTS idx_job_applications_user ON job_applications(user_id);
CREATE INDEX IF NOT EXISTS idx_job_applications_status ON job_applications(status);

ALTER TABLE job_applications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own applications" ON job_applications;
CREATE POLICY "Users can view own applications"
  ON job_applications FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Company admin can view applications for their listings" ON job_applications;
CREATE POLICY "Company admin can view applications for their listings"
  ON job_applications FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM job_listings jl
      JOIN companies c ON c.id = jl.company_id
      WHERE jl.id = job_id AND c.admin_user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Authenticated users can apply" ON job_applications;
CREATE POLICY "Authenticated users can apply"
  ON job_applications FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Company admin can update application status" ON job_applications;
CREATE POLICY "Company admin can update application status"
  ON job_applications FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM job_listings jl
      JOIN companies c ON c.id = jl.company_id
      WHERE jl.id = job_id AND c.admin_user_id = auth.uid()
    )
  );
