Work on the current Feature 28 branch/worktree according to repository conventions.

This prompt is PRE-APPROVED for a read-first safety audit followed by bounded implementation where the ownership rules are mechanically proven.

Feature 28 has now validated a healthy production-shaped Onboarding journey:

- durable operation snapshot reaches `completed`;
- 137,373 imported messages reconcile exactly to 137,373 graph messages;
- 116,633 conversation-linked + 20,740 recovered = 137,373;
- seven unresolved reaction targets remain explicitly accounted nonfatal anomalies;
- zero dangling graph endpoints;
- all four databases pass integrity checks;
- production archive remains untouched.

The next release blocker is:

> **Abandoned/incomplete installations need a safe path back to a known-clean MessageLens-owned state.**

The original tester cohort encountered incomplete Onboarding and is waiting for a new build. They are not actively relying on those incomplete MessageLens installations.

The desired experience is not:

> “Find Application Support and delete these files.”

It is:

> MessageLens recognizes that this installation was not completed, explains the situation, and offers a mechanically safe **Start Fresh** path.

Suggested prompt name:

`09-INSTALLATION-STATE-CLASSIFICATION-AND-PRESERVATION-SAFE-START-FRESH.MD`

# Critical existing defect

The option-launch control:

**Delete MessageLens App Data**

currently does nothing.

This is a release blocker.

A control that appears to offer a reset but is a no-op is worse than having no reset control.

Do NOT simply wire that existing button to recursive deletion.

First establish exactly what a MessageLens installation is and what may safely be removed.

# Product goal

A user with an abandoned/incomplete MessageLens installation should be able to:

1. launch the new build;
2. have MessageLens determine the state of its own installation;
3. understand whether the installation is complete, resumable, incomplete, or inconsistent;
4. deliberately choose **Start Fresh** where appropriate;
5. receive a clear explanation of what will be removed;
6. have only MessageLens-owned resettable state removed;
7. have Apple source data remain untouched;
8. have the clean-state result mechanically verified;
9. enter the same Onboarding Journey as a genuinely virgin installation.

No Terminal.

No manual file deletion.

No knowledge of database filenames.

# Governing safety rule

Start Fresh must be defined by **ownership**, not by directory convenience.

Do NOT implement:

`rm -rf MessageLens application support directory`

unless the audit proves every item under that root is both MessageLens-owned and intentionally disposable.

Classify artifacts individually/by canonical ownership.

# Hard external-source boundary

Start Fresh must NEVER modify or delete:

- Apple `chat.db`;
- Apple Messages WAL/SHM/source databases;
- Apple Messages attachment files;
- Contacts databases;
- Contacts files;
- iCloud data;
- any source folder selected through Historical Archives;
- any MessageLens recovery donor;
- any other external source data.

Add mechanical protections.

# First — define installation state

Create/refine a typed installation-state classifier.

It must derive from durable authoritative evidence, not merely file existence.

At minimum distinguish:

## Virgin

No consequential MessageLens installation has begun / no durable installed archive exists.

## In progress / resumable

Onboarding began, durable coherent work exists, and current architecture can safely reconcile/continue.

## Completed

Canonical durable readiness/completion invariants are satisfied.

## Incomplete legacy / abandoned

MessageLens-owned installation artifacts exist, but the installation does not satisfy current completion invariants and cannot be safely resumed through the modern Journey.

## Inconsistent / remediation required

Artifacts contradict one another or fail integrity/ownership checks such that neither normal resume nor ordinary use is safe.

Use actual project terminology.

Do not force these exact names if current architecture supports a cleaner typed model.

# Durable operation snapshot is evidence, not sole authority

Prompt 02 established:

- idle;
- running;
- interrupted;
- failed;
- completed.

Use this evidence.

But do not classify installation state solely from the snapshot.

Reconcile against:

- archive environment;
- canonical databases;
- schema/version;
- import facts;
- graph facts;
- readiness;
- integrity evidence where appropriate.

Durable operational/database truth outranks stale snapshot state.

# Completed installation

Define the exact canonical facts proving completion.

Reuse the production-shaped validation invariants.

Do not invent a second completion definition for Start Fresh.

A stale/incomplete Presence or operation snapshot must not make a healthy completed installation appear abandoned.

# Resumable installation

