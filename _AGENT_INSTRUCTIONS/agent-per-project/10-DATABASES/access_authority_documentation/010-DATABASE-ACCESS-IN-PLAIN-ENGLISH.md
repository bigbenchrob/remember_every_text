---
tier: project
scope: databases
owner: agent-per-project
last_reviewed: 2026-08-09
source_of_truth: doc
links:
  - ../00-all-databases-accessed.md
  - ../../50-ENVIRONMENT-SAFETY/00-overview.md
  - ../../90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/README.md
tests: []
---

# MessageLens Data Access In Plain English

This is a translation guide for humans. It explains why MessageLens now talks
about archive roots, admission, authority, persistent providers, mutation
coordination, maintenance locks, and source-scoped identity.

The short version is:

> MessageLens used to know "the folder where my databases live." It now first
> proves which MessageLens data folder this particular build may use, and only
> then opens the databases and other persistent resources inside it.

The machinery is legitimate, but the terminology can make it sound more
mysterious than it is.

## The Three Questions

When the terminology becomes confusing, return to these three questions:

```text
Which MessageLens data set may this process use?
    -> archive access authority

May this workflow perform a protected change right now?
    -> archive mutation coordination

Where did these imported records originally come from?
    -> source identity
```

These questions are independent. Answering one does not answer either of the
others.

## Why This Exists

Before development and production were deliberately separated, MessageLens
effectively had one global answer to:

```text
Where are my databases?
```

Long-lived providers could take that directory and open their files:

```text
database directory
    -> import database
    -> working database
    -> overlay database
```

That was simple, but it depended too heavily on convention. A development
build could resolve the production Application Support directory and open
valuable production data writable. As onboarding, reset, graph rebuilding,
historical import, and attachment work became more powerful, that was no
longer an acceptable risk.

The development/production split changed the startup question from:

```text
Where is the database directory?
```

to:

```text
Which complete MessageLens data set belongs to this running build?
```

MessageLens now answers that question before constructing any app-owned
persistent database.

## Archive Root Means MessageLens Data Folder

In this part of the code, `archive` does not mean only an old backup or a set of
historical Messages files.

It means the complete persistent MessageLens data set.

An **archive root** is simply the top-level folder containing one such data
set. Conceptually:

```text
MessageLens Data Folder/
  macos_import_ss.db
  working_ss.db
  user_overlays.db
  presence.db
  attachment_archive/
  logs and diagnostics
  archive identity marker
  other archive-scoped state
```

The name `databaseDirectory` became too narrow because databases are not the
only durable resources that must stay together. Attachments, operational
evidence, diagnostics, and identity information belong to the same data set.

When reading the code, it is reasonable to translate:

```text
archive root
```

as:

```text
this MessageLens data folder
```

## Archive Admission Means Checking The Folder

**Archive admission** means checking that this running build is allowed to use
this particular MessageLens data folder.

Startup establishes facts such as:

- whether this is a development, production, or test build;
- the app's bundle identifier and product name;
- the canonical folder path claimed by native startup;
- whether production signing is valid when production requires it;
- whether the folder's identity marker belongs to the same environment;
- whether native startup and Dart independently agree on the canonical root.

Conceptually:

```text
Who am I?
    MessageLens Development

Which data folder am I supposed to use?
    /.../MessageLens Development/

Does that folder identify itself as development data?
    yes

May startup continue?
    yes
```

A development build may not silently fall back to production data. A test may
not silently use the app's Application Support data. Production may not adopt
an unmarked folder merely because it contains plausible database files.

If the checks fail, startup fails before persistent providers are constructed.
This is what `fail closed` means here: do not guess, and do not choose a more
dangerous fallback.

## `ArchiveAccessAuthority` Is The Validated Ticket

After those checks pass, MessageLens creates an `ArchiveAccessAuthority`.

In ordinary language, this object is a validated ticket saying:

```text
This process may use this exact MessageLens data folder.
```

The ticket carries the resolved archive identity and canonical root. It can
resolve a relative archive path without allowing that path to escape the
admitted folder.

It is not:

- a database manager;
- a repository;
- a migration engine;
- a feature owner;
- a per-query user permission;
- a decision that a disruptive operation is safe right now.

Its job is narrower: establish **which data folder this process may open**.

