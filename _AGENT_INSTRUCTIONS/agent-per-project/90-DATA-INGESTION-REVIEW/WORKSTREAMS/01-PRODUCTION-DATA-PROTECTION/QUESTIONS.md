---
tier: project
scope: production-data-protection
owner: agent-per-project
last_reviewed: 2026-07-27
source_of_truth: decision-record
status: settled-and-implemented
links:
  - ./CURRENT-STATE-AUDIT.md
  - ./PROPOSAL.md
tests: []
---

# Production Data Protection Implementation Decisions

## Purpose

This document records the bounded decisions identified by the architectural
proposal and the implementation adjustments made while applying them. It does
not authorize production adoption.

The decisions preserve two non-negotiable facts:

1. the existing production app and archive identity must remain stable; and
2. ordinary development must become mechanically incapable of opening that
   archive.

## 1. Development Application Identity

### Decision

Use:

```text
Bundle identifier:
com.bigbenchsoftware.MessageLens.development

Product/display name:
MessageLens Development
```

Standard Debug and Profile launches use this identity.

Production retains:

```text
com.bigbenchsoftware.MessageLens
MessageLens
```

Optimized local testing uses Profile with the development identity. Release
remains production-shaped and fails closed unless native validation confirms
the expected production signing identity.

### Production configuration

Production archive authority requires all of:

- production archive environment;
- production bundle identifier;
- production build configuration;
- expected production signing team/identity;
- canonical production root and marker.

An unsigned or ad hoc local Release artifact cannot acquire production archive
authority merely because it inherited the production bundle identifier.

The notarization/distribution script becomes the explicit production build
entry point. It must verify the production environment metadata after signing.

### Why

A distinct development identity gives macOS, Application Support,
SharedPreferences, native instance detection, logs, and FDA a truthful
application boundary. Production identity remains unchanged for existing users.

## 2. Native-To-Dart Identity Handoff

### Decision

Native macOS bootstrap is the first resolver because process admission occurs
before Flutter starts.

Build configuration supplies immutable values through `Info.plist`/xcconfig.
Native bootstrap:

1. reads the declared environment and application identity;
2. derives the canonical root and archive-scoped lock;
3. validates production signing requirements when production is declared;
4. acquires process authority;
5. exposes the resulting immutable claim to Dart through a narrow platform
   channel after the Flutter engine is created.

Dart does not independently re-derive the intended environment. It validates
the received native claim, validates the archive marker, and constructs the
archive access authority consumed by providers.

### Failure rule

If native and Dart facts disagree, startup stops before persistent providers or
background ingestion start.

### Why

Two independent resolvers could disagree about the lock and writable root. One
native claim followed by Dart validation preserves one authority chain.

## 3. Archive Marker

### Decision

Use a small versioned JSON marker in each persistent archive root:

```json
{
  "formatVersion": 1,
  "environment": "development",
  "archiveInstanceId": "<uuid>",
  "createdAtUtc": "<iso-8601>"
}
```

The marker:

- is written atomically;
- is immutable except through a future explicit marker migration;
- does not contain database schema versions or personal data;
- is validated before database construction;
- is included in every snapshot and support report.

The canonical root is not stored as identity. The resolver already owns the
expected path, and storing it would make legitimate restored development/test
archives unnecessarily path-bound.

### Existing production archive

The existing unmarked production archive is adopted only through a dedicated,
reviewed production procedure with a verified recovery checkpoint. Ordinary
startup never silently creates its production marker.

Development may create a new marker automatically only in an empty, canonical
development root.

Tests create markers only in their supplied temporary roots.

## 4. Preferences, Logs, And Other Persistent State

### Decision

All persistent state is environment-scoped.

- Databases, attachment files, pipeline evidence, and archive incident evidence
  derive from archive access authority.
- Window state is stored in the environment-scoped overlay database. The
  application no longer relies on SharedPreferences for this persistent state.
- Application logs derive their directory name from the validated application
  identity/environment rather than hard-coded `MessageLens`.
- Overlay-backed window state follows the environment's overlay database.
- Pre-admission diagnostics go only to the system console or memory.

No persistent logger or window-state service starts before archive admission.

### Why

Protecting only SQLite files would still allow debug activity to alter
production preferences, logs, attachment state, or operational evidence.

## 5. Initial Operation-Authority Scope

### Decision

Begin conservatively with one reentrant, exclusive archive-maintenance
authority covering:

- live source import and graph update;
- full graph build;
- onboarding import/reimport;
- reset and automatic recovery;
- historical archive import/removal;
- attachment reconciliation/clearing;
- destructive schema/data maintenance.

The same owner may re-enter for nested stages of one operation.

Ordinary overlay user-intent transactions remain independent unless a specific
maintenance operation explicitly declares that overlay access must pause.

`DbMaintenanceLock` may remain as a derived UI/read-availability signal during
migration, but it is not a second mutation authority.

### Why

The current failure is incomplete authority coverage. A speculative
resource-compatibility matrix would add risk before safe concurrency has been
demonstrated.

## 6. First Recovery Checkpoint

### Decision

The first accepted production checkpoint is an offline, complete archive
snapshot plus a machine-readable manifest.

The application must be stopped. The checkpoint includes:

- the archive identity marker;
- all active databases and SQLite sidecars;
- overlay data;
- archive-source metadata;
- the complete attachment archive;
- pipeline/incident evidence stored with the archive.

The manifest records:

- archive instance and environment;
- snapshot time;
- file inventory, sizes, and hashes;
- database integrity-check results;
- exclusions, which must be empty unless explicitly approved;
- validation result.

Application logs outside the archive are exported as accompanying operational
evidence but are not required to reconstruct archive state.

### Why

The existing manual snapshot excludes attachments and has no objective
completeness receipt. The first production boundary needs evidence before it
needs sophisticated backup automation.

## 7. Production Adoption

### Decision

Production adoption is the final implementation phase, not an ordinary startup
migration.

It requires:

1. a verified complete checkpoint;
2. a read-only inventory and database health report;
3. confirmation that the root is the existing canonical production root;
4. atomic production marker creation;
5. restart and identity verification;
6. proof that development rejects the production root;
7. retained completion evidence.

No database content is moved or rewritten merely to adopt archive identity.

## 8. Development FDA

### Decision

Development may be granted Full Disk Access separately when work requires
reading live Apple sources.

Development FDA does not weaken isolation because its writable app-owned root
remains development-only.

The default development experience may therefore require one additional macOS
permission grant. That cost is accepted.

## 9. Production Build Command

### Decision

The existing `tool/build_and_notarize.sh` remains the production distribution
authority but must be updated to:

- select the explicit production configuration;
- verify archive-environment metadata;
- verify production bundle identifier and signing;
- reject a development artifact;
- preserve the existing output/signing/notarization behavior.

Ordinary editor launch configurations and documented developer commands select
development.

## Remaining Runtime And Production Evidence

The decisions are settled for planning, but these facts remain subject to
runtime verification:

- a complete interactive development path manifest across every ordinary
  workflow;
- FDA behavior for the development identity;
- signed and notarized production artifact verification;
- production adoption and post-adoption synchronization.

Native claim delivery, environment-separated roots and locks, duplicate
same-archive exclusion, and disposable checkpoint restoration now have
automated evidence. The remaining items are validation or production-adoption
obligations, not unresolved architecture.
