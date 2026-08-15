---
tier: project
scope: initial-setup-completion-surface
owner: agent-per-project
last_reviewed: 2026-08-14
source_of_truth: code
links:
  - ./21-INITIAL-IMPORT-GRAPH-BUILD-LIFECYCLE-AUDIT.md
  - ./23-PRODUCTION-IMPORT-PROGRESS-SURFACE-AUDIT.md
  - ./24-TRUTHFUL-KEEP-OPEN-PROGRESS-GUIDANCE-IMPLEMENTATION.md
  - ./26-PRE-RESET-PREPARATION-PROGRESS-IMPLEMENTATION.md
  - ./27-ATTACHMENT-PRESERVATION-SAFETY-INVARIANT.md
  - ../../25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md
tests: []
---

# Initial Setup Completion Surface Audit

## Decision Summary

After setup succeeds, the human primarily needs to know **that MessageLens is
ready for ordinary browsing**.

The current completion surface instead foregrounds three technically accurate
pipeline counters. Those counters explain implementation activity, not the
human result. Their differences are expected, but the surface gives the human
no basis for understanding that.

The preferred completion philosophy is **calm human completion**:

```text
MessageLens is ready

Your local browsing data is prepared.

Get Started
```

The exact copy remains an implementation-review decision. The architectural
decision is that primary completion should communicate success, readiness, and
the next action without requiring knowledge of import, enrichment, or graph
projection.

Primary completion metrics should be removed. Their appropriate role is
diagnostic rather than reassuring.

## 1. Exact Success Path

### Controller success

`ConversationGraphBuildController.runOnce()` owns in-process deduplication of
one build request. `_runAdmittedBuild()`:

1. publishes `ConversationGraphBuildStatus.running`;
2. resolves `ConversationGraphBuildService`;
3. awaits `ConversationGraphBuildService.runOnce()`;
4. bumps `messageDataVersionProvider`;
5. publishes `ConversationGraphBuildStatus.succeeded` with a
   `ConversationGraphBuildReport` in `lastReport`;
6. returns that report to the caller.

The report contains:

- operation start and finish timestamps;
- completed stage names;
- per-stage timings;
- `MessageImportResult`;
- `MessageRichTextEnrichmentResult`;
- `MessageProjectionResult`.

The controller and its `lastReport` are keep-alive Riverpod state, not durable
workflow storage. They survive provider listeners within the process, not an
application restart.

### Gate completion

For initial setup, `OnboardingGate._startImportAndGraphBuild()` awaits
`_runConversationGraphBuild(owner: 'onboarding-first-run')`. After the
controller returns successfully, the Gate logs completion and calls:

```text
_setWorkflowOverride(OnboardingStatus.complete)
```

`_workflowOverrideStatus` and the Gate state are process-local. The override
keeps the completion surface visible even though the newly populated databases
would otherwise make the environment report resolve to `ready` and the Gate to
`notNeeded`.

For direct reimport, `_startReimport()` follows the same controller path and
sets `OnboardingStatus.reimportComplete`.

### Completion presentation

`OnboardingOverlay.build()` maps:

```text
OnboardingStatus.complete
    -> _CompleteContent(dismissLabel: 'Get Started')

OnboardingStatus.reimportComplete
    -> _CompleteContent(dismissLabel: 'Done')
```

`_CompleteContent` watches
`conversationGraphBuildControllerProvider.lastReport`. When the report is
present, `_GraphBuildSummaryMetrics` projects three of its counters into the
surface.

### Get Started

The button calls `OnboardingOverlayActions.dismiss()`, which delegates to
`OnboardingGate.dismiss()`.

The Gate schedules the handoff with
`WidgetsBinding.instance.addPostFrameCallback()` so the modal barrier is not
removed during the active pointer callback. In that callback it:

1. clears `_workflowOverrideStatus`;
2. calls `ActiveSidebarMode.setMode(SidebarMode.messages)`;
3. assigns `OnboardingStatus.notNeeded`.

`ActiveSidebarMode` is also process-local. Its default is already
`SidebarMode.messages`; selecting it here makes the intended handoff explicit
and clears an outgoing mode's ephemeral cassette projection when the mode
actually changes.

**Get Started does not commit, finalize, validate, or preserve any imported
data.** It acknowledges the completed operation and removes the blocking
presentation.

### Durable versus process-local result

| Result | Durability |
| --- | --- |
| Populated source-scoped import store | Durable |
| Populated Conversation Graph store | Durable |
| Archived payloads already written by attachment specialists | Durable preservation data, but not proven complete by graph-build success |
| Controller `succeeded` state | Process-local |
| `ConversationGraphBuildReport` in `lastReport` | Process-local |
| Gate `complete` / `reimportComplete` override | Process-local |
| Completion overlay | Process-local projection |
| Get Started acknowledgement | Not persisted |