Be conservative.

Only call an incomplete installation resumable if current architecture can prove:

- durable checkpoints are coherent;
- required schemas are supported;
- operation identity/reconciliation is valid;
- retry/resume is idempotent;
- continuation cannot duplicate or corrupt data.

Do not offer Resume merely because some databases exist.

# Legacy abandoned installations

Audit likely state produced by the original tester builds.

Use:

- historical schema/version docs;
- old Onboarding architecture;
- database marker history;
- operation-state history;
- git/docs where useful.

Determine what evidence lets the new build recognize:

> this is an older incomplete MessageLens installation.

Do not require recovering the exact state of each tester machine now.

Build a bounded classifier for known historical generations where evidence supports it.

# Artifact ownership inventory

Produce a complete table for MessageLens-owned persistent artifacts.

At minimum investigate:

- `macos_import_ss.db`;
- `working_ss.db`;
- overlay/user databases;
- `presence.db`;
- attachment archive;
- derived media;
- search/index databases;
- archive marker/environment metadata;
- source registry;
- preferences/settings;
- caches;
- logs/diagnostics;
- temporary files;
- any legacy database names.

For each classify:

### Rebuildable derived state

Safe to discard and regenerate from source.

### User-authored state

Potentially valuable; preserve by default unless user explicitly authorizes loss.

### Recovered/archived payload state

May contain bytes no longer present in Apple source data.

Potentially valuable.

### Operational metadata

Resettable if necessary.

### External source locator/evidence

Do not mutate external target.

# Critical attachment issue

Feature 26 established that a MessageLens data folder can contain attachment payloads worth recovering later.

Therefore Start Fresh must NOT casually delete an existing `attachment_archive` merely because it is MessageLens-owned.

Audit whether an incomplete tester installation may contain:

- unique attachment payloads no longer present in current Apple Messages;
- attachment archive data imported before Onboarding failed.

Determine safe policy.

Possible outcomes:

## Preserve attachment archive across Start Fresh

if architecture can re-adopt/reconcile it safely.

## Move/archive old MessageLens data folder

and start a new clean archive, preserving the old folder as recovery material.

## Explicit destructive option

only with clear warning.

Do not choose until evidence supports it.

# User-authored overlays

Likewise audit:

- nicknames;
- favourites;
- tags;
- notes;
- other overlays.

Even an incomplete installation may contain user-authored work.

Determine whether Start Fresh:

- preserves them;
- exports/copies them;
- leaves old archive intact;
- warns before deletion.

The original testers may have little/no such data, but product semantics must not assume that universally.

# Preferred architectural direction to evaluate

Consider whether **Start Fresh should create a new clean MessageLens archive/environment while preserving the old MessageLens data folder**, rather than destructively deleting the old one.

This may provide the strongest safety model:

old incomplete archive
→ retired/preserved
→ new virgin archive
→ Onboarding.

Advantages:

- no accidental loss of attachments/overlays;
- old folder can later serve as MessageLens attachment-recovery donor;
- rollback/forensics remain possible.

Costs:

- storage;
- archive-environment identity;
- canonical path switching;
- cleanup UX.

Audit this seriously.

Do not implement destructive reset if archive rotation is safer and already compatible with architecture.

# “Delete MessageLens App Data” reconsideration

The existing option-launch wording may no longer be appropriate.

If safe product behavior is actually:

**Start Fresh**

then retire/replace the misleading destructive wording.

Potential human concept:

> Start over with a new MessageLens setup.

Do not expose internal “App Data” terminology if the user doesn't need it.

# Start Fresh authorization

This is consequential.

Require explicit human authorization.

The confirmation must state, truthfully:

- Apple Messages and Contacts will not be changed;
- what existing MessageLens data will be preserved;
- what MessageLens state will be discarded/replaced;
- whether user-authored customizations will be retained;
- whether attachment archive remains available.

No vague:

“Are you sure?”

# Mutation authority

Start Fresh must run under canonical mutation/maintenance authority.

Requirements:

- no databases remain open while being replaced/retired;
- no concurrent Onboarding/import;
- no Historical Archives mutation;
- no attachment recovery;
- no search/index rebuild competing.

Use `ArchiveMutationCoordinator`.

Do not invent a separate reset lock.

# Database close protocol

