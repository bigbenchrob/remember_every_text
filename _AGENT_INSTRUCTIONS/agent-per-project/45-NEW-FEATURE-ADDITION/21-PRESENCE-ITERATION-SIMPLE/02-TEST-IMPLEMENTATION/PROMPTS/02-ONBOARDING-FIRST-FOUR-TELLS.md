Begin the first real onboarding workflow experiment in:

45-NEW-FEATURE-ADDITION/
21-PRESENCE-ITERATION-SIMPLE/
02-TEST-IMPLEMENTATION/

Read first:

- 00-ONBOARDING-STORY.md
- 10-STARTUP-HOOK.md
- the three PRESENCE-ITERATION-SIMPLE root orientation documents
- SYSTEM-BOUNDARIES.md, if present
- the complete working Presence laboratory implementation
- the current Tell Step, JourneyView, JourneyProgress, fixture, host, and tests

This remains implementation-led redesign from first principles.

The historical 43-PRESENCE package is not authoritative.

--------------------------------------------------------------------
Purpose
--------------------------------------------------------------------

Stop developing abstract Presence capabilities.

Use the working system to build the first few seconds of a genuine MessageLens onboarding experience.

This iteration implements only the first four explanatory Tell Steps.

It does not yet implement:

- opening System Settings;
- checking Full Disk Access;
- auditing agents;
- retries;
- import;
- production OnboardingGate integration;
- the complete onboarding Journey.

The current debug-only application path remains the safe real-application test surface.

--------------------------------------------------------------------
User experience
--------------------------------------------------------------------

Replace the current laboratory sequence with this onboarding introduction:

1. Tell

   Welcome to MessageLens.

2. Tell

   Before you get started, I need to make sure I can access the databases on your Mac that store information about your contacts and messages.

3. Tell

   Apple requires you to give MessageLens what it calls Full Disk Access.

   Despite the name, this does not mean MessageLens can simply browse through all of your personal files. As Apple explains:

   “Full Disk Access allows applications to access data like Mail, Messages, Safari, Home, Time Machine backups, and certain administrative settings.”

4. Tell

   I need this access to read your chat database, which stores your messages, and your Address Book database, which lets me match those messages with the people in your contacts.

Preserve the calm, direct, first-person voice.

Do not rewrite this into conventional setup-dialog language.

Do not add headings such as:

- Welcome
- Permissions
- Privacy
- Setup step 1 of 4

The user should experience one thought at a time.

--------------------------------------------------------------------
Transition behaviour
--------------------------------------------------------------------

The first three Tell Steps should advance automatically:

Tell fades in
    -> remains fully visible
    -> fades out
    -> transparent pause
    -> Journey advances
    -> next Tell mounts and fades in

Use the already preferred transition timing:

- fade in: 1 second;
- fade out: 1 second;
- transparent pause: 500 milliseconds.

The visible reading interval is a provisional presentation setting for this experiment.

Use one simple shared hold duration in the Tell presentation code.

Choose a deliberately generous initial value suitable for reading the longest passage, such as 10 seconds.

Do not calculate timing from word count.
Do not add per-Step timing to the database.
Do not create a timing service or presentation policy object.

The purpose is to watch the real experience and tune it afterward.

--------------------------------------------------------------------
Temporary endpoint
--------------------------------------------------------------------

This is only the first part of onboarding.

After the fourth Tell has been presented, do not show the existing laboratory word:

Done

Instead, leave the fourth message visible.

It represents the current edge of the implemented onboarding story.

Do not add:

- Next;
- Continue;
- “To be continued”;
- “Onboarding complete”;
- a fake fifth Step.

The partial Journey must simply remain on Step 4.

Implement the smallest explicit mechanism needed to distinguish:

- an automatically completing Tell;
- the final Tell in this partial experiment, which remains visible.

Do not generalize beyond those two behaviours.

Possible representations may include one minimal Tell presentation field or mode, but every addition must be justified by this exact workflow.

Do not anticipate Action, Audit, Ask, Wait, or future Tell behaviours.

--------------------------------------------------------------------
Data model
--------------------------------------------------------------------

The database remains the source of the Journey definition.

Revise the development fixture so it defines the four onboarding Tell Steps.

Do not hard-code the four messages inside JourneyView or the host.

If automatic-versus-held Tell behaviour must be persisted so the loaded Journey truthfully defines this experience, add only the smallest Tell-specific field required now.

Do not add:

- generic Step configuration;
- JSON;
- metadata;
- action keys;
- auditing keys;
- completion criteria;
- future Step modes;
- per-Step animation durations.

