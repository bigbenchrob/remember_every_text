Agreed. This is an excellent branch boundary: finish `Ftr.prov-rules` with a document that explains **why we are stopping**, commit the entire current state, merge it to `main`, then create `Ftr.gdbk-lifecycle` from that clean baseline. The new branch begins with the new feature folder rather than inheriting another implementation slice inside 23.

Here is the handoff prompt. I have included the Git transition as the **final act of this task**, after the handoff documentation and verification are complete.

Create the closing architectural handoff from the current Presence/Onboarding consolidation work into a new **Presence Guidebook Lifecycle** feature.

**This prompt is authorization to update documentation and, after verification, perform the Git commit/push/merge/branch transition described below. Do not stop to ask for plan confirmation.**

This is **not** authorization to implement the new guidebook lifecycle architecture yet.

Do **not** implement the previously proposed Step-6302 migration/reconciliation fix.

The observed Step-6302 failure has caused us to reconsider the premise behind runtime definition reconciliation itself.

---

# 1. Create the handoff document

In:

`45-NEW-FEATURE-ADDITION/23-PRESENCE-CONSOLIDATION-AND-ONBOARDING-OWNERSHIP/`

create:

`57-PRESENCE-GUIDEBOOK-LIFECYCLE-HANDOFF.md`

This should close the current feature-addition package conceptually and hand the next architectural question to a new sibling feature folder that will be created on the next branch.

Do not design the complete new architecture in this document.

Its job is to record:

```text
what we observed
what assumption that observation challenged
what principles are now agreed
what work is explicitly stopped
what questions move to the next feature
```

---

# 2. Record the concrete production observation

Document the manual production-shaped onboarding failure:

```text
Unable to continue setup:
Bad state: Existing Step 6302 in Trip TripDefinitionId(303)
cannot be redefined.
```

Record that this was observed only after Validation 54 corrected normal debug launches to use the **real production-shaped onboarding route**, rather than the Presence development harness.

This was therefore useful production evidence, not a laboratory-harness artifact.

Do not attempt to solve Step 6302 in this document.

---

# 3. Record why the previous Step-6302 fix is deliberately stopped

A previous proposed implementation direction treated the problem as:

```text
old persisted Step 6302
versus
new authored Step 6302

-> reconcile identities
-> allocate new IDs if meaning changed
-> preserve historical definitions
```

That work is now **superseded pending the new lifecycle design**.

The manual failure exposed a more fundamental question:

> Why is production runtime reconciling a second Dart-authored representation of the guidebook against `presence.db` at all?

Do not implement new Step IDs, definition revisions, or migration machinery as part of this handoff.

Do not weaken current immutability checks either.

The present blocker should remain documented as evidence motivating the new feature.

---

# 4. Record the corrected mental model

The agreed direction is:

> **Presence is a guidebook.**

`presence.db` may contain both:

```text
THE CURRENT GUIDEBOOK EDITION
    Schedule definitions
    Trip definitions
    Step definitions
    Tell text
    Agent IDs
    Choice options
    routing
    occurrences

CONVENIENT STATE WHILE USING THAT EDITION
    current Schedule run
    current Trip checkpoint
    completion
    execution trace
    other Presence-local runtime state
```

Within a single installed guidebook generation, that database may behave as ordinary durable state.

Quitting and reopening the same MessageLens version may resume from the Presence state stored there.

That is useful and should not be confused with cross-version preservation.

---

# 5. Record the crucial generation boundary

The newly agreed principle is:

> **Presence state may be durable within one guidebook generation and disposable when the guidebook generation changes.**

Conceptually:

```text
same guidebook generation
    -> keep presence.db
    -> resume normally

new guidebook generation
    -> old Presence guidebook/state may be discarded wholesale
    -> create the current Presence database
    -> install the current guidebook edition
    -> begin fresh
```

It is acceptable for a MessageLens software upgrade to lose:

```text
current Presence Trip
unfinished Presence Schedule
completed Presence Schedule
Presence execution trace
old readiness-guide position
```

because those describe the person's position in an obsolete edition of the guidebook.

Do not introduce migration machinery merely to preserve those facts.

---

# 6. Record the fresh-install problem

A new user's Application Support data folder is created de novo.

Drift can create the physical `presence.db` schema, but the database still needs its application-supplied content:

```text
Schedules
Trips
Steps
occurrences
Tell text
Agent IDs
Choice configuration
routes
```

There is no external authoritative database analogous to Apple Messages or Contacts from which this content can be imported.

Therefore the next feature must determine how MessageLens ships and installs the **current Presence guidebook catalog** into a fresh `presence.db`.

Do not choose the serialization/authoring format in this handoff.

Possible implementation forms such as:

```text
JSON
Dart data
SQL
another serialized catalog
```

remain open.

---

# 7. Record the upgrade simplification

