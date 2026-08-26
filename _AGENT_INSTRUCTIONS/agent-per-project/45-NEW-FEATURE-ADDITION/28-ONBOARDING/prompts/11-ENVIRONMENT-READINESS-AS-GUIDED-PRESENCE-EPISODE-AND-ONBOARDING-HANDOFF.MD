Work on the current Feature 28 branch/worktree according to repository conventions.

This prompt is PRE-APPROVED for implementation.

Feature 28 now has:

- durable typed Onboarding operation truth;
- real progress instrumentation;
- production-shaped performance validation;
- dependency-aware anomaly handling;
- production-shaped anomaly validation;
- preservation-safe Start Fresh;
- responsive Start Fresh execution;
- a healthy initial import that completes briskly and visibly advances.

The next problem is now primarily **human guidance and spatial ownership**.

Current Environment Readiness exposes too much machinery at once. The user can land on a dashboard containing:

- four readiness checks;
- sidebar status;
- large Re-check action;
- Ready To Import card;
- three-step “What to do” instructions;
- Current machine view diagnostics;
- Import action below the viewport.

This is not acceptable Onboarding behavior.

The page should answer:

> **What do I need to know or do right now?**

not:

> “Here is everything the readiness subsystem knows.”

Suggested prompt name:

`11-ENVIRONMENT-READINESS-AS-GUIDED-PRESENCE-EPISODE-AND-ONBOARDING-HANDOFF.MD`

# Central product principle

Environment Readiness is an **Onboarding Episode**, not a diagnostics dashboard.

At any moment, the human should see:

1. the meaning of the current state;
2. any action they need to take;
3. the primary next action.

Everything else is subordinate evidence.

# Progressive disclosure

Use this rule:

> The more certain MessageLens becomes about what the human needs to do, the less unrelated information should remain on screen.

Successful checks should progressively recede.

A blocker should become the focus.

A fully ready state should become extremely simple.

# Sidebar contract

During the Onboarding Journey, the normal application sidebar should be **closed**.

This applies during:

- prerequisite checking;
- blocked prerequisite Episodes;
- ready-to-import state;
- import;
- graph preparation;
- final verification;
- terminal Onboarding completion.

Do not leave future application controls visible but irrelevant.

Use the existing canonical `macos_ui` sidebar collapsed/open machinery.

Do NOT:

- fake hiding with zero-width hacks;
- overlay a white panel over it;
- create a second sidebar;
- permanently alter the user's normal sidebar preference.

Onboarding owns temporary sidebar visibility.

# Semantic reason

The sidebar represents:

> normal MessageLens navigation and controls.

Those controls should become available when Onboarding is actually complete.

The sidebar opening therefore becomes part of the Journey-to-application handoff.

# Sidebar reveal

After durable final readiness has been mechanically verified, Onboarding should present a terminal Episode:

**You’re ready to start**

with a single primary action:

**OK**

Do not open the sidebar yet.

When the human activates **OK**:

1. terminal Onboarding presentation yields;
2. normal application assumes ownership;
3. canonical sidebar opens using existing `macos_ui` animation;
4. ordinary MessageLens navigation becomes available.

The visual effect should naturally communicate:

> Setup is finished. Here are your controls.

Do not add explanatory animation copy merely to call attention to the sidebar.

# Truth requirement

The sidebar may open only after durable completion/readiness truth is established.

Do not trigger it from:

- progress reaching 100%;
- final import callback alone;
- animation completion;
- timer;
- optimistic UI state.

The reveal is a receipt of verified completion.

# Existing user sidebar preference

Audit how sidebar open/closed preference is currently stored.

Onboarding's forced-hidden state must not accidentally persist as the user's normal preference.

Likewise the terminal reveal should establish the intended initial normal-app state without corrupting future user-controlled sidebar behavior.

Document ownership.

# Environment Readiness state model

Audit current readiness state and map it into a small human-facing Episode model.

At minimum distinguish:

## Checking

MessageLens is actively establishing prerequisites.

## Blocked