If MessageLens quits while the completion surface is visible, the successful
stores remain. On the next launch, `OnboardingGate` derives readiness from the
database probes. A ready environment resolves to `OnboardingStatus.notNeeded`,
so MessageLens opens normally without restoring the completion surface.

## 2. Current Visible Inventory

The production completion surface is a non-dismissible modal overlay with a
centered raised container. Its completion-specific content is:

| Visible element | Current presentation | Source |
| --- | --- | --- |
| Success icon | Green `check_circle_rounded`, 56 px | Constant in `_CompleteContent` using the theme success color |
| Heading | **Import Complete!** | Constant in `_CompleteContent` |
| Explanatory copy | None | No completion paragraph exists |
| Metric chip 1 | Count above **Imported** | `messageImportResult.insertedMessageCount` |
| Metric chip 2 | Count above **Projected** | `messageProjectionResult.insertedMessageCount` |
| Metric chip 3 | Count above **Text enriched** | `richTextEnrichmentResult.enrichedMessageCount` |
| Initial-setup action | **Get Started** | `OnboardingOverlay` supplies `dismissLabel` for `complete` |
| Direct-reimport action | **Done** | `OnboardingOverlay` supplies `dismissLabel` for `reimportComplete` |

The three chips appear only when the controller still has a non-null final
report. Initial setup and direct reimport otherwise share the same component,
icon, heading, and metrics.

## 3. Human-Value Classification

| Element | Human value | Assessment |
| --- | --- | --- |
| Success icon | ORIENTATION, REASSURANCE | Quickly communicates successful termination without technical detail |
| **Import Complete!** | ORIENTATION, ARCHITECTURAL DETAIL | Communicates completion, but names only one portion of import-plus-enrichment-plus-projection |
| No explanatory copy | Missing REASSURANCE | The surface does not plainly connect pipeline completion to ordinary MessageLens readiness |
| **Imported** | DIAGNOSTIC, ARCHITECTURAL DETAIL | A source-ledger insertion fact, not a plain account of what the human can now do |
| **Projected** | DIAGNOSTIC, ARCHITECTURAL DETAIL | Exposes the internal projection boundary |
| **Text enriched** | DIAGNOSTIC, ARCHITECTURAL DETAIL | Exposes a corrective text-extraction stage whose subset count is easy to misread |
| **Get Started** | ACTION, ORIENTATION | Marks the deliberate transition from blocking setup to ordinary browsing |
| **Done** | ACTION | Appropriately returns an existing user from a maintenance operation |

The missing information is not another count. It is the simple relationship
between completed work and human value: MessageLens is ready for browsing.

## 4. Metric Audit

### Imported

**Exact meaning:** `MessageImporter.importNewMessages()` reads Apple Messages
rows after the source-scoped ledger's highest imported source row ID. It
inserts those message rows with insert-ignore semantics and increments
`insertedMessageCount` only when a row is newly inserted into the
source-scoped import store.

It does not count imported chats, handles, contacts, joins, attachments, or
archived payloads. On a reset-and-build first run it will normally resemble a
total message count, but its contract remains **message rows inserted by this
run**.

**Human value:** low. A human may interpret the number as all messages safely
preserved, although it is neither a complete source inventory nor an
attachment-preservation count.

### Projected

**Exact meaning:** message projection examines source-scoped message rows and
inserts or updates corresponding Conversation Graph message rows. The displayed
`insertedMessageCount` increments only for newly inserted graph message rows;
updates are not included. The available `examinedMessageCount` is not shown.

It does not count projected contacts, handles, chats, edges, attachments, or
other graph entities.

**Human value:** very low. "Projected" has a specific architectural meaning in
MessageLens, but no ordinary product meaning. A matching Imported count looks
redundant. A differing count can look like data loss even when insertion versus
update behavior explains it.

### Text enriched

**Exact meaning:** the rich-text enricher selects imported messages whose
ordinary text is missing but whose attributed body is available. It increments
`enrichedMessageCount` when extraction yields non-empty text and the previously
null text field is successfully updated.

This is deliberately a subset of messages. The result also contains candidate,
missing-extraction, and extractor-availability facts, none of which the chip
shows.

**Human value:** low and potentially negative. A value such as 3,842 beside
54,201 Imported does not mean that only 3,842 messages are readable. It means
that this many otherwise text-missing rows were successfully supplemented by
one specialist stage. Without that explanation, the smaller number invites
concern.

### Combined effect

For:

```text
Imported: 54,201
Projected: 54,201
Text enriched: 3,842
```