Audit every persistent database connection/provider.

Before reset/rotation:

- close canonical handles;
- invalidate providers appropriately;
- prevent automatic reopen mid-operation;
- verify no background task retains old environment.

This is likely one of the hardest parts.

Do not rely on filesystem deletion failing because a DB happens to be open.

# Reset/rotation transaction model

Filesystem operations cannot necessarily be one SQLite transaction.

Design a recoverable sequence.

If rotating old archive:

1. acquire mutation authority;
2. freeze/release database consumers;
3. verify source/external boundaries;
4. retire current MessageLens environment atomically where possible;
5. create/verify virgin environment;
6. update canonical active-environment pointer/locator;
7. reset operation/Presence state;
8. release authority;
9. enter virgin Onboarding.

If destructive reset is chosen, define equivalent safe ordering.

Do not implement this exact sequence blindly.

# Crash during Start Fresh

Analyze interruption at every boundary.

Especially:

- after old archive retired but before new created;
- after new created but before active locator updated;
- after locator update but before Onboarding state reset.

On relaunch, MessageLens must reconcile to:

- old preserved archive;
- new virgin archive;
- or a typed recoverable reset state.

No half-deleted mystery installation.

# Fresh-state verification

After Start Fresh, mechanically prove:

- new/current MessageLens environment satisfies virgin-state contract;
- no stale import/graph completion remains;
- no old operation snapshot says completed;
- Onboarding will start;
- external source files unchanged;
- preserved old archive still exists if rotation model used.

Do not simply navigate to the first Onboarding screen and call that success.

# Source immutability proof

Add tests that fingerprint/sample source paths before/after reset.

At minimum prove reset cannot target:

- live `chat.db`;
- Contacts;
- donor archive;
- external Messages folders.

Use path ownership/type boundaries, not just tests.

# Installation classifier and option-launch

The option-launch/reset surface should use the same typed installation classifier.

Do not show Start Fresh indiscriminately if:

- installation is healthy and completed;

unless there is an explicit advanced/reset mode where destructive implications are clear.

For abandoned tester installs, the new build should surface it naturally.

# Tester migration experience

Design and, where bounded by this task, implement the path:

legacy/incomplete installation detected
→ concise explanation
→ **Start Fresh**
→ confirmation
→ safe reset/rotation
→ verified virgin state
→ modern Onboarding.

Representative meaning:

**This MessageLens setup wasn't completed**

> You can start again with the new version. Your Messages and Contacts on this Mac won't be changed.

If old MessageLens data is preserved:

> I'll keep your existing MessageLens data folder in case it contains attachments or other information you may want later.

Use final wording consistent with product voice.

Do not patronize.

# Resume versus Start Fresh

If classifier says genuinely resumable:

do not automatically force reset.

Potential actions:

- Continue;
- Start Fresh.

But only offer Continue if proven safe.

For known legacy incomplete states that cannot resume:

offer Start Fresh as the clear path.

# Completed healthy installations

Do not interrupt ordinary users with reset prompts.

Option-launch advanced access may still expose Start Fresh if product wants it, but this task should prioritize abandoned installs.

# Start Fresh progress

The operation may involve:

- closing databases;
- preserving/retiring old archive;
- creating new environment;
- verifying virgin state.

Profile it.

If perceptible, use truthful progress.

Do not invent percentages.

This is a small operation compared with Onboarding; keep presentation proportional.

# Presence/Narrator

Start Fresh is a distinct Episode because the human explicitly authorized a reset.

Potential Narrator meaning:

**I'm preparing a clean MessageLens setup. Your Messages and Contacts won't be changed.**

Only if true.

Do not narrate implementation steps.

# Failure

If Start Fresh fails:

- old data must remain safe where possible;
- show typed failure;
- explain whether the original setup is unchanged/preserved;
- offer retry only when safe.

Never leave the user believing reset succeeded if active environment is inconsistent.

# Legacy no-op control

Remove the no-op behavior.

After this task there must be no reachable control labeled as deleting/resetting MessageLens data that silently does nothing.

If implementation must stop before wiring it, remove/disable the misleading control and document why.

# Automated clean-install harness

Use this work to establish a safe test seam for:

- virgin environment;
- incomplete environment;
- legacy abandoned environment;
- completed environment;
- Start Fresh result.

