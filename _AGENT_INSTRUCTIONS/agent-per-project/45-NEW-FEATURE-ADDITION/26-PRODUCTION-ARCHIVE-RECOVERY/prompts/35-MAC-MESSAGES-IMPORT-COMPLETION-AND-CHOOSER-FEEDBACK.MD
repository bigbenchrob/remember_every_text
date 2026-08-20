Work on branch `Ftr.archive-recovery`.

This prompt is PRE-APPROVED for implementation. Proceed directly after the planning pass unless investigation reveals that the requested behavior would require changing import semantics or materially broadening architecture.

Suggested prompt name:

`prompts/35-MAC-MESSAGES-IMPORT-COMPLETION-AND-CHOOSER-FEEDBACK.MD`

This should be the final bounded polish slice for the **Mac Messages** Historical Archives arm before we consider that arm substantially complete and begin evaluating MessageLens-folder ingestion.

## Manual validation result

The Prompt 34 import experience is greatly improved.

The user manually reimported the 2012 Messages source and confirmed:

- import succeeds;
- the new Directed Instrumentation is substantially more reassuring;
- Conversations / Messages / Attachments show real increasing counts;
- the changing counts eliminate the previous perception that MessageLens may have stalled;
- Participants / Relationships remain coarse, but this is acceptable given the current absence of one truthful monotonic denominator;
- terminal Checking that import finished appears;
- the new cartouche appears normally without inappropriate orange correspondence.

Two remaining UX refinements were identified.

## 1. Choose Messages Folder needs perceptible interaction feedback

The sidebar button:

`Choose Messages Folder…`

still feels too much like static text.

The user wants the same basic interaction truth now established for the primary Add action:

- visible hover/rollover response;
- visible pressed/click response;
- immediate acknowledgement that the control was activated.

This does not need animation theater.

It needs to behave unmistakably like a button.

## Audit and reuse established button grammar

Inspect the actual component used by:

`Choose Messages Folder…`

Compare it with the corrected:

`Add Messages to MessageLens`

interaction treatment.

Reuse established MessageLens/macOS button states and theme-owned colors.

Do not invent Historical-Archives-specific arbitrary colors.

The chooser should visibly communicate:

```text
normal
→ hover
→ pressed
→ native folder chooser
```

If appropriate for the existing component grammar, reuse the same kind of pressed treatment already established for Add:

- theme-owned hover/pressed background;
- shadow reduction/removal;
- subtle `0.98` pressed scale.

Do not force identical styling if one is a primary action and the other is a different canonical button class.

The semantic requirement is perceptible interaction feedback, not visual sameness.

Manual acceptance criterion:

> Before Finder opens, I can perceive that my pointer is over Choose Messages Folder and that my click registered.

Do not delay opening Finder merely to show an animation.

## 2. Import completion needs an explicit human terminal boundary

Manual observation:

The final:

`Checking that import finished`

stage becomes visible, but the completed instrumentation disappears before the user has comfortably taken in the fact that the entire journey succeeded.

The current 750 ms all-Done dwell improved this, but manual review shows that it still feels transient.

Do NOT simply make every execution stage artificially longer.

Instead, replace the ephemeral terminal transition with an explicit **successful-import modal**.

## Success modal

Once and only once the import has genuinely reached terminal success:

- all required source facts are committed;
- graph/browsing preparation has succeeded;
- final source/membership verification has succeeded;
- the source legitimately qualifies for Folders Already Added;

then present a concise modal.

Representative copy:

**Messages folder added**

The Messages folder you selected has been successfully added to MessageLens.

You should now see the additional messages reflected in your message timelines and heatmaps.

`OK`

Use final wording consistent with MessageLens product terminology.

Prefer `added` over implementation-oriented `imported` where natural, because the sidebar already uses:

Folders Already Added

and:

Add from a Messages Folder.

Do not use celebratory/cutesy language.

Do not expose implementation terminology.

## Important ordering

The modal represents a terminal fact.

