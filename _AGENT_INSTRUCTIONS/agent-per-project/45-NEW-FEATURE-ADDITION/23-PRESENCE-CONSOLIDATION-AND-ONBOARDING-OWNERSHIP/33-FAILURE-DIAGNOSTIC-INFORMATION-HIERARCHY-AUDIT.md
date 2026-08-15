---
tier: project
scope: stable-setup-failure-diagnostic-information-hierarchy
owner: agent-per-project
last_reviewed: 2026-08-14
source_of_truth: code
links:
  - ./30-INITIAL-SETUP-FAILURE-RECOVERY-SURFACE-AUDIT.md
  - ./31-BOUNDED-ACTIVE-PROGRESS-FAILURE-HEADLINE-IMPLEMENTATION.md
  - ./32-PHASE-NEUTRAL-STABLE-SETUP-FAILURE-COPY-IMPLEMENTATION.md
  - ./27-ATTACHMENT-PRESERVATION-SAFETY-INVARIANT.md
tests:
  - ../../../../test/essentials/onboarding/presentation/onboarding_overlay_failure_test.dart
  - ../../../../test/essentials/logging/application/diagnostic_report_actions_test.dart
---

# Failure Diagnostic Information Hierarchy Audit

## Decision Summary

The approved primary layer is complete:

> **MessageLens couldn't finish setup**

> MessageLens couldn't finish preparing your browsing data. You can try again.

Everything currently shown below it was audited against one rule:

> **Ordinary reading order should contain only information that changes the
> human's understanding or next action.**

The current secondary stack does not pass that test. It combines current
source and derived-store probes, raw exception text, a recorded timestamp,
unsupported phase and launch-history claims, repeated support instructions,
and internal storage terminology. None changes the supported next actions:
retry setup or send a support report.

The recommended long-term hierarchy is **calm primary + secondary support**:

```text
[failure icon]

MessageLens couldn't finish setup

MessageLens couldn't finish preparing your browsing data.
You can try again.

Try Again

Send Report To Developer
```

A local **Technical Details** disclosure is not yet earned. The current
workflow offers no user remediation selected from those details, while the
support report already preserves the useful diagnostic evidence.

The one next implementation slice should remove the **What to check** card
from ordinary stable-failure reading order. That single component currently
contains the highest-risk material: raw errors, unsupported lifecycle claims,
and duplicated support guidance. Environment Summary and support-transport
copy can be reviewed in later bounded slices.

## 1. Current Secondary-Content Inventory

Both stable failure branches are rendered by `_WelcomeContent` and currently
receive the same outer hierarchy.

### Shared content

After the settled title and body, both branches show:

1. **Environment summary**, a bordered diagnostic card containing:
   - Full Disk Access: `Available` or `Missing or blocked`;
   - Messages database: `Not found`, `Blocked`, `Readable`, or a detected
     message count;
   - Contacts database: `Not found`, `Blocked`, `Readable`, an unavailable
     reason, or a detected contact count;
   - Imported message data: creation/readability/row-count status;
   - Conversation browsing data: creation/readability/row-count status.
2. **What to check**, a bordered bullet-list card whose contents differ by
   persisted failure bucket.
3. A filled retry action.
4. An outlined **Send Report To Developer** action in the same action `Wrap`.
5. A caption explaining that MessageLens will try to open an email to
   `messagelens@gmail.com`, or reveal the report in Finder if attachment is not
   possible.
6. Post-action snackbar feedback reporting export failure, attached email
   success, or manual Finder presentation.

The branch icon and retry label also differ, even though the primary copy is
shared.

### `importFailed` content

The filled action is **Try Import Again**. **What to check** can contain:

```text
This import failure was recorded earlier today at <timestamp> during a
previous launch.
```

or an older/unknown variant of the same previous-launch claim;

```text
<raw persisted error>
```

```text
Confirm Messages and Contacts are still available on this Mac, then retry the
import.
```

```text
If the import fails again, use "Send Report To Developer" to have MessageLens
prepare an email with the diagnostic report attached when possible.
```

and, when the source-scoped import store is absent or empty:

```text
No usable imported message data was left behind, so the next retry will start
from a clean import pass.
```

There is no active production writer of the import-failure record. The branch
remains reachable through historical records, simulation, and current probe
classification.

### `graphProjectionFailed` content

The filled action is **Retry Import and Graph Build**. **What to check** can
contain:

```text
This graph projection failure was recorded earlier today at <timestamp>
during a previous launch.
```

or an older/unknown variant of the same previous-launch claim;

```text
<raw persisted error>
```

