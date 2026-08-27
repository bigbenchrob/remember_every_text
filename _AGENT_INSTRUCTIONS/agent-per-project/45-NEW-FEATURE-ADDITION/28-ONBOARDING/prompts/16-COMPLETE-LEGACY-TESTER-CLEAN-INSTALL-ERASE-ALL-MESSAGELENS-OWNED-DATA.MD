

Absolutely. I’d frame this as a **separate destructive clean-install operation**, explicitly for legacy/early-tester installs, and keep the existing conservative Start Fresh unchanged.



Work on the current Feature 28 branch/worktree according to repository conventions.

This prompt is PRE-APPROVED for a read-first safety audit followed by bounded implementation.

Feature 28 is otherwise release-ready.

The remaining requirement is specific to the early tester cohort:

> Their existing MessageLens installations are obsolete, incomplete, and not in active use. We want them to begin the new version from an absolutely virgin MessageLens installation rather than migrate, remediate, or preserve old MessageLens-owned state.

These early tester data folders predate important modern features such as the managed attachment archive.

The desired result is:

> Remove the entire old MessageLens-owned installation, recreate a mechanically verified virgin environment, and enter the current six-node Onboarding Journey exactly as a first-time installation would.

This is intentionally DIFFERENT from the existing preservation-safe **Start Fresh** workflow.

Suggested prompt name:

`16-COMPLETE-LEGACY-TESTER-CLEAN-INSTALL-ERASE-ALL-MESSAGELENS-OWNED-DATA.MD`

# Preserve existing Start Fresh semantics

Do NOT change the existing ordinary Start Fresh behavior.

Current Start Fresh intentionally preserves:

- `attachment_archive/`;
- user overlays/customizations;
- Presence/history;
- diagnostics;
- archive identity;
- preferences;
- other potentially valuable MessageLens-owned information;

while rebuilding derived import/graph data.

That remains correct for ordinary users.

This new operation has a different contract.

# New operation contract

Create a separate destructive operation conceptually:

**Erase MessageLens Setup and Start Over**

or equivalent product wording.

Its meaning is:

> Delete all MessageLens-owned installation state associated with this local installation and recreate the product as a virgin first launch.

It must NOT mean:

> delete external Messages/Contacts/source data.

# Intended initial audience

This is primarily for:

- early testers;
- legacy incomplete installs;
- development/support recovery;
- users who deliberately want to discard all MessageLens-owned state.

Do not make this the ordinary default recovery action for healthy users.

# Hard source-data boundary

This operation must NEVER modify or delete:

- Apple `chat.db`;
- Apple Messages WAL/SHM;
- Apple Messages attachment files;
- Contacts databases;
- Contacts files;
- iCloud data;
- Historical Archive source folders;
- MessageLens recovery donor folders;
- arbitrary user-selected source locations;
- any file outside canonical MessageLens-owned storage/preferences.

Make this mechanically enforceable.

# Define “all MessageLens-owned state”

Audit every persistent artifact currently owned by MessageLens.

At minimum include where applicable:

- import databases;
- graph/working databases;
- overlay/user databases;
- Presence database/history;
- archive marker/environment identity;
- preferences/settings owned by MessageLens;
- attachment archive;
- search/index databases;
- caches;
- diagnostics/log files;
- source registry;
- operation snapshots;
- onboarding state;
- temporary staging files;
- legacy database names;
- legacy markers/directories from older tester builds.

Produce an explicit ownership inventory before implementation.

# Important difference from Start Fresh

For this operation, unlike ordinary Start Fresh, it is acceptable and intended to delete:

- overlays;
- tags;
- favourites;
- notes;
- nicknames;
- Presence history;
- diagnostics;
- attachment archive;
- archive identity;
- preferences;
- every other MessageLens-owned artifact;

because the human has explicitly chosen a true clean installation.

Do not preserve them silently.

# Legacy installations

Audit historical versions sufficiently to identify legacy MessageLens-owned artifacts that current code may no longer create.

The early testers may have:

- old database filenames;
- old schema generations;
- obsolete preferences;
- abandoned onboarding state;
- old cache directories.

