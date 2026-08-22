Work on the current Feature 27 branch/worktree according to repository conventions.

This prompt is PRE-APPROVED for implementation.

Feature 27’s semantic/query correction is complete.

The report now has a trustworthy mathematical foundation and a fast set-based query.

This task designs and implements the **human-facing Message History Coverage report** on top of that truth.

Do not reopen the denominator/category architecture unless implementation exposes a genuine contradiction.

Suggested prompt name:

`03-MESSAGE-HISTORY-COVERAGE-PRODUCT-PRESENTATION.MD`

# Settled semantic model

Treat the following as authoritative.

## Denominator

Every physical current-Mac:

`chat.db.message.ROWID`

## Exactly one terminal category per denominator row

### Conversation-linked

The current-source message is represented in MessageLens and linked into the conversation graph.

### Recovered / unlinked

The current-source message is represented in MessageLens but is not linked to a normal conversation and belongs to the canonical recovered/unlinked path.

### Unaccounted

The current `chat.db` row cannot be reconciled to either accounted-for category.

## Exact invariant

`conversationLinked + recoveredUnlinked + unaccounted = totalCurrentMessages`

No clamps.

No historical-source contamination.

No gross graph-count arithmetic.

## Overall report states

- complete;
- incomplete;
- temporarilyUnavailable;
- failed.

## Performance

Representative corrected query:

- 137,340 current-source rows;
- approximately 0.10 seconds.

Therefore:

> Do not build a theatrical loading/progress journey for an operation that normally completes in approximately one tenth of a second.

# Product purpose

The user should be able to answer:

> Has MessageLens accounted for every message currently stored in this Mac’s Messages database?

If yes, the page should communicate that simply and confidently.

If not, the page should make the exception understandable and, where architecture supports it, inspectable/actionable.

The page is a **coverage report**, not a database diagnostics dashboard.

# First — inspect current completed presentation

Before editing, inspect the existing completed report UI and its tests.

Document briefly:

- current headings;
- cards;
- counts;
- status language;
- colors/icons;
- actions;
- diagnostics;
- layout;
- any stale assumptions from the old arithmetic.

Remove/rewrite only what no longer serves the corrected semantic model.

# Governing presentation principle

The amount of UI should be proportional to the amount of uncertainty and required action.

When everything is accounted for, the report should be calm and concise.

When exceptions exist, the exceptions become the focus.

Do not make a healthy result look like an aircraft cockpit.

# Sidebar

Audit the existing sidebar copy against the corrected semantics.

The sidebar should explain, concisely:

- this report compares the messages currently stored by Messages on this Mac with MessageLens’s current-source accounting;
- messages may be accounted for either in normal conversations or through the recovered/unlinked path;
- the report identifies anything that MessageLens cannot account for.

Do not mention implementation concepts such as:

- source 1;
- source-scoped IDs;
- graph rows;
- SQL;
- ROWID.

The existing `chat.db` reference may remain if it genuinely helps the intended audience, but reconsider whether it is necessary in primary copy.

Do not over-explain.

# Center-panel hierarchy

Use the established Settings/Track architecture.

The report should have a stable center composition consistent with polished MessageLens Settings features.

Do not simply center a status card vertically in unused space.

Determine the correct Tracks from current Settings architecture.

Use Tracks rather than magic top padding.

# Immediate first paint

Because the query is now ~0.10 seconds:

- publish a truthful neutral report/loading state immediately;
- allow result to replace it naturally;
- do not deliberately delay the result so the loading state can be seen;
- do not add spinner choreography;
- do not add Narrator solely because computation occurred.

A brief native loading indicator is acceptable if it appears naturally on slower hardware.

But if the result arrives before it is perceptible, that is ideal.

# Narrator decision

Default recommendation:

**No Narrator during normal report calculation.**

Narrator is useful when human meaning/scope changes during extended work.

That is not normally true here.

The final report itself should communicate the meaning.

Do not import Feature 26’s operation grammar where it is not earned.

# Complete state

When:

`unaccounted == 0`

the report is complete.

The primary human message should be approximately:

**All messages on this Mac are accounted for**

or:

**Your message history is fully accounted for**

Choose wording based on existing product voice and sidebar context.

Be precise about scope.

Avoid wording that could imply Historical Archives messages are included in the denominator if they are not.

For example, “All messages in MessageLens” would be wrong.

# Complete-state evidence

Show enough evidence to substantiate the conclusion without overwhelming it.

Potential hierarchy:

**All messages on this Mac are accounted for**

`137,340 messages`

Then perhaps a restrained breakdown:

