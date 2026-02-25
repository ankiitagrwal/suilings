# Database schema and migrations

## One schema, two ways to run it

- **`migrations/001_suilings_schema.sql`** – Used by Supabase when you run `supabase db push` or apply migrations. On a **fresh database**, this is the only migration; it creates all 8 tables the app uses.
- **`RESTORE_SCHEMA.sql`** – **Backup / disaster recovery**. Run this manually in the Supabase SQL Editor if you:
  - Dropped tables by mistake
  - Need to restore after an incident
  - Want to set up a new project DB without using the CLI

Both files define the **same** schema (8 tables only). Safe to run `RESTORE_SCHEMA.sql` multiple times (uses `IF NOT EXISTS` / `DROP IF EXISTS`).

## Tables created (8)

| Table | Purpose |
|-------|--------|
| `profiles` | User profile (id = auth.users.id) |
| `exercises` | Exercise catalog (seed with `scripts/seed-exercises.ts`) |
| `exercise_progress` | Per-user progress per exercise |
| `feedback` | Feedback form submissions |
| `user_wallets` | Linked Sui wallets |
| `sbt_credentials` | Minted SBT credentials |
| `playground_snippets` | Playground code snippets |
| `activity_feed` | Activity stream (optional) |

## Redeploy / fresh DB

1. **Option A – Supabase CLI**  
   Reset and apply migrations:
   ```bash
   supabase db reset
   ```
   or on a new project:
   ```bash
   supabase db push
   ```
   Only `001_suilings_schema.sql` runs → you get the 8 tables.

2. **Option B – Manual**  
   In Supabase Dashboard → SQL Editor, paste and run the contents of **`RESTORE_SCHEMA.sql`**.

## Existing production DB

If production already ran the old migrations (004–012), you do **not** need to run 001 or RESTORE_SCHEMA for normal operation. Use RESTORE_SCHEMA only for disaster recovery (e.g. after dropping tables). For a new environment or after a full reset, run 001 (via CLI) or RESTORE_SCHEMA (via SQL Editor).
