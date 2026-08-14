This audit gives us a very clean next move.

The best current experience is indeed minimal calm: one truthful coarse statement, one indeterminate activity indicator, and one instruction that resolves the human’s actual uncertainty—what should I do while this is happening? 23-PRODUCTION-IMPORT-PROGRESS-SURFACE-AUDIT.md

The existing paragraph is the obvious weak point because it mostly repeats the headline. The audit recommends replacing that repetition with actionable reassurance:

Keep MessageLens open while it prepares your messages. You can use other apps in the meantime.

That wording is supported by the current runtime facts: the operation is process-local, quitting or closing the last MessageLens window terminates it, while switching to another app does not. 23-PRODUCTION-IMPORT-PROGRESS-SURFACE-AUDIT.md

I also like that the audit resists elapsed time. It is available, but it measures waiting rather than progress and risks making the human stare at the clock. 23-PRODUCTION-IMPORT-PROGRESS-SURFACE-AUDIT.md And it correctly rejects the temptation to promote the hidden importing/buildingGraph states into fake stage telemetry—they are not truthful stages. 23-PRODUCTION-IMPORT-PROGRESS-SURFACE-AUDIT.md

So the next implementation slice should be tiny.

Implement the single next presentation slice recommended by:

23-PRODUCTION-IMPORT-PROGRESS-SURFACE-AUDIT.md

The goal is:

Replace the repetitive active-progress explanatory paragraph with concise, truthful guidance telling the human to keep MessageLens open while setup runs and reassuring them that using other applications is fine.

Do not redesign the progress surface.

Do not change operation behavior.

Do not add telemetry.

Do not change Presence.

⸻

1. Current defect

During active progress, the current paragraph says approximately:

MessageLens is building its local browsing data from Messages.

or for direct reimport:

MessageLens is rebuilding its local browsing data from Messages.

These statements are broadly truthful, but they add little beyond the existing progress headline.

They do not answer the more useful question:

What should I do while this is running?

⸻

2. Replace the active-progress paragraph

Use concise guidance expressing this supported contract:

Keep MessageLens open while it prepares your messages.
You can use other apps in the meantime.

Exact wording may be adjusted slightly to fit current style, but preserve both truths:

1. MessageLens must remain open;
2. the human may use other applications while it works.

Do not claim:

- the work will survive quitting;
- the work will survive closing the last MessageLens window;
- the work will resume later;
- sleep/restart behavior is guaranteed;
- the user may safely terminate MessageLens.

⸻

3. First-run and reimport wording

Prefer one shared guidance string if it remains natural for both first run and direct reimport.

If the current presentation structure requires context-specific copy, keep the distinction minimal.

Do not create separate prose systems.

The headline already conveys:

Building browsing data…

versus:

Rebuilding browsing data…

The guidance itself may remain shared.

⸻

4. Preserve the existing visual hierarchy

Keep unchanged:

- existing heading;
- indeterminate linear progress indicator;
- controller-derived preparing/running state;
- completion surface;
- failure surface;
- layout structure unless a tiny spacing adjustment is required.

Do not add:

- elapsed time;
- percentage;
- stage name;
- ETA;
- counters;
- additional iconography;
- another progress indicator;
- new controls.

⸻

5. Preserve explicit non-cancellability

Do not reintroduce:

- Abort;
- Cancel;
- Stop;
- Quit Setup;
- Try Later;
- Return;
- cleanup actions.

The new copy must not imply that closing MessageLens is a supported way to stop safely.

⸻

6. Operation layer unchanged

Do not modify:

- OnboardingGate;
- ArchiveMutationCoordinator;
- MessageDataResetService;
- ConversationGraphBuildController;
- ConversationGraphBuildOrchestrator;
- restart/recovery logic;
- failure persistence.

This slice is presentation copy only.

⸻

7. Focused tests

Update/add presentation tests proving:

First-run active progress

Visible:

Keep MessageLens open

and wording equivalent to:

You can use other apps

Direct reimport active progress

The same truthful guidance appears.

Existing progress remains

Prove:

- truthful coarse heading remains;
- indeterminate progress indicator remains;
- no unsupported percentage/stage/ETA appears.

No cancellation control

Confirm no Abort/Cancel/Stop affordance is present.

No resume promise

Ensure the copy does not claim the work will resume after quitting/relaunch.

⸻

8. Documentation

Create:

24-TRUTHFUL-KEEP-OPEN-PROGRESS-GUIDANCE-IMPLEMENTATION.md

Record:

1. previous repetitive paragraph;
2. final wording;
3. operational facts supporting it;
4. first-run/reimport reuse;
5. confirmation that operation behavior is unchanged;
6. tests;
7. deviations from Audit 23.

Update:

- 00-START-HERE.md
- package index
- DOCUMENTATION_PASS_LOG.md

Do not rewrite Audit 23.

⸻

9. Verification

Run:

- focused onboarding progress presentation tests;
- Onboarding overlay tests;
- relevant Environment Readiness tests;
- complete Onboarding tests;
- architecture tripwires;
- flutter analyze;
- formatting;
- git diff --check;
- debug macOS build.

Do not launch against the production archive.

⸻

Hard constraints

Do not:

- change operation lifecycle;
- change Gate states;
- add stage telemetry;
- add elapsed time;
- add percentage;
- add ETA;
- add cancellation;
- add resume language;
- alter completion;
- alter failure/recovery;
- modify Presence;
- change schema.

If the wording change unexpectedly requires any of those, stop and explain why.

⸻

Success criterion

During active setup, the human should now be able to answer:

What is happening?
MessageLens is building local browsing data.
Is it still working?
Yes; the indeterminate activity indicator is active.
What should I do?
Keep MessageLens open.
You can use other apps.

The UI should become slightly more reassuring without becoming more complicated.

Stop after this slice and report before any further progress-surface changes.
