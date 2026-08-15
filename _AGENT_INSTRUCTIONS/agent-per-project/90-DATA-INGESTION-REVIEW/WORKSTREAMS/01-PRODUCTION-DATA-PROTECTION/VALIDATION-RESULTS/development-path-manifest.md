# Development Path Manifest

Date: 2026-07-27
Status: provider/static coverage and external-root startup complete; full
interactive workflow exercise pending

The following app-owned targets derive from admitted development authority:

- source-scoped import database;
- Conversation graph database;
- overlay database and window state;
- attachment archive and thumbnail cache;
- logs, pipeline audits, and incidents;
- support-bundle archive evidence;
- onboarding, readiness, reset, and health file stores.

Automated provider tests prove that these stores reject construction before
admission and resolve beneath the supplied development/test root afterward.

## Machine-Local External Root Verification

The ignored development launch configuration supplies:

```text
MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT=/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development
```

Observed startup evidence:

- the external directory existed and was writable;
- native claim resolution canonicalized the configured directory;
- Dart independently canonicalized the same configured directory;
- exact-root admission succeeded;
- the external root received its development marker and archive-scoped process
  lock;
- application logs, `macos_import_ss.db`, and `user_overlays.db` were created
  beneath the external root;
- the existing internal Application Support development archive remained in
  place with unchanged file checksums during the verification;
- no production root was opened or modified.

An initial validation attempt encountered an already-running development
instance launched without the override. The archive-scoped single-instance
authority rejected the second launch as designed. After stopping the stale
instance, the external-root launch succeeded.

Validation Gate 4 still requires one instrumented interactive pass through all
ordinary workflows, including attachment archival. This report proves startup
authority and initial persistent-store routing; it does not claim that the full
interactive exercise has occurred.
