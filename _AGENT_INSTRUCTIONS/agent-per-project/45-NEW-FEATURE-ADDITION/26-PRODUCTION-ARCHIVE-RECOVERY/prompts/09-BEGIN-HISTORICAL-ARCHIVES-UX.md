Work on branch Ftr.archive-recovery.

Historical Archives execution mechanics have now been manually validated on the disposable staging archive:

- historical source removal works;
- source-1/current history remains intact;
- corrected maintenance handling no longer diverts the user into Onboarding;
- historical reimport works;
- Apple timestamps are correct through DateConverter;
- restart against the intended staging archive opens normal MessageLens with history beginning July 2012.

Do not revisit those mechanics unless this task uncovers a concrete presentation dependency.

The next Feature 26 concern is the Historical Archives user experience.

This task is DESIGN/AUDIT ONLY. Do not implement the redesign yet.

Read the current Feature 26 responses, especially the import/removal audits and the current Historical Archives implementation.

GOAL

Replace the current “large control panel containing everything the system knows” interaction model with a new MessageLens interaction grammar:

NARRATOR + DIRECTED INSTRUMENTATION

These terms are intentional.

NARRATOR

The Narrator provides meaning, orientation, transitions, and decisions.

It should speak briefly at meaningful boundaries, for example:

“Let’s see what’s in this Messages folder.”

or:

“Good. This archive can extend your history back to July 2012.”

The Narrator must NOT become a stream of reassurance.

Avoid:

“I’ve got you.”
“Everything is going well.”
“Still working.”
“Don’t worry.”

repeated throughout an operation.

The Narrator should appear, say what the next phase means, and then get out of the way.

DIRECTED INSTRUMENTATION

Directed Instrumentation exposes a small number of real system facts or real pieces of work at the moment they are useful.

Conceptually:

MESSAGES ARCHIVE

Folder access ✓
Messages database ✓
8,882 messages found ✓
July 2012 → June 2017 ✓

These are not decorative science-fiction effects and not fake progress.

Every displayed item must correspond to an actual check, operation, or completed piece of work.

The instrumentation should give the user confidence through evidence rather than through repeated reassurance.

CORE INTERACTION RULES

1. The human makes decisions; the human does not advance the workflow.

Do not create a Next / Next / Next wizard.

If MessageLens knows the next safe action, it should proceed automatically.

A button should appear only when the human genuinely owns a decision, permission boundary, destructive choice, ambiguity, retry, or cancellation.

2. Narration is for transitions.

Use prose when the meaning of the task changes.

3. Instrumentation is for work and waiting.

While MessageLens is doing known work, show small real task panels rather than a spinner or generic progress bar.

4. Choice is for actual human decisions.

Examples:

- choose a Messages folder;
- begin importing after reviewing what was found;
- remove an already imported historical source;
- retry after a genuine failure.

5. Success must be unmistakable.

The user should never have to scroll down to discover that an import completed.

6. Do not show developer diagnostics by default.

Terms such as graph projection, provider invalidation, source registry, mutation authority, ss_id, etc. belong behind a disclosure or diagnostic surface unless they are genuinely necessary to explain a problem.

7. Do not hide useful truth merely to make the interface calm.

The goal is not minimal information.

The goal is small amounts of meaningful information at the right moment.

8. No fake percentages.

Prefer real completed work:

Reading archive ✓
Adding messages ✓
Preparing conversations ✓
Updating search and heatmap …

rather than “63% complete” unless the underlying operation genuinely provides meaningful measurable progress.

9. No long-lived generic spinner saying “Your data is being imported.”

Break work into the actual coarse tasks the app performs.

10. Preserve automatic flow.

Once the user authorizes import, MessageLens should run through all non-decision stages without requiring further clicks.

CURRENT UX PROBLEMS TO ADDRESS

The present Historical Archives surface is well organized but too information-dense.

Observed problems include:

- the page extends far beyond the visible window;
- important success state can occur below the fold;
- the user must synthesize many status boxes, preflight facts, dry-run facts, progress rows, activity log entries, and result summaries;
- the selected donor remains visible after source removal, which is technically coherent but may not match the human expectation of starting fresh;
- execution-state meaning is mixed with diagnostics and source metadata;
- the user can have difficulty determining what action is currently expected.

