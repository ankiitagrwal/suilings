-- Migration 001: Suilings full schema (8 tables only)
-- Use for fresh deploy. Same as RESTORE_SCHEMA.sql for disaster recovery.

-- ---------------------------------------------------------------------------
-- 1. PROFILES (extends auth.users; app uses id = auth.users.id)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE,
  full_name TEXT,
  display_name TEXT,
  bio TEXT,
  avatar_url TEXT,
  github_username TEXT,
  twitter_username TEXT,
  website TEXT,
  location TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_profiles_username ON profiles(username);
CREATE INDEX IF NOT EXISTS idx_profiles_github_username ON profiles(github_username);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Profiles are viewable by everyone" ON profiles;
CREATE POLICY "Profiles are viewable by everyone"
  ON profiles FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;
CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE USING (auth.uid() = id);

CREATE OR REPLACE FUNCTION update_profiles_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_profiles_updated_at ON profiles;
CREATE TRIGGER set_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_profiles_updated_at();

-- ---------------------------------------------------------------------------
-- 2. EXERCISES (from seed script)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS exercises (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  path TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'general',
  mode TEXT NOT NULL DEFAULT 'build',
  hint TEXT DEFAULT '',
  order_index INT DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_exercises_category ON exercises(category);
CREATE INDEX IF NOT EXISTS idx_exercises_order ON exercises(order_index);

ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Exercises are viewable by everyone" ON exercises;
CREATE POLICY "Exercises are viewable by everyone"
  ON exercises FOR SELECT USING (true);

-- ---------------------------------------------------------------------------
-- 3. EXERCISE_PROGRESS
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS exercise_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  exercise_id TEXT NOT NULL,
  status TEXT DEFAULT 'in-progress',
  last_code TEXT,
  completed BOOLEAN DEFAULT false,
  is_completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMP WITH TIME ZONE,
  attempts_count INT DEFAULT 0,
  attempt_count INT DEFAULT 0,
  is_skipped BOOLEAN DEFAULT false,
  solution_viewed BOOLEAN DEFAULT false,
  solution_viewed_at TIMESTAMP WITH TIME ZONE,
  time_spent_seconds INT DEFAULT 0,
  difficulty_rating INT CHECK (difficulty_rating IS NULL OR (difficulty_rating >= 1 AND difficulty_rating <= 5)),
  started_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, exercise_id)
);

CREATE INDEX IF NOT EXISTS idx_exercise_progress_user ON exercise_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_exercise_progress_exercise ON exercise_progress(exercise_id);
CREATE INDEX IF NOT EXISTS idx_exercise_progress_completed ON exercise_progress(user_id) WHERE completed = true OR is_completed = true;

ALTER TABLE exercise_progress ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own progress" ON exercise_progress;
CREATE POLICY "Users can view own progress"
  ON exercise_progress FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Public can view progress for profiles" ON exercise_progress;
CREATE POLICY "Public can view progress for profiles"
  ON exercise_progress FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can insert own progress" ON exercise_progress;
CREATE POLICY "Users can insert own progress"
  ON exercise_progress FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own progress" ON exercise_progress;
CREATE POLICY "Users can update own progress"
  ON exercise_progress FOR UPDATE USING (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION update_exercise_progress_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_exercise_progress_updated_at ON exercise_progress;
CREATE TRIGGER set_exercise_progress_updated_at
  BEFORE UPDATE ON exercise_progress
  FOR EACH ROW
  EXECUTE FUNCTION update_exercise_progress_updated_at();

-- ---------------------------------------------------------------------------
-- 4. FEEDBACK
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS feedback (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT,
  email TEXT,
  type TEXT DEFAULT 'General Feedback',
  message TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE feedback ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can insert feedback" ON feedback;
CREATE POLICY "Anyone can insert feedback"
  ON feedback FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Service role can read feedback" ON feedback;
CREATE POLICY "Service role can read feedback"
  ON feedback FOR SELECT USING (true);

-- ---------------------------------------------------------------------------
-- 5. USER_WALLETS
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_wallets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  wallet_address TEXT NOT NULL,
  github_username TEXT,
  linked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_primary BOOLEAN DEFAULT true,
  signature TEXT,
  message TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, wallet_address)
);

CREATE INDEX IF NOT EXISTS idx_user_wallets_user ON user_wallets(user_id);
CREATE INDEX IF NOT EXISTS idx_user_wallets_address ON user_wallets(wallet_address);