- In conversations: 137,2xx
- Recovered/unlinked: xx

Do not make `Unaccounted: 0` visually dominant if the headline already says everything is accounted for.

It may be useful as explicit evidence, but use judgment.

# Recovered/unlinked wording

The technical category name may not be appropriate as primary UI.

Determine the established user-facing terminology from Recovered Messages.

Potential meanings:

- Recovered messages;
- Messages recovered outside conversations;
- Recovered but not linked to a conversation.

Use terminology consistent with the owned feature.

Do not invent a new synonym if the app already has canonical wording.

# Complete state with recovered/unlinked messages

A report can still be fully accounted for when some messages are recovered/unlinked.

This distinction should be understandable.

For example:

> MessageLens has accounted for all 137,340 messages on this Mac.
> 137,323 appear in conversations and 17 are available in Recovered Messages.

This is illustrative, not mandatory copy.

The important semantic rule is:

> recovered/unlinked is accounted-for, not a warning.

Do not color it as failure merely because it is outside a normal conversation.

# Incomplete state

When:

`unaccounted > 0`

do NOT use reassuring “Fully Accounted For” language.

The primary message should state the exception clearly.

Representative:

**12 messages have not been accounted for**

or:

**MessageLens couldn’t account for 12 messages on this Mac**

Use product voice.

Then provide the full denominator context:

`137,328 of 137,340 accounted for`

or equivalent.

Do not use percentages as the sole evidence.

# Severity

Unaccounted messages are meaningful but not necessarily catastrophic.

Avoid giant red error treatment unless the design system uses destructive red specifically for data-integrity failure.

Prefer a clear caution/warning treatment consistent with MessageLens.

The report is identifying an exception, not announcing database corruption.

# Actionability audit

Before adding any action, determine what the user can genuinely inspect.

Audit whether the exact unaccounted current-source ROWIDs can be projected into:

- a list;
- Recovered Messages;
- Unknown Sources;
- another evidence view.

If an existing canonical destination can show them, provide a clear action such as:

`Review unaccounted messages`

only if it actually lands on those exact messages.

Do not add a button that merely navigates vaguely to another feature.

If no exact inspection path exists yet:

- report the count honestly;
- put technical identifiers/examples under Details if appropriate;
- document the missing action as a future bounded slice.

Do not invent a new browser in this task unless the implementation is trivial and already supported by canonical evidence.

# Recovered Messages action

If `recoveredUnlinked > 0` and Recovered Messages is an existing user-facing destination that displays precisely that category, consider a subtle action:

`View Recovered Messages`

This should not imply a problem.

Use existing navigation architecture.

Do not duplicate Recovered Messages inside the coverage report.

# Primary numerical presentation

Design a compact breakdown.

Potential model:

Total messages on this Mac 137,340
In conversations 137,323
Recovered messages 17
Unaccounted 0

But avoid reverting to a sterile `HEADER > item:value` diagnostics table if a more human composition works better.

Feature 26 established that center panels can tell a concise story instead of satisfying a formal header contract.

Use that lesson.

# Possible visual representation

Consider whether a simple scalar/segmented representation adds value.

For example, a thin horizontal coverage bar could show:

- conversation-linked;
- recovered;
- unaccounted.

However:

- do not create a chart merely because this is a report;
- tiny recovered/unaccounted populations may be visually invisible;
- exact counts remain more important.

If a visual representation does not materially improve comprehension, omit it.

Do not spend scope on chart infrastructure.

# Details disclosure

Use **Details** for diagnostic evidence that advanced users/agents may need.

Potential content:

- total current `chat.db` rows;
- exact category counts;
- report generated time;
- current source identity;
- invariant reconciliation;
- perhaps sample unaccounted IDs if safe/useful;
- maintenance/read failure diagnostics.

Do not expose:

- raw SQL;
- implementation stack traces;
- internal provider names.

Technical logs remain elsewhere.

# Temporarily unavailable state

When maintenance prevents a truthful report:

show a calm, honest state.

Representative:

**Message history coverage is temporarily unavailable**

> MessageLens is currently updating its message data. The report will be available when that work finishes.

Do not:

- show zero;
- show stale complete result;
- trigger Onboarding;
- present failure.

If existing architecture automatically refreshes when maintenance ends, do so.

If not, provide a simple Retry action only if needed.

# Failed state

A real failure should be distinct.

Representative:

**Message history coverage couldn’t be checked**

Provide:

- concise explanation;
- Retry if safe;
- Details for diagnostic evidence.

Do not convert failure to `temporarilyUnavailable` unless maintenance is actually the cause.

