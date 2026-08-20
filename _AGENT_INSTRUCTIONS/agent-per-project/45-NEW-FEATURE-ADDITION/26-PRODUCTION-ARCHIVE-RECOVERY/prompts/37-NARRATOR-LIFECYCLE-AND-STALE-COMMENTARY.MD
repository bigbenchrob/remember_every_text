Work on branch `Ftr.archive-recovery`.

This prompt is PRE-APPROVED for implementation. Proceed directly after the planning pass unless investigation reveals a genuine conflict with the typed import-stage model.

Suggested prompt name:

`prompts/37-NARRATOR-LIFECYCLE-AND-STALE-COMMENTARY.MD`

This is a small Narrator lifecycle refinement for the Mac Messages Historical Archives import journey.

Do not redesign import execution, Directed Instrumentation, progress counts, sidebar layout, success modal, or removal.

## Manual review finding

Prompt 36 correctly introduced a Narrator scope transition when import moves from the selected Messages folder into preparation of the combined MessageLens history.

The resulting statement is useful while graph preparation is actually occurring:

**The messages from this folder are added. Now I’m updating your combined MessageLens history so everything appears together.**

However, manual review exposed a lifecycle problem.

Once:

`Preparing conversations for browsing`

and all of its real units:

- Participants
- Conversations
- Messages
- Attachments
- Relationships

are Done, the workflow advances to:

`Checking that import finished`

but the previous Narrator statement remains visible.

At that point it has become stale.

The instrumentation visibly says the combined-history preparation is finished, while Narrator continues saying:

> Now I’m updating your combined MessageLens history…

The two parts of the UI contradict each other temporally.

## Governing rule

Codify and apply this principle:

> Narrator appears when human interpretation is useful, and disappears or changes when that interpretation is no longer current.

Narrator does NOT require a replacement statement merely because the previous statement expires.

Silence is a legitimate Narrator state.

This complements the existing rule:

> Narrator explains changes in meaning and scope; Directed Instrumentation reports factual work within that scope.

Together:

- Narrator speaks when interpretation is needed.
- Directed Instrumentation continuously reports actual work.
- Narrator stops speaking when its statement ceases to describe the current state.

## Do not narrate every implementation stage

Do NOT convert this into:

stage 1 → Narrator sentence
stage 2 → Narrator sentence
stage 3 → Narrator sentence
stage 4 → Narrator sentence

That would recreate the plodding experience we explicitly want to avoid.

Narrator is not a verbose progress log.

Only stages that require human interpretation earn narration.

## Current import journey

### Source-addition phase

While:

`Adding messages from this folder`

is current, retain:

**Adding this Messages folder to MessageLens.**

This provides useful context for the source-specific work.

### Combined-history phase

When typed `preparingConversations` becomes current, retain:

**The messages from this folder are added. Now I’m updating your combined MessageLens history so everything appears together.**

This is especially important because the numerical workload now describes the much larger combined MessageLens history rather than the selected 8,882-message source.

### Final verification

When:

`Preparing conversations for browsing`

has genuinely completed and:

`Checking that import finished`

becomes current, the combined-history Narrator statement must disappear.

Preferred behavior:

**no Narrator statement**

during final verification.

The Directed Instrumentation row:

`Checking that import finished`

already communicates the current work adequately.

Do not add a sentence such as:

“I’m checking that everything finished correctly.”

unless investigation demonstrates that the instrumentation is genuinely ambiguous without it.

The default requirement is Narrator silence.

## Presentation behavior

When no Narrator statement is currently earned:

- remove the Narrator text cleanly;
- let Directed Instrumentation remain in its established position/flow;
- do not leave a large awkward reserved blank area merely because Narrator might exist in another state.

Use the existing layout/Track architecture truthfully.

Do not introduce abrupt horizontal movement or break the established center-panel alignment.

A normal vertical reflow when Narrator content ceases to exist is acceptable if consistent with the design system.

## Typed-state ownership

Drive Narrator lifecycle entirely from typed workflow/progress state.

Do not:

- use timers;
- inspect rendered strings;
- infer completion from numeric progress;
- hide Narrator after an arbitrary duration;
- let widgets independently guess whether commentary is stale.

Conceptually:

source-addition current
→ source Narrator