The clean-install operation should remove known MessageLens-owned legacy artifacts as well as current ones.

Do not require those old databases to be migrated/opened first.

That is one of the central purposes of this path.

# Avoid migration before deletion

A tester selecting complete clean install should not first incur:

- schema upgrades;
- reconciliation;
- graph rebuild;
- migration of obsolete databases.

The operation should determine ownership safely, close what can be open, then remove the old installation.

Do not update data we intend to discard.

# Entry point / product exposure

Design a bounded entry point.

Possible locations:

- advanced/Option-launch;
- legacy-incomplete-install recovery screen;
- Settings advanced reset surface.

Prefer a name that makes destructiveness unmistakable.

Potential wording:

**Erase MessageLens Setup and Start Over…**

Do not call it merely:

**Start Fresh**

because that already has preservation-safe semantics.

# Legacy tester path

For known abandoned/legacy incomplete installations, consider offering this operation naturally.

Representative meaning:

**Start with a completely clean MessageLens installation**

> This will erase the existing MessageLens setup on this Mac and rebuild it from your current Messages and Contacts.

For the early testers, this may be the recommended action.

Do not force it on completed healthy users.

# Confirmation

Require explicit authorization.

The confirmation must clearly state what WILL be erased.

Representative:

**Erase this MessageLens setup and start over?**

> MessageLens will permanently delete its existing local data on this Mac, including imported databases, customizations, setup history, diagnostics, and any archived attachment copies stored by MessageLens.

Then state what will NOT be touched:

> Your Apple Messages, Contacts, and other source data will not be changed.

Buttons:

**Cancel**
**Erase and Start Over**

Use product voice.

Do not use a vague generic destructive dialog.

# Optional second confirmation

Audit whether repository/product conventions justify a second confirmation for this broader destructive action.

Do not add confirmation theater unnecessarily.

One explicit, very clear destructive authorization may be enough.

# Mutation authority

Require a distinct exact-scope ArchiveMutation operation, conceptually:

`completeInstallationErase`

or equivalent.

Do not reuse ordinary `startFresh` scope if that would obscure the broader mutation authority.

The capability should authorize only the canonical MessageLens-owned targets.

# Database shutdown

Before removing data:

- acquire mutation authority;
- block competing operations;
- close all MessageLens database providers/connections;
- prevent automatic reopen;
- stop/resolve background workers;
- invalidate provider state safely.

This includes:

- import;
- graph;
- overlay;
- Presence;
- search/index;
- attachment metadata;
- any legacy DB handles.

No filesystem deletion while providers can immediately recreate/open the old environment.

# Preferences/state reset

Identify where MessageLens preferences live.

A true clean install should reset MessageLens-owned preferences to first-launch defaults.

Do NOT affect unrelated app/system preferences.

After relaunch/transition, the application should behave like a first-ever launch.

# Archive identity

Delete/reset MessageLens archive identity.

The new installation should receive identity through the normal virgin initialization path.

Do not preserve the old archive UUID/marker.

# Attachment archive

For this operation, delete the entire MessageLens-managed `attachment_archive/`.

This is explicitly acceptable for the targeted early testers and any user who authorizes full erasure.

Do not touch Apple Messages attachments.

Add path-boundary tripwires.

# Historical Archives metadata

Delete MessageLens-owned registry/state relating to Historical Archives.

Do NOT delete the external Historical Archive source folders themselves.

After clean install, the user may re-add them later if desired.

# Diagnostics/logs

Reset MessageLens-owned diagnostics/log history if those files live under the installation data root or canonical app-owned diagnostic locations.

Audit whether deleting active log files requires close/reopen behavior.

# Filesystem deletion model

Prefer canonical explicit owned targets over broad arbitrary recursive deletion.

If the entire canonical MessageLens data root is proven exclusively MessageLens-owned, removing that root may be appropriate.

But mechanically protect against:

- symlink traversal;
- user-supplied root;
- accidental `/`;
- volume root;
- external donor path;
- Apple Application Support source paths.

Validate canonical root identity before deletion.

# Symlink safety