when imported rows exist:

```text
The imported message data exists, so the failure happened while preparing it
for browsing.
```

when graph rows do not exist:

```text
The conversation browsing data is still empty or incomplete. Retrying will
rerun setup.
```

and always:

```text
If this keeps happening, use "Send Report To Developer" to have MessageLens
prepare an email with the support bundle attached when possible.
```

### Evidence already retained outside ordinary reading order

`exportOnboardingFailureDiagnosticReport()` supplies the support bundle with:

- observed environment state and blocker kind;
- Full Disk Access status;
- Messages, Contacts, import-ledger, and Conversation Graph probe paths,
  existence, readability, row counts, and probe failures;
- raw import and graph-projection failure messages;
- the latest recorded failure timestamp;
- current and previous application logs;
- pipeline audit logs when available;
- database-health output when available.

The support bundle excludes raw database files and row-level sampling. Removing
technical facts from ordinary UI therefore does not remove their diagnostic
record.

## 2. Purpose Classification

| Current item | Classification | Visible without request? | Finding |
| --- | --- | --- | --- |
| Environment Summary: FDA and source probes | `DIAGNOSTIC`, sometimes `REDUNDANT` | No on stable failure | Stable failure classification is reached only after higher-priority permission/source blockers have been excluded. These facts do not select a different action and are already in the support report. |
| Environment Summary: imported/graph store facts | `DIAGNOSTIC`, `IMPLEMENTATION DETAIL` | No | The labels expose MessageLens's internal pipeline and do not help a human choose between retry and report. The support report preserves them more precisely. |
| Raw persisted error | `DIAGNOSTIC`, often `IMPLEMENTATION DETAIL` | No | It can be unbounded and can expose SQL, paths, provider/service names, or arbitrary exception text. It never changes the supported action. |
| Recorded timestamp | `DIAGNOSTIC` | No | It can help support correlate logs, but it does not determine retry behavior and does not prove launch provenance. |
| “Previous launch” statement | `IMPLEMENTATION DETAIL`, `REDUNDANT`; factual status `UNSUPPORTED` | No | Persistence proves recording time, not that process lifetime ended between failure and presentation. |
| Confirm Messages and Contacts are available | `ACTION-CRITICAL` only on a source-unavailable surface; here `REDUNDANT` | No on stable failure | The current report has already passed higher-priority source-readiness classification. Retry is the supported action. |
| Report-export advice in What to check | `SUPPORT`, `REDUNDANT` | No | The visible button and transport caption already explain the same capability. |
| No usable imported rows / clean import pass | `REASSURANCE`, `DIAGNOSTIC`, `IMPLEMENTATION DETAIL` | No | The human cannot choose a different retry mode. “Clean import pass” also says nothing useful about preserved attachments or external sources. |
| Imported rows imply failure while preparing browsing | `DIAGNOSTIC`, `IMPLEMENTATION DETAIL`; factual status `UNSUPPORTED` | No | Surviving imported rows do not identify the stage that failed. |
| Conversation browsing data empty/incomplete | `DIAGNOSTIC`, `IMPLEMENTATION DETAIL` | No | The probe can truthfully report current row state, but it cannot identify the failure stage. The only useful clause, that retry reruns setup, is already implied by the primary action and can be stated separately if later evidence shows it is needed. |
| Retry action | `ACTION-CRITICAL` | Yes | It is the primary supported recovery action. |
| Send Report To Developer | `SUPPORT` | Yes, visually secondary | It gives a direct escape when retry does not resolve the failure. It remains useful without exposing diagnostics in ordinary UI. |
| Email/Finder transport paragraph | `SUPPORT`, `REDUNDANT` | Not required | Transport mechanics do not change whether the human should request a report. Result-specific snackbar feedback communicates the actual outcome after activation. |

No current secondary item changes the retry operation itself. There is no
resume choice, alternate repair path, selectable failed stage, or user-facing
decision derived from the raw evidence.

## 3. Raw Persisted Error Audit

The raw import or graph-projection failure message is appended directly to the
branch's `notes` and rendered as an ordinary body-style bullet under **What to
check**. It is therefore not visually encoded as developer-only material.

The persistence boundary accepts an arbitrary `String`. Current production
capture is based on `error.toString()`. The value can contain:

- SQLite exception text and SQL statements;
- database, source, or attachment paths;
- service, provider, repository, or stage names;
- filesystem and permission errors;
- an arbitrarily long third-party exception description.

The human does not need this text to choose **Try Again**. The support-report
header already includes the same raw failure messages, and the bundle adds
logs and database health.

