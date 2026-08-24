---
tier: project
scope: onboarding-source-anomalies
owner: agent-per-project
last_reviewed: 2026-08-24
source_of_truth: implementation-record
---

# Dependency-Aware Anomaly Policy for Remaining Onboarding Domains

## Result

Onboarding source intake now distinguishes structural failure from degraded
interpretation without introducing a generic catch-and-skip mechanism.

The durable operation snapshot carries one fixed, typed set of exact anomaly
totals. It contains no source payload, names, addresses, message text, or raw
handle values. Repeated progress observations coalesce by maximum count so
bounded snapshot writes do not double-count an anomaly.

## Dependency Table

| Domain | Identity authority | Parents | Dependents | Optional enrichment | Safe degraded form | Safe local omission | Fatal conditions |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Chat | source ROWID + GUID | none | participant edges, chat-message edges, conversations | service, group metadata, read date | nullable metadata; zero participants | an invalid participant edge only | missing ROWID or GUID |
| Message | source ROWID + GUID + direction | chat edge is optional | rich text, reactions, attachments, graph message | timestamp, sender, text, service flags | nullable timestamp/sender/text; unlinked evidence | invalid child relationship only | missing ROWID, GUID, or direction |
| Rich text | parent message identity | message | displayed text | attributed-string interpretation | parent message and raw blob remain; text unavailable is counted | one undecodable blob | decoder capability unavailable for a run with candidates |
| Attachment | source ROWID | message edge is optional | graph attachment and archive resolution | GUID, filename, UTI, MIME, physical payload | source fact with nullable metadata; payload availability remains a later truthful fact | invalid message-attachment edge | missing source ROWID or unsafe database failure |
| Reaction | carrier message identity plus raw associated fields | carrier message | optional target resolution | reaction type and target interpretation | carrier survives with raw fields and nullable target | none required in the current model | carrier message structural failure |
| Contact | AddressBook `Z_PK` | none; contacts only enrich handles | contact channels and matching | names, organization, labels, channels | source contact survives as unavailable enrichment | record without identity; unusable channel | source database/systemic import failure |

## Policy Vocabulary

- **Fully preserved:** the ordinary import and projection path.
- **Preserved with degraded interpretation:** structural source fact survives,
  while optional semantics remain null or opaque and an exact count is kept.
- **Locally omitted with explicit accounting:** only a child relationship or
  enrichment fact whose omission cannot change parent truth.
- **Recovered through canonical fallback:** a valid message without a usable
  conversation edge remains graph evidence owned by Recovered Messages.
- **Fatal structural/integrity failure:** required identity, direction, or a
  run-wide decoding capability is unavailable.

## Domain Decisions

### Chats

Chat ROWID and GUID remain required. MessageLens does not fabricate either.
Service, group metadata, last-read date, and participant count may be absent.
An invalid chat-handle relationship is omitted and counted, but the chat is
not discarded. An invalid chat-message edge is likewise omitted; its message
then remains eligible for the canonical recovered/unlinked presentation.

### Messages and Reactions

Message ROWID, GUID, and `is_from_me` remain structural. Timestamp, sender,
plain text, attributed interpretation, and a chat edge are not allowed to
erase an otherwise valid message. Missing canonical timestamps and messages
without chat edges are counted. The latter use the existing Recovered Messages
ownership; Unknown Sources is not an anomaly bucket.

Reactions remain message carriers with raw associated GUID/type evidence. If
their target cannot be resolved, the carrier message is projected with a null
target and the unresolved target is counted. No target or semantic value is
invented.

All Apple timestamp conversion continues to use the mandatory
`DateConverter` utility.

### Rich Text

A single malformed attributed body is local. The message identity, raw blob,
relationships, attachments, and any plain text remain intact; unavailable
decoded text is counted. If the typedstream decoder capability itself is
unavailable while candidates exist, intake fails with a typed systemic source
exception. Treating every candidate as a coincidental local anomaly would make
completion untrustworthy.

No arbitrary prevalence threshold was introduced. The proven escalation rule
is capability based, not percentage based.

### Attachments

Attachment ROWID establishes the source-scoped fact. Sparse descriptive
metadata is preserved and counted rather than rejected. Payload existence is
not claimed by this importer; physical preservation and availability remain
owned by the attachment archive/resolution architecture. A broken
message-attachment child edge is omitted and counted without affecting the
parent message.

### Contacts

Contacts enrich message identity; they do not own message existence. A source
contact with no usable display fields remains in the import ledger with the
existing neutral placeholder and is counted as unavailable enrichment. A row
without `Z_PK`, or a channel without a valid owner/value, is locally omitted
and counted. No Messages record depends on these rows for existence.

## Referential and Completion Semantics

Relationship importers now verify both source endpoints before constructing a
source-scoped edge. They never manufacture an endpoint or insert a dangling
edge. Safely handled rows still advance real progress.

Onboarding is **complete** when every source fact was preserved normally,
preserved through an approved degraded form, recovered through canonical
ownership, or omitted only under one of the explicit child/enrichment rules
above. Exact typed totals survive completion in the canonical operation
snapshot.

There is no new “complete with attention” state. These anomalies are not
normally actionable by the user. A fatal structural or systemic exception
prevents the graph-build stage from completing and therefore prevents durable
readiness verification.

## Durable Evidence

`SourceImportAnomalyCounts` contains fixed fields for the approved outcomes:

- opaque handles;
- unavailable message timestamps;
- recovered unlinked messages;
- unavailable rich-text decoding;
- sparse attachment metadata;
- unresolved reaction targets;
- omitted/unavailable contact enrichment;
- omitted chat-message, chat-handle, and message-attachment relationships.

Only exact totals are durable. Representative source ROWIDs were not added:
the existing progress cursor already supplies bounded technical location, and
persisting per-anomaly samples was not necessary to make this slice truthful.

## Performance

The healthy path remains row-oriented and exception-free. Message relationship
and reaction evidence is calculated by source-database `EXISTS` expressions,
not by one Dart database query per message. Relationship endpoint validation
is performed in one joined source query per relationship table. Durable
snapshot writes retain the existing bounded progress cadence.

## Intentionally Fatal Conditions

- missing chat ROWID or GUID;
- missing message ROWID, GUID, or direction;
- missing attachment ROWID;
- source database/integrity failures;
- typedstream decoder capability unavailable when decoding work exists.

Changing those outcomes would require fabricated identity, ambiguous
completion, or a schema/identity redesign and was outside this slice.

## Verification

- 394 focused source-import, Conversation Graph, Recovered Messages,
  Onboarding, and Message History Coverage tests passed.
- 412 architecture tripwires passed, including the new dependency-aware source
  anomaly policy checks.
- The complete Flutter suite passed: 2,027 tests.
- `flutter analyze` completed with no issues.
- The macOS debug build completed successfully as `MessageLens Development.app`.
- Formatting and `git diff --check` completed cleanly.

The healthy path adds joined or correlated source-SQL checks rather than
per-row Dart queries. Anomalous fixtures exercise the same bounded progress
cadence and deterministic classifications. No new production-shaped timing run
was required because this slice did not alter the previously profiled
observation cadence or introduce per-record persistence.