Do not recursively follow symlinks out of the MessageLens-owned root.

Use safe filesystem semantics.

Test malicious/unexpected symlink fixtures.

# Environment-variable development roots

The development build supports explicit roots such as:

`MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT`

The erase operation must work correctly there without weakening production boundaries.

In development:

- erase only that explicit MessageLens staging root;
- never infer parent volume ownership.

# Crash/interruption model

This destructive operation has different interruption characteristics from Start Fresh.

Analyze:

- crash after some files removed;
- crash after root removed but before virgin recreation;
- failure creating new environment.

On next launch, absence/partial absence of MessageLens-owned data should resolve safely to:

- virgin;
- remediationRequired;
- retryable clean-install state.

Do not require restoring deleted MessageLens data after explicit destruction.

The important invariant is:

> external source data remains safe and the application can converge to virgin.

# Preferred sequencing

Audit and implement a recoverable sequence conceptually:

1. human authorizes;
2. operation presentation takes ownership;
3. acquire exact mutation authority;
4. close/freeze MessageLens persistence;
5. verify canonical owned-root boundary;
6. erase all MessageLens-owned state;
7. reset app-owned preferences/state;
8. recreate/initialize only what virgin startup requires;
9. mechanically classify installation as `virgin`;
10. create a new Onboarding Journey occurrence;
11. enter `Messages` Episode;
12. release mutation authority appropriately.

Do not use this exact sequence blindly if architecture requires another order.

# Immediate presentation

After **Erase and Start Over**:

- confirmation disappears;
- a clean-install operation surface appears immediately;
- first frame paints before filesystem work;
- no dead/inert Settings page.

Reuse lessons from Start Fresh.

# Progress

This operation will probably be fast.

Use truthful coarse stages only if perceptible:

- Preparing clean installation
- Removing old MessageLens setup
- Checking clean installation

Do not add percentages.

Do not add artificial dwell.

# Terminal transition

If virgin verification succeeds:

do not show a generic “Done” and make the user relaunch manually.

Automatically hand ownership to the current Onboarding Journey Coordinator.

Journey path starts at the correct first Episode.

# Failure behavior

If erase fails:

- show typed failure;
- state whether some MessageLens data may already have been removed;
- reassure only that external Messages/Contacts were not touched if mechanically true;
- offer Retry where safe.

Do not attempt to reconstruct old MessageLens state.

# Installation classifier

After successful erasure:

`virgin`

must be proven through the canonical classifier.

Do not assume “directory deleted = virgin.”

Any required first-launch initialization should be consistent with the classifier’s virgin contract.

# Tester-specific validation

Create a safe staging fixture representing an old incomplete installation.

Include legacy artifacts where feasible.

Run:

legacy/incomplete fixture
→ Erase and Start Over
→ virgin classification
→ modern six-node Onboarding
→ production-shaped import
→ completed classification.

Do not use real tester machines yet.

# Manual local validation

After automated tests, provide a procedure for the user to validate this against a disposable development root.

The acceptance sequence:

1. completed/incomplete staging environment contains old MessageLens artifacts;
2. select Erase MessageLens Setup and Start Over;
3. confirm destructive wording;
4. operation completes;
5. old root/artifacts gone or recreated virgin as designed;
6. external source fingerprints unchanged;
7. Onboarding begins at Messages;
8. full Journey completes;
9. installation classifies completed.

# External source fingerprinting

For staging tests, fingerprint representative external files before/after:

- `chat.db`;
- Contacts DB;
- external Historical Archive donor if present.

SHA-256 must remain identical where stable/readable.

Do not hash massive source trees unnecessarily.

# Tests — ownership

Cover all current and legacy MessageLens-owned artifact classes.

Prove:

- they are removed;
- no external artifact is included.

# Tests — path safety

Cover:

- canonical root;
- development root;
- root `/`;
- volume root;
- parent directory;
- symlink escaping root;
- donor path;
- Apple source path.

Unsafe targets must fail closed.

# Tests — preferences/history

Prove:

- overlays erased;
- Presence history erased;
- preferences reset;
- archive identity erased;
- attachment archive erased;
- logs/diagnostics erased/reset according to policy.