**Verdict:** raw error belongs only in support/developer diagnostics. It does
not belong in ordinary secondary UI, and no Technical Details disclosure is
currently required to preserve its value.

## 4. Failure Timestamp Audit

The persisted record contains a UTC `recordedAt` value. Presentation converts
it to local `YYYY-MM-DD HH:mm` text and classifies it as today, older, or
unknown. The timestamp can help support correlate a record with logs, but it
does not alter the supported action or prove that the record is stale.

The current sentence additionally claims the failure was recorded “during a
previous launch.” That claim remains present in both stable failure branches.
The store records a timestamp; it does not record process identity, launch
identity, or a restart boundary. A failure recorded during the current launch
can therefore be presented with false previous-launch wording.

**Verdict:** retain the timestamp in support diagnostics. Remove both timestamp
and previous-launch narrative from ordinary UI. The narrative is unsupported,
not merely too technical.

## 5. Environment Summary Audit

The card presents five coarse health rows. It contains no database paths, but
two labels require internal architecture knowledge:

- **Imported message data** means the source-scoped import store;
- **Conversation browsing data** means the Conversation Graph projection.

On a stable failure branch, FDA and current source availability have already
won or lost earlier classification decisions. If they were presently blocked,
the user would ordinarily see permission/source remediation instead. The
derived-store rows explain internal state but do not offer a different action.

If the human saw only the calm failure message and **Try Again**, no important
decision would be unavailable because Environment Summary was absent.

**Verdict:** Environment Summary is support-oriented diagnostic material and
does not belong in the long-term ordinary failure hierarchy. It is not the
first removal only because the **What to check** card contains higher-risk raw
and factually unsupported content.

## 6. “What To Check” Audit

Despite its actionable title, most of the card does not describe checks the
human can perform.

| Note kind | Actual role | Finding |
| --- | --- | --- |
| persisted timestamp and freshness | diagnostic history | Not remediation; previous-launch wording is unsupported. |
| raw error | developer diagnostic | Not remediation; can expose internal and private path detail. |
| source availability reminder | generic remediation | Redundant on this classified surface; actual source blockers have their own earlier state. |
| imported/graph row statements | current-store diagnosis | Internal evidence, not a user choice; one phase claim overcommits. |
| report-export advice | support instruction | Duplicates the visible report button and transport caption. |
| clean-pass statement | reassurance plus implementation detail | Does not change retry; does not explain preservation boundaries. |

The title **What to check** gives diagnostic and historical facts an
actionability they do not possess. Removing this card from the stable failure
branches loses no supported remediation path.

## 7. Phase-Specific Secondary Truth Audit

| Statement | Classification | Reason |
| --- | --- | --- |
| “This import/graph projection failure was recorded … during a previous launch.” | `UNSUPPORTED` | A timestamp and persisted record do not prove launch identity or a restart. |
| “The imported message data exists, so the failure happened while preparing it for browsing.” | `UNSUPPORTED` | Every controller-lifecycle failure is written to the coarse graph bucket. Imported rows can survive a failure during import, enrichment, joins, projection, or later publication. |
| “The conversation browsing data is still empty or incomplete.” | `TRUTHFUL` as current probe state | It reports current rows, not failure phase. |
| “Retrying will rerun setup.” | `TRUTHFUL` | Retry resets allow-listed rebuildable stores and invokes the complete build. |
| “No usable imported message data was left behind.” | `TRUTHFUL` only as a narrow import-store probe statement | It does not describe archived attachment payloads, Apple sources, overlay intent, or every recoverable artifact. |
| “The next retry will start from a clean import pass.” | `OVERCOMMITTED` as ordinary reassurance | The operation does begin again rather than resume, but “clean” is imprecise about deliberately preserved data and side effects. |

Secondary placement does not make unsupported wording acceptable. The first
two statements should not survive an eventual move into another human-facing
container.

## 8. Retry Explanation

The actual operation is:

```text
retry
    -> admit one mutation operation
    -> reset allow-listed rebuildable derived stores
    -> run the complete build from the beginning
```

It does not resume a failed stage. The stable surface currently communicates
this indirectly through button labels and two **What to check** notes.

The distinction can reassure a technically curious reader, but it does not
change the decision to retry. The settled primary sentence and action are
sufficient for the current surface. If later testing shows that people expect
resume, one bounded sentence such as “MessageLens will restart setup from the
beginning” could be evaluated separately. It should not mention clearing all
data, starting from scratch, or rebuilding everything.

## 9. Send Report To Developer Hierarchy

