Work on branch `Ftr.archive-recovery`.

This prompt is PRE-APPROVED for implementation.

This is intentionally a substantial final task for this work session. Begin with the required architecture/execution audit, then proceed directly through the bounded implementation slices below without stopping for intermediate approval, provided the investigation confirms the assumptions and hard invariants.

Do NOT stop merely because the implementation is large.

Stop only if you discover that truthful implementation would require:

- changing source-scoped ingestion semantics;
- changing database schema/persistence format;
- weakening mutation authority;
- inventing progress rather than observing real work;
- modifying donor/source data;
- materially redesigning architecture outside Historical Archives.

Suggested prompt name:

`prompts/32-MAC-MESSAGES-INGESTION-NARRATOR-DIRECTED-INSTRUMENTATION.MD`

# PURPOSE

Complete the **Mac Messages** arm of Historical Archives from successful folder qualification through successful ingestion.

The existing execution mechanics have already been exercised manually and can import the 2012 Messages source successfully.

What remains unacceptable is the old user experience.

During the most recent manual reimport, after choosing a valid Messages folder and authorizing import, the user saw the old large control-panel presentation for roughly 30–60 seconds:

- Execution Gate Blocked;
- Preflight running;
- red/yellow state tiles;
- large status/control sections;
- long periods with unclear meaning;
- eventually everything turned green;
- a Progress panel finally reported completion.

The import itself succeeded and the heatmaps correctly extended back through 2012.

The mechanics work.

The presentation does not.

This task should make valid Mac Messages ingestion the first complete expression of:

**Narrator + Directed Instrumentation**

# DESIGN GRAMMAR ALREADY ESTABLISHED

Preserve these principles.

## Narrator

Narrator provides:

- meaning;
- transitions;
- interpretation;
- genuine human decisions.

Narrator does NOT provide a continuous stream of reassurance.

Avoid repeated:

- “I’ve got you”;
- “Everything is going well”;
- “Still working”;
- generic encouragement.

Narrator speaks at meaningful boundaries, then gets out of the way.

## Directed Instrumentation

Directed Instrumentation provides visible evidence of real machine work.

It answers:

- What has finished?
- What is happening now?
- What remains?

It must derive from actual execution observations.

No fake stages.

No timer-driven progression.

No invented percentages.

No generic long-lived spinner when real sequential work can be observed.

## Human decisions

The human makes decisions.

The human does NOT advance routine workflow.

No:

Next → Next → Next → Next.

If MessageLens knows the next safe operation, it proceeds automatically.

Controls appear only for:

- folder choice;
- consequential import authorization;
- cancellation where genuinely supported;
- retry after a real failure;
- destructive decisions.

# EXISTING HISTORICAL ARCHIVES STRUCTURE

Preserve the now-established sidebar architecture.

Historical Archives

umbrella explanation

`Mac Messages | MessageLens`

MessageLens remains disabled.

Mac Messages arm:

Folders Already Added

[imported source cartouches]

Add from a Messages Folder

[guidance]

Choose Messages Folder…

The virgin hub center panel is empty.

The sidebar and center panel are one composition.

Sidebar:
**which object / which workflow?**

Center:
**what matters / what is happening?**

# EXISTING TRACK GEOMETRY

Historical Archives now participates in shared Tracks A–E.

The fixed upper sidebar geometry and center-panel relationship are established.

The trailing edge of Track E establishes the common start coordinate for the cartouche-list / meaningful center-content region.

Preserve this.

Do not introduce magic top padding.

Do not undo the current sidebar spacing.

The valid-folder/import journey should occupy the center-panel region already earned by the Add workflow.

# EXISTING FOLDER-SELECTION BOUNDARIES

These are already solved and MUST remain unchanged.

## Invalid folder

Folder lacks required regular `chat.db`

→ add attempt terminates  
→ virgin hub restored  
→ modal explains invalid folder  
→ dismissal leaves hub  
→ no orange  
→ no blue  
→ no center error state.

## Already-added folder

Chosen folder canonically resolves to currently imported source

→ add attempt terminates  
→ hub restored  
→ modal says folder already added  
→ dismissal  
→ gentle transient orange correspondence points to matching existing cartouche  
→ fade completely  
→ hub remains virgin.