# Tests — mutation/concurrency

Prove the operation cannot overlap:

- initial import;
- graph build;
- Start Fresh;
- Historical Archives mutation;
- attachment recovery.

# Tests — crash/reconciliation

Cover major interruption boundaries.

On relaunch, state must converge safely toward virgin/remediation rather than a fake completed install.

# Tests — UI

Prove:

- completed healthy user does not accidentally trigger this path without explicit advanced action;
- legacy abandoned install can be offered the path appropriately;
- destructive confirmation is explicit;
- operation surface paints immediately;
- success enters Onboarding automatically;
- failure visible.

# Tests — Start Fresh regression

Preservation-safe Start Fresh must remain unchanged.

Add explicit regression:

ordinary Start Fresh
→ preserves overlays/attachments/history.

Complete erase
→ removes them.

The two operations must not collapse into one implementation accidentally.

# Architecture tripwires

Protect:

1. complete erase and Start Fresh are distinct operations;

2. only exact mutation capability can erase full installation;

3. external Apple/source paths can never be erase targets;

4. attachment archive deletion allowed only under complete erase;

5. overlays/preferences/Presence deletion allowed only under complete erase;

6. no migration is required before deleting obsolete legacy state;

7. canonical root/path safety required;

8. symlink escape forbidden;

9. successful operation requires virgin classification;

10. ordinary healthy user is not silently reset;

11. operation presentation must own UI before deletion;

12. startup after erase routes through Journey Coordinator.

# Documentation

Create:

`16-COMPLETE-LEGACY-TESTER-CLEAN-INSTALL-ERASE-ALL-MESSAGELENS-OWNED-DATA-IMPLEMENTATION.md`

Document:

- difference from Start Fresh;
- intended audience;
- full owned-artifact inventory;
- legacy artifacts;
- destructive authorization;
- mutation scope;
- root/path safety;
- DB shutdown;
- preference/archive identity reset;
- attachment archive deletion;
- interruption semantics;
- virgin verification;
- tester migration workflow.

Update canonical reset/Onboarding/archive-environment docs.

Update Feature 28 index/documentation log.

Update version/changelog according to repository rules.

# Tester rollout guidance

At the end provide an exact recommended flow for the three early testers.

Ideally:

1. install new MessageLens build;
2. launch;
3. legacy/incomplete installation detected;
4. choose **Erase MessageLens Setup and Start Over**;
5. confirm;
6. new Onboarding begins;
7. proceed through six-node Journey.

No Terminal instructions.

Do not yet send this to testers until local staging validation passes.

# Verification

Run:

- complete erase tests;
- Start Fresh regressions;
- installation classifier;
- archive environment;
- database lifecycle;
- preferences/overlay/Presence;
- attachment archive;
- Historical Archives regressions;
- source immutability;
- path safety/symlink tests;
- mutation coordinator;
- Onboarding Journey;
- architecture tripwires;
- full Flutter suite;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build.

Commit and push if clean.

# Stop conditions

STOP if:

- canonical MessageLens ownership boundary cannot be proven;
- current app root contains non-MessageLens user files;
- external source/donor paths can overlap the MessageLens root;
- providers cannot be closed reliably;
- preference erasure affects unrelated application/system state;
- virgin state cannot be verified after deletion;
- old tester installations cannot be identified without opening/migrating unsupported schemas.

Do not ship a destructive command with an ambiguous target.

# Final report

Report:

- final operation name;
- exact difference from Start Fresh;
- intended availability;
- full deletion inventory;
- exact preserved external boundaries;
- path/symlink safety;
- mutation scope;
- crash/reconciliation behavior;
- virgin verification;
- legacy fixture validation;
- Start Fresh regression result;
- tests/verification;
- commit hash;
- exact manual local validation procedure;
- exact future tester instructions.

Acceptance standard:

> An early tester with an obsolete, unused MessageLens installation should be able to erase every byte of MessageLens-owned setup and begin again exactly like a first-time user, without migrating obsolete databases and without any possibility of touching Apple Messages, Contacts, or other external source data.