ALTER TABLE user_wallets ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own wallets" ON user_wallets;
CREATE POLICY "Users can view own wallets"
  ON user_wallets FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own wallet" ON user_wallets;
CREATE POLICY "Users can insert own wallet"
  ON user_wallets FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own wallet" ON user_wallets;
CREATE POLICY "Users can update own wallet"
  ON user_wallets FOR UPDATE USING (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- 6. SBT_CREDENTIALS
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sbt_credentials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  wallet_address TEXT NOT NULL,
  sbt_object_id TEXT NOT NULL,
  github_username TEXT NOT NULL,
  completed_exercises INT NOT NULL DEFAULT 0,
  completion_date TIMESTAMP WITH TIME ZONE NOT NULL,
  streak_days INT NOT NULL DEFAULT 0,
  total_time_minutes INT,
  mint_transaction_digest TEXT NOT NULL,
  mint_status TEXT NOT NULL DEFAULT 'pending' CHECK (mint_status IN ('pending', 'confirmed', 'failed')),
  blockchain_network TEXT NOT NULL DEFAULT 'mainnet' CHECK (blockchain_network IN ('mainnet', 'testnet', 'devnet', 'localnet')),
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sbt_credentials_user ON sbt_credentials(user_id);
CREATE INDEX IF NOT EXISTS idx_sbt_credentials_github ON sbt_credentials(github_username);
CREATE INDEX IF NOT EXISTS idx_sbt_credentials_wallet ON sbt_credentials(wallet_address);
CREATE INDEX IF NOT EXISTS idx_sbt_credentials_object ON sbt_credentials(sbt_object_id);

ALTER TABLE sbt_credentials ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Credentials viewable by owner or public for verification" ON sbt_credentials;
CREATE POLICY "Credentials viewable by owner or public for verification"
  ON sbt_credentials FOR SELECT USING (auth.uid() = user_id OR true);

DROP POLICY IF EXISTS "Service/authenticated can insert credentials" ON sbt_credentials;
CREATE POLICY "Service/authenticated can insert credentials"
  ON sbt_credentials FOR INSERT WITH CHECK (true);

-- ---------------------------------------------------------------------------
-- 7. PLAYGROUND_SNIPPETS
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS playground_snippets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  title TEXT NOT NULL DEFAULT 'Untitled',
  code TEXT NOT NULL,
  description TEXT,
  is_public BOOLEAN DEFAULT true,
  fork_count INT DEFAULT 0,
  view_count INT DEFAULT 0,
  forked_from UUID REFERENCES playground_snippets(id) ON DELETE SET NULL,
  tags TEXT[] DEFAULT '{}',
  last_viewed_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_playground_user_id ON playground_snippets(user_id);
CREATE INDEX IF NOT EXISTS idx_playground_public ON playground_snippets(is_public);
CREATE INDEX IF NOT EXISTS idx_playground_created ON playground_snippets(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_playground_snippets_search ON playground_snippets USING gin(to_tsvector('english', title || ' ' || COALESCE(description, '')));
CREATE INDEX IF NOT EXISTS idx_playground_snippets_tags ON playground_snippets USING gin(tags);

ALTER TABLE playground_snippets ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public snippets are viewable by everyone" ON playground_snippets;
CREATE POLICY "Public snippets are viewable by everyone"
  ON playground_snippets FOR SELECT USING (is_public = true);

DROP POLICY IF EXISTS "Users can view own snippets" ON playground_snippets;
CREATE POLICY "Users can view own snippets"
  ON playground_snippets FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own snippets" ON playground_snippets;
CREATE POLICY "Users can insert own snippets"
  ON playground_snippets FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own snippets" ON playground_snippets;
CREATE POLICY "Users can update own snippets"
  ON playground_snippets FOR UPDATE USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own snippets" ON playground_snippets;
CREATE POLICY "Users can delete own snippets"
  ON playground_snippets FOR DELETE USING (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION update_playground_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_playground_snippets_updated_at ON playground_snippets;
CREATE TRIGGER update_playground_snippets_updated_at
  BEFORE UPDATE ON playground_snippets
  FOR EACH ROW
  EXECUTE FUNCTION update_playground_updated_at();

CREATE OR REPLACE FUNCTION increment_view_count(snippet_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE playground_snippets SET view_count = view_count + 1 WHERE id = snippet_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION increment_fork_count(snippet_id UUID)
RETURNS VOID AS $$
BEGIN
  UPDATE playground_snippets SET fork_count = fork_count + 1 WHERE id = snippet_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION increment_view_count(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION increment_fork_count(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION increment_view_count(UUID) TO anon;
GRANT EXECUTE ON FUNCTION increment_fork_count(UUID) TO anon;

-- ---------------------------------------------------------------------------
-- 8. ACTIVITY_FEED
-- ---------------------------------------------------------------------------
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'activity_type') THEN
    CREATE TYPE activity_type AS ENUM (
      'exercise_completed', 'snippet_created', 'snippet_forked', 'achievement_earned',
      'credential_minted', 'user_followed', 'exercise_commented', 'streak_milestone'
    );
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS activity_feed (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  activity_type activity_type NOT NULL,
  metadata JSONB DEFAULT '{}',
  is_public BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_activity_feed_user_id ON activity_feed(user_id);
CREATE INDEX IF NOT EXISTS idx_activity_feed_created ON activity_feed(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_activity_feed_user_public ON activity_feed(user_id, created_at DESC) WHERE is_public = true;

ALTER TABLE activity_feed ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public activities are viewable" ON activity_feed;
CREATE POLICY "Public activities are viewable" ON activity_feed FOR SELECT USING (is_public = true OR auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can create own activities" ON activity_feed;
CREATE POLICY "Users can create own activities" ON activity_feed FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own activities" ON activity_feed;
CREATE POLICY "Users can update own activities" ON activity_feed FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own activities" ON activity_feed;
CREATE POLICY "Users can delete own activities" ON activity_feed FOR DELETE USING (auth.uid() = user_id);

CREATE OR REPLACE FUNCTION create_exercise_completion_activity()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.completed = true AND (OLD.completed IS NULL OR OLD.completed = false) THEN
    INSERT INTO activity_feed (user_id, activity_type, metadata)
    VALUES (NEW.user_id, 'exercise_completed', jsonb_build_object('exercise_id', NEW.exercise_id, 'exercise_name', NEW.exercise_id));
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_exercise_completed ON exercise_progress;
CREATE TRIGGER on_exercise_completed AFTER UPDATE ON exercise_progress FOR EACH ROW EXECUTE FUNCTION create_exercise_completion_activity();

CREATE OR REPLACE FUNCTION create_snippet_activity()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO activity_feed (user_id, activity_type, metadata)
  VALUES (NEW.user_id, 'snippet_created', jsonb_build_object('snippet_id', NEW.id, 'snippet_title', NEW.title, 'is_public', NEW.is_public));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS on_snippet_created ON playground_snippets;
CREATE TRIGGER on_snippet_created AFTER INSERT ON playground_snippets FOR EACH ROW WHEN (NEW.user_id IS NOT NULL) EXECUTE FUNCTION create_snippet_activity();

-- ---------------------------------------------------------------------------
-- RPC: get_credential_by_identifier
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_credential_by_identifier(identifier TEXT)
RETURNS TABLE (
  user_id UUID, sbt_object_id TEXT, github_username TEXT, wallet_address TEXT,
  completed_exercises INT, completion_date TIMESTAMPTZ, streak_days INT, total_time_minutes INT,
  mint_transaction_digest TEXT, mint_status TEXT, blockchain_network TEXT, metadata JSONB,
  created_at TIMESTAMPTZ, updated_at TIMESTAMPTZ, days_since_completion INT, avatar_url TEXT, full_name TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT c.user_id, c.sbt_object_id, c.github_username, c.wallet_address,
    c.completed_exercises, c.completion_date, c.streak_days, c.total_time_minutes,
    c.mint_transaction_digest, c.mint_status, c.blockchain_network, c.metadata,
    c.created_at, c.updated_at,
    EXTRACT(DAY FROM (NOW() - c.completion_date))::INT,
    p.avatar_url, p.full_name
  FROM sbt_credentials c
  LEFT JOIN profiles p ON p.id = c.user_id
  WHERE LOWER(c.github_username) = LOWER(identifier)
     OR LOWER(c.wallet_address) = LOWER(identifier)
     OR LOWER(c.sbt_object_id) = LOWER(identifier);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

GRANT EXECUTE ON FUNCTION get_credential_by_identifier(TEXT) TO anon;
GRANT EXECUTE ON FUNCTION get_credential_by_identifier(TEXT) TO authenticated;
