Work on branch Ftr.archive-recovery.

This prompt is PRE-APPROVED for implementation. After your planning pass, proceed directly with the bounded implementation below unless investigation reveals a genuine architectural conflict.

Suggested prompt name:

`prompts/29-HISTORICAL-ARCHIVE-SELECTED-SOURCE-TRACK-ALIGNMENT.MD`

This is a presentation/layout refinement only.

Do not change the selected-source wording, removal behavior, sidebar spacing, archive semantics, or any ingestion workflow.

CURRENT STATE

Prompt 27 / Response 28 successfully simplified the selected-source center panel.

The current center content is:

- “This is a Mac Messages folder.”
- trustworthy import date when available;
- human-readable message count and date range;
- More Details;
- Remove this folder… with existing destructive confirmation flow.

Archive identity remains solely in the blue-selected sidebar cartouche.

This content is correct.

The remaining problem is spatial.

CURRENT LAYOUT ISSUE

The center-panel content currently begins near the top of the center region using:

`SingleChildScrollView → Center → ConstrainedBox(maxWidth: 760) → left-aligned Column`

This makes the content read as though it belongs to Historical Archives generally.

But the content actually belongs to the selected archive cartouche in the sidebar.

MessageLens already has a vertical-track / column-band architecture specifically to make sidebar and center-panel relationships spatially coherent.

Use it.

GOAL

Align the top of the selected-source center-panel story with the top of the selected archive cartouche in the sidebar.

Conceptually:

SIDEBAR CENTER

umbrella copy [empty corresponding band]

Mac Messages | MessageLens [empty corresponding band]

major section spacer [empty corresponding band]

Folders Already Added [empty corresponding band]

[selected archive cartouche] This is a Mac Messages folder.
...
More Details
Remove this folder…

The layout itself should communicate:

“This center content belongs to that selected archive object.”

No repeated folder name, arrow, orange reference, or extra heading is necessary.

TRACK/BAND REQUIREMENT

Do NOT achieve the alignment by adding:

- a magic `SizedBox(height: ...)`;
- hard-coded top padding;
- a locally measured pixel offset;
- viewport-relative spacing;
- duplicated copies of sidebar spacing constants.

Use the existing shared vertical-track / column-band mechanism.

Inspect the current MessageLens track implementation, including the shared vertical column-band definitions already used elsewhere.

Extend or consume the existing track vocabulary narrowly if Historical Archives does not yet have named bands for these elements.

Do not create a second local track system.

TRACKS TO REPRESENT

The existing sidebar hierarchy should mechanically correspond to bands for at least:

1. umbrella/context block;
2. source-type segmented control;
3. major spacer before existing folders;
4. Folders Already Added heading;
5. first/selected cartouche region.

The center panel should consume the same earlier bands as empty structural space and begin selected-source content at the cartouche band.

Do not put visible placeholder widgets in those empty bands.

They are structural tracks, not blank cards.

MULTIPLE CARTOUCHES

Design this carefully enough that the solution does not secretly assume there will always be exactly one archive.

The future sidebar may contain multiple Folders Already Added cartouches.

If an existing vertical-track model can associate center content with the selected row/object, use that.

If the current band architecture only supports fixed global bands and cannot truthfully align to an arbitrary selected cartouche in a variable list, STOP and report that architectural limitation rather than implementing a fake fixed offset.

Do not over-engineer a generic scrolling synchronization system in this slice.

The immediate goal is to use the established track model honestly.

WIDTH / HORIZONTAL ALIGNMENT

Preserve the existing sensible max-width behavior unless the track integration requires a small structural adjustment.

The center content should remain left-aligned and readable.

Do not stretch prose across the full center panel.

This task is about vertical correspondence, not width redesign.

PRESERVE SELECTED-SOURCE STORY

Do not alter:

- “This is a Mac Messages folder.”
- trustworthy import-date behavior;
- human-readable message count/date range;
- omission of unsupported unique-contribution count;
- More Details;
- Remove this folder…;
- destructive styling;
- confirmation flow.

Do not reintroduce:

- archive name;
- Historical Archives title;
- Historical Messages Archive subhead;
- status rows;
- green checks.

SIDEBAR

Do not modify the currently approved sidebar hierarchy or spacing.

The current three-region spacing is working well.

Preserve:

- umbrella copy;
- Mac Messages | MessageLens control;
- Folders Already Added;
- cartouche layout;
- Add from a Messages Folder section;
- all current gaps.

The center should adapt to the established sidebar tracks, not vice versa.

MECHANICAL RESPONSIBILITY

Preserve the rule:

Sidebar = which object?

Center panel = what matters about that object?

The shared tracks provide the spatial relationship between those responsibilities.

TESTS

Add/update focused layout/architecture tests proving:

1. selected-source content begins on the archive-cartouche vertical track;

2. umbrella/context bands remain visually empty in the center;

3. segmented-control band remains visually empty in the center;

4. Folders Already Added heading band remains visually empty in the center;

5. no magic fixed top inset is introduced;

6. existing shared track/band definitions are used;

7. center content remains left-aligned and width-constrained;

8. sidebar spacing/content is unchanged;

9. selected-source wording/actions are unchanged;

10. virgin hub center remains empty;

11. addArchive context remains unaffected;

12. navigation-away reset remains unchanged.

Avoid brittle screenshot-coordinate assertions where possible.

Prefer structural assertions against named track/band composition.

SCOPE / NON-GOALS

Do not:

- redesign sidebar;
- redesign selected-source copy;
- redesign removal;
- redesign valid-folder ingestion;
- implement MessageLens ingestion;
- change source identity;
- change persistence;
- change DateConverter;
- change mutation authority;
- change database schema;
- add generic scroll synchronization;
- perform GUI archive mutations.

DOCUMENTATION

Create the next Feature 26 implementation record under responses/.

Document:

- why selected-source content aligns with the selected sidebar object rather than the top of the feature;
- shared track/band definitions used;
- any narrow track extension made;
- how empty center bands are structural rather than content;
- behavior with multiple possible cartouches;
- confirmation that no magic top offset was introduced.

Update version/changelog according to repository rules.

VERIFICATION

Run focused Historical Archives panel/layout tests, shared track/band tests, Settings tests, architecture tripwires, flutter analyze, formatting, and git diff --check.

Commit and push if clean.

STOP after this alignment refinement.

Do not proceed into valid-folder ingestion yet.

Report:

- exact shared track mechanism reused;
- exact band where selected-source content begins;
- whether multiple-cartouche alignment required any limitation;
- confirmation that no hard-coded top spacer was used;
- confirmation that sidebar/content semantics remained unchanged;
- manual review instructions.