Do not regress either path.

# VALID NEW FOLDER EARNS THE CENTER PANEL

This task begins at the third branch:

chosen folder

→ contains readable/qualifying `chat.db`

→ is NOT currently added

→ valid new Messages-folder candidate

At this point, and only at this point, the folder has earned center-panel context.

# FIRST: AUDIT THE ENTIRE REAL INGESTION PATH

Before editing presentation, trace the current valid-folder workflow from successful qualification through terminal import success.

Document the exact existing operations and boundaries.

Trace at minimum:

1. folder inspection / source preflight;
2. source metadata/identity registration where applicable;
3. dry-run/comparison against current MessageLens history;
4. human import authorization;
5. archive/source reading;
6. preparation/transformation of archive records;
7. source-scoped import-ledger writes;
8. conversation graph/browsing-data preparation;
9. search/heatmap/support-table rebuilding;
10. shared evidence/read-model refresh;
11. final source membership / readiness verification;
12. terminal success.

These names are NOT assumed to be the real stage boundaries.

Use the implementation as source of truth.

For each actual operation determine:

- where it begins;
- where it completes;
- whether it can fail independently;
- whether it already publishes observations;
- whether a small typed observation can truthfully be emitted at the real boundary;
- whether the operation is pre-authorization inspection or post-authorization mutation.

# REUSE THE REMOVAL LESSON

Removal now has typed execution observations:

`SourceScopedArchiveGraphRemovalObservation`

mapped into Historical Archives removal progress.

Use that implementation as architectural precedent.

Do NOT blindly reuse its types.

Import and removal are different operations.

But the successful lesson is:

execution owns work  
→ typed observations report real boundaries  
→ Historical Archives maps them to human presentation  
→ Directed Instrumentation renders them.

If import currently lacks equivalent observations, introduce the smallest import-specific typed observation seam justified by the real sequential calls.

Do not build a generic application-wide workflow engine.

# PHASE 1 — VALID FOLDER INSPECTION

After a genuinely new valid folder is selected, center-panel context begins.

Narrator should establish meaning briefly.

Representative:

**Let’s see what’s in this Messages folder.**

Then Directed Instrumentation should expose only real inspection work.

If current preflight is only observable as one operation:

MESSAGES FOLDER

Inspecting Messages history Working

That is acceptable.

If truthful sub-observations already exist, expose a small number of useful ones.

Do not fabricate:

Checking folder…
Checking database…
Counting messages…

merely because those sound plausible.

# INSPECTION SUCCESS → INTERPRETATION

When inspection/dry-run completes, replace active inspection with resolved evidence.

The user should immediately understand:

- this is a usable Mac Messages folder;
- how many messages it contains;
- what historical period it covers;
- how much appears genuinely new to MessageLens;
- how much overlaps existing history.

Use the corrected GUID-compatible comparison semantics.

Never regress to the previous impossible:

15,395 already represented  
-6,513 new

Human-facing comparison quantities must share one coherent denominator.

Representative Directed Instrumentation/evidence:

MESSAGES FOLDER

Messages 8,882
Dates Jul 2012 – Jun 2017
New to MessageLens 2,369
Already represented 6,513

Use actual typed facts.

# NARRATOR INTERPRETS THE RESULT

After evidence resolves, Narrator should explain what matters.

Representative meaning:

**This folder can extend your MessageLens history back to July 2012.**

Optionally, where supported:

**I found 2,369 messages that aren’t already in MessageLens.**

Do not over-explain.

Do not repeat every number already visible in instrumentation.

Narrator interprets; instrumentation supplies evidence.

# HUMAN IMPORT DECISION

Only now present the genuine consequential action.

Use a clear action such as:

`Add Messages to MessageLens`

or:

`Import Messages`

Choose wording consistent with the established “Folders Already Added” / “Add from a Messages Folder” vocabulary.

Prefer human vocabulary over implementation terminology.

Do not call it Begin Import merely because the old panel did.

There may also be:

`Choose a Different Folder`

only if it is genuinely useful in this active valid-candidate context.

Do not duplicate the sidebar chooser unnecessarily.

