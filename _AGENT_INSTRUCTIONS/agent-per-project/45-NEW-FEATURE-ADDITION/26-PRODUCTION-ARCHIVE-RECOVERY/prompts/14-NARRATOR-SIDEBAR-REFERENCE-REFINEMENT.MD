Work on branch Ftr.archive-recovery.

This is the next bounded Historical Archives Narrator + Directed Instrumentation slice.

Prompt name:

prompts/14-NARRATOR-SIDEBAR-REFERENCE-REFINEMENT.MD

Read:

- responses/10-HISTORICAL-ARCHIVES-NARRATOR-DIRECTED-INSTRUMENTATION-DESIGN.md
- responses/12-NARRATOR-SLICE-01-IMPLEMENTATION.md
- the implementation record for the already-imported/reference-signal slice
- the canonical All Messages/context-sidebar implementation and documentation for the existing orange “this is what I am referring to” grammar

Do not proceed to import-running/completion redesign yet.

MANUAL REVIEW FINDINGS

The already-imported recognition branch works conceptually, but manual review exposed four interaction problems.

1. Competing sidebar action

While the center panel is actively guiding the user through a selected archive, the sidebar still shows an active “Add an Archive Folder” action.

This is confusing because the center panel already owns the current journey and already provides the appropriate next actions such as Choose Another Folder.

The sidebar should provide context and navigation while the center panel owns the current workflow.

2. Incorrect orange treatment

The Historical Archives reference pulse and settled highlight use colors that are much darker than the established orange referential treatment elsewhere in MessageLens.

The pulse can almost obscure the text.

Do not invent Historical-Archives-specific orange values.

Use the exact established orange correspondence/reference grammar from the All Messages context sidebar, including its reduced-motion behavior and legibility characteristics.

Orange means:

“This is the thing I am referring to.”

It does NOT mean warning, error, caution, or selection.

3. Known Archive Sources cartouches have unclear semantics

The sidebar shows previously added archives as cartouches under Known Archive Sources, but it is not obvious whether those objects are merely informational or clickable.

Give them one simple, stable semantic meaning:

Clicking a Known Archive Source means:

“Show me this archive.”

The center panel then becomes the place where the user sees and manages that archive.

Do not make the cartouche itself a collection of management controls.

4. Re-selecting the same already-imported folder produces no fresh feedback

Current behavior:

- user selects an already-imported folder;
- MessageLens recognizes it;
- Narrator says it is already part of MessageLens;
- matching cartouche pulses;
- user chooses Choose Another Folder;
- user selects exactly the same folder again;
- folder chooser closes;
- durable/presentation state is still alreadyImported;
- therefore the UI can appear to do nothing.

The human performed a new action. MessageLens should acknowledge it even though durable archive state did not change.

GOAL

Refine the interaction so the sidebar and center panel have clear responsibilities and repeated source recognition produces fresh, meaningful referential feedback.

SIDEBAR / CENTER RESPONSIBILITY

Adopt this rule:

CENTER PANEL
owns the current archive journey, narration, evidence, decisions, and management actions.

SIDEBAR
owns archive context, source navigation, and referential correspondence.

When a selected-folder journey is active in the center panel, do not simultaneously offer “Add an Archive Folder” as a competing sidebar workflow action.

“Add an Archive Folder” should be visible when it represents a genuine starting/navigation action, such as when no archive investigation is active.

Derive exact visibility from the presentation state; do not hide it with arbitrary timing.

KNOWN ARCHIVE SOURCE CARTOUCHE

Make each Known Archive Source cartouche clearly actionable with the semantic contract:

“Show me this archive.”

Clicking one should:

- select/reference that known archive in the Historical Archives presentation;
- show its existing source information in the center panel;
- not start import;
- not start removal;
- not reopen the folder chooser;
- not mutate archive data.

Use existing canonical source identity, not display-label matching.

The center panel remains responsible for any later management action.

Do not overload the cartouche itself with Remove, Reimport, Details, etc.

ORANGE REFERENTIAL GRAMMAR

Reuse the exact canonical All Messages/context-sidebar reference treatment.

Inspect the implementation rather than copying approximate colors.

The Historical Archives cartouche should use:

- the same orange reference chrome;
- the same legible text treatment;
- the same pulse visual language;
- the same reduced-motion semantics.

Do not create a second palette or nearly-equivalent animation.

If reuse requires extracting one tiny existing presentation helper, do so narrowly.

Do not create generic animation infrastructure.

REPEATED RECOGNITION

Separate:

archive recognition STATE

from

archive recognition OCCURRENCE.

The source can remain in alreadyImported state while a new human folder-selection action generates a new recognition occurrence.

