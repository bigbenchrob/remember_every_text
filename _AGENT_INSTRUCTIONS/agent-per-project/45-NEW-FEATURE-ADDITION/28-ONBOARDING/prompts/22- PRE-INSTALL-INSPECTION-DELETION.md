### Good — this is exactly the result we needed, and it vindicates your decision to narrow the problem.
### The important correction is thatmissing attachment_archive/ is not sufficient. The distributed 0.1.16+17 build already knew about attachment preservation and derived media; those directories were just lazy/optional. So deleting them in Development would not faithfully reproduce the tester state.
The strong discriminator is much better:
### macos_import.db v4
* working.db v3
* user_overlays.db v3
* no .messagelens-archive.json
* no macos_import_ss.db
* no working_ss.db
* no presence.db

⠀That identifies the exact pre-source-scoped generation used by the April tester build, even though it cannot prove that the folder came from precisely version 0.1.16+17.
And the audit’s next-step recommendation is sensibly bounded: build only the read-only legacy inspector first; stop before deletion. That lets us prove that current installations, Start Fresh installations, damaged current roots, and partial legacy roots cannot trip the gate accidentally.
I would proceed exactly that way. Here is the next prompt:
### PRE-CONFIRMED / PRE-APPROVED: proceed with this bounded implementation without requesting further authorization.
Work on the current Ftr.archive-recovery branch/worktree according to repository conventions.
Read:
### 18-LAST-DISTRIBUTED-TESTER-BUILD-LEGACY-INSTALL-SIGNATURE-AUDIT.md
The scope is deliberately narrow.
Implement only the read-only legacy tester installation inspector and startup classification/projection described in Response 18.
Do NOT implement deletion yet.
Do NOT extend generalized Complete Erase.
Do NOT add migration.
# Product purpose
### We have exactly three early testers who installed the April 27, 2026 tester build (MessageLens 0.1.16+17) and are not actively using MessageLens.
Their old MessageLens-owned data is disposable.
Before we offer deletion, current MessageLens must first be able to prove:
This is the known pre-source-scoped MessageLens database generation used by the last tester-distributed build.
# Exact legacy signature
### A root may classify as:
### legacyTesterInstall
only if ALL of the following are true:
* root is the canonical production MessageLens root supplied through current native archive claim/admission;
* root is non-empty and unmarked;
* macos_import.db exists, is readable read-only, reports legacy schema version 4, and has the required legacy-v4 table fingerprint;
* working.db exists, is readable read-only, reports legacy schema version 3, and has the required legacy-v3 table fingerprint;
* user_overlays.db exists, is readable read-only, reports legacy schema version 3, and has the required legacy-v3 table fingerprint;
* .messagelens-archive.json is absent;
* macos_import_ss.db is absent;
* working_ss.db is absent;
* presence.db is absent.

⠀Optional old artifacts such as:
* attachment_archive/;
* derived_media/;
* logs;
* SQLite -wal / -shm;
* unknown legacy files

⠀neither establish nor invalidate the signature.
# Read-only inspection boundary
### The inspector must never open these databases through current production providers.
### It must:
* open legacy SQLite stores read-only/query-only;
* perform no migration;
* perform no schema writes;
* create no marker;
* create no current database;
* create no log inside the legacy root;
* leave cancellation/failure completely non-mutating.

⠀Prefer a narrow component such as:
### LegacyTesterInstallInspector
or current repository naming equivalent.
# Typed result
### Return a small typed result sufficient for startup routing.
### At minimum distinguish:
* exact legacy tester generation proven;
* not legacy;
* inspection failed / cannot prove.

⠀Do not create a historical-version taxonomy.
Do not attempt to identify exact 0.1.16+17 from the data folder, because Response 18 proved that information is not persisted.
# Startup projection
### Integrate the inspector only at the point where the current app encounters an unmarked production root that cannot undergo ordinary archive admission.
### If and only if exactlegacyTesterInstall is proven:
* project a typed Onboarding/startup state indicating old tester data was detected;
* do not open normal current persistent stores;
* do not migrate;
* do not erase yet.