Therefore it must appear only AFTER actual terminal success.

A strong desired sequence is:

```text
final real stage completes
→ all instrumentation rows become Done
→ operation is terminally successful
→ add workflow resolves to hub
→ new cartouche now legitimately exists under Folders Already Added
→ center panel becomes empty
→ success modal appears over that stable hub
→ user presses OK
→ modal disappears
→ stable virgin hub remains.
```

This is preferable to leaving the add workflow artificially alive solely to support the modal.

When the modal is visible, the world behind it should already be the truthful post-import world.

## No orange / blue success reference

Preserve the Prompt 33/34 correction.

The newly created cartouche should:

- simply appear;
- remain ordinary/unselected;
- receive no orange correspondence;
- receive no automatic blue selection.

The modal does not need to point at it.

The appearance of the new cartouche plus the completion modal is sufficient evidence.

Orange remains reserved for the distinct duplicate-folder semantic:

> “That existing thing over there is what I mean.”

Do not broaden orange semantics.

## Modal dismissal owns no workflow transition

Pressing `OK` should only dismiss the success notice.

It must NOT:

- trigger import finalization;
- create the cartouche;
- select the cartouche;
- navigate to Messages;
- open a heatmap;
- restart Historical Archives;
- alter source state.

All import work and hub restoration must already be complete before the modal is shown.

This makes OK a genuine acknowledgement rather than another wizard-style Next button.

## Completion dwell

Reassess whether the existing 750 ms all-Done dwell is still useful once the success modal exists.

The user should be able to perceive that the final instrumentation reached Done, but there is no longer a need for the dwell itself to communicate the entire completion result.

Choose the smallest truthful behavior.

Acceptable options include:

A. preserve the current 750 ms all-Done dwell, then hub + modal;

or:

B. modestly shorten the dwell if the modal makes 750 ms unnecessary.

Do NOT remove the ability to perceive the final all-Done instrumentation entirely.

Do NOT increase it into a multi-second artificial delay.

Document the final duration and reasoning.

## Session safety

The success modal must be process/presentation state only.

Guard it with the current Historical Archives presentation-session/occurrence model.

A late success-notice callback must not resurrect stale Historical Archives state.

If the user somehow navigates away during terminal transition:

- do not reopen Historical Archives later merely to show the modal;
- do not let dismissal mutate a newer session.

Determine the cleanest behavior consistent with existing modal/session handling.

## Failure

The success modal must never appear for:

- failed inspection;
- partial import failure;
- graph-projection failure;
- final verification failure;
- cancelled candidate;
- abandoned/navigated-away session.

Terminal success only.

Preserve current failure Directed Instrumentation and retry behavior.

## Ready state

Do not redesign the now-validated ready state.

Preserve:

- stable evidence;
- Add Messages to MessageLens;
- Cancel;
- Details;
- corrected arithmetic;
- stable controls through incidental refresh.

## Import instrumentation

Do not redesign the now-validated progress system.

Preserve:

Top-level stages:

1. Adding messages from this folder
2. Preparing conversations for browsing
3. Checking that import finished

Preserve graph units:

- Participants;
- Conversations;
- Messages;
- Attachments;
- Relationships.

Preserve real numerical progress for:

- Conversations;
- Messages;
- Attachments.

Preserve coarse status for:

- Participants;
- Relationships.

Do not add fake denominators.

Do not add a progress bar in this task.

Manual validation indicates the current changing raw counts adequately solve the stalled-perception problem.

## Participants / Relationships

Leave these coarse unless this task happens to uncover an essentially free truthful denominator.

Do not broaden scope to redesign their repository execution.

The user explicitly considers their current coarse behavior acceptable.

## Sidebar / Tracks

Preserve the approved Mac Messages sidebar:

- umbrella copy;
- `Mac Messages | MessageLens`;
- MessageLens disabled;
- Folders Already Added;
- current cartouches;
- Add from a Messages Folder;
- guidance;
- Choose Messages Folder.

Preserve Historical Archives Tracks A–E.