preparing-conversations current
→ combined-history Narrator

final-verification current
→ Narrator absent

terminal success
→ existing success-modal lifecycle

Use the actual existing typed state names and boundaries.

## Failure semantics

Narrator must remain truthful under failure.

### Source-addition failure

Do not show combined-history Narrator.

### Graph/preparation failure

If preparation fails while the combined-history phase is genuinely current, the combined-history Narrator may remain as contextual explanation alongside the failed instrumentation.

Do not immediately erase useful context merely because the stage failed.

### Final-verification failure

Once graph preparation has completed and final verification owns the workflow, the old combined-history Narrator must remain absent.

Failure presentation/instrumentation owns the explanation.

Do not resurrect stale Narrator commentary.

## Success

Preserve the existing success sequence unchanged:

- final verification succeeds;
- all-Done state remains perceptible according to current completion behavior;
- hub/cartouche finalize;
- success modal appears;
- OK only dismisses.

Do not add a Narrator success sentence before the modal.

The modal already owns terminal acknowledgement.

## Removal journey

Audit the removal Narrator lifecycle briefly for the same stale-commentary class of bug.

Do not redesign removal.

If removal currently leaves a Narrator sentence visible after its meaning has expired while a later instrumentation stage runs, apply the same principle narrowly.

If it is already truthful, leave it unchanged.

Report what you found.

## Canonical documentation

Update the appropriate Narrator + Directed Instrumentation design documentation with this broader rule:

> Narrator commentary has a lifecycle. It is present only while its interpretation applies to the current human-visible state. When that meaning expires, Narrator either transitions to a newly earned interpretation or becomes silent.

Also preserve:

> Silence is preferable to commentary that merely paraphrases self-explanatory instrumentation.

This should become part of the reusable design grammar, not remain a Historical Archives special case.

## Tests

Add/update the smallest clear focused tests proving:

1. source-addition state shows source-specific Narrator;

2. preparing-conversations state shows combined-history Narrator;

3. combined-history Narrator remains while graph preparation is genuinely current;

4. final-verification state does not show the combined-history Narrator;

5. final-verification does not automatically receive replacement Narrator copy;

6. transition to Narrator silence is driven by typed state;

7. no timer controls Narrator expiry;

8. no numeric progress value controls Narrator expiry;

9. source-addition failure never shows combined-history narration;

10. graph-preparation failure retains truthful contextual narration where appropriate;

11. final-verification failure does not resurrect combined-history narration;

12. success modal remains the terminal acknowledgement;

13. Directed Instrumentation remains visible and unchanged when Narrator becomes silent;

14. progress counts and denominators remain unchanged;

15. ready-state behavior remains unchanged;

16. Tracks/sidebar layout remain unchanged;

17. removal remains unchanged unless an equivalent stale-commentary defect is actually found.

Do not mechanically create one test method per numbered item.

## Scope / non-goals

Do not:

- change import stages;
- change graph projector progress;
- change denominators;
- add progress bars;
- change ready-state evidence;
- change button behavior;
- change success-modal wording;
- change cartouche behavior;
- change sidebar spacing;
- change source identity;
- change persistence;
- change DateConverter;
- change mutation authority;
- implement MessageLens-folder ingestion.

## Documentation

Create the next Feature 26 implementation record under `responses/`.

Document:

- the stale Narrator defect observed manually;
- exact typed state where combined-history narration begins;
- exact typed state where it expires;
- silence during final verification;
- failure behavior;
- removal audit result;
- canonical Narrator lifecycle rule.

Update version/changelog according to repository rules.

## Verification

Run:

- focused Historical Archives import/presentation tests;
- Narrator lifecycle tests;
- removal presentation tests as appropriate;
- Settings tests;
- architecture tripwires;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build if required.

Commit and push if clean.

STOP after this Narrator lifecycle refinement.

Do not proceed into MessageLens-folder ingestion yet.

## Report back with

- exact typed boundary where combined-history Narrator appears;
- exact typed boundary where it disappears;
- confirmation that final verification is intentionally Narrator-silent;
- failure behavior;
- removal audit result;
- canonical documentation updated with the Narrator lifecycle rule;
- manual staging-review instructions.

Acceptance standard:

> Narrator should never continue describing work that Directed Instrumentation has already shown to be finished.
