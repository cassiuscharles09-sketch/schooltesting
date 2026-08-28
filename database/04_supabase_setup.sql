-- =========================================================================
-- DATAMEXT COLLEGE OF ST. ADELINE (DCSA)
-- SUPABASE CLOUD DATABASE SETUP & REAL-TIME SYNC CONFIGURATION
-- =========================================================================

-- 1. Create Applicants Table for Cloud Synchronization
CREATE TABLE IF NOT EXISTS applicants (
  id TEXT PRIMARY KEY,
  first_name TEXT NOT NULL,
  middle_name TEXT,
  last_name TEXT NOT NULL,
  suffix TEXT,
  gender TEXT,
  birth_date TEXT,
  age INTEGER,
  civil_status TEXT DEFAULT 'Single',
  email TEXT,
  contact_no TEXT,
  address TEXT,
  guardian_name TEXT,
  guardian_contact TEXT,
  guardian_relation TEXT,
  level TEXT,
  program TEXT,
  branch TEXT,
  entry_type TEXT,
  last_school TEXT,
  voucher_beneficiary TEXT,
  status TEXT DEFAULT 'Pending',
  date_applied TEXT,
  notes TEXT,
  student_id TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Enable Row Level Security (RLS)
ALTER TABLE applicants ENABLE ROW LEVEL SECURITY;

-- 3. Create Public Policies (Allows GitHub Pages / Mobile submissions to sync)
DROP POLICY IF EXISTS "Allow public insert" ON applicants;
DROP POLICY IF EXISTS "Allow public select" ON applicants;
DROP POLICY IF EXISTS "Allow public update" ON applicants;
DROP POLICY IF EXISTS "Allow public delete" ON applicants;

CREATE POLICY "Allow public insert" ON applicants FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public select" ON applicants FOR SELECT USING (true);
CREATE POLICY "Allow public update" ON applicants FOR UPDATE USING (true);
CREATE POLICY "Allow public delete" ON applicants FOR DELETE USING (true);
