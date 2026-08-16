Yes. I’d make this a **branch-and-documentation transition only**. No archive inspection yet; the next prompt can begin the read-only forensic inventory from a clean emergency branch.

### Prompt for Codex — Suspend Feature 25 and Start Production Archive Recovery

Suspend the current Presence Guidebook Lifecycle work cleanly and create a new branch and Feature Addition package for the higher-priority **Production Archive Recovery** task.

**This prompt is authorization to update documentation and perform the Git operations described below. Do not stop to ask for plan confirmation.**

Do **not** begin archive investigation or recovery implementation in this task.

Do **not** merge the suspended guidebook-lifecycle branch into `main`.

The goal is:

```text
Ftr.gdbk-lifecycle
    -> document suspension
    -> commit
    -> push
    -> leave parked and unmerged

main
    -> update safely

new emergency branch
    -> Ftr.archive-recovery
    -> create new Feature Addition folder
    -> establish scope/safety rules
    -> STOP
```

## 1. Verify starting state

Confirm:

- current repository;
- current branch;
- worktree status.

The expected current branch is:

```text
Ftr.gdbk-lifecycle
```

Use Git’s actual spelling/case if it differs.

Do not discard, reset, or stash away intended work.

If there are unexpected unrelated uncommitted changes, inspect them and preserve them. Do not silently delete anything.

---

## 2. Create the Feature 25 suspension handoff

In:

```text
_AGENT_INSTRUCTIONS/
  agent-per-project/
    45-NEW-FEATURE-ADDITION/
      25-PRESENCE-GUIDEBOOK-LIFECYCLE/
```

create:

```text
03-FEATURE-SUSPENSION-HANDOFF.md
```

This is a **suspension**, not an abandonment or supersession.

Record briefly and clearly:

### Current status

Feature 25 has established and accepted the architecture that:

- `presence.db` is a replaceable Presence guidebook plus generation-local execution state;
- same-guidebook-generation runs/checkpoints/trace may remain durable;
- a future guidebook-generation replacement may discard the whole Presence database and begin fresh;
- durable human intent belongs to its owning domain rather than being preserved merely as Presence geometry;
- runtime `presence.db` is intended to become the sole installed guidebook authority;
- Onboarding and other consumers should provide domain Agents/capabilities rather than owning Schedule/Trip/Step geometry.

### Work completed

Reference:

```text
00-START-HERE.md
01-PRESENCE-GUIDEBOOK-LIFECYCLE-ARCHITECTURE-AUDIT.md
```

The architecture audit concluded that all current `presence.db` content is safely replaceable at a guidebook-generation boundary.

### Intended next work when resumed

The next planned implementation remains the first recommended Feature 25 slice:

> Establish a deterministic, side-effect-free Presence guidebook catalog contract and validator as scaffolding for fresh installation.

No guidebook installation, replacement, serialization, or database recreation has yet been implemented.

### Important historical warning

Do not resume by implementing the old tactical Step-6302 reconciliation/migration idea.

The Step-6302 conflict was evidence that motivated the replaceable-guidebook lifecycle.

### Reason for suspension

Feature 25 is being temporarily suspended because a higher-priority production-data recovery task has become urgent:

> Safely recover historical Messages records and preserved archived image attachments from a saved March 2026 MessageLens Application Support data folder into the current MessageLens production data folder.

Feature 25 should later resume from its current accepted architecture.

---

## 3. Update Feature 25 navigation

Update, as appropriate:

- `25-PRESENCE-GUIDEBOOK-LIFECYCLE/00-START-HERE.md`
- Feature Addition `INDEX.md`
- `DOCUMENTATION_PASS_LOG.md`

Mark Feature 25 as:

```text
SUSPENDED — architecture retained; implementation to resume later
```

Do not rewrite the architecture audit.

Do not create additional implementation plans.

---

## 4. Verify before parking the branch

Run:

```text
git diff --check
```

and the lightweight documentation/architecture checks normally appropriate.

There is no need for a full application test suite unless repository policy requires it for documentation-only changes.

Inspect the diff.

---

## 5. Commit and push `Ftr.gdbk-lifecycle`

Stage all intended current changes on this branch.

Do not stage:

- ignored build output;
- credentials/secrets;
- accidental generated artifacts contrary to repository policy.

Create a clear suspension commit, conceptually:

```text
Suspend Presence guidebook lifecycle for archive recovery priority
```

Use repository commit conventions if they prescribe something different.

Push the existing branch to its upstream.

Do not force-push.

Record the resulting commit hash.

---

## 6. Do NOT merge Feature 25 to main

This is deliberate.

`Ftr.gdbk-lifecycle` contains incomplete feature work and should remain parked on its remote branch.

Do not merge it into `main`.

Do not cherry-pick its Feature 25 documentation into `main` as part of this task.

Its branch is the durable checkpoint from which Feature 25 will later resume.

---

## 7. Return to clean `main`

After the Feature 25 push succeeds:

```bash
git switch main
git fetch
git pull --ff-only
```

Use the repository’s normal safe equivalent if required.

Do not rebase or rewrite published history.

Confirm `main` is clean before creating the emergency branch.

If switching reveals merge conflicts or an unexpected divergence, stop and report rather than guessing.

