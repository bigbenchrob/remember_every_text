Work on branch Ftr.archive-recovery.

This prompt is PRE-APPROVED for implementation. After your planning pass, proceed directly with the bounded implementation below without stopping for another approval, provided investigation confirms the assumptions and hard invariants. Stop only if the work would require broadening scope or changing an invariant.

Suggested prompt name:

`prompts/27-HISTORICAL-ARCHIVE-SELECTED-SOURCE-STORY.MD`

This is a presentation-only redesign of the center panel shown when the user deliberately selects an existing folder under **Folders Already Added**.

Do not redesign removal execution yet. Restore/expose its entry action as specified below, but preserve existing removal semantics.

## DESIGN PRINCIPLE

Apply this rule explicitly:

> Do not make each UI region independently self-explanatory when the surrounding UI has already established the context.

In Historical Archives:

SIDEBAR
= which archive am I looking at?

CENTER PANEL
= what matters about that archive?

The selected cartouche is already prominently visible and blue-selected in the sidebar.

Therefore the center panel must not repeat the archive name merely to satisfy a conventional Header → Subhead → Content hierarchy.

The sidebar and center panel are one composition.

## CURRENT PROBLEMS

The selected-source center panel currently behaves too much like a self-contained document/dashboard.

It redundantly contains concepts such as:

- Historical Archives;
- Historical Messages Archive;
- repeated archive/source identity;
- formal item/value rows;
- status-style presentation;
- green resolved/check semantics.

This produces duplication and ignores the context already established by the selected sidebar cartouche.

The center panel should instead tell the useful human story of the selected archive.

## GOAL

When the user clicks an existing cartouche under **Folders Already Added**:

- cartouche remains blue-selected;
- center panel follows the established vertical-track layout;
- center panel does NOT repeat the folder/archive name;
- center panel does NOT repeat Historical Archives;
- center panel does NOT show a redundant Historical Messages Archive eyebrow/subheading;
- center panel does NOT use green success checkmarks;
- center panel does NOT use a formal label-left/value-right dashboard.

Instead, it should answer:

1. What kind of thing is this?
2. What historical material does it contain?
3. What did adding it contribute to MessageLens?
4. Can I see more?
5. Can I remove it?

## VERTICAL TRACK

Restore/use the established MessageLens vertical-track composition.

The useful content should share a strong left alignment rather than scattering labels and values across the width.

Conceptually:

This is a Mac Messages folder.

[optional trustworthy import-date sentence]

It contains 8,882 messages sent or received
between July 2012 and June 2017.

You already had some of these. Adding this folder
brought 2,369 additional messages into your
MessageLens history.

More Details

[ Remove this folder… ]

This is representative structure, not mandatory final line wrapping.

Use existing vertical-track/layout primitives if already available.

Do not invent another local alignment system.

## DO NOT REPEAT THE ARCHIVE NAME

Do not render:

Messages_2012-IMPORT_SOURCE

or equivalent selected-source display identity in the center panel merely as a header/subheader.

The user deliberately clicked that object and it remains visibly selected in the sidebar.

The cartouche owns object identity.

The center panel owns meaning and management.

The exact path/name may remain available under More Details if useful.

## OPENING STATEMENT

Begin simply:

This is a Mac Messages folder.

Do not prepend:

Historical Archives

or:

Historical Messages Archive

The source type is useful information.

The feature identity is already known.

## IMPORT DATE

If and only if there is a trustworthy successful-import completion date, follow with a natural sentence such as:

You added it to MessageLens on August 10, 2026.

Use the same trustworthy rule established in the cartouche cleanup:

`lastImportFinishedAtUtc` only when paired with `lastImportSuccess == true`, unless current code now exposes a more authoritative equivalent.

Do not infer the date from:

- source registration;
- dry run;
- preflight;
- filesystem timestamps;
- logs;
- database modification times.

If no trustworthy import date exists, omit the sentence completely.

Do not show:

unknown

not yet imported

or another fallback.

The archive is already under Folders Already Added; contradictory fallback copy is unacceptable.

## MESSAGE COUNT AND DATE RANGE

Express these as a human statement rather than a formal item/value table.

Representative form:

It contains 8,882 messages sent or received between July 2012 and June 2017.

Use actual typed/durable facts.

Use existing human date formatting.

Do not show exact UTC timestamps in the primary view.

## UNIQUE CONTRIBUTION

This is important.

The current selected-source presentation tells the user how many messages the archive contains, but not what adding it actually accomplished.

Show a human-facing statement describing the archive's unique contribution to MessageLens.

For the validated 2012 source, prior preflight evidence established:

- 8,882 source messages;
- 6,513 already represented;
- 2,369 likely/new unique messages.

But do NOT hard-code 2,369.

First establish what durable/current evidence can truthfully support a statement such as:

You already had some of these. Adding this folder brought 2,369 additional messages into your MessageLens history.

Determine whether the currently persisted Historical Archives source metadata contains a trustworthy successful-import comparison/result that represents this quantity.

IMPORTANT:

Do not recompute or invent a number from semantically incompatible counts.

The previous `15,395 / -6,513` bug demonstrated why the denominator matters.