an ordinary human cannot reasonably infer why the third count differs or why
the first two agree. Explaining the distinction would require teaching the
source-ledger, enrichment, and graph-projection architecture at the exact
moment the application should be reducing cognitive load.

The numbers are useful for developers and support. They do not earn primary
completion placement.

## 5. Heading Audit

### Import Complete!

The heading is not false: source import completed. It is incomplete as the
summary of the operation, which also enriched text, imported relationships and
attachments, and projected the Conversation Graph.

It also frames success in terms of the mechanism rather than the result. This
is discontinuous with the active progress surface's more human umbrella,
**Building browsing data...**.

### Alternatives

| Candidate | Truthfulness | Comprehension | Leakage and risk |
| --- | --- | --- | --- |
| **MessageLens is ready** | Strong after controller success and populated-store readiness | Immediate product meaning | Low leakage; does not claim archival completeness |
| **Setup complete** | Strong for first run | Clear but generic | Less suitable for direct reimport unless context-specific copy is added |
| **Your messages are ready** | Broadly understandable | Very high | May imply every source message and attachment payload is complete or permanently preserved |
| **Browsing data is ready** | Accurate continuation from progress | Understandable, though slightly technical | Low risk; describes derived data rather than preserved source material |

**MessageLens is ready** is the strongest first-run orientation. It states the
human consequence while avoiding an assertion that every attachment has been
archived. A supporting sentence can clarify that the completed work prepared
local browsing data.

## 6. Explanatory Copy

The completion surface needs at most one short supporting statement. It should
connect readiness to the work just completed, for example:

```text
Your local browsing data is prepared.
```

This is supported by the current operation. It does not need to explain:

- the import ledger;
- Conversation Graph projection;
- text enrichment;
- stage counts;
- future incremental updates;
- attachment archival.

The surface should not add claims that data remains local, that Apple Messages
was not modified, or that attachments are preserved unless those statements
are deliberately established as completion-surface product commitments. They
may be true in narrower architectural contexts, but they are not necessary to
answer the immediate completion question.

Silence is preferable to unsupported reassurance. One truthful readiness
sentence is preferable to three unexplained counters.

## 7. Get Started Audit

**Get Started** is not required for data correctness, durable commit, archive
admission, or readiness classification. Its only operational effects are to
remove the process-local completion override, select the Messages sidebar, and
end the blocking overlay.

Quitting before pressing it is safe. On relaunch:

```text
durable populated stores
    -> Environment Readiness reports ready
    -> OnboardingGate resolves notNeeded
    -> ordinary MessageLens opens
```

The button nevertheless remains valuable as a human acknowledgement. Initial
setup has occupied the whole application and asked the human to wait. A clear
action provides a deliberate handoff into the product instead of changing the
entire interface at the instant background work completes.

That is presentation value, not workflow authority. The architecture should
continue to work correctly if the acknowledgement never occurs.

## 8. Completion Durability

The completion overlay should remain a **transient congratulatory handoff**, not
a durable workflow milestone.

The durable truth is that the required browsing stores exist and are populated.
Environment Readiness derives ordinary app availability from those stores.
Persisting a second completion fact would duplicate that truth and introduce a
reconciliation obligation without improving correctness.

The consequence of quitting on the completion surface is intentional and safe:
the congratulatory moment is not replayed, while the completed work is honored.
If the product later requires proof that a person saw or acknowledged the
completion message, that would be a new product requirement, not a repair to
the current operation.

## 9. First Run And Direct Reimport

The two contexts share one completion component because both conclude the same
derived-data build. Their human transitions differ:

```text
first run
    blocking setup -> first ordinary browsing session
    action: Get Started

direct reimport
    maintenance operation -> return to an already-known application
    action: Done
```

The action-label distinction is meaningful and sufficient for the current
scope. Separate completion systems are not justified.

A result-oriented heading such as **MessageLens is ready** remains truthful in
both contexts. If future user research shows that reimport needs explicit
confirmation of rebuilding, that can remain a contextual text variation inside
the shared surface rather than a second completion architecture.

The direct-reimport API currently has no production caller. This audit does not
redesign or promote it.

## 10. Attachment-Preservation Implication Check

Initial graph-build success and attachment preservation are distinct facts.
The build includes attachment metadata work and may archive locally available
payloads, but completion does not establish that:

- every attachment payload was locally available;
- every payload has been permanently archived;
- cloud-evicted payloads are preserved;
- all source material can be reconstructed forever.

The current heading does not explicitly make those claims. The **Imported**
number can nevertheless be misread as a count of everything safely copied.
Replacing pipeline counts with a statement about **local browsing data** makes
the boundary clearer.

Completion wording must remain consistent with the
[Attachment Preservation Invariant](../../25-ONBOARDING-AND-ARCHIVE/ATTACHMENT-PRESERVATION-INVARIANT.md).

