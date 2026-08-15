PRODUCTION-ARCHIVE-LIVE-PRESERVATION.md

Purpose

The archive-isolation architecture deliberately separates development and production archives. During the transition period before production adoption, this creates an operational question that must be answered explicitly:

Which archive is responsible for preserving newly arriving Apple Messages attachments?

This document records the current understanding, the associated risk, and the required operational procedure until production adoption is complete.

⸻

Background

Historically, MessageLens development and production operated against a single application archive.

The archive-isolation project intentionally changed this.

Development now runs against its own admitted development archive, while the existing production archive remains isolated and untouched pending the authorized production-adoption procedure.

This is the correct architectural direction and is a primary safety goal of the project.

⸻

Operational Risk

Apple Messages increasingly treats attachment files as transient storage.

Image attachments, videos, audio, and other message assets may eventually be removed from Apple’s attachment store even though the corresponding message remains present in chat.db.

MessageLens preserves these assets by copying them into its own attachment archive.

If no admitted archive performs this preservation before Apple removes the original attachment, the opportunity to archive that attachment may be permanently lost.

⸻

Current Assumption

Until production adoption has been completed and verified, assume:

- the production archive remains the canonical long-term archive;
- newly arriving attachments should ultimately be preserved there;
- development experiments must never endanger production preservation.

This assumption should be verified before production adoption.

⸻

Required Verification

Before production adoption, determine precisely:

1. Which admitted archive currently performs live incremental message monitoring.
2. Which admitted archive currently copies newly arriving attachments into its archive.
3. Whether development and production archives can preserve attachments independently.
4. Whether attachment preservation is suspended whenever no admitted archive is running.

The answers should become permanent project documentation.

⸻

Temporary Operational Procedure

Until responsibility has been explicitly verified and documented:

- continue treating the existing production archive as the authoritative preservation archive;
- periodically launch the production application if required to ensure newly arriving attachments are archived before Apple removes them;
- do not assume that running the development application alone preserves production attachment history.

The exact launch frequency depends on Apple’s attachment-retention behaviour and should be reconsidered once the preservation owner is confirmed.

⸻

Desired Long-Term Architecture

Eventually, attachment preservation should not depend on remembering which application to launch.

Instead, one admitted archive should explicitly own the role of:

Primary Live Preservation Archive

Responsibilities would include:

- incremental message monitoring;
- attachment preservation;
- live graph updates;
- operational evidence generation.

Development archives would remain isolated and experimental while the designated primary archive would provide continuous preservation of irreplaceable user data.

⸻

Completion Condition

This document may be retired once:

- production adoption has completed successfully;
- responsibility for live attachment preservation has been mechanically assigned;
- documentation identifies the preserving archive unambiguously;
- ordinary operation no longer depends on manual user intervention.

⸻
