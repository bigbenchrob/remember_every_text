Here’s the cleaned-up short Codex prompt:

> Work on branch `Ftr.archive-recovery`.
>
> Read:
>
> - `26-PRODUCTION-ARCHIVE-RECOVERY/00-START-HERE.md`
> - `26-PRODUCTION-ARCHIVE-RECOVERY/03-HISTORICAL-MESSAGES-2012-2016-INGESTION-AUDIT.md`
>
> Perform **staging-clone rehearsal preparation only**.
>
> Use these disposable working copies:
>
> ```text
> /Volumes/WD_ELEMENTS/ARCHIVE_INGESTION_TRIAL/2026-08_16-DATA_FOLDER-STAGING
> /Volumes/WD_ELEMENTS/ARCHIVE_INGESTION_TRIAL/Messages_2012-DONOR
> ```
>
> Do not touch:
>
> - current production MessageLens data;
> - the frozen production backup;
> - the original `/Volumes/WD_ELEMENTS/Old_Messages/Messages_2012` donor;
> - any attachment payloads.
>
> ## Tasks
>
> 1. Verify that `2026-08_16-DATA_FOLDER-STAGING` is a complete production-shaped MessageLens clone and passes the repository’s existing integrity/checkpoint verification appropriate for a restored archive.
> 2. Verify the donor copy:
>
> ```text
> /Volumes/WD_ELEMENTS/ARCHIVE_INGESTION_TRIAL/Messages_2012-DONOR/chat.db
> ```
>
> has SHA-256:
>
> ```text
> b6180dd4511fe0b345e2dae2bc6adb7baabf8354d3521eb9ebd69ab849a5a174
> ```
>
> Its WAL is known to be empty. Do not use its WAL/SHM in the rehearsal source.
>
> 3. Create:
>
> ```text
> /Volumes/WD_ELEMENTS/ARCHIVE_INGESTION_TRIAL/Messages_2012-IMPORT_SOURCE
> ```
>
> containing **only a byte-identical copy of `chat.db`**.
>
> Verify the copied `chat.db` has the same SHA-256, then make the copied file and containing source folder read-only.
>
> 4. Reclassify **only**:
>
> ```text
> /Volumes/WD_ELEMENTS/ARCHIVE_INGESTION_TRIAL/2026-08_16-DATA_FOLDER-STAGING
> ```
>
> as a development archive using the repository’s existing supported format-v1 archive-marker conventions/tooling.
>
> Give it:
>
> - environment = `development`;
> - a fresh archive instance ID.
>
> Preserve the original copied production marker as evidence before replacing the staging clone’s marker.
>
> Do not alter any production marker or production archive.
>
> 5. Verify structurally that the staging root is admissible by the **MessageLens Development** identity and not as production.
> 6. Report the exact launch command using:
>
> ```text
> MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT="/Volumes/WD_ELEMENTS/ARCHIVE_INGESTION_TRIAL/2026-08_16-DATA_FOLDER-STAGING"
> ```
>
> and `flutter run -d macos`.
>
> ## Stop point
>
> **STOP before launching MessageLens.**
>
> Do not:
>
> - run Historical Archives preflight;
> - run dry run;
> - import anything;
> - alter databases beyond the staging clone’s archive marker;
> - write to `attachment_archive`;
> - modify the donor copy except for creating the separate `Messages_2012-IMPORT_SOURCE`;
> - modify application code unless a genuine preparation blocker is found.
>
> Report:
>
> ```text
> staging integrity result
> original staging marker
> new development marker / archive instance ID
> donor hash
> import-source hash
> import-source permissions
> development-admission verification
> exact launch command
> any blocker
> ```
>
> If any safety check fails, stop and report rather than improvising.
