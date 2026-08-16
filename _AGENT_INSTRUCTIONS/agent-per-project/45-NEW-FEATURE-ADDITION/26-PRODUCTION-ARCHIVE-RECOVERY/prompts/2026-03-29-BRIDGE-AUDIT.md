

> Work on branch `Ftr.archive-recovery`.
>
> Read:
>
> `26-PRODUCTION-ARCHIVE-RECOVERY/00-START-HERE.md`
>
> Then perform the first **strictly read-only attachment-recovery feasibility audit**.
>
> The donor Apple Messages backup is:
>
> `/Volumes/WD_ELEMENTS/DO_NOT_LOSE/iMessages_backup/Messages-bkp-2026-03-29`
>
> It contains:
>
> - the donor `chat.db`;
> - the preserved Apple Messages attachment tree, apparently named `Attachments-2026-03-29`, approximately 44 GB.
>
> The current production MessageLens archive is the currently configured production data folder. Resolve its exact path from current application configuration/documentation rather than guessing.
>
> ## Objective
>
> Determine whether the donor `chat.db` can serve as a relational index allowing preserved donor attachment payloads to be matched to **messages already present in the current MessageLens archive**, including translation through the current source-scoped message identity model.
>
> The intended bridge is conceptually:
>
> ```text
> donor attachment payload
> -> donor chat.db attachment record
> -> donor message_attachment_join
> -> donor chat.db message
> -> stable Apple/source message identity
> -> current MessageLens source-scoped identity
> -> current MessageLens message
> -> current attachment/archive record
> ```
>
> Do not assume exact column/table names. Establish the real bridge from current schemas and code.
>
> ## Hard safety rules
>
> **Both donor and current production archives are read-only for this task.**
>
> - Open SQLite databases read-only/query-only.
> - Do not launch MessageLens against either archive.
> - Do not checkpoint, vacuum, migrate, repair, normalize, copy, rename, delete, or modify anything.
> - Do not write a recovery script yet.
> - Do not copy attachment payloads.
> - Do not ingest donor messages.
> - Do not investigate the separate circa-2012 Messages archive.
>
> The donor attachment payloads are preservation data. Treat them like gold.
>
> ## Questions to answer
>
> 1. How does donor `chat.db` identify and link attachment records, physical attachment paths, and owning message records?
> 2. What stable source identity from those donor message records survives into current MessageLens?
> 3. How does the source-scoped model translate that identity to the current MessageLens message ID?
> 4. Can the relational chain be demonstrated end-to-end on a small representative sample without heuristics?
> 5. Approximately what proportion of donor attachment records/payloads can be directly mapped to current MessageLens messages?
> 6. How does current MessageLens determine whether the corresponding payload is already safely archived or is missing?
> 7. What existing attachment-archival code could later perform the actual copy without changing message history?
> 8. What residue remains: unmapped DB records, filesystem orphans, missing donor files, or destination conflicts?
>
> ## Success threshold
>
> This is **preservation recovery, not forensic completeness**.
>
> If the direct relational bridge maps roughly **99%** of the relevant preserved attachments, consider the matching strategy successful.
>
> Do **not** start inventing increasingly speculative heuristic fallback algorithms merely to approach 100%. Quantify the unmapped residue and leave it for later unless the direct match rate is unexpectedly poor.
>
> Keep separate:
>
> ```text
> relational match rate
>     donor attachment -> current MessageLens message
>
> recovery opportunity
>     matched payload exists in donor but is absent from current archive
> ```
>
> ## Output
>
> Create:
>
> `26-PRODUCTION-ARCHIVE-RECOVERY/01-MARCH-2026-ATTACHMENT-RELATIONAL-BRIDGE-AUDIT.md`
>
> Record:
>
> - exact donor/current structures inspected;
> - exact relational identity bridge;
> - source-scoped translation;
> - sample proof;
> - counts and direct-match rate;
> - already-present versus apparently recoverable payloads where safely measurable;
> - unmapped/conflict categories;
> - existing code seam suitable for eventual recovery;
> - **one smallest next implementation step**.
>
> Update the package index/log as appropriate.
>
> Run only non-mutating verification and `git diff --check`.
>
> **Stop after the read-only audit. Do not recover any files yet.**
>
> If anything would require writing to either archive to answer these questions, stop and report the limitation instead.

That should give us the one number that matters first: **does the clean relational bridge still get us approximately 99%?** If yes, we can stop thinking about matching algorithms and build the smallest possible recovery operation.