Determine the cleanest responsibility from the now-established hub model.

The important invariant is:

nothing mutates before explicit human authorization.

# IMPORT AUTHORIZATION MODAL

Audit whether the current import button directly begins mutation.

For a consequential operation adding thousands of historical records, decide whether a confirmation modal is already part of the current interaction or is warranted by existing MessageLens conventions.

Do NOT add a redundant “Are you sure?” modal if the ready-state evidence plus explicit `Add Messages to MessageLens` action already constitutes clear informed authorization.

Prefer one meaningful decision over confirmation theater.

Document the decision.

# POST-AUTHORIZATION: OPERATION OWNS CENTER PANEL

Once import is authorized:

- ready-state decision content disappears;
- folder-management/inspection controls disappear;
- import operation becomes sole center-panel context;
- Narrator transitions briefly;
- Directed Instrumentation takes over.

Representative Narrator:

**Adding this Messages folder to MessageLens.**

Then stop narrating while the machine works.

# REAL IMPORT STAGES

Expose the real post-authorization sequential work discovered in the audit.

Likely human concepts may include things such as:

- Reading messages from this folder
- Adding messages to MessageLens
- Preparing conversations
- Updating search and timeline views
- Checking that everything finished

BUT THESE LABELS ARE ONLY EXAMPLES.

Every row must correspond to a real execution boundary.

Do not add five rows merely because five looks good.

If the implementation has three meaningful observable phases, show three.

If it has six but several are too technical and inseparable from a human perspective, map them carefully without lying about progress.

A human-facing stage may aggregate contiguous real operations only when its active/completed boundary remains truthful.

# DIRECTED INSTRUMENTATION GRAMMAR

Use the removal journey as the visual precedent.

Each row may be:

- Done;
- Working;
- Waiting;
- Failed.

Completed rows remain visible.

Exactly one stage should be Working during strictly sequential work.

Later stages remain Waiting.

No percentages.

No timer-driven advancement.

No artificial delays to make fast stages visible.

If a stage completes before the UI renders it active, it may simply appear Done.

Truth over theater.

# REMOVE THE OLD GIANT CONTROL PANEL

For the new valid-folder journey, the old presentation must no longer dominate the user experience.

Do not show the old primary stack of:

- Execution Gate Blocked;
- Preflight Running;
- gate cards;
- giant preflight summary;
- dry-run summary;
- activity log;
- Progress panel;
- result summary;
- technical status blocks.

These may remain available under Details/diagnostics where useful.

The ordinary journey should not require scrolling to discover success.

# DETAILS

Use a collapsed Details disclosure where appropriate.

Technical evidence may include:

- source path;
- exact `chat.db` path;
- chat count;
- handle count;
- missing GUID diagnostics;
- exact timestamps;
- source key;
- dry-run methodology;
- execution gate state;
- internal stage/activity history;
- source registration information.

Do not delete diagnostic evidence merely because it leaves the primary journey.

# SIDEBAR DURING IMPORT

This requires careful semantics.

Before terminal success, the new folder does NOT yet qualify for:

Folders Already Added

merely because import has begun.

Do not prematurely create a permanent imported-source cartouche.

However, the sidebar must not contradict the active journey.

Determine the smallest transient presentation needed.

Potentially:

- Add workflow remains the active sidebar context;
- chooser/add controls become unavailable while mutation runs;
- Folders Already Added remains based on durable imported truth;
- no new cartouche appears until terminal success.

Do not lie in the durable read model.

# TERMINAL SUCCESS

Successful import should be derived from the complete operation, not merely source-row insertion.

Before presenting success, establish that:

- source-scoped imported facts were written successfully;
- graph/browsing preparation completed;
- search/heatmap/support refresh completed as required;
- final readiness/membership verification succeeded.

Then the source legitimately qualifies for:

Folders Already Added.

# SUCCESS TRANSITION

Do not leave the user on a giant permanent “Import Complete” report.

Prefer a concise completion moment followed by natural object creation.

A strong candidate sequence is:

final stage becomes Done  
→ brief Narrator completion:

**Done. This folder is now part of MessageLens.**

