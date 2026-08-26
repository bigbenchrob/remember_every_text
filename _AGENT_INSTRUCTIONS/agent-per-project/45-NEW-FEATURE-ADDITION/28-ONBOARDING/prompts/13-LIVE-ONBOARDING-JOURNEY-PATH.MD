Here’s the next prompt.



Work on the current Feature 28 branch/worktree according to repository conventions.

This prompt is PRE-APPROVED for implementation.

Prompt 12 established a single typed `OnboardingJourneyCoordinator` as the sole authority for active Onboarding Episode selection.

That makes it finally safe to add a visual Journey path.

The purpose is orientation, not progress estimation.

Suggested prompt name:

`13-LIVE-ONBOARDING-JOURNEY-PATH.MD`

## Product goal

Add a compact live ball-and-stick Journey path at the top of the Onboarding window.

It should answer:

> Where am I in the overall setup journey?

The existing layers remain distinct:

- Journey path = where am I overall?
- Narrator = what does the current Episode mean?
- Directed Instrumentation = what work is happening inside this Episode?

Do not let these responsibilities overlap.

## Single authority

The Journey path must derive only from `OnboardingJourneyCoordinator`.

It must not infer state from:

- readiness cards;
- progress counters;
- provider timing;
- modal state;
- app focus;
- operation callbacks.

If the Coordinator says the current Episode is X, the Journey path shows X.

## Episode topology

Audit the final typed Episode model from Prompt 12 and derive the path from that model.

Do not hard-code an obsolete speculative sequence.

Likely concepts may include:

- Messages access
- Message history
- Contacts
- Ready
- Importing
- Verifying
- Start

Use actual current Episodes and product-appropriate labels.

Keep the number of visible nodes small enough to read at a glance.

## Completed/current/future states

Each node should have a truthful state:

### Completed
Authoritative completion predicate passed.

### Current
This is the active Episode.

### Future
Not yet eligible.

If architecture supports:

### Skipped / not applicable
The Episode was legitimately bypassed.

Do not render skipped as completed.

## Backward transitions

If authoritative prerequisite evidence regresses, the marker must move backward truthfully.

Example:

Ready
→ FDA revoked
→ Messages-access blocker becomes current.

Do not preserve a fake visual sense of forward-only progress.

## Import progress

During the import Episode, the Journey node remains on Importing.

Do not animate the node continuously based on records.

Existing factual progress such as:

`Messages 84,000 / 137,373`

continues below through Directed Instrumentation.

## Terminal behavior

During:

**You’re ready to start**

the final Journey node is current.

After the human presses **OK** and Onboarding releases ownership:

- Journey path disappears;
- normal app assumes ownership;
- sidebar reveal proceeds as already implemented.

Do not leave the path visible in normal MessageLens.

## Visual language

Reuse the established MessageLens ball-and-stick / relationship visual language where appropriate.

Do not invent a foreign stepper aesthetic.

Desired characteristics:

- restrained;
- compact;
- thin connectors;
- small nodes;
- clear current emphasis;
- completed nodes visibly settled;
- future nodes subdued;
- enough labeling to orient without clutter.

Avoid:

- giant circles;
- numbered wizard steps unless existing design demands them;
- progress percentages;
- excessive animation;
- a subway-map appearance.

## Labels

Prefer human Episode names rather than implementation terms.

Do not show:

- `environmentPreparation`;
- `durableReadinessVerification`;
- provider/type names.

Use concise user-facing labels.

## Vertical footprint

The path should occupy a stable shallow Track/region at the top of Onboarding.

It must not push primary actions below the fold.

The existing manually approved readiness/import layouts should remain spacious.

## Tracks

Use canonical Track architecture.

Audit where the Journey path belongs relative to:

- title;
- Narrator;
- primary Episode content;
- Directed Instrumentation.

Do not use local magic padding.

The path should remain fixed in position across all Onboarding Episodes.

## Responsive layout

At supported narrow widths:

- nodes should remain legible;
- labels may shorten or adapt if necessary;
- path must not overflow awkwardly;
- primary content remains usable.

Do not introduce horizontal scrolling for normal supported window sizes.

## Animation

Use subtle animation only if canonical design supports it.

Potentially:

- current-node emphasis transition;
- connector settling when Episode completes.

Do not animate merely to imply activity.

Episode advancement should be perceptible but calm.

Respect reduced-motion settings.

## Accessibility

The visual path must have a meaningful semantic representation.

VoiceOver should be able to understand something equivalent to:

> Setup progress: Importing, step 5 of 7.

But do not imply fixed numeric progression if Episodes can be skipped/backtrack unless the semantics remain truthful.

Alternative:

> Current setup step: Importing. Messages access, Message history, Contacts, and Ready are complete.

Use the representation that best matches actual topology.

Do not rely on color alone.

## Failure/blocker states

A blocker does not create a new Journey node unless it is already a typed Episode.

Example:

needs Full Disk Access
→ current node remains Messages access.

The blocker details appear below.

Do not add red error nodes for transient child conditions.

## Modal behavior

If a modal Moment appears within an Episode:

- path remains unchanged;
- modal cannot advance it.

Returning from System Settings likewise does not move the path until Coordinator evidence advances the Episode.

## Diagnostic value

The Journey path should help expose erroneous transitions during testing.

Add debug/test coverage showing sequence changes clearly.

Do not add production diagnostic text solely for developers.

## Tests

Add/update focused tests proving:

1. path derives only from Journey Coordinator;
2. current node matches each Episode;
3. completed nodes require actual completed predicates;
4. future nodes cannot appear completed;
5. System Settings return does not move the path;
6. modal dismissal does not move the path;
7. backward prerequisite regression moves marker backward;
8. import record progress does not change Journey node;
9. terminal Episode shows final node current;
10. OK removes Journey path;
11. sidebar reveal occurs after path disappears;
12. skipped/not-applicable state is truthful if supported;
13. reduced motion honored;
14. accessibility semantics expose current Journey position;
15. responsive layout remains stable.

## Architecture tripwires

Protect:

- no widget-derived Episode inference;
- no progress-derived Journey advancement;
- no modal-driven node advancement;
- no independent Journey-path state;
- path disappears outside Onboarding ownership.

## Documentation

Create:

`13-LIVE-ONBOARDING-JOURNEY-PATH-IMPLEMENTATION.md`

Document:

- final topology;
- node labels;
- state mapping;
- Track placement;
- backward transitions;
- terminal behavior;
- accessibility;
- animation/reduced-motion decisions.

Update Feature 28 index/documentation log.

Update version/changelog according to repository rules.

## Verification

Run:

- Journey Coordinator tests;
- Onboarding presentation tests;
- Track/layout tests;
- accessibility tests;
- sidebar handoff tests;
- architecture tripwires;
- full Flutter suite;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build.

Commit and push if clean.

## Final report

Report:

- final Journey path topology;
- exact labels;
- current/completed/future rendering;
- skipped/backward behavior;
- Track placement;
- accessibility behavior;
- reduced-motion behavior;
- tests/verification;
- commit hash;
- manual review instructions.

Acceptance standard:

> The Journey path should make the whole Onboarding undertaking legible at a glance without becoming another progress system. It must be a faithful projection of the one authoritative typed Journey: the ball moves because the Journey advanced, not because the UI guessed that it probably should have.