The support action is useful and already visually subordinate: retry is filled
while report export is outlined. Although both share the action `Wrap`, their
styles express the right priority.

The explanatory paragraph beneath them is not required before activation. It
describes email/Finder transport rather than the decision to request help.
After activation, the snackbar truthfully reports the transport result.

**Verdict:** keep **Send Report To Developer** visible as the secondary escape
path. Its transport paragraph does not belong in the eventual minimal ordinary
reading order, but changing it is not part of the next slice.

The support capability remains complete even if all ordinary diagnostic cards
are removed: the export action constructs its report directly from
`OnboardingEnvironmentReport`, logs, and database-health services rather than
scraping visible text.

## 10. Automatic-Recovery Comparison

Automatic recovery currently presents a calm headline followed by:

```text
MessageLens detected signs that an earlier setup attempt left incomplete local
data. It is clearing that data now so setup can restart cleanly.
```

It then displays `resetAppDatabasesReason` in a bordered caption panel. That
reason can mention **import ledger**, **conversation graph**, **graph
projection**, and row-count disparity.

The same hierarchy principle applies:

```text
human
    MessageLens is cleaning up incomplete browsing data so setup can restart.

diagnostics
    the probe evidence that caused recovery to be inferred
```

The current phrase “clearing that data” can be read more broadly than the real
allow-listed derived-store reset, and “restart cleanly” does not describe the
preservation boundary. The raw reason is diagnostic, not a human action.

Recovery should receive its own later bounded presentation slice. This audit
does not change it.

## 11. Attachment-Preservation Language Check

The current reset boundary distinguishes:

```text
AUTHORITATIVE EXTERNAL SOURCES — NEVER OUR DELETION TARGET
    Apple Messages chat.db
    Apple Contacts databases
    locally available Messages attachment payloads

REBUILDABLE MESSAGELENS DERIVED STORES
    source-scoped import database
    Conversation Graph / working stores
    indexes and projections

MESSAGELENS PRESERVATION DATA — TREAT LIKE GOLD
    archived attachment payloads
```

Current stable failure copy does not claim that Apple sources or archived
payloads will be deleted. Two secondary phrases nevertheless deserve caution:

- **clean import pass** can be mistaken for a globally clean start;
- automatic recovery's **clearing that data** does not identify the narrow
  rebuildable category.

Neither phrase should be expanded into broad reassurance such as “nothing can
go wrong.” Future copy should name **incomplete browsing data** when it needs to
describe the reset and should avoid **all data**, **starting from scratch**, or
**rebuilding everything**.

## 12. Overflow Assessment

`OnboardingOverlay` constrains its card to a maximum height of 920 pixels. The
stable failure test encountered overflow at default test typography when the
complete secondary stack was rendered. Slice 32 retained the stack and used a
test-only reduced text scale so primary-copy behavior could be verified without
silently redesigning diagnostics or layout.

The content responsible for most variable height is not legitimate primary
content:

- five Environment Summary rows;
- a multi-note **What to check** card;
- unbounded raw exception text;
- repeated report-transport guidance.

Removing or demoting those items should largely eliminate the overflow
naturally. After the recommended first slice, Environment Summary and the
transport paragraph remain, but removal of the unbounded notes card should
make the normal stable branches fit the existing envelope in ordinary cases.

If a later minimal surface still overflows under supported accessibility text
scaling, that will be a legitimate layout/accessibility problem. Current
evidence does not justify scrolling, smaller typography, reduced spacing, or a
larger card before the hierarchy is corrected.

## 13. Comparison Of Information Hierarchies

### A. Everything visible

**Comprehension:** poor. User action competes with internal state and arbitrary
errors.

**Truthfulness:** poor. It exposes unsupported launch and phase claims.

**Support value:** high in volume but low in usability; the same evidence is
already exported more completely.

**Cognitive load and overflow:** highest and unbounded.

**Implementation complexity:** current implementation is simple, but it makes
the ordinary surface carry every concern.

**Verdict:** reject.

### B. Calm primary + secondary support

**Comprehension:** strongest. It answers what happened and what to do.

**Truthfulness:** strongest. It stays within proven phase-neutral facts.

**Support value:** preserved by the visible report action and existing bundle.

**Cognitive load and overflow:** lowest.

**Implementation complexity:** lowest; it removes presentation rather than
adding another stateful interaction.

**Verdict:** recommend.

### C. Calm primary + explicit technical disclosure

**Comprehension:** acceptable while collapsed, but it invites users into
details that cannot guide a supported remedy.

**Truthfulness:** depends on first removing unsupported phase and launch claims.

