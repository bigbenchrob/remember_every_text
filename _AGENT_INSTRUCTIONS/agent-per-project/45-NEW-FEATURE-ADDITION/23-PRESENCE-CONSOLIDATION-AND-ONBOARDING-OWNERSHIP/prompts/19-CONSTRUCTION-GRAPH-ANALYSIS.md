Here is the next Codex assignment: **analysis only**, focused on the initial import/graph-build lifecycle as it really exists today.

Perform an **analysis-only audit** of the initial import / Conversation Graph construction lifecycle that follows the accepted-readiness handoff.

Read first:

- `19-POST-READINESS-ONBOARDING-HANDOFF-AUDIT.md`
- `20-DURABLE-ACCEPTED-READINESS-IMPORT-HANDOFF-IMPLEMENTATION.md`
- current `OnboardingGate`
- `EnvironmentReadinessActions.startImportAndGraphBuild()`
- `ArchiveMutationCoordinator`
- `MessageDataResetService`
- `ConversationGraphBuildController`
- `ConversationGraphBuildOrchestrator`
- current initial-import / graph-build presentation
- failure/recovery storage
- any current documentation describing first-run import, graph construction, abort, recovery, and completion

Use current code as source of truth.

Do not implement code.

Do not change Presence.

Do not invent `ActionStep`.

Do not redesign UI.

The purpose of this audit is to establish the **smallest truthful operational model** for the long-running initial setup that begins when the human presses:

```text
Import My Messages
```

and ends when MessageLens is ready for ordinary use or has failed/recovered.

---

# 1. Trace the exact operation from the button press

Start at the real production action:

```text
EnvironmentReadinessActions.startImportAndGraphBuild()
    -> OnboardingGate.startImportAndGraphBuild()
```

Trace every meaningful call from there through success or failure.

Document the exact order of:

- pre-mutation checks;
- mutation admission;
- data reset;
- import;
- graph projection;
- status changes;
- success handling;
- failure handling;
- completion presentation.

Name the actual classes/providers/methods.

Do not summarize several distinct operations as “import.”

---

# 2. Identify the real operation boundary

Answer:

> What is the smallest real unit that the application treats as one initial-setup operation?

The previous audit found that source import and graph projection are currently one `ConversationGraphBuildController.runOnce()` lifecycle.

Verify that from code.

Determine whether the true unit is conceptually:

```text
reset
+
source import
+
graph projection
```

or whether reset is a separate admitted precondition followed by one build operation.

State clearly which parts are one operation and which are preparatory/recovery work.

---

# 3. Inventory every currently observable phase

List all phases that exist in code, even if they are not exposed live to the UI.

For each phase, record:

```text
name
owner
durable mutation?
live progress exposed?
failure boundary?
restart behavior?
```

Pay special attention to the orchestrator stages such as:

```text
import_chats
import_handles
import_contacts
import_messages
enrich_missing_text
import_attachments
...
project_handles
project_contacts
...
```

Verify actual current stage names from code.

Do not assume older documentation is current.

---

# 4. Distinguish operational truth from presentation fiction

Audit the current UI/status model.

The prior audit found:

```text
OnboardingStatus.importing
OnboardingStatus.buildingGraph
```

may imply two separate operations even though one controller lifecycle owns the real work.

Verify this precisely.

For every displayed status, answer:

- what actual code is running at that moment;
- whether the label is literally true;
- whether it is merely a coarse approximation;
- whether the UI can know more from current APIs.

Flag any status wording that is misleading.

Do not rewrite the copy yet.

---

# 5. Audit progress information that already exists

Determine exactly what progress information is available today.

Check:

- `ConversationGraphBuildState`;
- orchestrator stage names;
- stage start/end timestamps;
- counts, row totals, or percentages;
- import ledger data;
- log output;
- final `ConversationGraphBuildReport`;
- any streams/notifiers/callbacks emitted during execution.

Classify each as:

```text
live and consumable by UI
live but internal
available only after completion
durable
ephemeral
```

Answer this specifically:

> Could production UI today truthfully show “Importing messages”, “Importing attachments”, “Building conversations”, etc. without modifying the operation layer?

If no, state exactly what missing live seam would be required.

---

# 6. Audit the current “Abort Import” behavior

This is important.

Trace exactly what happens when the human presses:

```text
Abort Import
```

Answer:

- Does it signal cancellation to the active controller?
- Does the active operation stop?
- Does it merely trigger cleanup/reset?
- Can cleanup race with still-running import/build work?
- Is the control currently semantically truthful?
- What happens after abort?
- What happens if the process exits during or immediately after abort?

Do not fix it in this audit.

If the label is materially misleading, say so directly.

---

# 7. Failure semantics

Trace all failure paths.

For each:

- where exception/error originates;
- where it is caught;
- what state is persisted;
- what partial durable output may remain;
- what the next launch sees;
- whether retry means resume or clean restart;
- whether cleanup is automatic.

Distinguish:

```text
caught failure
abrupt process termination
database corruption / partial stores
permission failure during operation
```

if these are separate realities.

---

# 8. Restart semantics

Create a restart table for at least:

```text
before reset
during reset
after reset / before build
during import
during graph projection
after build success / before final completion UI
after caught failure
during recovery cleanup
```

For each, identify:

```text
durable authority
what gets reconstructed
whether work resumes
whether work restarts
whether cleanup occurs
what the human sees
```