The authority is created once during startup and injected into the
application's Riverpod container. App-owned persistent providers cannot obtain
their physical root before that ticket exists.

## What Happened To The Database Providers?

The database providers still perform the familiar job: they open individual
stores. The new safety check sits in front of physical construction.

Current physical construction is centralized under:

```text
lib/essentials/db/feature_level_providers/
```

The public doorway remains:

```text
lib/essentials/db/feature_level_providers.dart
```

That file exports the approved provider seams. The folder contains their named
implementations, including the long-lived persistent database constructors.

The flow is:

```text
ArchiveAccessAuthority
    "use this MessageLens data folder"
                 |
      +----------+----------+----------+
      |          |          |          |
      v          v          v          v
  import DB   graph DB   overlay DB  Presence DB
  provider    provider    provider    provider
      |          |          |          |
      v          v          v          v
macos_import  working_ss  user_       presence.db
  _ss.db        .db       overlays.db
```

This is partly a new layer and partly a reorganization:

- database schemas and repositories still belong to their owning essentials;
- physical filenames are centralized;
- physical roots come only from the validated ticket;
- long-lived app-owned database instances are constructed centrally;
- features should normally consume repositories or semantic providers rather
  than construct or locate database files themselves.

For example, source import usually consumes the semantic import-ledger
provider. That provider may be backed by the centralized physical import
database, but import code does not need to know its filename or root.

Centralization does not transfer the meaning of the data to `essentials/db`.
Presence still owns Presence semantics. Overlay still owns durable user intent.
The graph still owns derived graph state. The import ledger still owns imported
source facts.

## A Separate Question: May This Workflow Change The Data Now?

Knowing the correct data folder does not mean every operation may mutate it at
any time.

MessageLens therefore has a second mechanism for protected archive changes:
the `ArchiveMutationCoordinator`.

In ordinary language, it answers:

```text
May this workflow perform this protected change right now?
```

Examples of named operations include:

- live graph update;
- graph build;
- onboarding import;
- message-data reset;
- historical archive import or removal;
- attachment reconciliation or clearing;
- destructive maintenance.

The coordinator is the single process-local token for these protected
mutations. One owner acquires it for a named operation. Another unrelated
operation cannot acquire it at the same time. Nested work belonging to the same
owner may re-enter without inventing a second source of authority.

For especially destructive production operations, the coordinator also
requires evidence of a verified checkpoint before allowing work to proceed.

Feature code still owns its business operation. The coordinator does not know
how to import messages, rebuild a graph, or clear attachments. It only decides
whether the protected operation may enter the archive-mutation section.

This is operation coordination, not a role system. MessageLens does not
generally issue one credential to "Migrators" and another to business
features. Architectural boundaries determine which feature may perform which
kind of work; the coordinator prevents protected mutations from colliding.

## `dbMaintenanceLockProvider` Is A Smaller Derived Signal

`dbMaintenanceLockProvider` is not another independent authority.

It translates part of the mutation coordinator's current state into a simpler
answer for readers and UI:

```text
Would reopening the graph database be unsafe during this operation?
```

Only some protected operations currently produce that condition, including
message-data reset, historical archive import or removal, and destructive
maintenance. Not every import, graph build, or ordinary write shuts down every
database reader.

When this signal is active:

- the graph database provider refuses to create a new graph connection;
- selected read models can return an unavailable/empty presentation instead of
  reopening the graph;
- the owning destructive workflow is responsible for closing and invalidating
  the affected existing providers when necessary.

The signal does not automatically revoke every open SQLite handle. It does not
currently gate every persistent store. Overlay and Presence, for example, are
separate stores with different continuity requirements.

If an admitted operation itself needs the graph, it prepares that
feature-owned capability before entering the protected interval. The prepared
connection may finish the owning operation's work. A different consumer still
cannot create a fresh graph connection while the signal is active. This is
sequencing within the existing authority model, not a bypass around it.

Therefore this mental translation is more accurate than "all database access
is locked":

```text
dbMaintenanceLockProvider
    = this destructive operation says affected graph readers must not reopen
      the database right now
```

## A Third Question: Where Did Imported Records Come From?

**Source-scoped identity** is unrelated to permissions and locking.

It answers:

```text
Which original source database produced this imported fact?
```