One or more prerequisites prevent safe continuation.

## Ready

Everything required for import is available.

## Failed / cannot check

A real readiness inspection failed.

Do not conflate:

blocked prerequisite

with:

inspection failure.

Use existing typed readiness truth.

Do not duplicate it in presentation.

# Checking state

Keep this calm and minimal.

Representative meaning:

**Checking what MessageLens needs**

or equivalent product voice.

Show a native activity indication if the check is perceptible.

Do not show a giant four-row dashboard immediately unless useful.

Do not artificially dwell if readiness completes quickly.

# Ready state

When all required checks pass, the current dashboard should collapse into a simple readiness Episode.

Representative meaning:

**Everything is ready**

> MessageLens can read the Messages and Contacts available on this Mac. I’m ready to make a local copy for browsing.

Primary action:

**Import My Messages**

The exact copy should follow established MessageLens voice.

The button must be:

- visible without scrolling;
- visually primary;
- immediately understandable;
- not competing with Re-check.

Do not require the human to read a three-step instruction panel before pressing it.

# Ready-state evidence

The four successful checks are useful evidence but no longer primary content.

Move them under:

**Details**

or another established progressive-disclosure mechanism.

Potential details:

- Full Disk Access: available;
- Messages database: available;
- Contacts database: available;
- import storage/pipeline: ready.

Do not make green cards dominate a successful state.

# Remove ready-state Re-check dominance

The current screenshot makes **Re-check** one of the most visually dominant controls even though everything has passed.

That is wrong.

When Ready:

- primary action = Import My Messages;
- Re-check should disappear or become subordinate under Details if genuinely useful.

Do not invite the user to repeat work they do not need.

# Current machine view

Audit the current `Current machine view` panel.

This is diagnostic evidence.

It should not occupy primary Onboarding space in the ordinary ready state.

Move useful evidence to Details.

Remove duplicated information.

Do not delete diagnostics needed by support/agents.

# “What to do” panel

The current three-step instructions largely explain the obvious button flow.

Audit whether any of it adds information.

Prefer direct action:

**Import My Messages**

over:

1. Start the import when ready.
2. MessageLens will copy...
3. When setup finishes...

Narrator/Presence can explain scope when import begins.

Do not retain instructions merely because space exists.

# Blocked state — one blocker owns the Episode

If a prerequisite fails, the page should not require the human to scan four cards to discover which one is red.

The blocker becomes the main story.

For example:

**MessageLens needs Full Disk Access**

Then explain:

- why;
- exactly what the human needs to do;
- whether MessageLens can open System Settings;
- whether a restart/relaunch is required;
- how MessageLens will detect resolution.

Successful checks become subordinate evidence.

# Multiple blockers

If more than one prerequisite fails:

- prioritize blockers in the order the human should resolve them;
- do not present four equal red cards.

After the first blocker is resolved, move naturally to the next.

Details may show the complete prerequisite inventory.

# Full Disk Access Episode

Audit existing FDA guidance.

The human needs exact actionable instructions.

Determine:

- whether MessageLens can deep-link/open the appropriate System Settings pane;
- whether app restart is required;
- whether Re-check is necessary;
- whether MessageLens can detect permission automatically.

Do not claim automatic detection if unavailable.

# Messages history prerequisite

This is one of the original tester failure classes and deserves careful treatment.

The real product requirement appears to be:

> The Messages history the user expects MessageLens to import must actually be present locally on this Mac.

Do NOT casually phrase this as:

> “You must enable Messages in iCloud.”

First establish exactly what MessageLens can know.

Audit:

- whether `chat.db` exists;
- row count/date range;
- whether Messages in iCloud is detectable on the Mac;
- whether MessageLens can determine synchronization completeness;
- whether it can know the iPhone's setting;
- whether it can know that older expected history is missing.

Separate:

### Mechanical prerequisite

A readable local Messages database exists.

from:

### Human expectation prerequisite

The Mac actually contains the message history the human expects to import.

MessageLens may not be able to prove the second automatically.

# iCloud guidance