Do not invent operation checkpointing.

Document what actually happens today.

---

# 9. Inspect durable evidence already available

Identify all durable artifacts that can tell startup what happened:

- import ledger;
- graph database existence/state;
- schema/version markers;
- readiness probes;
- failure store;
- Presence run completion;
- filesystem state.

For each, say what it can and cannot prove.

The goal is to understand whether a durable job-state abstraction is actually necessary or whether current derived-state probing is intentional and sufficient.

---

# 10. Define the honest user-facing story

Without designing widgets, describe the smallest truthful narrative the app can currently support.

For example, it might be:

```text
Preparing MessageLens
    -> Building local message data
    -> Finishing setup
```

or something more detailed.

But derive this from actual operation observability.

Answer:

> What can we truthfully tell the human while work is happening today?

and separately:

> What would we like to tell them but cannot yet support from live operation facts?

This distinction matters.

---

# 11. Evaluate the “I’ve got you” requirement

The desired production experience during major data work is calm, low-noise, and reassuring.

Evaluate what that means architecturally, not aesthetically.

Consider whether the UI needs:

- percentage;
- current stage;
- elapsed time;
- activity indicator only;
- explanation of what is safe to do;
- warning not to quit;
- explicit “you can leave this running” reassurance;
- cancel/abort affordance;
- retry affordance.

For each, classify:

```text
supported by current operation semantics
unsupported
actively misleading
```

Do not design the screen.

---

# 12. Revisit whether “Abort Import” should exist

Based on actual cancellation semantics, conclude one of:

```text
Abort is currently truthful and should remain.
```

```text
Abort is not a real cancellation and should be renamed/reframed.
```

```text
A real cancellation mechanism is required before offering Abort.
```

Do not implement it.

Explain the operational reason.

---

# 13. Determine the first smallest implementation slice

Recommend exactly **one** next implementation slice.

Candidates may include, if supported by evidence:

- expose live stage identity from the existing orchestrator;
- simplify progress UI to match existing coarse truth;
- remove/rename misleading Abort behavior;
- add a proper cancellation seam;
- make failure/retry presentation truthful;
- add a durable operation-state record;
- something else discovered in code.

Do not recommend several slices at once.

Use this format:

```text
Next concern:
Why it comes next:
Current defect:
Smallest implementation:
Owner:
Persistence impact:
Restart impact:
Presentation impact:
Test seam:
```

---

# 14. Explicitly assess whether a generic operation Step is earned

Compare this lifecycle again with `OpenFdaSettingsStep`.

Conclude one of:

```text
Generic operation Step still NOT earned.
```

or:

```text
A generic operation Step is now earned because...
```

If earned, identify the exact shared mechanical contract.

Do not use vague similarities like “both do work.”

Compare:

- start semantics;
- awaited completion;
- progress;
- mutation;
- restart;
- failure;
- cancellation;
- result;
- fresh verification after completion.

---

# 15. Audit whether this belongs in Presence at all

Answer separately:

> Should Presence eventually own the user-facing sequence around this operation?

and:

> Should Presence own the operation itself?

These may have different answers.

For example:

```text
Presence may own:
    Tell / Choice / completion sequence

OnboardingGate / specialists may still own:
    destructive admitted operation
```

Do not collapse workflow ownership and operational ownership.

---

# 16. Produce a concrete lifecycle diagram

Include one compact diagram from:

```text
Import My Messages
```

through:

```text
success -> ordinary MessageLens
failure -> retry/recovery
```

Show ownership boundaries among:

```text
Environment Readiness
OnboardingGate
ArchiveMutationCoordinator
MessageDataResetService
ConversationGraphBuildController
ConversationGraphBuildOrchestrator
source-import specialists
Conversation Graph specialists
failure/recovery store
```

Mark which states are durable and which are in-memory.

---

# 17. Documentation output

Create:

`21-INITIAL-IMPORT-GRAPH-BUILD-LIFECYCLE-AUDIT.md`

Include:

1. exact execution path;
2. real operation boundary;
3. phase inventory;
4. presentation-vs-operation truth audit;
5. progress-data inventory;
6. Abort behavior;
7. failure semantics;
8. restart table;
9. durable evidence inventory;
10. truthful user-facing narrative;
11. “I’ve got you” requirements supported/unsupported;
12. one next implementation slice;
13. generic operation-Step verdict;
14. Presence-vs-operation ownership conclusion;
15. lifecycle diagram.

Update:

- `00-START-HERE.md`
- package index
- `DOCUMENTATION_PASS_LOG.md`

Do not alter application code.

---

# Hard constraints

Do not:

- implement anything;
- change UI;
- change import logic;
- add cancellation;
- add progress events;
- add schema;
- add durable job state;
- change Presence;
- add ActionStep;
- refactor `OnboardingGate`;
- rename user-facing copy in code;
- change recovery;
- change failure handling.

This is an evidence-gathering pass only.

---

# Success criterion

At the end of the audit, we should be able to answer:

> **The first production defect in the import/graph-build lifecycle is **\_\_\_\_**, and the smallest truthful next implementation is **\_\_\_\_**.**

We should also know whether the calm production experience can be built from current operation facts or whether one small missing operation-observability seam must be added first.

Stop after the audit and report back before implementation.

This should tell us whether the next job is primarily presentation cleanup or whether the operation layer is currently too opaque to support the calm progress experience properly.