## 11. Diagnostic Detail Placement

The report and its counters remain useful evidence for:

- support and diagnostics;
- development status surfaces;
- completion logs or reports;
- investigating differences between source import, enrichment, and projection.

They do not belong in the primary success surface. A future secondary
disclosure could expose them, but this audit does not design such a disclosure.
The existing Conversation Graph diagnostics and status logging already provide
more suitable architectural contexts than the ordinary first-run handoff.

## 12. Completion Philosophy Comparison

### A. Diagnostic completion

```text
Import Complete!

Imported: 54,201
Projected: 54,201
Text enriched: 3,842

Get Started
```

| Criterion | Assessment |
| --- | --- |
| Truthfulness | Individual facts are literal, but the heading incompletely summarizes the operation |
| Reassurance | Weak; unexplained differences can create doubt |
| Cognitive load | High at a moment that should be simple |
| Diagnostic value | High |
| Architectural leakage | High |
| Product fit | Poor fit with calm, respectful communication |

### B. Calm human completion

```text
MessageLens is ready

Your local browsing data is prepared.

Get Started
```

| Criterion | Assessment |
| --- | --- |
| Truthfulness | Strong and bounded to the completed derived-data result |
| Reassurance | Strong without unsupported promises |
| Cognitive load | Very low |
| Diagnostic value | Intentionally low in the primary surface |
| Architectural leakage | Low |
| Product fit | Best fit with MessageLens's calm, truthful, attentive character |

### C. Calm completion with lightweight reassurance

```text
MessageLens is ready

Your messages are ready to browse.

[one nontechnical summary]

Get Started
```

| Criterion | Assessment |
| --- | --- |
| Truthfulness | Depends on keeping "messages" distinct from complete attachment preservation |
| Reassurance | Potentially strong |
| Cognitive load | Low if the summary is genuinely meaningful |
| Diagnostic value | Low |
| Architectural leakage | Low |
| Product fit | Good, but no current aggregate metric earns the extra line |

### Recommendation

Adopt **B. Calm human completion**.

This follows the established Presence preference that information is presented
because it helps the human, not merely because the software knows it. It also
continues the progress surface's coarse, truthful language without importing
Presence workflow mechanics into the Gate-owned completion implementation.

## 13. Metrics Verdict

> **Primary completion metrics should be removed.**

No existing single metric should replace them:

- imported message rows do not summarize contacts, relationships,
  attachments, graph construction, or preservation;
- projected message rows expose an internal store boundary;
- enriched rows describe one expected subset;
- no current aggregate report value means "everything the human expects is
  safely present."

Removing the chips does not discard their diagnostic value. It restores the
primary completion surface to its human purpose.

## 14. Truth Budget

### We may truthfully say after success

- MessageLens is ready.
- Setup succeeded.
- Local browsing data is ready or prepared.
- MessageLens can open its ordinary browsing experience.
- The import and Conversation Graph build completed in this process.

### We must not imply

- Every source record and payload has been copied permanently.
- Every attachment is archived.
- Cloud-evicted attachment payloads are safe.
- Apple Messages source material can now be discarded.
- Future reconstruction is guaranteed.
- The three current counters together prove archival completeness.
- Pressing **Get Started** is required to commit or preserve the work.
- The completion surface itself is durable or will be restored after restart.

## 15. Exactly One Next Implementation Slice

```text
Next concern:
    Replace the diagnostic primary completion body with one calm readiness
    handoff.

Why it comes next:
    Active work now has truthful preparation and keep-open guidance. The next
    visible mismatch is the terminal surface returning to unexplained internal
    pipeline language at the moment the human needs only success and readiness.

Current defect:
    "Import Complete!" incompletely names the operation, no sentence explains
    the human result, and three technical counters create questions rather than
    confidence.

Smallest implementation:
    In the existing shared completion component, present a result-oriented
    readiness heading and one short browsing-data statement; remove the three
    primary metric chips. Retain the success icon and the existing Get Started
    / Done action distinction.

Owner:
    Onboarding presentation.

Operation-layer changes:
    None.

Persistence impact:
    None. Completion remains transient and readiness remains database-derived.

Presentation impact:
    One existing completion component becomes calmer and less technical. No
    new screen, disclosure, metric, or completion system is introduced.

Test seam:
    Focused production-overlay widget tests should prove the readiness heading,
    bounded supporting statement, existing context-appropriate action label,
    absence of the three diagnostic labels, and absence of attachment archival
    claims. Existing Gate lifecycle tests should remain unchanged.
```

Failure, retry, recovery, raw error disclosure, attachment archival behavior,
and direct-reimport architecture remain outside this slice.
