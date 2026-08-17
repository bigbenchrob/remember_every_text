Work on branch Ftr.archive-recovery.

This is the next bounded Historical Archives Narrator + Directed Instrumentation slice.

Prompt name suggestion:

prompts/13-NARRATOR-ALREADY-IMPORTED-REFERENCE-SIGNAL.MD

Read:

- responses/10-HISTORICAL-ARCHIVES-NARRATOR-DIRECTED-INSTRUMENTATION-DESIGN.md
- responses/12-NARRATOR-SLICE-01-IMPLEMENTATION.md
- the current Historical Archives sidebar/known-source presentation
- the repository documentation and implementation for the existing orange “this is what I am referring to” signal grammar, if one already exists

Do not redesign import-running/completion/removal yet.

OBSERVED MANUAL RESULT

Narrator Slice 01 is visually successful, but manual use exposed a missing semantic branch.

The user selected Messages_2012-IMPORT_SOURCE even though that archive had already been imported.

The sidebar already contained a Known Archive Source cartouche for that archive, but the user did not notice it.

The center panel proceeded through the ordinary ready-for-import presentation and displayed nonsensical comparison evidence:

- Messages: 8,882
- New to MessageLens: -6,513
- Already represented: 15,395

The important UX lesson is not merely “fix the arithmetic.”

Once MessageLens recognizes that the newly chosen folder corresponds to an archive source already present in MessageLens, it should immediately tell the user that fact and visually point to the existing object it is referring to.

GOAL

Implement the already-imported-source branch of Narrator + Directed Instrumentation.

The intended interaction is:

User chooses folder
→ MessageLens inspects/identifies it
→ selected source matches an already-imported known archive source
→ ordinary ready-for-import journey stops
→ Narrator says, in plain language:

“This archive is already part of MessageLens.”

→ the matching Known Archive Source cartouche in the sidebar receives the existing orange referential-attention treatment
→ a brief transient pulse draws the eye to that cartouche
→ the orange may then settle into the normal referential state or disappear according to the existing signal grammar
→ center panel presents the already-imported archive truth
→ no Import Archive action is offered

ORANGE SIGNAL GRAMMAR

This orange treatment is NOT:

- warning;
- failure;
- caution;
- destructive state;
- selected-state replacement.

Its meaning is:

“This is the thing I am referring to.”

The Narrator is effectively pointing.

The transient pulse has a specific human purpose:

“Oops — look here. This is the archive I mean.”

It should attract attention briefly, then stop demanding attention.

Do not invent a new orange meaning if the repository already contains a canonical referential-attention grammar. Reuse its semantics and implementation where appropriate.

If the existing grammar is documented but not yet reusable at this boundary, introduce the smallest presentation seam needed. Do not create a general animation framework.

ALREADY-IMPORTED STATE

Representative primary composition:

Historical Archives

This archive is already part of MessageLens.

MESSAGES ARCHIVE

Messages 8,882
Dates Jul 2012 – Jun 2017
Status Already imported

[ Choose Another Folder ]

[ Remove from MessageLens… ] only if current removal policy already permits this action here.

Details

Use actual existing typed facts.

Do not hard-code source name, dates, or counts.

Do not display:

- New to MessageLens
- Already represented
- Import Archive

when the selected source is already imported and there is no meaningful new import work.

SOURCE IDENTITY

Determine the existing canonical identity by which the selected inspected folder is matched to a Known Archive Source.

Do not invent fuzzy/path-name matching if durable source identity already exists.

The center-panel already-imported state and the highlighted sidebar cartouche must derive from the same canonical source identity.

The UI must not merely compare display labels.

REFERENTIAL PULSE

When the state transitions from inspection into already-imported:

- request one transient referential pulse on the matching sidebar Known Archive Source cartouche;
- do not continuously pulse;
- do not replay the pulse on every rebuild/provider refresh;
- do not turn normal selection into permanent animation;
- do not require the user to click the sidebar item.

The pulse belongs to the semantic transition:

“MessageLens has just recognized the thing you selected as that existing archive over there.”

Establish an explicit one-shot presentation/event seam if necessary rather than inferring pulse timing from arbitrary widget rebuilds.

Keep it presentation-scoped. Do not persist pulse state as durable user data.

ARITHMETIC / EVIDENCE INVARIANT

Separately investigate the impossible Slice-01 dry-run numbers.

The primary fix is correct semantic classification: an already-imported source should not enter the ordinary new-archive decision composition.

But also make the comparison model mechanically incapable of presenting impossible human-facing values.

For any ordinary import-decision evidence:

- “new” must never be negative;
- “already represented” must not exceed the comparable source population represented by that presentation;
- the displayed quantities must have one clear semantic denominator.

Trace why the already-imported source produced:

8,882 total
15,395 already represented
-6,513 new

Do not simply clamp negative numbers to zero.

Identify and correct the semantic/counting error at the appropriate evidence boundary.

If 15,395 is a legitimate internal count of multiple observations across sources, keep it as diagnostic evidence if useful, but do not present it as “already represented” against an 8,882-message source.

HUMAN JOURNEY RULE

The user should not be expected to notice the Known Archive Sources cartouche independently and mentally reconcile it with the center panel.

MessageLens already knows the relationship.

Therefore MessageLens should say so and point.

This is a core Narrator + Directed Instrumentation principle:

Narrator provides meaning.
Directed Instrumentation provides evidence.
Orange referential attention identifies the object currently being discussed.

TESTS

Add focused tests proving:

1. selecting an already-imported archive enters an explicit already-imported presentation state;

2. it does not enter the ordinary ready-for-import state;

3. Import Archive is absent;

4. the Narrator states that the archive is already part of MessageLens;

5. the matching Known Archive Source is identified by canonical source identity;

6. the matching sidebar cartouche receives one referential-attention pulse when recognition occurs;

7. an unrelated known-source cartouche does not pulse;

8. the pulse does not replay merely because providers/widgets rebuild;

9. choosing another folder clears the referential relationship appropriately;

10. ordinary genuinely new archives still follow the existing Slice-01 ready-for-import journey;

11. human-facing dry-run evidence can never expose negative-new / over-total already-represented values;

12. no import/removal execution behavior changes.

SCOPE / NON-GOALS

Do not:

- redesign import-running/completion;
- redesign removal-running/completion;
- change source-scoped identity;
- change mutation authority;
- change DateConverter;
- change database schema;
- change archive persistence;
- perform GUI archive mutations;
- add generic application-wide narrator infrastructure;
- add generic animation infrastructure.

This is one earned Historical Archives presentation branch plus the referential-attention connection to the sidebar.

DOCUMENTATION

Create the next Feature 26 implementation record under responses/.

Document:

- the already-imported state;
- canonical identity used to match center and sidebar;
- orange referential-attention semantics;
- transient pulse lifecycle;
- cause and correction of the impossible comparison numbers;
- tests proving the pulse is one-shot and semantic rather than rebuild-driven.

Update version/changelog if required by repository rules.

VERIFICATION

Run focused Historical Archives workflow/presentation/sidebar tests, architecture tripwires, flutter analyze, formatting, and git diff --check.

Commit and push if clean.

STOP after this slice.

Do not proceed to import-running/completion redesign.

Report back with:

- exact already-imported classification rule;
- how the sidebar cartouche is targeted;
- how the transient orange pulse is triggered and prevented from replaying;
- why the 15,395 / -6,513 arithmetic occurred;
- what invariant now prevents such evidence;
- manual launch instructions for reviewing the interaction against the staging archive.
