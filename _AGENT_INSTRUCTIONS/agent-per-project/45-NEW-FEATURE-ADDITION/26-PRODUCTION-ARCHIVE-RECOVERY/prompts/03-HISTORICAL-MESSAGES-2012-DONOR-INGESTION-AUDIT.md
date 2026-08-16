Work on branch `Ftr.archive-recovery`.

> Reopen Feature Addition:
>
> `26-PRODUCTION-ARCHIVE-RECOVERY`
>
> Read its existing `00-START-HERE.md` and recent audit/closure documents, then perform a **strictly read-only historical Messages ingestion feasibility audit**.
>
> Historical donor:
>
> `/Volumes/WD_ELEMENTS/Old_Messages/Messages_2012`
>
> Current production MessageLens root:
>
> `~/Library/Application Support/com.bigbenchsoftware.MessageLens`
>
> **Do not mutate either location.**

> The current production snapshot/backup is being completed separately. Do not create a staging clone or run ingestion yet.
>
> ## Objective
>
> Determine the safest way to ingest the historical Messages records from `Messages_2016` into a **disposable clone of the current production MessageLens archive**, using the existing source-scoped historical-ingestion machinery.
>
> Do not design a new importer unless the existing architecture genuinely cannot do the job.
>
> ## Safety
>
> - Treat the historical donor as read-only preservation data.
> - Use immutable SQLite inspection where possible.
> - Do not open the donor in a mode that can modify WAL/SHM coordination state.
> - Do not launch MessageLens against the donor or production archive.
> - Do not alter production databases or `attachment_archive`.
> - Do not copy or ingest anything yet.
>
> ## Establish from evidence
>
> 1. Exact structure of `Messages_2016`.
> 2. Which `chat.db` family is authoritative and whether WAL contains relevant uncheckpointed records.
> 3. Earliest/latest message dates and counts.
> 4. Whether this donor actually contains the expected roughly 2012–2016 history; determine the dates rather than assuming them.
> 5. Amount of chronological/identity overlap with the current live Messages source.
> 6. How existing historical-source ingestion assigns a separate `source_id` and produces source-scoped message/attachment IDs.
> 7. Which existing production components implement historical ingestion, especially the current `historicalArchiveImport` path and related snapshot/import/graph services.
> 8. Whether the existing code can ingest this donor **without resetting or replacing the live-source import data, current graph facts, Overlay, or attachment archive**.
> 9. How overlapping messages are represented. Do not assume deduplication behavior; establish it from current source-scoped architecture.
> 10. Whether historical attachment payload ingestion is necessary for this first operation. The immediate priority is old message history; do not expand scope unless the existing import requires attachment handling.
>
> ## Staging plan
>
> Produce an exact safe rehearsal procedure:
>
> ```text
> completed production snapshot
>     -> disposable working clone
>     -> historical donor remains read-only
>     -> run existing historical ingestion against clone
>     -> verify live/current data unchanged
>     -> verify historical source added
>     -> inspect old messages in MessageLens
> ```
>
> Identify precisely how MessageLens would be pointed at the **staging clone**, without any possibility of accidentally selecting the real production folder.
>
> Do not execute this procedure yet.
>
> ## Verification plan
>
> Define the minimum checks required before we would ever promote a successfully tested staging archive:
>
> - current live-source message counts/content preserved;
> - current attachment archive unchanged;
> - Overlay/user intent preserved;
> - historical source registered distinctly;
> - expected old date range visible;
> - graph contains the historical messages;
> - restart works;
> - normal live-source catch-up remains possible afterward.
>
> ## Output
>
> Create:
>
> `26-PRODUCTION-ARCHIVE-RECOVERY/03-HISTORICAL-MESSAGES-2012-2016-INGESTION-AUDIT.md`
>
> Update the Feature 26 start page/index/log to say the feature has been temporarily reopened for this separate historical-message recovery task.
>
> End with **one concrete recommended next operation**: the staging-clone rehearsal.
>
> Do not implement or execute ingestion.
>
> Run only non-mutating verification and `git diff --check`, then stop.