The direction under consideration is intentionally much simpler than per-version workflow migrations.

Reject as the starting assumption:

```text
version 1 -> update these Steps
version 1.5 -> update these other Trips
version 2 -> move these occurrences
...
```

Instead, investigate a generation model conceptually like:

```text
installed guidebook generation == application guidebook generation
    -> use existing presence.db

generation differs / database absent
    -> replace Presence database/catalog wholesale
    -> install current edition
```

The new feature must determine the exact database-lifecycle mechanism and safety rules.

The handoff should record this direction without prematurely implementing it.

---

# 8. Record the runtime source-of-truth principle

The desired runtime model is:

```text
presence.db
    -> sole runtime authority for guidebook geometry/content

Presence
    -> reads Schedule
    -> reads Trips
    -> reads Steps
    -> executes what the database says
```

Runtime should not need a second complete authored Schedule object merely to ask:

```text
"Does Step 6302 still contain the same text?"
```

For example:

```text
Presence asks:
    What does Step 4242 say?

presence.db answers:
    whatever the current installed record says
```

The next feature should investigate how to remove runtime definition reconciliation while retaining a clean installation/authoring boundary.

---

# 9. Restore the “poor Onboarding” ownership principle

Record explicitly that the desired end-state returns to the established blank-stare architecture.

Onboarding should own domain expertise such as:

```text
onboarding.messages-source-readable
onboarding.messages-source-access-denied
onboarding.messages-source-history-sufficient
Contacts readiness
other onboarding-specific facts/actions
```

Onboarding should **not need runtime knowledge of**:

```text
Schedule IDs
Trip IDs
Step IDs
Step text
occurrence positions
routing geometry
ChoiceStep placement
```

Conceptually:

```text
Presence
    reads guidebook
    encounters opaque Agent ID
        |
        v
Agent resolver
        |
        v
Onboarding specialist
    answers the domain question
```

Ask Onboarding:

> What is Step 6302?

Desired answer:

> Blank stare.

Ask Onboarding:

> Can the Messages source currently be read?

That is its business.

---

# 10. Record the durable-user-intent distinction

Do **not** move Presence run/checkpoint machinery into `overlay.db`.

Instead record this rule:

> Durable meaning should survive a guidebook replacement only when that meaning matters independently of the Presence geometry that elicited it.

Example of Presence-local disposable state:

```text
user is currently at Trip 308
Schedule 6 completed
ChoiceStep 6903 was previously displayed
```

Example of genuinely durable user intent:

```text
"I prefer detailed step-by-step guidance."

versus

"Take care of most of it for me."
```

That preference remains meaningful even if every Presence Schedule/Trip/Step ID changes tomorrow.

Such durable semantic preference may appropriately belong in `overlay.db` or another domain-owned durable store.

The important test is:

> **Would this fact still mean something if the entire Presence guidebook were replaced tomorrow?**

If yes, it may deserve durable domain storage.

If no, Presence-local persistence is sufficient.

Do not introduce new Overlay fields in this handoff.

---

# 11. Record that even current accepted-readiness state may be disposable

The current implementation uses completed Presence Schedule state as durable evidence for some onboarding decisions, including the sparse-history **Import Anyway** route.

Under the new direction, do not assume such Presence completion must survive a software/guidebook upgrade.

If the user upgrades MessageLens before import and is asked a short readiness question again, that may be entirely acceptable.

Do not move this state into Overlay pre-emptively.

Only durable human intent that genuinely deserves survival should be promoted out of Presence.

---

# 12. Record what remains unchanged

This new direction does **not** invalidate the core Presence execution grammar.

Preserve the conceptual model:

```text
Schedule
    ordered batting order of Trip occurrences

Trip
    ordered sequence of Step occurrences

Step
    performs narrow concrete work

Scheduler
    interprets only terminal TripDefinitionId?
```

Also preserve:

- generic `TestStep`;
- opaque `TestAgentId`;
- generic `ChoiceStep`;
- `FixedDestinationStep`;
- Tell presentation;
- Trip-granular restart within one guidebook generation;
- Presence/Onboarding semantic ownership;
- attachment-preservation invariant;
- production Gate → actual Onboarding host boundary.

The new feature concerns **guidebook installation, replacement, lifecycle, and runtime authority**, not a rewrite of Presence grammar.

---

# 13. Close Feature Addition 23 cleanly

Update the package's:

- `00-START-HERE.md`
- package index
- `DOCUMENTATION_PASS_LOG.md`

to say that Feature Addition 23 has reached a natural architectural boundary.

Record that further work on:

```text
Presence guidebook installation
generation/replacement
runtime definition authority
removal of runtime reconciliation
cross-version Presence-state policy
```

has moved to a new feature addition.

Do not create the new folder yet.

That happens in the **next prompt on the new branch**.

