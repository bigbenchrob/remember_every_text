Preservation Continuity Recovery — Revised Operational State

The cause of the onboarding behaviour is now understood and confirmed.

Debug/Run correctly launches:

Bundle identifier:
com.bigbenchsoftware.MessageLens.development
Environment:
development
Archive root:
/Volumes/WD_ELEMENTS/DEVELOPMENT_DATA_FOLDER/MessageLens Development

That development archive is currently uninitialized, so entering onboarding is expected.

The previous Debug process can no longer serve as the provisional production preservation process because Debug has already been mechanically separated from the production archive.

Current operational fact

There is presently no running MessageLens process preserving newly arriving Messages attachments into the production archive.

The former prerequisite of obtaining fresh preservation evidence from the legacy Debug process is therefore impossible and must be retired.

Do not undo development isolation.

Do not repoint Debug or VS Code Run at the production archive.

Do not launch the months-old /Applications/MessageLens.app merely because it has the production bundle identity.

Immediate objective

Treat the present state as an urgent but controlled production-preservation handoff preparation.

Prepare the fastest safe path to a current signed production application capable of opening the existing production archive and resuming live Messages and attachment preservation.

Authorized work

Proceed autonomously to:

1. Identify the exact current production build command and signing requirements.
2. Create or refine a non-publishing production-candidate build path from the current codebase.
3. Build a current production candidate without installing or launching it.
4. Statically verify:
   - bundle identifier;
   - product name;
   - archive environment;
   - signing identity and team;
   - entitlements;
   - Full Disk Access expectations;
   - canonical production archive root;
   - absence of development identity or development-root metadata.
5. Verify that the candidate’s startup logic will recognize the existing production archive as unmarked and will therefore require the explicit production-adoption procedure rather than silently onboarding, creating a new archive, or failing ambiguously.
6. Rehearse the complete production adoption and startup sequence against a disposable copy of the production archive or a representative disposable production clone.
7. Verify checkpoint creation, marker adoption, startup, source access, catch-up import, attachment preservation, and rollback entirely in the disposable rehearsal.
8. Produce the exact cutover runbook for the real production archive.

Critical sequencing correction

The implementation plans must be updated to reflect:

- development separation is already active;
- the legacy Debug preservation process no longer exists;
- fresh legacy-process evidence is not available;
- the next continuity mechanism is the current signed production candidate;
- production preservation remains interrupted until the authorized cutover;
- preparation should therefore be expedited without weakening production safeguards.

Do not continue implementing optional preservation-heartbeat architecture before the production candidate and handoff runbook are ready unless that implementation is strictly required for the candidate to preserve attachments safely.

The immediate goal is restoration of actual production preservation, not completion of every future observability feature.

Authorization boundary

You may build, sign, inspect, and rehearse using disposable archives.

You are not yet authorized to:

- launch the candidate against the real production archive;
- create the production marker in the real archive;
- replace or remove /Applications/MessageLens.app;
- stop or alter unrelated applications;
- modify production databases or attachments;
- perform the real production-adoption handoff.

Return when:

- the signed candidate is ready;
- static verification has passed;
- the disposable handoff rehearsal has passed;
- the exact real cutover and rollback runbook is ready for explicit authorization.

If a credential, signing identity, or external action is required, report only that specific blocker and the exact user action needed.
