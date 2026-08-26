---
tier: project
scope: onboarding
owner: essentials-onboarding
last_reviewed: 2026-08-26
source_of_truth: feature-implementation-record
---

# Live Onboarding Journey Path

## Result

Onboarding now presents one compact ball-and-stick path derived exclusively
from the current typed `OnboardingJourneyState`. The path is orientation, not
an estimate of operational progress.

## Topology And Labels

> **Current topology:** Feature 28's subsequent node-semantics audit removed
> Verify from the human path while retaining durable verification as a
> mandatory internal coordinator gate. See
> [`14-ONBOARDING-JOURNEY-NODE-SEMANTICS-AND-VERIFICATION-GATE-IMPLEMENTATION.md`](14-ONBOARDING-JOURNEY-NODE-SEMANTICS-AND-VERIFICATION-GATE-IMPLEMENTATION.md).

The topology introduced by this implementation slice was:

```text
Messages -> History -> Contacts -> Ready -> Import -> Verify -> Start
```

The corresponding accessible labels are:

- Messages access;
- Message history;
- Contacts;
- Ready to import;
- Importing;
- Verifying;
- Start.

Recovery, import preparation, graph construction, and first-run operation
failure remain within the Import node. They do not create extra Journey nodes.
Record counts and substage progress remain Directed Instrumentation below the
path.

## State Projection

The projection accepts only `OnboardingJourneyState`:

- nodes before the active Episode are completed;
- the active Episode is current;
- later nodes are future;
- normal-application and reimport states project no first-run path.

The current topology has no legitimately skipped prerequisite node. Message
history or Contacts can be passed without a separate interaction only when the
coordinator's authoritative evidence has satisfied that predicate; those nodes
are therefore completed, not skipped.

Fresh prerequisite evidence may move the coordinator backward. Because the
path has no retained progress state, its current marker and completed set move
backward in the same rebuild. System Settings return, modal dismissal,
operation counters, and provider occurrence changes cannot move it by
themselves.

## Placement Audit

The path is the first stable region in both established first-run presentation
hosts:

- Environment Readiness prerequisite Episodes;
- the Onboarding operation, verification, failure, and terminal overlay.

Its standard vertical allocation is 74 pixels. The readiness Episode measures
its centered/scrollable body from the actual remaining constraints, so the path
does not require a compensating inset and does not push actions below the fold.

`PageTrackLayoutMatrix` was deliberately not introduced. Canonical Tracks
coordinate shared geometry among peer page columns. First-run Onboarding is one
full-window presentation surface with no peer columns, so a page matrix would
invent a cross-column relationship that does not exist. The truthful canonical
equivalent is one fixed presentation region followed by the host's native
content flow.

## Visual And Accessibility Contract

- completed nodes are filled and carry a check glyph;
- the current node has a larger ring and inner dot;
- future nodes remain hollow and subdued;
- connectors settle only through the current Episode;
- labels remain two-line bounded at narrow supported widths;
- the standard path uses a calm 180 ms state transition;
- `MediaQuery.disableAnimations` reduces every path transition to zero duration.

The whole path is exposed as one semantic statement, for example:

> Current setup step: Verifying. Messages access, Message history, Contacts,
> Ready to import, and Importing are complete.

Color is never the only state distinction.

## Terminal Behavior

`OnboardingReadyToStart` keeps Start current. Terminal OK moves the coordinator
to `OnboardingNormalApplication`; that state projects no path. Existing sidebar
ownership then reveals normal navigation after Onboarding has disappeared.

## Verification

Focused projection and widget coverage protects:

- every first-run Episode mapping;
- completed/current/future derivation;
- backward prerequisite regression;
- import-node stability across occurrences;
- absence outside first-run ownership;
- narrow-width layout;
- semantic narration;
- reduced motion.

Architecture coverage prohibits Gate, environment-report, operation-snapshot,
or independent widget state from becoming Journey-path authority.

Completed verification:

- 225 Onboarding, Environment Readiness, and sidebar-handoff tests passed;
- 385 architecture tripwires passed;
- the complete 2,095-test Flutter suite passed;
- `flutter analyze` reported no issues;
- `git diff --check` passed;
- the macOS debug build completed successfully.