Temp/staging roots only.

This will be essential for the remaining Onboarding work.

# Manual tester procedure

Do NOT ask the six testers to use this yet.

First validate locally/staging.

At the end, document the future tester flow.

We will authorize external tester use only after full Onboarding completion.

# Tests — classifier

Cover:

- virgin;
- running/resumable;
- interrupted/resumable;
- completed;
- failed but resumable;
- legacy incomplete;
- inconsistent;
- stale snapshot vs healthy durable DB truth.

# Tests — ownership

Prove every owned artifact has a policy.

Add tripwire requiring new persistent MessageLens artifacts to declare Start Fresh ownership semantics where repository architecture supports such enforcement.

# Tests — reset/rotation

Cover:

- successful Start Fresh;
- source files unchanged;
- old archive preserved if chosen;
- new environment virgin;
- Presence/snapshot reset;
- provider/database close;
- no stale graph/import readiness;
- Onboarding reappears.

# Tests — interruption

Cover crash/failure at major reset boundaries.

Ensure relaunch reconciliation is deterministic.

# Tests — user-owned value

If overlays/attachments are preserved:

prove they survive in the preserved archive.

If any are intentionally deleted:

prove explicit authorization contract.

# Tests — concurrency

Prove Start Fresh cannot overlap:

- import;
- graph build;
- Historical Archives mutation;
- attachment recovery.

# Architecture tripwires

Protect:

1. external Apple source paths can never be reset targets;

2. Start Fresh requires mutation authority;

3. databases must be closed before environment replacement;

4. installation classifier is typed/canonical;

5. operation snapshot alone cannot define installation state;

6. no recursive deletion based solely on a user-visible path;

7. attachment/user-overlay preservation policy is explicit;

8. no reset control is a no-op;

9. successful reset requires virgin-state verification;

10. completed healthy install is not misclassified abandoned.

# No anomaly changes

Prompt 08 validated current anomaly policy.

Do not alter it.

# No watchdog

Do not revisit liveness thresholds.

Healthy Onboarding progress is now effective.

# Documentation

Create:

`09-INSTALLATION-STATE-CLASSIFICATION-AND-PRESERVATION-SAFE-START-FRESH-IMPLEMENTATION.md`

Document:

- installation-state classifier;
- artifact ownership inventory;
- attachment policy;
- overlay policy;
- destructive reset vs archive-rotation decision;
- active-environment switching;
- mutation authority;
- close protocol;
- interruption/reconciliation;
- virgin verification;
- tester migration flow;
- old no-op control disposition;
- test harness.

Update canonical Onboarding/archive-environment docs.

Update Feature 28 index/documentation log.

Update version/changelog according to repository rules.

# Verification

Run:

- installation classifier tests;
- archive environment tests;
- Onboarding snapshot/readiness tests;
- database lifecycle tests;
- reset/rotation tests;
- source immutability tests;
- mutation coordinator tests;
- Historical Archives regressions;
- attachment archive tests;
- overlay tests;
- architecture tripwires;
- full Flutter suite;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build.

Commit and push if clean.

# Stop conditions

STOP before destructive implementation if:

- attachment archive may contain unique value and cannot be preserved safely;
- user-authored overlays cannot be preserved or clearly authorized for deletion;
- active environment cannot be switched atomically/recoverably;
- database consumers cannot be reliably closed;
- reset requires schema migration;
- legacy incomplete state cannot be distinguished safely from completed state.

Do not make “Start Fresh” mean “hope this directory was disposable.”

# Final report

Report:

- final typed installation states;
- exact completion/resumability evidence;
- full artifact ownership table;
- attachment preservation decision;
- overlay preservation decision;
- reset vs archive-rotation architecture;
- old no-op control disposition;
- exact Start Fresh workflow;
- interruption recovery;
- virgin-state verification;
- tester migration experience;
- tests/tripwires;
- full verification;
- commit hash;
- whether Start Fresh is ready for local manual validation;
- recommended next Feature 28 slice.

Acceptance standard:

> A person with an abandoned MessageLens installation must be able to return to a known-clean Onboarding state without understanding the filesystem and without risking Messages, Contacts, attachments, or user-created MessageLens information. “Fresh” must be a mechanically verified installation state, not a folder-deletion recipe.