If Messages in iCloud is the normal mechanism by which an iPhone's history reaches the Mac, explain that as guidance—not as an unverifiable machine fact.

Potential meaning:

> MessageLens imports the Messages history stored on this Mac. If messages you expect are missing here, make sure Messages in iCloud is enabled and has finished syncing on your devices before continuing.

Only use wording supported by the actual platform/product behavior.

Do not claim MessageLens inspected the iPhone.

# Date-range evidence

Consider whether readiness can cheaply show a human-useful sanity check such as:

> Messages on this Mac: Jan 2014 – Aug 2026

or:

> I found 137,373 messages on this Mac.

This could help a tester realize:

> “Wait, my history should go back to 2012.”

before import.

But do not turn readiness back into a dashboard.

Potentially put this in the Ready Episode as one concise evidence line or under Details.

Audit usefulness and cost.

# Contacts prerequisite

Determine whether Contacts access is truly required or enriching.

The current card says:

> Names and contact details improve message context.

That sounds optional.

If Contacts failure does not prevent message import, do NOT present it as a hard blocker.

Classify prerequisites as:

- required;
- optional enrichment;
- unavailable but non-blocking.

This is important.

A user should not be prevented from importing Messages merely because Contacts enrichment is unavailable unless architecture truly requires it.

# Import Readiness

The current `Import Readiness` card appears to expose internal pipeline readiness.

Determine whether the human needs to see this at all.

If it is purely internal:

- use it to gate Ready state;
- hide it from primary UI.

Do not make the user interpret “App storage and pipeline setup are ready for import.”

# Presence/Narrator

Use Narrator only where human meaning changes.

Examples:

## Ready

**Everything is ready.**

## Blocked

**I need Full Disk Access before I can read your Messages history.**

## Import begins

**I’m building the first local copy of your message history.**

The latter has already tested well manually.

Do not narrate every prerequisite check.

# Guided dialogs landing here

Audit all Presence-guided dialogs/actions that navigate to Environment Readiness.

For each ensure:

dialog explanation
→ navigation
→ same relevant Episode remains visually dominant.

Do not guide the user through FDA and then land them on an undifferentiated dashboard.

If a specific blocker caused navigation, preserve that blocker focus.

# Import action handoff

When **Import My Messages** is pressed:

- button feedback immediate;
- ready Episode yields immediately;
- operation Presence takes ownership;
- first frame paints;
- import begins;
- existing real progress instrumentation is reused.

Do not reintroduce the old dead-click problem.

# Import progress presentation

The current production-shaped import presentation has been manually approved as effective.

Preserve:

- Narrator scope;
- factual record totals;
- responsive progress;
- appropriate determinate/indeterminate activity treatment.

Do not redesign it broadly in this task.

# Final verification

After import/graph work:

- verify durable readiness;
- do not abruptly reveal normal app;
- transition to terminal Onboarding Episode.

# Terminal Episode

Create/refine:

**You’re ready to start**

with concise supporting copy if needed.

Primary action:

**OK**

This is not a generic success modal if Presence architecture favors an in-window Episode.

Use canonical Onboarding rendering.

The user should have enough time to recognize that setup has finished.

No automatic disappearance after 750 ms/1.5 s.

Human owns the final handoff.

# OK handoff

On OK:

- mark/retain durable completed truth;
- dismiss terminal Journey presentation;
- normal MessageLens assumes ownership;
- sidebar opens;
- initial normal destination renders.

Determine canonical initial destination.

Likely Conversations if existing product architecture says so.

Do not invent a new landing page.

# No sidebar during Onboarding tests

Add structural tests proving sidebar is closed for:

- checking;
- blocked;
- ready;
- importing;
- verification;
- terminal ready-to-start.

And opens only after terminal OK.

# Window resizing

Use stable Tracks/content geometry.

Readiness states should remain coherent at supported window sizes.

The primary action must remain visible without vertical scrolling at the minimum supported Onboarding window size.

This is a hard UX requirement.

# Scroll discipline

