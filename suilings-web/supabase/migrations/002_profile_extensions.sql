-- ---------------------------------------------------------------------------
-- Profile extensions for talent directory and hiring features
-- Adds columns used by /developers page, profile editing, and hiring platform
-- ---------------------------------------------------------------------------

ALTER TABLE profiles ADD COLUMN IF NOT EXISTS discord_username TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS open_to_work BOOLEAN DEFAULT false;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS skills_summary TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS available_roles TEXT[] DEFAULT '{}';
