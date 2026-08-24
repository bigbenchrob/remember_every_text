---
tier: project
scope: onboarding-source-anomalies
owner: 28-ONBOARDING
last_reviewed: 2026-08-24
source_of_truth: implementation-record
---

# Dependency-Aware Source Anomaly Handling: Handles

## Result

Handle source identity and semantic handle interpretation are now separate.
A nonempty source handle that cannot truthfully be interpreted as a phone or
email is preserved in the import ledger and Conversation Graph under its
canonical source-scoped row identity. It does not enter canonical alias
grouping or normalization-based contact matching.

No database schema changed. Existing tables already preserve the required raw
value, source ID, source ROWID, source-scoped ID, and graph relationships.

## Dependency Map

| Source domain | Authoritative source identity | Downstream dependencies | Optional interpretation | Required structural truth | If dropped | Opaque preservation policy |
| --- | --- | --- | --- | --- | --- | --- |
| Handle | `handle.ROWID`, packed with source ID | `chat_handle_join`, message sender handle, graph handle topology, contact enrichment | Phone/email normalization, alias grouping, contact matching | Source ROWID and raw nonempty identifier | Chats lose participants; messages lose sender evidence | Implemented: preserve raw handle and relationships; omit alias/contact semantics |
| Chat | `chat.ROWID` plus source GUID where present | Chat-handle membership, chat-message membership, conversation projection | Display labels and other descriptive metadata | Source identity and truthful relationship keys | Conversation membership becomes incomplete | Preserve source identity and usable joins; do not invent missing relationships. Domain policy remains future work |
| Message | `message.ROWID` plus source GUID | Chat membership, sender, attachments, reactions, evidence/search | Text decoding and optional presentation fields | Source identity and every relationship the source actually supplies | User evidence is lost | Preserve the row and raw/recovery evidence when optional interpretation fails. Required-identity policy remains future work |
| Attachment | `attachment.ROWID` and source relationship | Message-to-attachment evidence and optional preservation payload | MIME/UTI/path interpretation, thumbnailing | Attachment identity and truthful message relation | Message may remain, but attachment evidence is lost | Keep message and attachment evidence distinct; payload unavailability is local and must never be reported as archived |
| Reaction | Source message/reaction evidence and associated-message reference | Target-message annotation and reaction presentation | Reaction-kind interpretation | Truthful source carrier and target relationship | Reaction evidence is lost; target message need not be lost | Preserve carrier evidence; never invent a target when association cannot be proved |
| Contact | AddressBook source row identity | Contact channels, graph contact, contact-to-handle enrichment | Name preparation and channel-to-handle matching | Source identity for imported contact evidence | Identity enrichment is lost; Messages data should not be blocked | Contacts remain enrichment. A failed match creates no fake contact or handle edge |

This table is an audit, not a generic fallback framework. Each domain still
requires its own dependency proof before anomaly policy changes.

## Handle Pipeline

```text
chat.db handle ROWID + selected source ID
    -> SourceScopedRowKey
    -> import handles row with raw id/service
    -> typed HandleIdentifierInterpretation
       -> normalized: eligible for canonical alias grouping
       -> preservedUnnormalized: source identity only
    -> graph handles row
    -> chat/message relationships continue to use source-scoped handle ID
    -> display may fall back to raw graph handle metadata
```

`HandleIdentifierInterpretation` has two successful outcomes:

- `NormalizedHandleIdentifier` carries the established canonical phone/email
  grouping value.
- `PreservedUnnormalizedHandleIdentifier` states explicitly that no semantic
  grouping value was established.

`HandleIdentifierNormalizationException` is the narrow typed boundary for an
interpreter rejecting semantic normalization while source identity remains
usable. Structural failures such as a missing source ROWID or empty required
identifier still fail with bounded source-row context. Other exceptions are
not swallowed.

## Historical Archetype and Prior Behavior

The tester archetype is a punctuation-heavy service identifier resembling
`*city*`. Repository history does not prove that this exact literal caused the
historical Onboarding stop. Current import code already preserved that row.

The current defect was later in graph projection: the old alias builder used a
raw-text fallback as a canonical grouping key. That did not drop the row, but
it assigned unsupported semantic meaning and could merge two distinct source
rows merely because their opaque raw strings matched.

The correction removes that false fallback. It also rebuilds derived aliases,
resynchronizes existing message canonical-sender references, and removes
derived contact edges whose canonical-handle basis no longer exists. Raw graph
handles, sender source identity, messages, and chats remain intact.
The now-unused raw-fallback canonical grouping helper was removed so it cannot
become an attractive path for a later caller.

## Determinism and Privacy

Opaque identity is the existing `SourceScopedRowKey(sourceId, sourceRowId)`.
No random ID, hash, local arithmetic, or synthetic phone/email value exists.
Two opaque source rows with identical raw values therefore remain distinct.

Raw values remain in their existing source-derived database columns for
presentation fallback and future forensic interpretation. Outcome accounting
contains only counts; broad operation snapshots and exceptions do not include
the raw value.

## Accounting

Handle import and projection now report:

- examined handles;
- normalized handles;
- handles preserved without normalization.

The preserved count propagates through source-import progress, graph-build
observation, and the durable Onboarding operation snapshot. A successfully
returned result has zero fatal rows by definition. Structural failure remains
a typed stage failure with bounded domain/source-ROWID context rather than a
misleading returned counter.

No new warning surface was added. Ordinary progress remains uncluttered; the
durable diagnostic evidence is available if a future Details surface earns it.

## Performance

Normal values use the typed return path rather than exceptions. Focused tests
interpret a representative 10,000-value normal set without exception control
flow. A local profile classified 100,000 mixed phone, email, scheme-prefixed,
and opaque values in 34,836 microseconds on the development Mac (75,000
normalized; 25,000 preserved). This is directional evidence rather than a
portable performance threshold. The change adds one bounded string
classification during handle import and projection; it adds no per-message
work and no extra database query per handle.

## Structural Anomaly Principle

> Preserve source identity and relationships whenever interpretation is
> optional.

> Fail only when continuing would create false relationships, lose required
> identity, or make durable graph truth untrustworthy.

This principle does not authorize skipping anomalous rows. Opaque preservation
is valid only where the current schema can retain the source record and every
required relationship truthfully.

## Verification Coverage

Focused tests prove:

- established phone and email normalization is unchanged;
- punctuation-heavy and unexpected service identifiers are opaque;
- typed normalization rejection preserves the source row;
- duplicate opaque raw strings do not merge;
- opaque handles retain deterministic source-scoped identity;
- chat and message relationships survive import and projection;
- message presentation retains raw sender evidence with no fake canonical ID;
- contact matching ignores opaque raw strings;
- reprojection clears stale alias, message-canonical, and contact-edge meaning;
- structural source identity failure still fails with bounded row context;
- progress and durable snapshot accounting survive JSON round trips;
- architecture tripwires prohibit raw fallback canonicalization.