⠀Any other unmarked/invalid root must retain current fail-closed behavior.
# Generalized Complete Erase
### Keep its implementation quarantined.
### Do not expose it as the solution here.
### Do not use the existing broad erase-only admission rule as a substitute for this positive fingerprint.
### If current Prompt-16 code broadly admits arbitrary non-empty unmarked roots for erase, narrow that admission only as necessary so the special path requires the exact typed legacy proof.
### Do not otherwise refactor Complete Erase.
# Tests
### Add focused fixtures/tests proving:
1. exact 4/3/3 legacy trio + no modern evidence → legacyTesterInstall;
2. same legacy trio with optional attachment_archive/ → still legacy;
3. same with derived_media/ → still legacy;
4. healthy current marked install → not legacy;
5. ordinary Start Fresh install → not legacy;
6. missing only attachment_archive/ → not legacy;
7. missing marker alone → not legacy;
8. only one/two old databases → not legacy;
9. wrong legacy schema versions → not legacy;
10. right filenames but wrong table fingerprints → not legacy;
11. legacy trio plus macos_import_ss.db → not legacy;
12. legacy trio plus working_ss.db → not legacy;
13. legacy trio plus presence.db → not legacy;
14. legacy trio plus current marker → not legacy;
15. current installation containing retired old DB residue → not legacy;
16. inspection error → fail closed, no mutation;
17. inspection does not create/migrate/write any SQLite store;
18. no current database provider opens during legacy inspection.

⠀Include architecture tripwires protecting:
* no migration of legacy tester stores;
* no broad “unmarked folder = erasable” rule;
* exact positive legacy proof required;
* no normal store admission before legacy decision;
* no deletion in this slice.

⠀Presentation
### Add only the minimum typed startup/Onboarding state necessary to demonstrate that the legacy condition can be represented.
### Do NOT finalize dialog copy/actions yet if that would couple inspection to deletion.
### If a minimal placeholder presentation is required for integration testing, keep it bounded and document that the next slice owns authorization/deletion.
# Development testing
### Determine a simple way to reproduce the exact legacy signature using the normal MessageLens Development arm.
### Do not use arbitrary development-root overrides or external clones.
### Because deletingattachment_archive/ is not sufficient, identify the smallest safe Development-only fixture/preparation procedure that produces the proven legacy 4/3/3 signature without touching Production.
If this cannot be done simply with existing test/dev facilities, report that rather than building another fixture framework.
# Documentation
### Create:
### 19-LEGACY-TESTER-INSTALL-INSPECTOR-AND-STARTUP-CLASSIFICATION-IMPLEMENTATION.md
Document:
* exact signature;
* read-only inspection path;
* typed result;
* startup integration point;
* false-positive protection;
* relationship to current archive admission;
* relationship to generalized Complete Erase;
* tests;
* recommended next deletion/authorization slice.

⠀Update Feature 28 index/documentation log as appropriate.
Version/changelog only if repository rules require it for this code change.
# Verification
### Run:
* focused legacy inspector tests;
* archive admission tests;
* installation classification tests;
* Onboarding startup tests;
* Complete Erase regression tests as necessary;
* architecture tripwires;
* full Flutter suite if practical;
* flutter analyze;
* formatting;
* git diff --check;
* macOS debug build.

⠀Commit and push if clean.
# Stop conditions
### STOP if:
* exact legacy schema/table fingerprints cannot be checked without opening/migrating stores through current providers;
* native production-root admission cannot distinguish this path without broadening destructive authority;
* implementation requires a generalized historical classifier;
* implementation requires schema migration;
* ordinary current/Start Fresh installations can satisfy the signature;
* achieving this requires modifying tester/production data.

⠀Final report
### Return:
* exact typed legacy result;
* inspector location;
* startup integration point;
* proof that inspection is read-only;
* false-positive test matrix result;
* whether broad Prompt-16 erase-only admission was narrowed;
* whether a simple ordinary-Development reproduction is available;
* verification results;
* documentation path;
* commit hash.

⠀Stop there.
Do not implement the delete confirmation or delete operation until this inspector has been reviewed.
Acceptance standard:
Current MessageLens can recognize the specific pre-source-scoped tester generation positively and read-only, while every other unmarked, incomplete, current, Start Fresh, or damaged installation remains incapable of entering the tester-delete path.
That gets us back to a very sane rhythm: prove recognition first, then add one tiny “Yes, throw it away” step.