→ newly added cartouche appears under Folders Already Added  
→ optional gentle orange referential correspondence may point to the new cartouche ONLY if semantically useful  
→ add workflow ends  
→ return to virgin hub  
→ center panel becomes empty.

However, do not blindly implement the orange reference.

Consider its established meaning:

“This is the thing I am referring to.”

If the completion Narrator says “This folder is now part of MessageLens,” a brief gentle correspondence to the newly created cartouche may be appropriate.

If implemented:

- use the same gentle fade-in / hold / fade-out grammar already established;
- no deep orange;
- no pulse;
- no blue selection;
- reference is process-only;
- clear completely.

If the new cartouche appearing is already sufficient evidence, omit the orange.

Use judgment and document the decision.

# SUCCESS MUST BE ABOVE THE FOLD

At no point should the user have to scroll down to discover whether import succeeded.

The active/completion instrumentation must occupy the primary center-panel region.

# FAILURE SEMANTICS

Audit failures at each real stage.

If inspection fails before authorization:

- preserve the already-established qualification/error boundaries;
- do not mutate;
- present only truthful retry/change-folder options.

If post-authorization import fails:

- completed stages remain Done;
- actual failing stage becomes Failed;
- later stages remain Waiting/not started;
- do not claim success;
- do not create a Folders Already Added cartouche unless durable imported truth and overall workflow semantics genuinely justify it.

Partial mutation is especially important.

If source rows were written but graph preparation or finalization failed:

- do not simply classify the source as successfully added because positive imported facts exist;
- do not silently return to hub;
- surface the incomplete operation truthfully;
- preserve/recover enough context for retry or repair according to current architecture.

If current architecture cannot safely represent a partial import failure, STOP and report the exact gap rather than inventing recovery semantics.

# IMPORT / MAINTENANCE AUTHORITY

Preserve the owner-aware ArchiveMutationCoordinator design.

Historical import is an admitted operation.

Its authorized graph/database access must work inside its own scope.

Unrelated callers remain mechanically blocked.

No pre-open workaround.

No ordering hack.

No broad database availability escape hatch.

# ONBOARDING INVARIANT

During legitimate import maintenance:

- Environment Readiness must not appear;
- graph rebuilding must not become `graphProjectionFailed`;
- active maintenance remains `maintenanceInProgress`;
- Historical Archives remains the visible journey until terminal success/failure.

Add regression tests around the new observation invalidations.

# DATE CONVERSION INVARIANT

ALL Apple timestamps continue through:

`lib/core/util/date_converter.dart`

Do not add local Apple epoch arithmetic.

Do not add magnitude heuristics elsewhere.

Preserve the architecture tripwire prohibiting alternate conversion schemes.

# SOURCE SAFETY

Historical Messages source is read-only input.

Import must not modify:

- source `chat.db`;
- source WAL/SHM content;
- source Attachments;
- original donor folder.

Preserve the immutable/read-only historical-source opening correction already established.

# ATTACHMENTS

Do not broaden this task into historical attachment-payload recovery.

The Mac Messages arm currently accepts a valid `chat.db` without requiring Attachments.

Preserve that behavior.

If attachment metadata is part of the existing import facts, leave existing mechanics intact.

Do not build attachment payload ingestion in this task unless it is already an inseparable part of the current successful import path.

# LIVE MESSAGE CATCH-UP

Preserve current production/development live-source behavior.

Historical import must not interfere with normal source-1/current-Mac data.

Tests must prove unrelated current-source facts survive.

# SOURCE-SCOPED DUPLICATION

Preserve the established architecture:

overlapping historical GUIDs may exist as separate source occurrences where source-scoped ingestion requires that.

Do not “deduplicate” by destroying source provenance.

Human-facing dry-run comparison may describe overlap by GUID, but durable source-scoped identity remains intact.

# CARTOUCHE MEMBERSHIP

Preserve the established rule:

Folders Already Added

means:

canonical source identity

- positive/current successfully-added source truth according to the finalized workflow semantics.

Do not list preflight-only remembered sources.

Do not list merely inspected folders.

Do not confuse source registry memory with successfully added archive membership.

If current membership needs a transient completion guard to avoid premature appearance during import, use presentation state rather than falsifying repositories.

# TRACKS

