# Supabase Mirror Implementation Plan

This guide coordinates the work required to mirror the working Drift database into Supabase for downstream clients (including the companion iOS application). Follow the numbered steps in order; later steps assume earlier ones are complete.

## Step 1 – Schema Inventory & Supabase Definition

1. **Inventory working Drift schema**
   - Export table definitions from `working_database.dart` (Drift schema) for: identities, chats, chat participants, messages, attachments, reactions, read-state tables, and projection metadata.
   - Capture primary keys, foreign keys, unique indexes, and nullable/enum semantics.
   - Note any computed fields (e.g., derived display names) that should either be materialized or recomputed on the client.
2. **Model Supabase (Postgres) tables**
   - Translate each Drift table to an equivalent Postgres `CREATE TABLE` statement, leveraging matching data types (`TEXT`, `INTEGER`, `TIMESTAMP WITH TIME ZONE`, `BOOLEAN`, `UUID`).
   - Encode enum-like columns using Postgres `ENUM` or validated `CHECK` constraints that mirror Drift value objects.
   - Define foreign keys to enforce referential integrity between chats, identities, messages, and attachments.
   - Add indexes needed for common read patterns (by chat, by message GUID, by identity) and for Supabase row-level security checks.
3. **Plan migration and versioning**
   - Store the SQL as `supabase/migrations/<timestamp>_initial_schema.sql` so the CLI can apply it.
   - Document how Drift schema changes propagate to Supabase: maintain a shared changelog and add a tooling step to regenerate SQL when Drift tables evolve.
4. **Decide data partitioning and tenancy**
   - Determine whether rows are partitioned per Apple ID / user, or if a single account hosts all mirrored data.
   - If multi-tenant, add `owner_user_id` columns and design row-level security policies around them.
5. **Validation checklist**
   - Ensure a local Supabase project (or remote dev instance) can apply the schema without errors.
   - Verify sample inserts for each table succeed and foreign key constraints match expectations.

## Step 2 – Projection & Sync Service

1. **Service placement & responsibilities**
   - Add a new application-layer service under `lib/essentials/db_migrate/application/supabase/` that orchestrates the mirror push once the ledger→working migration completes.
   - Responsibilities: detect newly projected batches, compute row-level diffs versus the last mirrored snapshot, and upsert those rows into Supabase while recording sync metadata locally.
   - Expose the service through a Riverpod `@riverpod` provider (e.g., `supabaseMirrorSyncServiceProvider`) so UI/tools can trigger or observe sync progress without manual instantiation.
2. **Trigger integration**
   - Extend `LedgerToWorkingMigrationService` to emit a domain event (or update projection state) once a batch finishes; the new sync service should subscribe to that provider/state change.
   - Support manual re-sync via a command method (e.g., `mirrorBatch({required int batchId})`) for recovery scenarios.
3. **Differences & batching strategy**
   - Track the last mirrored `batch_id` plus per-table high-water marks (e.g., `messages.lastSyncedRowId`) inside a new Drift table `supabase_sync_state`.
   - When processing a batch, fetch only rows with `updated_at > last_synced_at` or `id > last_synced_id` depending on table semantics; prefer deterministic ordering (GUID or integer primary key).
   - Chunk large tables (messages, attachments) into configurable batch sizes (default 500 rows) to keep HTTP payloads manageable.
4. **Supabase interaction**
   - Prefer the Supabase REST (PostgREST) API using service-role key stored in secure config, or the Supabase Dart client if we add it to dependencies; both support bulk `upsert` with `on_conflict` keys.
   - Define table-specific upsert payloads in `lib/essentials/db_migrate/infrastructure/supabase_dto/` with JSON serialization helpers to ensure consistent key casing and epoch handling.
   - Handle deletes by mirroring `deleted_at` soft-delete markers; if hard deletes are required later, document cascade behavior separately.
5. **Resilience & observability**
   - Implement exponential backoff with jitter for HTTP failures (start 1s, max 60s) and retry up to 5 times before surfacing an error.
   - Log sync progress through the existing debug settings logger plus a dedicated `SupabaseSyncLog` Drift table capturing batch id, table name, attempt count, and status.
   - Emit `DbMigrationProgress` updates similar to the local migration so the UI can show combined migration+mirror progress.
6. **Security & credential handling**
   - Read Supabase service role key and URL from secure configuration (macOS keychain or encrypted settings file); do not commit secrets.
   - Restrict service-role usage to the migration process; the companion app will rely on end-user auth covered in Step 3.
7. **Validation checklist**
   - Unit-test diff generation using ledger fixtures to ensure only changed rows are sent.
   - Add integration smoke test that mocks Supabase endpoint (e.g., using `http` package + fake server) to validate batched upserts and retry behavior.
   - Verify sync state table prevents duplicate uploads when running the service twice for the same batch.

## Step 3 – Supabase Auth & Security

1. **Authentication strategy**
   - Enable Supabase Auth providers: email/password (dev fallback) and Sign in with Apple (required for the companion iOS app).
   - Configure Apple Sign-In in Supabase dashboard with Services ID, redirect URLs, and client secret handled via Supabase-managed key material.
   - For development/testing, allow username/password with enforced email confirmation; restrict production logins to Apple Sign-In.