Do not assume every current field should remain in the primary journey.

CURRENT INFORMATION MUST NOT BE LOST

Inventory all information currently shown by Historical Archives and classify each item as one of:

A. Primary journey
The user needs this now.

B. Directed instrumentation
Useful while a particular check or operation is occurring.

C. Decision evidence
Needed before a consequential human action.

D. Completion evidence
Useful after success.

E. Details / diagnostics
Useful on demand but not in the normal journey.

F. Developer-only
Should not normally be shown to an ordinary user.

Do this classification before proposing widgets.

DESIGN THE HUMAN JOURNEY

Map the complete Historical Archives lifecycle from:

- no folder selected;
- choosing a folder;
- source inspection/preflight;
- archive understood and ready;
- import authorization;
- import running;
- import success;
- already-imported archive;
- archive removal authorization;
- archive removal running;
- removal success;
- retryable failure;
- non-retryable/diagnostic failure.

For each state specify:

- what the Narrator says, if anything;
- what Directed Instrumentation is visible;
- what actual facts drive each instrument;
- whether a human decision is required;
- what controls are present;
- what happens automatically next;
- what information is hidden behind Details;
- what should remain visible above the fold.

Do not write polished final marketing copy yet. Use representative plain-English copy sufficient to establish tone and information hierarchy.

PROPOSE A SMALL VISUAL GRAMMAR

Define a reusable but modest presentation vocabulary, for example:

- Narrator card / transition statement;
- instrumentation tableau;
- resolved check row;
- active work row;
- warning/failure row;
- decision card;
- completion card;
- Details disclosure.

Do not invent a generic application-wide framework unless the Historical Archives evidence actually earns it.

This task should design Historical Archives first.

If the resulting vocabulary later proves reusable by Onboarding or other workflows, that can be extracted later.

IMPORTANT TONE

This should feel competent, calm, and slightly futuristic because the user can see the machine doing real work.

It must not feel:

- chatty;
- cute;
- theatrical;
- like a terminal emulator;
- like fake “hacker” animation;
- like a corporate wizard;
- like a Vegas slot machine requiring constant button presses.

A useful summary is:

Narrator provides meaning.
Directed Instrumentation provides evidence.
The human provides decisions.
MessageLens provides momentum.

ARCHITECTURAL CONSTRAINTS

Do not change:

- Historical Archives import/removal semantics;
- source-scoped identity;
- archive mutation authority;
- DateConverter behavior;
- graph projection;
- attachment archival;
- source registration;
- OnboardingGate;
- database schema;
- archive data.

Do not perform any GUI archive mutation.

This is presentation/workflow design only.

DELIVERABLE

Create:

responses/10-HISTORICAL-ARCHIVES-NARRATOR-DIRECTED-INSTRUMENTATION-DESIGN.md

The document should contain:

1. current information inventory and classification;
2. current interaction problems;
3. Narrator + Directed Instrumentation principles;
4. complete Historical Archives state journey;
5. proposed primary-screen hierarchy for each major state;
6. what moves behind Details;
7. real underlying facts backing each instrument;
8. automatic-transition versus human-decision boundaries;
9. failure/retry behavior;
10. low-fidelity textual mockups for the most important states;
11. smallest safe implementation slices;
12. explicit non-goals.

For the implementation slicing, prefer something like:

Slice 1 — introduce the new presentation/state composition without changing execution;
Slice 2 — preflight/ready journey;
Slice 3 — running instrumentation;
Slice 4 — completion/removal states;
Slice 5 — details/diagnostics cleanup.

But derive the actual slices from the current code rather than forcing this structure.

Also identify which current widgets/models can be reused and which are presentation debt that should disappear.

Run only non-mutating analysis and git diff --check.

STOP after the design document.

Do not implement the redesign yet.

Report back with:

- the proposed interaction sequence;
- the primary Narrator/Instrumentation rhythm;
- the major information that moves out of the default view;
- the proposed implementation slices;
- any architectural obstacle that would prevent truthful real-time instrumentation.

That should give us something much more useful than a visual mockup: a **behavioral specification** for the first real Narrator + Directed Instrumentation experience.