Because the store is still disposable and executor-backed, keep schema version handling consistent with the existing laboratory approach. Do not invent a physical migration.

--------------------------------------------------------------------
Tell component ownership
--------------------------------------------------------------------

TellStepView continues to own Tell presentation.

JourneyView must not regain:

- fade state;
- animation timing;
- automatic timing;
- Next controls;
- Tell completion logic.

TellStepView may:

- display the Tell;
- perform its opening fade;
- hold it visibly;
- perform its closing fade and pause when the Tell is automatic;
- report completion upward;
- remain visible indefinitely when this Tell is the current partial endpoint.

TellStepView must remain ignorant of:

- Journey;
- JourneyProgress;
- sibling Steps;
- whether the Journey represents onboarding;
- Full Disk Access;
- whether another Step exists.

Any automatic/held distinction must arrive through its own Tell data or view model.

--------------------------------------------------------------------
JourneyView ownership
--------------------------------------------------------------------

JourneyView continues to know only:

- the loaded Journey;
- JourneyProgress;
- the current Step;
- which current Step view to construct;
- how to advance after that Step reports completion.

It must not contain onboarding copy or timing logic.

It must not know that Step 4 is special because it discusses databases.

--------------------------------------------------------------------
Host and startup scope
--------------------------------------------------------------------

PresenceIterationSimpleHost continues to:

- create the in-memory executor;
- seed and load the development Journey;
- pass the loaded Journey into JourneyView.

Do not yet connect this to production OnboardingGate.

Do not modify:

- onboarding_gate_provider.dart;
- OnboardingCenterPanelSyncController;
- EnvironmentReadinessPanelView;
- import actions;
- router-backed production startup.

The startup-hook documents have identified the later seam. This iteration tests the experience before touching that seam.

--------------------------------------------------------------------
Ask behaviour
--------------------------------------------------------------------

The current onboarding introduction contains no Ask Step.

Do not remove the proven Ask implementation or tests, but do not use it in this Journey.

Do not work on answer relaying, result ownership, or contractor state in this iteration.

--------------------------------------------------------------------
Tests
--------------------------------------------------------------------

Add or update focused tests proving:

1. The fixture loads four TellSteps in the intended order.
2. The exact four onboarding messages are preserved.
3. Step 1 fades in automatically.
4. Step 1 remains visible for the provisional hold duration.
5. Step 1 fades out and reports completion once.
6. JourneyView advances automatically to Step 2.
7. The same lifecycle advances through Steps 2 and 3.
8. Step 4 fades in.
9. Step 4 remains visible after all automatic timing has elapsed.
10. Step 4 does not report completion.
11. JourneyView never displays Done during this partial onboarding sequence.
12. No Next or Continue button appears.
13. Rebuilds and timers do not cause duplicate advancement.
14. TellStepView remains ignorant of JourneyProgress and siblings.

Use controlled widget-test time advancement. Do not use real waits.

Preserve all existing repository, JourneyProgress, Tell, and Ask tests.

--------------------------------------------------------------------
Questions to answer afterward
--------------------------------------------------------------------

Report:

1. What minimal data distinguishes an automatic Tell from the held endpoint Tell?
2. Where is the visible hold duration owned?
3. What does TellStepView report for an automatic Tell?
4. Why does Step 4 remain current?
5. Did Journey or JourneyProgress require any onboarding-specific knowledge?
6. Does the sequence feel calm at the initial timing?
7. What presentation issue became visible only after watching the real copy?
8. What exact next user interaction should follow Step 4?
9. Is production OnboardingGate integration now justified, or should the next interaction be proven in the debug workflow first?

--------------------------------------------------------------------
Scope discipline
--------------------------------------------------------------------

Do not introduce:

- production startup integration;
- Action Step;
- Audit Step;
- auditing agents;
- Full Disk Access checks;
- System Settings navigation;
- conditional routing;
- loops;
- providers;
- JourneyViewModel;
- result envelopes;
- answer storage;
- physical database persistence;
- progress indicators;
- step counters;
- generic presentation modes beyond what these four Tells require.

This task is successful when the running debug application calmly presents these four thoughts, one at a time, and remains on the fourth.

--------------------------------------------------------------------
Verification
--------------------------------------------------------------------

Run:

- all focused onboarding-introduction tests;
- all Presence tests;
- architecture tripwires;
- the full test suite if practical;
- flutter analyze;
- macOS debug build;
- formatting checks;
- git diff --check.

Do not broaden the task.