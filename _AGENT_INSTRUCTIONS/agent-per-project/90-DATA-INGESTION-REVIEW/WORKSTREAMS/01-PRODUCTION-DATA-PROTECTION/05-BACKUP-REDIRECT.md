Final Production Cutover Preparation

Before continuing, I want to clarify both the operational state and the style of communication I expect.

Communication

Please write for a senior software engineer, not for a compiler.

Use plain English.

Avoid introducing new terminology when ordinary engineering terms already exist.

For example:

- “verified production backup” is clearer than “offline checkpoint” when discussing operational procedures.
- “backup folder” is clearer than “checkpoint destination.”
- “restore the backup” is clearer than “restore the checkpoint.”

Specialized terminology is appropriate only when it represents a genuinely new architectural concept.

The goal of these documents is long-term maintainability by humans.

⸻

Current Operational State

Development isolation is now functioning correctly.

Debug/Profile launches now use:

- MessageLens Development
- the development bundle identity
- the external development archive

This behaviour is correct.

The previous Debug process no longer preserves the production archive.

That is expected.

The production archive is currently unowned until the new production application assumes responsibility.

Do not undo development isolation.

Do not point Debug back at production.

Do not attempt to recreate the previous workflow.

⸻

Existing Production Backup

I have already manually created a complete offline backup of the entire production Application Support folder on an external drive immediately before this transition.

Unless you discover evidence that this backup is incomplete, corrupted, or missing required files, treat it as the operational recovery backup for this transition.

Do not require me to create another backup merely because internal implementation terminology refers to a “checkpoint.”

If additional confidence is required, verify the existing backup.

Do not duplicate it.

⸻

Separate These Concepts

Please distinguish clearly between the following:

Operational Backup

A complete offline copy of the production archive created for disaster recovery.

This already exists.

Its purpose is:

If the production transition fails catastrophically, the archive can be restored.

⸻

Adoption Inventory

A read-only inspection of the current production archive immediately before adoption.

Its purpose is:

- confirm expected files exist;
- verify database integrity;
- record archive state;
- verify marker state;
- establish pre-cutover evidence.

This is not another backup.

⸻

Archive Adoption

The operation that introduces archive identity while leaving the production archive itself in place.

⸻

These are different concepts.

Please keep them distinct in the documentation.

⸻

Authorized Remaining Work

Proceed autonomously to:

1. Produce the final signed and notarized production artifact.
2. Verify:
   - bundle identifier;
   - product name;
   - archive environment;
   - signing identity;
   - entitlements;
   - notarization;
   - canonical production archive policy.
3. Verify the existing offline backup rather than creating another one unless you discover an actual deficiency.
4. Produce the read-only adoption inventory of the production archive.
5. Complete the production cutover runbook.
6. Present the final authorization package.

⸻

Do Not Yet

Do not:

- launch the production candidate;
- install the production application;
- create the production archive marker;
- modify the production archive;
- perform archive adoption;
- replace the existing application;
- begin the production cutover.

Those actions still require explicit authorization.

⸻

Final Authorization Package

Return with one concise engineering report containing:

Production artifact

- location
- identity verification
- signing verification
- notarization verification

Existing backup

Confirm whether my existing backup is complete and suitable for recovery.

Only recommend creating another backup if you have objective evidence that the existing one is inadequate.

Production archive inventory

Summarize:

- databases
- attachment archive
- integrity checks
- pre-cutover state

Use plain English.

Avoid unnecessary jargon.

Production cutover

Provide:

- estimated sequence of operations;
- expected interruption points;
- point before which the operation is fully reversible;
- point after which recovery requires restoring the verified backup;
- post-launch verification steps.

The report should be readable by a future engineer who has never seen this project before.

Clarity is now more valuable than sophistication.

Our goal is not to impress the reader.

Our goal is to preserve a lifetime of conversations safely.