Feature 23 may still receive future factual corrections, but it is no longer the working home for this architectural change.

---

# 14. Do not implement the new lifecycle yet

This task must not:

- create a serialized guidebook;
- add a generation field;
- delete/recreate `presence.db`;
- change Drift schema;
- remove runtime reconciliation;
- alter Schedule builders;
- change Onboarding composition;
- add Overlay preferences;
- modify Step immutability;
- fix Step 6302 tactically;
- change production behavior.

This is documentation/handoff plus repository branch transition only.

---

# 15. Verify documentation before Git transition

Before committing:

- inspect the diff;
- ensure the handoff accurately reflects the current agreed direction;
- preserve unrelated current worktree changes because the user explicitly wants **all current changes committed**;
- do not discard/reset/stash away current work;
- run `git diff --check`;
- run any lightweight documentation/index consistency checks normally required by the repository.

Do not run destructive application operations.

---

# 16. Commit all current work on `Ftr.prov-rules`

After the handoff documentation is complete and verified:

1. Confirm the current branch and exact repository status.
2. Confirm the feature branch is the repository's existing branch corresponding to:

```text
Ftr.prov-rules
```

Use the branch's actual case/spelling as Git reports it; do not silently create a similarly named duplicate.

3. Stage **all intended current repository changes**, including the accumulated implementation and documentation work on this feature branch.

Do not stage ignored build products, credentials, secrets, or other files excluded by repository policy.

4. Review staged status/diff sufficiently to ensure no accidental generated/secret material is included.

5. Create one final feature-closing commit with a clear message reflecting the Presence/Onboarding production-readiness work and guidebook-lifecycle handoff.

A concept such as:

```text
Complete Presence onboarding consolidation and hand off guidebook lifecycle
```

is appropriate; follow repository commit conventions if they exist.

6. Push `Ftr.prov-rules` to its existing remote/upstream.

Do not force-push.

---

# 17. Merge the completed feature branch into `main`

After the feature branch push succeeds:

1. Switch to `main`.
2. Fetch the remote.
3. Bring local `main` up to date using the repository's normal safe convention.

Prefer fast-forward-only pull/update where applicable:

```bash
git pull --ff-only
```

Do not rewrite remote `main`.

4. Merge the completed `Ftr.prov-rules` branch into `main`.

Use the repository's established merge convention.

If no convention is documented, prefer a normal feature merge that preserves the feature boundary rather than rebasing published history.

5. If there are merge conflicts, **stop and report the conflicts** rather than making speculative resolutions.

6. After a clean merge, run:

```text
git status
git diff --check
```

and any lightweight repository-required post-merge validation.

7. Push updated `main`.

Do not force-push.

---

# 18. Create the new feature branch

Only after updated `main` has been successfully pushed:

create:

```text
Ftr.gdbk-lifecycle
```

from the updated `main`.

Use that exact name unless Git reveals a repository naming constraint that makes it invalid.

Then push it and establish upstream tracking:

```bash
git push -u origin Ftr.gdbk-lifecycle
```

Do not create the new feature folder yet.

The next prompt will begin the actual feature by creating:

```text
24-PRESENCE-GUIDEBOOK-LIFECYCLE/
```

on this new branch.

---

# 19. Final report

Stop after the new branch has been created and checked out.

Report:

### Documentation

- handoff document created;
- Feature 23 indexes/log updated;
- summary of the architectural handoff.

### Git

Report exact:

```text
closing feature branch:
closing commit:
feature branch push:
main merge commit / fast-forward result:
main push:
new branch:
new branch upstream:
final git status:
```

### Important confirmation

Explicitly confirm:

```text
No guidebook-lifecycle implementation has begun.
No presence.db was deleted or rewritten.
No Step-6302 tactical migration was implemented.
The new branch is based on the merged current main.
```

---

# Hard constraints

Do not:

- implement the new lifecycle;
- implement the previously proposed Step-6302 reconciliation fix;
- delete/reset `presence.db`;
- add workflow migrations;
- modify Overlay schema;
- change Presence runtime;
- change Onboarding runtime;
- discard any current intended worktree changes;
- rebase or force-push published branches;
- guess through merge conflicts;
- create `24-PRESENCE-GUIDEBOOK-LIFECYCLE` before the next prompt.

# Success criterion

We finish this task with:

```text
Feature 23
    documented and closed at its natural boundary
            |
            v
all current Ftr.prov-rules work
    committed and pushed
            |
            v
merged cleanly to main
            |
            v
main pushed
            |
            v
Ftr.gdbk-lifecycle
    created from that exact main
            |
            v
STOP
```

And the handoff leaves one clear architectural question for the new feature:

> **How should MessageLens install and replace Presence as a versioned guidebook whose local execution state is useful within one edition but need not survive replacement by a new edition?**