Preserve Historical Archives shared Tracks A–E.

Valid-folder inspection/import center content should use the same meaningful center region.

Do not add magic top offsets.

Do not disturb the approved sidebar spacing.

# PRESENTATION CONTEXT MODEL

Extend the current transient Historical Archives presentation context only as necessary.

Existing concepts include:

- `hub`;
- `existingSource`;
- `addArchive`;
- duplicate/invalid notices;
- removal operation context.

Add the smallest explicit import/inspection states needed to prevent semantic leakage.

For example, if justified:

- inspectingCandidate;
- readyToAdd;
- addingArchive;
- importFailed.

Do not create a generic state-machine framework.

The important requirement is mechanical impossibility:

each context can render only controls/evidence meaningful to that context.

# SIDEBAR / CENTER RESPONSIBILITY

Preserve:

Sidebar:

- source-type selection;
- existing imported folders;
- initiate Add from a Messages Folder;
- explain what folder to locate.

Center:

- inspect a valid candidate;
- interpret evidence;
- request genuine import authorization;
- show active import journey;
- show failure where meaningful.

A valid candidate earns the center panel.

An invalid or duplicate candidate does not.

# TESTS

Add/update comprehensive focused tests covering at minimum:

## Qualification / inspection

1. valid new folder earns add/import center context;

2. invalid folder still uses modal → hub;

3. duplicate already-added folder still uses modal → hub → gentle reference;

4. inspection automatically begins after valid selection;

5. inspection presentation uses only real observations;

6. successful inspection produces typed message/date/comparison evidence;

7. GUID comparison arithmetic cannot become negative or exceed its denominator;

8. no preflight-only source becomes a Folders Already Added cartouche;

9. inspection does not mutate source data or MessageLens imported facts;

10. successful inspection automatically reaches the genuine human import-decision state without Next controls.

Import authorization

11. no import mutation occurs before explicit human authorization;

12. import authorization is available only after successful current inspection;

13. stale persisted preflight knowledge cannot authorize import;

14. authorizing import enters a dedicated import-operation presentation context;

15. ready-state controls disappear once import begins;

16. no redundant confirmation step is introduced unless the audit establishes that current product safety conventions genuinely require one.

Directed Instrumentation

17. every displayed import stage corresponds to a real execution boundary;

18. no timer-generated or fabricated progress stages exist;

19. completed stages remain visible;

20. the current real stage is visibly active;

21. future stages remain waiting/not started;

22. no percentage is displayed without a real measurable denominator;

23. the old giant Execution Gate / Preflight / Activity Log / Progress / Result control-panel stack is absent from the ordinary journey;

24. technical execution evidence remains available under Details where useful;

25. no generic long-lived spinner substitutes for observable sequential work.

Import correctness

26. source-scoped historical facts are written using existing source identity semantics;

27. overlapping GUIDs preserve source provenance;

28. source-1/current-Mac facts survive unchanged;

29. graph/browsing preparation uses the admitted owner-aware mutation scope;

30. unrelated callers remain blocked during maintenance;

31. DateConverter remains the sole Apple timestamp conversion authority;

32. imported historical dates remain correct for Apple-second-era data;

33. source chat.db and donor/source files remain byte-for-byte untouched in appropriate fixture tests;

34. Attachments remains optional for this Messages-history ingestion path.

Success

35. a source does not appear under Folders Already Added merely because import has started;

36. terminal success requires all real required import/rebuild/finalization stages to succeed;

37. successful terminal verification causes the source to qualify for Folders Already Added;

38. the new cartouche appears only at terminal success;

39. import context ends automatically after success;

40. the UI returns to the virgin Historical Archives hub;

41. center panel becomes empty;

42. no Done or Next button is required;

43. completion is visible above the fold before/while the journey resolves to the hub;

44. any transient orange correspondence to the newly created cartouche, if implemented, is semantically justified, gentle, bounded, and non-persistent.

Failure / partial failure

45. inspection failure before authorization performs no import mutation;

46. a post-authorization failing stage is marked Failed;

47. genuinely completed earlier stages remain Done;

48. later unstarted stages do not falsely become Done;

49. partial import failure cannot be presented as success merely because source rows now exist;