# Loading state

Replace the old visually detached:

**Loading Message History Coverage…**

with a composition that belongs to the same stable report layout.

Because normal calculation is ~0.10 seconds, keep this minimal.

No elaborate Directed Instrumentation.

No artificial minimum duration.

# Tracks

Audit nearby Settings features and use the established Track matrix appropriately.

Goals:

- sidebar and center read as one page;
- result begins at a deliberate shared vertical coordinate;
- loading/result/unavailable/failed states share the same structural skeleton;
- state transitions do not make the report jump unnecessarily.

Do not redesign global Tracks.

# Selection/navigation lifecycle

When navigating away:

- stale report completion must not overwrite a newer Settings context;
- returning should recompute or reuse evidence according to existing provider policy;
- do not persist presentation-only report state unnecessarily.

Use existing Settings/session architecture.

# Accessibility

Apply current project conventions.

Ensure:

- headline status is available semantically;
- counts have understandable labels;
- warning state is not conveyed by color alone;
- Details is accessible;
- actions have meaningful labels;
- loading/unavailable states have appropriate semantics.

Do not add noisy live-region announcements for a ~0.10-second calculation unless platform conventions require them.

# Copy discipline

Avoid implementation terminology in primary UI:

- graph;
- source 1;
- source-scoped;
- ROWID;
- denominator;
- reconciliation.

The user-facing concept is:

> Messages currently on this Mac, and whether MessageLens knows where each one belongs.

# Historical Archives distinction

Do not imply this report measures every message MessageLens has ever imported.

Historical Archives messages are deliberately outside the denominator unless they also physically exist in the current Mac `chat.db`.

The wording must make this scope clear.

# Tests — presentation

Add/update focused tests covering:

1. complete state headline;

2. complete state with recovered/unlinked messages remains complete;

3. recovered/unlinked is not presented as failure;

4. incomplete state names exact unaccounted count;

5. incomplete state never shows complete language;

6. total/category counts render from typed report without UI arithmetic;

7. historical-source rows cannot appear in presentation counts;

8. temporarilyUnavailable has distinct copy;

9. failed has distinct copy;

10. loading uses stable layout;

11. no artificial loading delay;

12. Details exposes diagnostics appropriately;

13. exact navigation action exists only when backed by canonical evidence;

14. accessibility semantics do not rely on color.

Do not create one test per item mechanically.

# Tests — architecture/regression

Preserve Prompt 02 protections:

- exact partition invariant;
- no clamp;
- current-source identity only;
- historical-source exclusion;
- maintenance suppression;
- fast set-based query.

Add Track/layout tripwires where useful.

# Do not change

Do not change:

- denominator;
- category semantics;
- source-scoping rules;
- graph ownership;
- Recovered Messages ownership;
- maintenance authority;
- database schemas.

If presentation work reveals a semantic defect, STOP and report rather than quietly redefining the report.

# Documentation

Create:

`03-MESSAGE-HISTORY-COVERAGE-PRODUCT-PRESENTATION-IMPLEMENTATION.md`

under Feature 27 responses.

Document:

- final page hierarchy;
- complete/incomplete/unavailable/failed presentation;
- exact final copy;
- recovered-message treatment;
- actionability decisions;
- loading behavior;
- Narrator decision;
- Track mapping;
- accessibility;
- tests.

Update Feature 27 index/documentation log.

Update version/changelog according to repository rules.

# Verification

Run:

- Message History Coverage tests;
- Settings presentation/layout tests;
- Recovered Messages navigation tests if touched;
- maintenance/readiness regressions;
- architecture tripwires;
- full Flutter suite if feasible;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build.

Commit and push if clean.

# Stop conditions

STOP if:

- there is no truthful way to distinguish complete/incomplete in presentation;
- recovered/unlinked terminology conflicts with canonical Recovered Messages semantics;
- exact unaccounted-message navigation would require a new feature;
- Tracks require global redesign;
- presentation requires changing Prompt 02 semantics.

# Final report

Report:

- final complete-state copy;
- final incomplete-state copy;
- numerical hierarchy;
- treatment of recovered/unlinked messages;
- whether an exact unaccounted-message action exists;
- temporarilyUnavailable/failed behavior;
- loading behavior;
- Narrator decision;
- Track mapping;
- accessibility work;
- tests/verification;
- commit hash;
- manual review instructions.

Acceptance standard:

> A healthy report should tell the user, calmly and with just enough evidence, that every message currently on this Mac is accounted for. An incomplete report should make the exact exception unmistakable and actionable where possible. Neither state should expose the database machinery required to prove it.
