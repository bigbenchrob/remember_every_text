# Supabase Mirror Setup

This folder contains migrations and supporting documentation for mirroring the working Drift database into Supabase.

## Project reference

- Project dashboard: `https://supabase.com/dashboard/project/bvcfrctixmczhpnyqoub`
- **Do not** commit dashboard passwords or service keys. Store credentials in macOS Keychain or `.env.local` files excluded from git.

To configure the Supabase CLI locally:

1. Export an access token from the Supabase dashboard (Account Settings → Access Tokens).
2. Run:

```bash
supabase login
supabase link --project-ref bvcfrctixmczhpnyqoub
```

3. Store the generated `supabase/config.toml` securely; it is ignored by version control.

## Migrations

- `migrations/20250927T000000_initial_schema.sql` mirrors the working Drift tables and introduces per-user (`owner_user_id`) scoping required for row-level security.
- Apply the migration with:

```bash
supabase db push
```

or copy the SQL into the Supabase dashboard SQL editor and run it manually.

## Secrets management

- Service-role keys should be injected at runtime via environment variables (e.g., `SUPABASE_SERVICE_ROLE_KEY`).
- The macOS migration service should read secrets from the Keychain or a secure local file, never from source control.
- Update `_AGENT_CONTEXT/07-supabase-mirror-plan.md` if additional environment variables are introduced.