2. **Role separation**
   - Define three key roles:
     1. **end-user session** – JWT issued by Supabase Auth; used by the iOS app and any user-facing clients.
     2. **service role** – Supabase service key used exclusively by the migration mirror service for privileged upserts.
     3. **read-only analytics** (optional) – API key with read-only policies for tooling/BI dashboards.
   - Ensure service-role key is stored securely on macOS (Keychain or encrypted file). Never bundle it with client apps.
3. **Row-Level Security (RLS)**
   - Enable RLS for all mirrored tables (`chat`, `message`, `attachment`, etc.).
   - Introduce `owner_user_id` (UUID) column on every table, populated by the migration service during upsert.
   - Write policies:
     - `policy user_can_select_own_rows`: `using (auth.uid() = owner_user_id)` for SELECT.
     - `policy user_can_update_own_rows`: optional if companion app needs to update metadata.
     - `policy service_role_full_access`: grant insert/update/delete when `auth.jwt() ->> 'role' = 'service_role'`.
   - Ensure foreign keys also include `owner_user_id` consistency or rely on cascading via Postgres triggers.
4. **Service integration safeguards**
   - Migration service authenticates via service-role key over HTTPS; it must set `owner_user_id` for every record based on the signed-in macOS user’s Supabase profile (derive mapping from local config or Supabase Admin API).
   - Maintain a local cache of Supabase user IDs (profile table) keyed by Apple ID/email to avoid redundant admin lookups during sync.
   - Rotate service-role key periodically; document process for updating local secrets.
5. **Audit & logging**
   - Enable Supabase audit logs (logs explorer) and set retention to at least 30 days.
   - Migration service should log Supabase request IDs (`x-request-id`) in `SupabaseSyncLog` table to correlate with Supabase logs.
   - Consider adding a Postgres trigger to track last modified timestamps (`updated_at`) automatically (`created_at`/`updated_at` columns with default `now()` and `on update` triggers).
6. **Testing checklist**
   - Verify end-user JWT can only select rows matching its `owner_user_id`.
   - Confirm service-role key bypasses RLS (expected) but is blocked by Postgres grants if misused elsewhere.
   - Run integration test: create user via Supabase CLI, run mirror service with that user’s mapping, ensure data is readable/writeable only for that user via Supabase REST.

## Step 4 – Companion iOS Client Integration

1. **Client stack & project setup**
   - Use the official Supabase Swift client (`supabase-swift`) with Swift Package Manager in the iOS companion app.
   - Configure environment-specific Supabase URLs/anon keys via `xcconfig` files; keep production keys out of source control.
   - Set minimum iOS target to 15+ to leverage async/await for networking.
2. **Auth flow**
   - Integrate Sign in with Apple using Supabase’s `signInWithIdToken` (pass Apple ID credential to Supabase Auth).
   - Persist session using the Supabase client’s built-in storage; add keychain fallback for manual token refresh if needed.
3. **Data access layer**
   - Create a `SupabaseRepository` per domain aggregate (ChatsRepository, MessagesRepository, etc.) mirroring the Drift repositories.
   - Use typed DTOs matching the mirrored schema—leverage Swift `Codable` structs with snake_case coding keys to align with PostgREST responses.
   - Implement pagination helpers (e.g., `limit`/`range`) for messages and attachments to avoid loading entire histories at once.
4. **Caching & offline support**
   - Adopt a simple SQLite/Realm cache or Apple’s Core Data for local persistence if offline access is required; otherwise use in-memory caching with background refresh.
   - Cache per-chat message pages keyed by `chat_id` and last `updated_at`; invalidate cache when Supabase realtime or polling detects changes.
5. **Sync reconciliation**
   - Rely on Supabase realtime subscriptions for incremental updates (optional) or schedule periodic fetch (e.g., background fetch every 15 minutes).
   - Map `owner_user_id` to the signed-in user; ensure queries include `eq("owner_user_id", currentUserId)` to satisfy RLS and keep API calls efficient.
6. **Attachments handling**
   - If attachments remain in-table (binary blobs), download via Supabase REST and store temporarily in app sandbox; consider moving heavy media to Supabase Storage with signed URLs for streaming.
   - Provide streaming/download helpers that respect iOS background transfer policies.
7. **UI integration**
   - Map Supabase DTOs to SwiftUI view models similar to Flutter UI: chats list, conversation view, message detail.
   - Maintain consistency with Flutter naming to ease cross-platform feature parity (e.g., `ChatListItem`, `MessageBubbleModel`).
8. **Testing checklist**
   - Write integration tests using Supabase’s local dev stack (Docker) or staging project to validate auth and data retrieval.
   - Add unit tests for DTO decoding and repository pagination logic.
   - Ensure sign-out clears cached data and Supabase session tokens.

## Open Questions / Follow-Ups

- Clarify retention policies for mirrored data and how deletions sync.
- Decide whether to mirror attachments binary blobs or store them in Supabase Storage with signed URLs.
- Evaluate whether realtime subscriptions are required for clients or if polling is sufficient.