If Details content is long, Details may scroll.

The primary Episode/action should not be pushed below diagnostics.

Do not make the whole page a long vertical report.

# Accessibility

Check:

- blocker headline;
- instructions;
- ready headline;
- Import My Messages;
- Details disclosure;
- terminal OK;
- sidebar reveal;
- focus transition.

When terminal OK opens the sidebar, keyboard/VoiceOver focus should move to a sensible normal-app target.

Do not rely on animation alone to communicate completion.

# Tests — readiness states

Cover:

1. checking;

2. ready;

3. one required blocker;

4. multiple blockers with deterministic priority;

5. optional enrichment unavailable;

6. inspection failure.

# Tests — layout

7. sidebar hidden throughout Onboarding;

8. Import My Messages above fold at minimum supported window size;

9. diagnostics cannot push primary action below viewport;

10. Details progressive disclosure;

11. resize preserves layout.

# Tests — guided navigation

12. FDA guidance lands on FDA-focused Episode;

13. Messages-history guidance lands on Messages-focused Episode;

14. resolved blocker advances appropriately.

# Tests — import handoff

15. Import button immediately yields presentation;

16. existing progress observations render;

17. no duplicate import execution.

# Tests — completion handoff

18. durable completion required before terminal Episode;

19. sidebar remains closed during terminal Episode;

20. OK opens normal application/sidebar;

21. stale callback cannot reveal sidebar early;

22. sidebar user preference is not corrupted.

# Architecture tripwires

Protect:

- Onboarding owns temporary sidebar closure;
- normal app owns sidebar after completion;
- no local width hacks;
- primary action cannot be conditional on scrolling diagnostics;
- readiness presentation derives from typed readiness truth;
- optional prerequisite cannot become hard blocker accidentally;
- no iPhone/iCloud claim without evidence;
- terminal reveal requires durable completion.

# Documentation

Create:

`11-ENVIRONMENT-READINESS-AS-GUIDED-PRESENCE-EPISODE-AND-ONBOARDING-HANDOFF-IMPLEMENTATION.md`

Document:

- readiness Episode model;
- blocker priority;
- required vs optional prerequisites;
- iCloud/Messages-history truth;
- progressive disclosure;
- sidebar ownership;
- import handoff;
- terminal Episode;
- sidebar reveal;
- accessibility/focus;
- guided-dialog navigation.

Update canonical Onboarding/Presence/Track docs.

Update Feature 28 index/documentation log.

Update version/changelog according to repository rules.

# Verification

Run:

- Environment Readiness tests;
- Onboarding presentation tests;
- Presence tests;
- sidebar/navigation tests;
- import handoff tests;
- completion tests;
- maintenance/readiness tests;
- architecture tripwires;
- full Flutter suite;
- `flutter analyze`;
- formatting;
- `git diff --check`;
- macOS debug build.

Commit and push if clean.

# Stop conditions

STOP if:

- sidebar cannot be temporarily closed without corrupting persistent user preference;
- readiness truth cannot distinguish required from optional prerequisites;
- iCloud completeness cannot be represented honestly;
- terminal OK cannot hand off ownership safely;
- minimum supported window cannot keep primary action visible without global layout changes.

Do not solve these with visual hacks.

# Final report

Report:

- final checking/blocked/ready state designs;
- required vs optional prerequisite classification;
- exact Messages/iCloud guidance;
- whether date-range/count sanity evidence is shown;
- final ready-state copy;
- final blocker copy;
- sidebar ownership implementation;
- terminal ready-to-start design;
- OK handoff behavior;
- accessibility/focus behavior;
- guided-dialog landing behavior;
- tests/verification;
- commit hash;
- manual validation instructions;
- recommended next Feature 28 blocker.

Acceptance standard:

> During Onboarding, MessageLens should behave like a guide, not a control panel. When something blocks progress, that one thing should become obvious and actionable. When everything is ready, the user should see one unmistakable next step. And when setup is truly complete, the normal MessageLens controls should appear for the first time as a truthful handoff from Journey to application.