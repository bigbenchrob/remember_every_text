---
tier: project
scope: onboarding-environment-readiness-presentation
owner: 28-ONBOARDING
last_reviewed: 2026-08-26
source_of_truth: implementation-record
---

# Environment Readiness Guided Episode And Onboarding Handoff

## Result

Environment Readiness is now a guided Onboarding Episode rather than a
four-card diagnostics dashboard. The primary surface answers one question:

> What do I need to know or do right now?

Typed `OnboardingEnvironmentReport` truth is projected into four human-facing
presentation kinds:

- **checking**: a calm progress indication with no speculative action;
- **blocked**: one prioritized prerequisite and its next truthful action;
- **ready**: concise readiness meaning and one primary import action;
- **failed**: inspection or pipeline failure, distinct from a missing
  prerequisite.

The projection adds no competing readiness persistence. It consumes the
existing report and the durable required-sources acceptance fact.

## Progressive Disclosure

Successful prerequisite evidence now recedes under **Details**. The Details
region has its own bounded scroll surface, so diagnostic inventory cannot push
the primary Episode or action below the supported 900 by 720 minimum window.

Removed from primary ready-state presentation:

- the four equal check cards;
- the `What to do` panel;
- the `Current machine view` report;
- the dominant ready-state `Re-check` action.

The ready Episode is:

> **Everything is ready**
>
> MessageLens can read the Messages and Contacts available on this Mac. I’m
> ready to make a local copy for browsing.

Its only primary action is **Import My Messages**. One concise source sanity
line reports the already-probed local message count when available. No new date
query or private timestamp conversion was introduced.

## Blocker Priority

The typed report remains the blocker authority. Presentation does not combine
independent warning cards or infer a new priority scheme.

The current order established by report classification is:

1. Full Disk Access;
2. required Messages source availability;
3. required Contacts source availability;
4. local Messages-history sufficiency confirmation;
5. import or graph preparation failure.

Inspection failure is projected as `failed`, not as a blocked prerequisite.
When a report exists, its full evidence remains available under Details.

## Required And Optional Sources

Contacts is currently a **required source** because the active first-run import
and graph pipeline unconditionally resolves, imports, and projects Contacts.
The UI now says this directly instead of describing Contacts as optional
enrichment. Making Contacts optional would require a separate operational
architecture change and was not smuggled into presentation.

Import storage and Conversation Graph readiness are internal prerequisites.
They gate the ready state and appear in Details; they are not separate human
tasks.

## Messages And iCloud Truth

MessageLens can prove that the local `chat.db` exists, is readable, and contains
a measured number of rows. It cannot inspect an iPhone or prove that iCloud
sync is complete.

Sparse-history guidance therefore says:

> MessageLens imports only the history stored on this Mac. If messages you
> expect are missing here, make sure Messages in iCloud is enabled and has
> finished syncing on your devices before continuing.

This is guidance for reconciling human expectation with local evidence, not a
claim about an inspected remote device.

## Sidebar Ownership

The normal navigation column is now the canonical `macos_ui` left `Sidebar`,
not a fixed-width child in a page `Row`.

First-run Onboarding temporarily owns sidebar visibility during:

- prerequisite recovery and failure;
- FDA and required-source interaction;
- ready-to-import;
- import and graph preparation;
- terminal completion.

The sidebar tree and feature-owned navigation content remain unchanged.
Onboarding does not persist a closed preference and does not repeatedly
override user toggles after normal application ownership begins. Reimport is a
completed-installation maintenance workflow and does not take this first-run
ownership.

This is window composition, not Track geometry. Existing page Track matrices
continue to coordinate the same sidebar and center feature trees when the
normal application owns them.

## Import Handoff

The existing Environment Readiness action boundary still reports the import
intent to `OnboardingGate`. The ready Episode yields to the existing operation
overlay immediately, and the already-validated real import/graph progress
presentation remains unchanged.

## Terminal Episode And Application Handoff

Durable import and graph readiness are verified before `OnboardingStatus.complete`
is published. The terminal Episode now waits for the human:

> **You’re ready to start**
>
> Your local MessageLens browsing data is prepared.

The single action is **OK**. No timer or animation establishes completion.

On OK:

1. the existing Gate dismiss action clears the process-local workflow override;
2. ordinary Messages mode becomes active;
3. Onboarding status becomes `notNeeded`;
4. the navigation-owned sidebar visibility reconciler observes the ownership
   transition;
5. the canonical `macos_ui` sidebar opens with its native animation;
6. focus moves to the normal Messages/Settings navigation control.

The reconciler ignores stale post-frame work whose status no longer represents
the same ownership transition.

## Guided Navigation

The required-source Presence Schedule remains the prerequisite guide. When it
lands on Environment Readiness, the same typed report projection keeps the
active FDA, Messages, Contacts, or sparse-history concern visually dominant.
There is no separate dialog-owned blocker state.

## Verification Contract

Focused coverage now proves:

- checking, required blockers, sparse-history confirmation, ready, completed,
  retry, and inspection-failure projections;
- accepted sparse-history state survives repository restart;
- ready import remains above the fold at 900 by 720;
- Details does not displace the primary action;
- every first-run status owns sidebar closure;
- terminal ownership release opens the canonical sidebar;
- later user sidebar closure is not overridden;
- first-run and reimport terminal copy remain distinct;
- existing Gate completion still requires durable operation evidence.

Architecture tripwires protect the canonical sidebar seam, typed report
derivation, progressive disclosure, and the absence of width/overlay hiding
mechanics.
