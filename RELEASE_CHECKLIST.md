# Release Checklist

Use this checklist before cutting a release build or tagging a milestone. It keeps the macOS app, Supabase mirror, and documentation in sync while protecting sensitive credentials.

## 1. Project Health

- [ ] Run `flutter analyze` and ensure there are no issues.
- [ ] Run the targeted test suites that cover recent changes (use `flutter test --plain-name "<pattern>"`).
- [ ] Regenerate code when Drift tables or Riverpod providers changed:
  - `dart run build_runner build --delete-conflicting-outputs`
- [ ] Confirm `git status` is clean aside from intentional version bumps or release notes.

## 2. Supabase Configuration & Secrets

- [ ] Confirm the Supabase project reference is still `bvcfrctixmczhpnyqoub` (see `supabase/README.md`).
- [ ] Set the required environment variables for the session that will run migrations or the release build:
  - `SUPABASE_API_URL` – typically `https://bvcfrctixmczhpnyqoub.supabase.co`
  - `SUPABASE_SERVICE_ROLE_KEY` – the service-role key issued by Supabase
- [ ] Store secrets outside of the repo:
  - Preferred: macOS Keychain entry (e.g. `remember_every_text.supabase.service_role_key`).
  - Alternative: a local `.env.local` or shell profile (`~/.zprofile`) that is **git ignored**.
- [ ] If running the app through VS Code, update the local `.vscode/launch.json` placeholder with the real values **without committing changes**. Verify `.gitignore` excludes this file (it already does).
- [ ] For GUI launches (outside a terminal), export the variables globally with `launchctl setenv SUPABASE_API_URL …` and `launchctl setenv SUPABASE_SERVICE_ROLE_KEY …` before starting the app. Clear them with `launchctl unsetenv …` when done.
- [ ] After configuring secrets, confirm they’re available:
  - `printenv SUPABASE_API_URL`
  - `printenv SUPABASE_SERVICE_ROLE_KEY`
- [ ] Rotate the service-role key if it was shared or is older than 90 days. Update every local secret store at the same time.

## 3. Supabase Mirror Validation

- [ ] Run the migration pipeline on a fresh working database (`rm ~/sqlite_rmc/remember_every_text/working.db` then trigger the import) and ensure the Supabase mirror step completes without the "Projection failed" error.
- [ ] Review logs in `SupabaseSyncLogs` to confirm batches synced successfully.
- [ ] Spot-check data in Supabase (dashboard SQL editor or CLI) to ensure new rows carry the correct `owner_user_id` and timestamps.

## 4. Packaging & Distribution

- [ ] Update `CHANGELOG.md` or release notes to reflect the build.
- [ ] Bump the application version where required (macOS target, Flutter pubspec if applicable).
- [ ] Create the release build (`flutter build macos`) and verify it launches without missing assets.
- [ ] Smoke-test the packaged app with real Supabase credentials to ensure end-to-end sync still works.

## 5. Final Steps

- [ ] Tag the release in git and push tags.
- [ ] Attach the build artifact (zip/dmg) plus release notes where you distribute releases.
- [ ] Document any new environment variables or migration steps in `_AGENT_CONTEXT/07-supabase-mirror-plan.md` and `supabase/README.md` if they changed.
- [ ] Revoke temporary secrets or `launchctl` exports used during the release process.