---

## 8. Create the emergency branch

Create:

```text
Ftr.archive-recovery
```

from the updated `main`.

Then push and establish upstream tracking:

```bash
git push -u origin Ftr.archive-recovery
```

The new archive-recovery work must therefore **not inherit unfinished Feature 25 changes**.

---

## 9. Allocate the new Feature Addition folder

Inspect the existing directories under:

```text
45-NEW-FEATURE-ADDITION/
```

Do not assume `26-` is free.

If `26` is free, create:

```text
26-PRODUCTION-ARCHIVE-RECOVERY/
```

If `26` is occupied, use the **next free numeric prefix** and proceed without asking for confirmation.

The feature name should remain:

```text
PRODUCTION-ARCHIVE-RECOVERY
```

Do not call it generic Archive Ingestion.

This task is intentionally narrower.

---

## 10. Create only the initial feature scaffold

Inside the new feature folder create:

```text
00-START-HERE.md
```

Do **not** create the forensic inventory document yet.

That will be the next task.

The start page should establish the emergency objective:

> Safely make the current production MessageLens archive contain everything valuable preserved in the March 2026 MessageLens Application Support archive, especially historical Messages records and preserved archived image attachment payloads.

### Immediate priority

The March 2026 saved MessageLens folder contains both:

- historical Messages data reaching farther back than the current production archive, including records ultimately dating back to approximately 2011; and
- archived image attachment payloads preserved before Apple later evicted some local originals to iCloud.

Therefore recovering that March archive is the immediate priority.

The first recovery effort is for **this known donor archive and this known current production archive**.

Do not generalize it into a product feature for other users yet.

---

## 11. Put the safety invariant at the top

The start page must state prominently:

> **The March 2026 MessageLens archive is a read-only donor. The current MessageLens archive is production. The initial investigation is read-only and authorizes mutation of neither.**

Also state:

> **Archived attachment payloads are preservation data and must be treated like gold.**

No recovery operation may casually overwrite, delete, normalize, regenerate, relocate, or otherwise mutate archived payloads.

Any eventual collision where two files claim the same logical destination but differ in bytes must be surfaced explicitly rather than silently overwritten.

---

## 12. Establish the initial scope

The first investigative question for the next task will be:

```text
What exactly exists in the March 2026 donor archive,
what exists in the current production archive,
how do they overlap,
and what is the safest one-way union seam?
```

The first investigation will need to determine things such as:

- database files present in each archive;
- which stores contain the historical message facts we need;
- date ranges and approximate record counts;
- attachment archive structure;
- attachment identity/linkage;
- overlap with the current archive;
- which stores are authoritative/preservation data;
- which stores are safely rebuildable;
- what existing ingestion/import code may already be useful.

But **do not perform that investigation in this task**.

---

## 13. Explicitly defer general archive-ingestion product work

Record:

```text
FIRST
    recover the known March 2026 archive safely into the current production archive

LATER
    use that experience as evidence for a generalized archive-ingestion feature
```

Do not design:

- public archive-import UI;
- generalized archive discovery;
- arbitrary historical-folder ingestion;
- multi-user workflows;
- migration wizards.

---

## 14. Register the new feature

Update on `Ftr.archive-recovery`:

- Feature Addition `INDEX.md`
- `DOCUMENTATION_PASS_LOG.md`

Register the new feature folder and state that its first operative task is a **read-only donor/current archive inventory**.

Do not alter Feature 25 documentation from this new branch; Feature 25 remains parked on its own branch.

---

## 15. Commit the new branch scaffold

Run:

```text
git diff --check
```

Review the new documentation.

Commit the Feature Addition scaffold with a clear message, conceptually:

```text
Start production archive recovery feature
```

Push `Ftr.archive-recovery`.

Do not begin inventory work after the commit.

---

# Hard constraints

Do not:

- merge `Ftr.gdbk-lifecycle` into `main`;
- abandon or delete `Ftr.gdbk-lifecycle`;
- implement Presence guidebook lifecycle work;
- inspect or mutate `presence.db` as part of this task;
- begin archive inventory;
- read or modify the March donor archive;
- read or modify the current production archive for recovery purposes;
- write recovery scripts;
- copy attachment files;
- merge databases;
- generalize this into a user-facing archive-ingestion feature;
- alter archived attachment payloads;
- discard existing branch work;
- force-push or rebase published history.

If Git conflicts or unexpected branch divergence occur, stop and report rather than resolving speculatively.

# Success criterion

End with:

```text
Ftr.gdbk-lifecycle
    suspended cleanly
    suspension documented
    committed
    pushed
    NOT merged

main
    unchanged except for work already legitimately present there
    current and clean

Ftr.archive-recovery
    created from current main
    pushed with upstream

<next-free-number>-PRODUCTION-ARCHIVE-RECOVERY/
    00-START-HERE.md
```

And explicitly report:

```text
Feature 25 suspension commit:
Feature 25 push:
main base commit:
new archive branch:
new branch upstream:
allocated Feature Addition number:
archive-recovery scaffold commit:
final git status:
```

Then **STOP**.

The next task will begin the actual emergency work with a **strictly read-only forensic inventory of the March 2026 donor archive and the current production MessageLens archive**.