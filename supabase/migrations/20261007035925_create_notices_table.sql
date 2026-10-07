/*
# Create notices table

1. New Tables
- `notices`
  - `id` (uuid, primary key)
  - `title` (text, not null) — short heading of the notice
  - `body` (text, not null) — full message content
  - `is_active` (boolean, default true) — admin can toggle visibility without deleting
  - `pinned` (boolean, default false) — pinned notices show at the top for students
  - `created_at` (timestamptz, default now())
  - `updated_at` (timestamptz, default now())

2. Security
- Enable RLS on `notices`.
- All authenticated users (students + admins) can read notices.
- Only admins can insert, update, and delete notices.
- Admin check uses a subquery on `profiles` where `role = 'admin'`.
*/

CREATE TABLE IF NOT EXISTS notices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  body text NOT NULL,
  is_active boolean NOT NULL DEFAULT true,
  pinned boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE notices ENABLE ROW LEVEL SECURITY;

-- SELECT: all authenticated users can read notices
DROP POLICY IF EXISTS "authenticated_can_read_notices" ON notices;
CREATE POLICY "authenticated_can_read_notices"
  ON notices FOR SELECT
  TO authenticated
  USING (true);

-- INSERT: only admins
DROP POLICY IF EXISTS "admin_can_insert_notices" ON notices;
CREATE POLICY "admin_can_insert_notices"
  ON notices FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
  );

-- UPDATE: only admins
DROP POLICY IF EXISTS "admin_can_update_notices" ON notices;
CREATE POLICY "admin_can_update_notices"
  ON notices FOR UPDATE
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
  )
  WITH CHECK (
    EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
  );

-- DELETE: only admins
DROP POLICY IF EXISTS "admin_can_delete_notices" ON notices;
CREATE POLICY "admin_can_delete_notices"
  ON notices FOR DELETE
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE profiles.id = auth.uid() AND profiles.role = 'admin')
  );
