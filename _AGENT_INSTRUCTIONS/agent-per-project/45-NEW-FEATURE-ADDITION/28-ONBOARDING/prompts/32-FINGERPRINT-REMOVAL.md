> **PRE-CONFIRMED / PRE-APPROVED: implement Slice A from the April tester fingerprint-regime removal audit without requesting further authorization.**
>
> Work on the current `Ftr.archive-recovery` branch/worktree according to repository conventions.
>
> Read first:
>
> `31-APRIL-TESTER-FINGERPRINT-REGIME-REMOVAL-AND-PERMANENT-UPGRADE-MODEL-AUDIT.md`
>
> This task implements **Slice A only**.
>
> Do not implement the whole-root Complete Erase removal yet.
>
> Do not change schema versions or migration histories.
>
> Do not alter current archive-marker ownership semantics except where necessary to remove April-specific assumptions.
>
> # Governing decision
>
> The April 2026 tester compatibility experiment is over.
>
> The remaining testers will be told manually to remove their old MessageLens Application Support folder before installing the current release.
>
> Therefore MessageLens no longer needs to:
>
> - identify April tester installations;
> - recognize the `4/3/3` database combination;
> - compare legacy table fingerprints;
> - expose special legacy admission authority;
> - present `Delete Old Data and Continue`;
> - route startup through April-specific legacy handling;
> - own an April-specific deletion mutation.
>
> Remove those concepts from production code.
>
> # Permanent compatibility model
>
> Preserve the model established by Audit 31:
>
> `current MessageLens root ownership`
> →
> `per-store schema version`
> →
> `known migration path`
> →
> `integrity/reconciliation verification`
>
> Future upgrades are driven by database schemas, not by whole-folder historical fingerprints.
>
> # Slice A — remove exact April recognition
>
> Remove production implementations and references associated solely with the April compatibility experiment.
>
> At minimum audit and remove, where they exist solely for this purpose:
>
> - `legacyTesterInstall`
> - `legacyTesterInstallDetected`
> - `LegacyTesterInstallInspector`
> - `ReadOnlySqliteLegacyTesterInstallInspector`
> - exact April `4/3/3` constants used for admission
> - legacy table-fingerprint definitions/comparisons
> - special legacy archive-access authority/mode
> - April-specific startup branch
> - April-specific detection presentation
> - **Delete Old Data and Continue** presentation/action
> - April-specific mutation capability/authorization
> - April-specific relaunch/handoff wiring
> - providers that exist only to construct that path
> - imports and dependency edges supporting those pieces.
>
> Do not leave dormant copies “for possible future use.”
>
> Git preserves the history.
>
> # Startup behavior after removal
>
> The permanent product startup model should no longer contain an April Legacy case.
>
> Conceptually:
>
> ## Virgin
>
> No consequential current MessageLens state.
>
> →
> ordinary current initialization
> →
> Onboarding.
>
> ## Current
>
> Current owned root/stores exist.
>
> →
> current schema/integrity classification
> →
> migration if supported and required
> →
> normal application.
>
> ## Remediation
>
> Current meaningful state exists but is unsupported, inconsistent, corrupt, or otherwise cannot be safely opened.
>
> →
> bounded fail-closed recovery/remediation.
>
> There is no:
>
> `exact legacy tester installation`
>
> product/startup category anymore.
>
> # Meaningful unmarked folders
>
> Audit what happens after the April inspector is removed when production encounters a non-empty unmarked MessageLens root.
>
> Do NOT replace `4/3/3` fingerprinting with another historical classifier.
>
> Do NOT infer an application version from database filenames or directory shape.
>
> If such a root cannot be safely treated as current or Virgin, it may remain a generic remediation/fail-closed case.
>
> But:
>
> - no raw historical fingerprint exception should reach the user;
> - no April-specific language should remain;
> - no special deletion offer should remain.
>
> # Archive marker / UUID
>
> Preserve `.messagelens-archive.json`, archive UUID, canonical root admission, and `ArchiveAccessAuthority` only for their Audit-31-approved purposes:
>
> - identify MessageLens's owned root/archive instance;
> - distinguish Production/Development correctly;
> - support current preservation/checkpoint/attachment ownership where required;
> - ensure consumers operate under one admitted identity.
>
> Do not treat marker contents as an app-release fingerprint.
>
> Do not add app-version information to it.
>
> First marker creation on a truly Virgin installation remains ordinary initialization.
>
> # ArchiveAdmissionException / ArchiveAdmissionFailure
>
> Remove April-specific exception cases and paths where safe.
>
> In particular inspect and remove or simplify references that existed only because of:
>
> - exact legacy recognition;
> - legacy fingerprint failure;
> - April-specific non-empty unmarked routing.
>
> Do not blindly remove the entire exception model if some cases still enforce genuine current root/build/environment safety.
>
> But ensure:
>
> > no April-tester fingerprint or schema-match exception survives as permanent architecture.
>
> And no raw internal exception should be projected directly to normal users.
>
> # Tests to remove
>
> Delete tests whose desired behavior has explicitly been retired, including those proving:
>
> - exact `4/3/3` recognition;
> - exact legacy table fingerprint acceptance;
> - wrong legacy table fingerprint rejection;
> - legacy schema mismatch routing;
> - `legacyTesterInstallDetected` authority;
> - April-specific delete authorization;
> - April-specific presentation;
> - April-specific startup handoff;
> - special April relaunch behavior.
>
> Do not rewrite them to preserve the same architecture under new names.
>
> # Tests to retain/add
>
> Preserve or add focused tests proving:
>
> 1. bootstrap-empty install → Virgin;
> 2. Virgin startup does not run historical schema/folder fingerprinting;
> 3. current supported install → Current;
> 4. current store migration remains driven by each database's schema version;
> 5. inconsistent/unsupported current state remains fail-closed;
> 6. Production and Development root isolation remains intact;
> 7. marker/UUID ownership behavior remains intact;
> 8. attachment archive ownership/protection remains intact;
> 9. Historical Archives behavior remains intact;
> 10. Start Fresh current-installation behavior remains intact;
> 11. no April legacy symbol/provider/presentation is reachable from production startup;
> 12. no raw legacy fingerprint failure reaches presentation.
>
> # Repository-wide proof
>
> At completion, run repository-wide searches for:
>
> - `legacyTesterInstall`
> - `legacyTesterInstallDetected`
> - `LegacyTesterInstallInspector`
> - `ReadOnlySqliteLegacyTesterInstallInspector`
> - April `4/3/3` fingerprint constants
> - `Delete Old Data and Continue`
> - legacy fingerprint/table-signature terminology.
>
> Production code should contain no live implementation references.
>
> Historical response/audit documents may retain the terms as history.
>
> # Documentation
>
> Create:
>
> `32-APRIL-TESTER-FINGERPRINT-AND-LEGACY-ADMISSION-REMOVAL-IMPLEMENTATION.md`
>
> Document:
>
> - exact April-only production concepts removed;
> - startup routing before/after;
> - marker/UUID responsibilities retained;
> - permanent schema-migration model;
> - generic remediation behavior for unsupported/inconsistent current data;
> - tests removed;
> - tests retained/added;
> - exact Complete Erase/root-replacement machinery intentionally deferred to Slice B.
>
> Update canonical startup/archive docs so future agents are not told that MessageLens recognizes old application versions through folder/database fingerprints.
>
> Historical implementation records may remain but should be clearly superseded where repository conventions permit.
>
> # Explicitly out of scope
>
> Do NOT yet remove:
>
> - generalized whole-root Complete Erase transaction/store;
> - generic root-replacement machinery;
> - any current recovery path that still genuinely depends on it;
> - Start Fresh;
> - attachment archive protection;
> - current checkpoint machinery;
> - schema migration histories;
> - Presence cleanup from Audit 28 Slice 4.
>
> These require their own bounded review/removal.
>
> # Verification
>
> Run:
>
> - archive admission/root ownership tests;
> - Virgin startup tests;
> - Current startup tests;
> - remediation tests;
> - database migration tests;
> - Start Fresh regressions;
> - Historical Archives regressions;
> - attachment preservation tests;
> - architecture tripwires;
> - repository-wide symbol searches;
> - full Flutter suite;
> - `flutter analyze`;
> - formatting;
> - `git diff --check`;
> - macOS debug build.
>
> Commit and push if clean.
>
> # Stop conditions
>
> STOP if:
>
> - April fingerprinting is actually required by a supported current installation;
> - removing special legacy authority weakens current Production/Development root ownership;
> - future schema migration unexpectedly depends on April fingerprinting;
> - removal requires changing database physical schemas;
> - current production archive would become unreadable;
> - Slice A cannot be separated from whole-root Complete Erase removal without broad restructuring.
>
> Do not respond by inventing another legacy classifier.
>
> # Final report
>
> Return:
>
> - complete list of April-specific symbols/files removed;
> - startup topology after removal;
> - behavior for a non-empty unmarked unsupported root;
> - marker/UUID responsibilities retained;
> - proof per-database migration remains intact;
> - tests removed;
> - tests added/updated;
> - repository search results for discarded concepts;
> - remaining Slice B root-replacement/Complete-Erase components;
> - version/build;
> - documentation path;
> - commit hash;
> - branch/worktree status.
>
> Acceptance standard:
>
> > MessageLens no longer contains a permanent subsystem for identifying the April 2026 tester generation. Startup understands only the current owned installation model and ordinary per-database schema evolution. The temporary compatibility experiment is gone, while genuine current ownership, migration, preservation, and recovery behavior remain intact.