For example:

```text
current Mac chat.db
    -> source A

historical Messages archive
    -> source B

both enter the canonical import ledger
    -> rows retain their source identity
```

This lets one import system preserve provenance and distinguish records from
multiple live or historical sources. It does not decide which MessageLens data
folder may be opened, and it does not authorize a mutation.

## The Whole Picture

```text
MESSAGE LENS STARTS
        |
        v
Identify this build/process
        |
        v
Choose and validate this build's MessageLens data folder
        |
        v
ArchiveAccessAuthority
"this process may use this folder"
        |
        +----------------+----------------+----------------+
        v                v                v                v
 import provider     graph provider   overlay provider  Presence provider
        |                |                |                |
        v                v                v                v
 macos_import_ss.db  working_ss.db   user_overlays.db   presence.db
```

Independently:

```text
PROTECTED ARCHIVE CHANGE
        |
        v
ArchiveMutationCoordinator
"may this operation run now?"
        |
        v
possible derived maintenance/read-suppression signal
```

And independently again:

```text
chat.db / archived chat database / AddressBook source
        |
        v
source identity
"where did this imported fact come from?"
        |
        v
canonical source-scoped import ledger
```

## Presence As A Concrete Example

`presence.db` is simply another app-owned persistent store inside the validated
MessageLens data folder.

The sequence is:

```text
MessageLens validates its data folder
    -> receives the validated ticket
    -> Presence database provider resolves presence.db inside that folder
    -> provider opens one app-lifetime Drift database instance
    -> Presence repositories use that instance
```

The validated ticket does not own Presence definitions, schedule runs, or
execution traces. Presence owns what those tables mean. The ticket only keeps
the wrong build from locating and opening the wrong `presence.db`.

## Common Misunderstandings

### "Archive authority decides which feature can query each database"

No. It decides which complete MessageLens data folder this process may use.
Feature ownership and repository boundaries decide how code should consume the
data.

### "The maintenance lock gives Migrators exclusive ownership of working_ss.db"

Not as a general rule. Protected mutations enter the mutation coordinator.
Some destructive operations additionally block graph-database reopen and close
or invalidate affected instances. Ordinary import and graph work are not all
treated as global database shutdowns.

### "Central database providers mean essentials/db owns all database meaning"

No. `essentials/db` owns physical construction, common lifecycle, and the
public database seam. Domain meaning remains with Presence, overlay, graph,
source import, and their repositories.

### "Source-scoped means the source has access authority"

No. It is provenance: the identity of the original source from which imported
facts came.

### "Archive means historical import"

Not here. The archive root is the whole current MessageLens data set. A
historical Messages database is an input source that may be imported into that
data set.

## Translation Dictionary

| Code or documentation says | Read it as |
| --- | --- |
| archive | one complete MessageLens data set |
| archive root | the folder containing that data set |
| archive admission | check that this build may use that folder |
| `ArchiveAccessAuthority` | validated ticket identifying the permitted folder |
| persistent provider | app-lifetime opener for one store or resource inside that folder |
| `feature_level_providers.dart` | public doorway to approved provider seams |
| `feature_level_providers/` | named implementations behind that doorway |
| archive mutation coordinator | exclusive entrance for a protected archive-changing workflow |
| operation authority | permission for one named protected mutation to run now |
| maintenance lock | derived signal that affected graph readers must not reopen during this operation |
| source identity / source-scoped | which original source produced these imported facts |
| fail closed | stop instead of guessing or falling back to a more dangerous location |

## Where To Look Next

- [`../00-all-databases-accessed.md`](../00-all-databases-accessed.md) is the
  canonical inventory of database files, providers, and ownership.
- [`../../50-ENVIRONMENT-SAFETY/00-overview.md`](../../50-ENVIRONMENT-SAFETY/00-overview.md)
  defines the exact development, production, and test safety rules.
- [`../../90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/README.md`](../../90-DATA-INGESTION-REVIEW/WORKSTREAMS/01-PRODUCTION-DATA-PROTECTION/README.md)
  records why the development/production split was introduced and how it was
  validated.

The machinery is more substantial than the old global database directory, but
its purpose is straightforward: the wrong build should not open the wrong data
set, protected mutations should not collide, and imported facts should retain
their original source identity.