Do not change current spacing.

## Mechanical responsibility

Preserve the final ownership model.

### Virgin hub

Sidebar:

- existing folders;
- start a new folder-selection attempt.

Center:

- empty.

### Ready candidate

Center:

- candidate evidence;
- Add;
- Cancel;
- Details.

### Import running

Center:

- Narrator;
- Directed Instrumentation.

### Terminal success

Underlying feature:

- already restored to virgin hub;
- new cartouche exists ordinarily.

Modal:

- acknowledges completed import.

### After OK

Exactly the same virgin hub remains.

## Tests

Add/update the smallest clear focused test set proving:

### Chooser feedback

1. Choose Messages Folder uses an established interactive button component;

2. hover state is visibly distinct from normal;

3. pressed state is visibly distinct from hover/normal;

4. chooser still opens through the existing action seam;

5. no artificial delay is introduced before Finder;

6. button interaction changes no archive semantics.

### Success modal

7. modal cannot appear before terminal import success;

8. source import must succeed first;

9. graph preparation must succeed first;

10. final verification must succeed first;

11. source must legitimately qualify as added before modal presentation;

12. hub is restored before/under the modal;

13. center panel is empty behind the modal;

14. new cartouche already exists behind the modal;

15. new cartouche is not orange;

16. new cartouche is not blue-selected;

17. modal contains concise human success wording;

18. modal mentions that additional messages should now appear in timelines/heatmaps;

19. OK only dismisses the modal;

20. OK performs no archive/database mutation;

21. OK does not navigate elsewhere;

22. after OK, virgin hub remains unchanged.

### Failure/session

23. failed import never produces success modal;

24. partial failure never produces success modal;

25. final verification failure never produces success modal;

26. Cancel never produces success modal;

27. stale/abandoned presentation session cannot later surface the modal;

28. stale modal dismissal cannot mutate a newer session.

### Regression

29. existing all-Done instrumentation remains perceptible before modal transition;

30. Conversations/Messages/Attachments numerical progress remains unchanged;

31. Participants/Relationships coarse behavior remains unchanged;

32. duplicate-folder orange behavior remains unchanged;

33. invalid-folder modal remains unchanged;

34. removal journey remains unchanged;

35. ready-state stability remains unchanged;

36. Tracks/sidebar layout remain unchanged;

37. Onboarding remains suppressed during admitted maintenance.

Do not mechanically create one test method for every numbered item.

## Safety

Do not perform a real GUI staging import.

Use fixtures/temp stores for automated verification.

Do not mutate:

- production MessageLens data;
- staging archive;
- donor folders;
- attachment payloads.

The human will perform final manual validation.

## Documentation

Create the next Feature 26 implementation record under `responses/`.

Document:

- chooser-button component and hover/pressed treatment;
- success-modal lifecycle;
- exact terminal-success prerequisite;
- hub/cartouche state before modal appearance;
- final completion-dwell duration;
- session safety;
- explicit confirmation that OK is acknowledgement only;
- explicit confirmation that successful cartouche receives no orange/blue reference;
- preserved instrumentation behavior.

Update version/changelog according to repository rules.

## Verification

Run:

- focused Historical Archives chooser/import/presentation tests;
- Settings tests;
- button/component tests as appropriate;
- source-scoped import/graph tests;
- Onboarding/maintenance regressions;
- architecture tripwires;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build if required.

Commit and push if clean.

STOP after this slice.

Do not proceed into MessageLens-folder ingestion yet.

## Report back with

- exact chooser hover/pressed treatment;
- exact success-modal wording;
- exact terminal-success prerequisite;
- final all-Done dwell duration;
- confirmation that hub/cartouche state is finalized before modal;
- confirmation that OK only dismisses;
- confirmation that successful cartouche remains ordinary/unselected;
- manual staging-review instructions.

Acceptance standard:

> Choosing a folder should unmistakably feel like pressing a real control, and a successful import should end with an equally unmistakable human acknowledgement that the work is finished.