Any displayed contribution count must have clear GUID-based/human-message semantics.

If current durable evidence cannot truthfully establish the unique contribution for an already-imported source, omit the numeric contribution sentence rather than inventing it.

A weaker truthful sentence may be acceptable only if directly supported, but do not add vague filler merely to occupy space.

Report any evidence limitation.

Do not introduce a schema change merely to obtain this number in this slice.

## MORE DETAILS

Provide a quiet:

More Details

disclosure/action.

This is where technical or forensic information may live, including as appropriate:

- full folder/chat.db path;
- source identity;
- exact timestamps;
- chat/handle counts;
- comparison methodology;
- import result details;
- graph/projection counts;
- workflow history.

Do not put those facts back into the primary view.

Reuse the existing Details disclosure mechanism where possible.

## REMOVE ACTION

Restore/expose the source-specific removal entry action in this selected-source management view.

Use wording:

Remove this folder…

The ellipsis is intentional: clicking it begins a confirmation/destructive flow; it must NOT immediately remove anything.

Give this control the established MessageLens destructive/caution styling.

It should feel consequential and unmistakably different from ordinary navigation/action buttons.

Do not invent a new scary color if MessageLens already has canonical destructive/caution styling.

Do not make it look like an error state; nothing is wrong.

This is a deliberate destructive action.

IMPORTANT:

This task restores/presents the entry action only.

Do not redesign or alter the underlying historical removal semantics in this slice.

Preserve the existing confirmation/mutation authority/removal service behavior.

If the removal button was accidentally lost only at the presentation layer, reconnect it to the existing action seam.

If restoring it would require changing removal execution semantics, STOP and report instead.

## NO DIRECTED-INSTRUMENTATION CHECKMARKS

This is not an active operation.

Do not show:

- green checkmarks;
- Found;
- Ready;
- Imported status indicators;
- working/waiting rows.

Directed Instrumentation is useful when the machine is checking or doing work.

This center panel is a stable object-management view.

Use ordinary human facts.

## PRESENTATION MECHANICAL RESPONSIBILITY

Make the selected-source context structurally incapable of showing:

- Import Archive;
- Choose Messages Folder;
- Choose Another Folder;
- duplicate-folder errors;
- invalid-folder errors;
- add-flow Narrator content.

Likewise, Add Archive context must not gain selected-source management controls merely because this presentation exists.

Sidebar selection establishes `existingSource`.

Only that context earns this center-panel composition.

## TESTS

Add/update focused tests proving:

1. selecting an existing imported cartouche produces the source-management center panel;

2. selected cartouche remains blue;

3. center panel does not repeat Historical Archives;

4. center panel does not show Historical Messages Archive;

5. center panel does not repeat the selected archive name;

6. center panel begins with source-type meaning such as “This is a Mac Messages folder”;

7. trustworthy import date appears as a human sentence when available;

8. import-date sentence is omitted when trustworthy evidence is unavailable;

9. message count and date range are presented as human-readable content rather than formal item/value rows;

10. unique-contribution count is shown only when trustworthy semantically compatible evidence exists;

11. no impossible/negative/over-total comparison evidence can reach this view;

12. More Details remains available;

13. Remove this folder… is present when current removal policy permits it;

14. removal action uses established destructive/caution styling;

15. clicking Remove this folder… does not immediately mutate data and continues through the existing confirmation/removal seam;

16. no green check/status instrumentation appears;

17. no Add/Choose-folder actions appear in existingSource context;

18. navigation-away reset remains unchanged;

19. no import/removal execution semantics change.

## SCOPE / NON-GOALS

Do not:

- redesign the sidebar;
- change the newly approved sidebar spacing;
- change cartouche typography;
- redesign add-folder inspection;
- redesign import running/completion;
- redesign removal execution;
- change source identity;
- change persistence schema;
- add new durable metadata merely for contribution count;
- change DateConverter;
- change mutation authority;
- perform GUI archive mutations.

This task is the selected-existing-source center-panel story and restoration of its existing removal entry action.

## DOCUMENTATION

Create the next Feature 26 implementation record under `responses/`.

Document:

- the rule that sidebar and center panel form one composition;
- sidebar owns object identity;
- center panel owns meaning/management;
- removal of redundant header/subheader/name/status presentation;
- restoration of vertical-track composition;
- authoritative evidence used for import date;
- authoritative evidence, if any, used for unique contribution;
- omission behavior when evidence is unavailable;
- restored destructive removal entry action.

Update version/changelog according to repository rules.

## VERIFICATION

Run:

- focused Historical Archives selected-source/panel tests;
- sidebar/context tests;
- removal-entry/confirmation tests;
- Settings tests as appropriate;
- architecture tripwires;
- `flutter analyze`;
- formatting;
- `git diff --check`.

Commit and push if clean.

STOP after this selected-source redesign.

Do not proceed into valid-folder ingestion yet.

Report:

- final primary center-panel wording/structure;
- exact vertical-track primitive reused;
- import-date evidence source;
- unique-contribution evidence source or reason omitted;
- exact destructive style reused;
- confirmation that archive identity is not redundantly repeated;
- confirmation that removal execution semantics remain unchanged;
- manual review instructions.