**Support value:** duplicates the support bundle unless a user must quote or
inspect details before exporting.

**Cognitive load and overflow:** low while collapsed, high when expanded.

**Implementation complexity:** introduces local interaction state and an
additional accessibility/test surface. No existing Onboarding disclosure
component or established local pattern was found.

**Verdict:** do not add it now.

## 14. Technical Details Verdict

> **A Technical Details disclosure is not yet earned; support reporting is
> sufficient.**

The current facts have diagnostic value, but no supported user decision relies
on them. The support action already packages them with better context. Adding a
disclosure would preserve complexity in the UI without enabling a new action.

If future support practice demonstrates a concrete need for on-screen details,
the minimum candidates would be raw error, recorded timestamp, environment
summary, and recovery reason. Unsupported phase and previous-launch narratives
would still be excluded. That future evidence does not exist yet.

## 15. Information Removable Without Diagnostic Loss

| Visible item | Existing retained source | Diagnostic loss if removed from UI |
| --- | --- | --- |
| raw persisted error | support header, persistence, logs | None |
| timestamp | support header and persistence | None |
| FDA and database probe summary | support header and database-health report | None |
| imported/graph row facts | support header and database-health report | None |
| report-export advice | visible action and result snackbar | None |
| email/Finder transport explanation | exporter behavior and result snackbar | None |
| previous-launch claim | no truthful equivalent should be retained | None; removal improves accuracy |
| inferred failed-phase claim | no truthful equivalent should be retained | None; removal improves accuracy |

The generic source reminder and clean-pass explanation are not copied verbatim
into the bundle, but their underlying source/store facts are. Neither provides
a supported branch in human behavior.

## 16. Proposed Final Reading Order

### Shown ordinarily

```text
[failure icon]

MessageLens couldn't finish setup

MessageLens couldn't finish preparing your browsing data.
You can try again.

[Try Again]

[Send Report To Developer]
```

The exact retry label may remain branch-specific until separately reviewed.

### Not shown ordinarily

- Environment Summary;
- **What to check**;
- raw errors;
- failure timestamp and freshness;
- import-ledger and Conversation Graph facts;
- inferred failure phase;
- previous-launch claims;
- report transport mechanics.

### Available diagnostically

- persisted raw failure and timestamp;
- current environment and database probes;
- current and previous logs;
- pipeline incident logs;
- database-health report;
- support export result feedback.

## 17. Exactly One Next Implementation Slice

```text
Next concern:
    Remove the What to check card from ordinary stable-failure reading order.

Why it comes next:
    It contains unbounded raw errors, unsupported phase/launch claims, and
    repeated support guidance. It is the highest-risk and most variable part
    of the remaining hierarchy.

Current defect:
    Stable import and graph failure presentations append branch-specific notes
    to an ordinary body-style diagnostic card labeled as actionable guidance.

Smallest implementation:
    For importFailed and graphProjectionFailed only, stop supplying/rendering
    the branch notes card. Preserve the report, persisted values, support
    export, logs, Environment Summary, actions, and transport caption. Do not
    replace the card with a disclosure.

Owner:
    Onboarding presentation.

Operation-layer changes:
    None.

Persistence impact:
    None. Existing records and timestamps remain readable and writable.

Support-report impact:
    None. The exporter reads OnboardingEnvironmentReport directly.

Layout impact:
    Removes the largest variable-height component, including unbounded raw
    exception text. No new geometry mechanism is required.

Test seam:
    Both stable branches retain the settled primary copy, retry dispatch, and
    support export; raw errors, timestamp/previous-launch wording, phase claims,
    and What to check are absent from ordinary UI but remain in report headers.
```

This slice is one component removal. It does not also remove Environment
Summary or support-transport copy.

## 18. Remaining Layout Verdict

After applying the recommended information hierarchy conceptually, the stable
failure surface should not require scrolling for ordinary content. The
observed overflow is primarily an information-density and unbounded-diagnostic
problem rather than evidence that the overlay needs a new geometry mechanism.

Accessibility verification remains necessary after the hierarchy is reduced.
If the eventual minimal surface cannot fit at supported text scales, scrolling
or another accessible layout response can then be evaluated from truthful
content requirements.

## Presence Assessment

No Presence change is required.

Stable failure diagnostics remain owned by Onboarding presentation and support
infrastructure. Presence does not gain failure classification, diagnostic
disclosure, persistence, retry, or report-export responsibility.

## Scope Confirmation

This audit changes no application code, UI, schema, persistence, retry,
recovery, reset, support bundle, attachment archive, or Presence behavior.