Example:

First selection:

Narrator:
“This archive is already part of MessageLens.”

Matching sidebar source pulses.

User presses Choose Another Folder and selects the same folder again.

Narrator should acknowledge the fresh event, for example:

“That’s the same archive — it’s already part of MessageLens.”

Matching sidebar source pulses again.

Do not use sarcastic or scolding language.

The tone may lightly acknowledge that the same source has been chosen again, but should remain calm and competent.

Do not block the folder from being selected merely because it is already imported.

The user's selection is useful input: MessageLens can identify what they chose and explain its relationship to existing state.

Do not silently ignore the repeated selection.

PULSE SEMANTICS

A pulse should occur once per semantic recognition event.

Therefore:

- initial recognition of an already-imported source -> pulse occurrence increments;
- selecting the same source again through a fresh folder-chooser action -> pulse occurrence increments again;
- provider rebuild -> no increment;
- widget rebuild -> no increment;
- sidebar navigation to the already-known source -> do not automatically fabricate a “recognition” pulse unless the interaction semantics genuinely call for referential pointing;
- selecting a different folder -> old reference clears or moves appropriately.

Keep the occurrence process/presentation-scoped.

Never persist it.

Never use it as identity.

KNOWN-SOURCE CENTER STATE

When a user clicks a Known Archive Source cartouche, show an appropriate already-known/archive-management composition.

For an imported source, representative primary content is:

Historical Archives

This archive is already part of MessageLens.

MESSAGES ARCHIVE

Messages 8,882
Dates Jul 2012 – Jun 2017
Status Already imported

[ Choose Another Folder ]

[ Remove from MessageLens… ] only where current removal policy permits it.

Details

Do not show Import Archive when there is no new import decision.

Do not treat clicking the sidebar cartouche itself as a request to remove or reimport.

ADD ARCHIVE ACTION VISIBILITY

Establish a simple state rule.

For example:

no active source/investigation
-> sidebar may show Add an Archive Folder

active center-panel source journey
-> center-panel controls own folder-changing actions
-> sidebar Add an Archive Folder is absent or inactive according to the cleanest existing layout contract

Do not display duplicate controls in two places just because both can technically invoke the chooser.

The user should not need to decide which of two equivalent buttons is the “right” one.

TESTS

Add focused tests proving:

1. Add an Archive Folder is visible in the appropriate no-source/sidebar starting state;

2. it is not presented as a competing action while an active selected-source journey owns the center panel;

3. a Known Archive Source cartouche is actionable as “show this archive”;

4. clicking it shows that source in the center panel without starting import/removal;

5. cartouche and center panel resolve the same canonical source identity;

6. Historical Archives uses the canonical All Messages orange reference treatment rather than local dark colors;

7. the reference treatment remains legible during pulse and settled correspondence;

8. reduced-motion behavior matches the established grammar;

9. first recognition of an already-imported selected folder produces exactly one pulse;

10. selecting the same folder again through a fresh chooser action produces a new recognition occurrence and one new pulse;

11. provider/widget rebuilds do not replay a pulse;

12. repeated selection receives fresh Narrator feedback rather than appearing to do nothing;

13. selecting a different source clears/moves the reference correctly;

14. no import/removal execution semantics change.

SCOPE / NON-GOALS

Do not:

- redesign import-running/completion;
- redesign removal-running/completion;
- change Historical Archives persistence;
- change source-scoped identity;
- change canonical source-key generation;
- change mutation authority;
- change DateConverter;
- change database schema;
- perform archive import/removal;
- create generic Navigator/Narrator infrastructure;
- create generic animation infrastructure.

This is a presentation/navigation/referral refinement only.

DOCUMENTATION

Create the next Feature 26 implementation record under responses/.

Document:

- sidebar versus center-panel responsibility;
- Known Archive Source cartouche semantic contract;
- canonical orange grammar reused;
- repeated-recognition occurrence behavior;
- one-shot pulse rules;
- Add Archive action visibility rule;
- tests proving no rebuild-driven pulse replay.

Update version/changelog according to repository rules.

VERIFICATION

Run focused Historical Archives sidebar/panel/workflow tests, relevant All Messages reference-signal tests, reduced-motion tests, architecture tripwires, flutter analyze, formatting, and git diff --check.

Commit and push if clean.

STOP after this slice.

Do not proceed to import-running/completion redesign.

Report:

- exact visibility rule for Add an Archive Folder;
- exact cartouche click semantics;
- how canonical orange styling was reused;
- how repeated selection generates a fresh occurrence without changing durable state;
- exact pulse replay prevention;
- manual launch instructions for review against the staging archive.
