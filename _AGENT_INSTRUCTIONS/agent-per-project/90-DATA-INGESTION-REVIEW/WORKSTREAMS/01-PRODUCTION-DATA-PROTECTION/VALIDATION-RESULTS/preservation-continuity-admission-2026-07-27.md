# Preservation Continuity Admission

Date: 2026-07-27

Result: Transitional process identified; freshness not established

> Historical observation, superseded operational conclusion.
>
> Subsequent verification established that Debug/Run had already been
> mechanically separated from production. No legacy Debug preservation process
> currently exists. See
> [`../04-REVISED-OPERATIONAL-STATE.md`](../04-REVISED-OPERATIONAL-STATE.md)
> and
> [`production-candidate-and-adoption-rehearsal-2026-07-27.md`](production-candidate-and-adoption-rehearsal-2026-07-27.md).
> The process and archive observations below remain useful audit history, but
> their recommended operating procedure is no longer current.

This report applies the implementation-slice admission contract in
[`../PRODUCTION-PRESERVATION-AUTHORITY.md`](../PRODUCTION-PRESERVATION-AUTHORITY.md).
It is a read-only observation. No production process was launched or stopped,
and no production archive content was changed for this verification.

## Corrected Operational Context

The months-old `/Applications/MessageLens.app` is not the canonical production
application and must not automatically receive preservation responsibility.
It remains a reference artifact until the current production identity and
handoff procedure have been established.

For several months, the normal operational workflow was to run MessageLens from
VS Code in Debug mode. That process unintentionally became the process that
maintained the production archive. The production archive is still unmarked
and has not completed the separately authorized production-adoption procedure.
It therefore has no admitted `ArchiveInstanceId` under the new architecture.

## Process Observed

One MessageLens-related process was running:

```text
PID: 67049
launched: 2026-07-26 10:06:35 PDT
executable:
/Users/rob/Development/FlutterProjects/rob_index/build/macos/Build/Products/Debug/rob_index.app/Contents/MacOS/rob_index
bundle identifier: com.example.robIndex
```

This legacy Debug process does not carry the target production application
identity and was not admitted through the new archive-identity boundary.
Nevertheless, it is the bounded provisional preservation process because it is
the process that has actually maintained the production archive.

## Preservation Evidence

The legacy process has nevertheless been operating against the production
archive. Read-only inspection found:

- live graph updates committed to the production graph;
- a source advance from row `151998` to `152000` at 06:43 PDT;
- five attachments archived successfully for that source range;
- a later source advance from row `152000` to `152001` at 07:34 PDT;
- one attachment archived successfully for that source range;
- the latest persisted attachment sweep completed at
  `2026-07-27T17:19:16.224290Z` (10:19 PDT) with:
  - 100 candidates scanned;
  - 0 newly archived;
  - 100 skipped;
  - 0 failed.

The archive-enabled setting is absent from `overlay_settings`, which the current
settings contract interprets as enabled. Successful archive operations provide
stronger direct evidence that attachment preservation was enabled during the
observed runs.

At 15:02 PDT, the latest persisted sweep evidence was approximately four hours
and forty-three minutes old. The process still existed, but fresh preservation
activity could not be demonstrated.

## Admission Decision

The observation identifies the transitional preservation process but does not
establish fresh operational evidence. Transition implementation remains gated
because:

1. the running legacy process has not been admitted under the target
   architecture;
2. its latest durable preservation evidence was stale at the observation time;
3. the production archive has no adopted marker or explicit authority
   assignment; and
4. no current signed production successor has yet been staged and verified.

A live PID is not sufficient evidence. This observation demonstrates why the
architecture requires a fresh heartbeat and operation evidence rather than a
persisted running flag or process-presence check.

## Historical Required Next Step (Superseded)

Before transition implementation begins:

1. leave the legacy Debug preservation process running;
2. verify a fresh Messages source probe and attachment-preservation pass from
   that process;
3. prepare and statically verify a current signed production successor without
   launching it against the production archive;
4. keep development launches confined to the separate development identity and
   archive;
5. perform no process or archive handoff until the production preservation
   handoff plan is reviewed and separately authorized.

This report does not authorize stopping the legacy process, launching the old
installed application, adopting the production archive, or installing a
successor.