50. a failed/incomplete source does not incorrectly become an ordinary Folders Already Added object unless current durable semantics prove successful addition;

51. maintenance-related invalidations do not divert the user into Onboarding;

52. retry/recovery controls appear only when existing architecture truthfully supports them.

Regression

53. duplicate-folder modal/reference behavior remains unchanged;

54. invalid-folder modal behavior remains unchanged;

55. existing-source blue selection remains unchanged;

56. removal journey and its Directed Instrumentation remain unchanged;

57. navigation-away session guards still prevent stale async work from resurrecting abandoned Historical Archives presentation;

58. Historical Archives Tracks A–E remain intact;

59. approved Mac Messages sidebar wording and spacing remain unchanged;

60. MessageLens segment remains disabled and mechanically inert.

Do not treat the exact number of tests as a requirement for sixty separate test methods. Cover these behaviors with the smallest clear set of focused tests.

SAFETY / MANUAL STAGING

Do not perform the real GUI import yourself.

Automated tests must use fixtures, temporary databases, or existing isolated test infrastructure.

Do not mutate:

- production MessageLens data;
- the disposable staging archive used for human review;
- frozen production snapshots;
- `/Volumes/WD_ELEMENTS/Old_Messages/Messages_2012`;
- `/Volumes/WD_ELEMENTS/ARCHIVE_INGESTION_TRIAL/Messages_2012-DONOR`;
- the historical donor/source;
- real attachment payloads.

The human will perform the final staging rehearsal.

DOCUMENTATION

Create the next Feature 26 implementation record under `responses/`.

This should be a substantial implementation record documenting:

1. the audited real import execution sequence;

2. pre-authorization versus post-authorization boundaries;

3. exact typed import observations introduced or reused;

4. mapping from execution observations to human-facing Directed Instrumentation;

5. final Narrator transitions;

6. ready-for-import evidence and decision;

7. removal of the old giant control-panel journey from the primary UX;

8. Details/diagnostic disposition;

9. success semantics and cartouche-appearance boundary;

10. partial-failure semantics;

11. source-1 protection;

12. donor/source immutability;

13. DateConverter invariant;

14. mutation-authority/Onboarding protection;

15. preservation of Tracks and sidebar responsibility;

16. explicit non-goals, including MessageLens-folder ingestion and attachment-payload recovery.

Update Feature 26 start/index/log documentation as required by repository conventions.

Update version/changelog according to repository rules.

VERIFICATION

Run the appropriate comprehensive verification, including:

- focused Historical Archives inspection/import/presentation tests;
- source-scoped import tests;
- graph import/projection tests;
- mutation-coordinator and owner-aware admission tests;
- Onboarding/readiness regression tests;
- Settings tests;
- DateConverter/timestamp tests;
- relevant Track/layout tests;
- complete architecture tripwire suite;
- `flutter analyze`;
- `dart format` / repository formatting checks;
- `git diff --check`;
- macOS debug build if required by repository conventions.

Commit and push if clean.

STOP CONDITION

STOP after the **Mac Messages valid-folder ingestion journey** is implemented, documented, verified, committed, and pushed.

Do NOT proceed into:

- MessageLens-folder ingestion;
- enabling the MessageLens segmented-control arm;
- historical attachment-payload recovery;
- Presence guidebook work;
- unrelated UI cleanup.

REPORT BACK WITH

1. exact real import stages discovered;

2. exact typed observation seam introduced/reused;

3. exact human-facing Directed Instrumentation rows;

4. final valid-folder inspection/ready-state presentation;

5. exact human import-authorization wording;

6. whether an additional confirmation modal was used and why;

7. exact success transition and cartouche timing;

8. failure/partial-failure behavior;

9. confirmation that the old giant control-panel presentation is no longer the ordinary valid-import journey;

10. confirmation that source-1/current-Mac data is protected;

11. confirmation that donor/source files remain untouched;

12. confirmation that DateConverter remains the sole Apple timestamp authority;

13. confirmation that Onboarding cannot appear merely because admitted import maintenance is underway;

14. manual staging instructions for importing `Messages_2012-IMPORT_SOURCE` and observing the complete Narrator + Directed Instrumentation journey.
