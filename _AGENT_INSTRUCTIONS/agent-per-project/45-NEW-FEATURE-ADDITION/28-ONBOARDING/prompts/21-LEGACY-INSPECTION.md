Yes. I’d make the first pass **strictly read-only and evidence-driven**. We want to identify the exact legacy signature of the build those testers installed before touching current Onboarding again.

> Work on the current `Ftr.archive-recovery` branch/worktree according to repository conventions.
>
> This prompt is READ-ONLY.
>
> Do not modify application code, website files, the DMG, tester data, production data, or current MessageLens archives.
>
> The objective is narrow:
>
> > Determine the exact persistent-data shape created by the last tester-distributed MessageLens build, so current Onboarding can recognize those old tester installations and offer a simple “delete old MessageLens data and continue” path.
>
> The known distributed artifact is:
>
> `/Users/rob/Development/website/MessageLens/assets/downloads/MessageLens-latest.dmg`
>
> The surrounding tester website is:
>
> `/Users/rob/Development/website/MessageLens`
>
> ## Scope
>
> Inspect the DMG and the website metadata/readme/build data needed to establish:
>
> 1. exact app version/build distributed;
> 2. bundle identifier/product identity;
> 3. approximate distribution date if recorded;
> 4. schema/database generations used by that build;
> 5. exact MessageLens-owned persistent artifacts that build would create in its normal production data folder;
> 6. whether it predates:
>    - `.messagelens-archive.json`;
>    - `attachment_archive/`;
>    - `derived_media/`;
>    - current overlay schema;
>    - current Presence schema;
>    - current import/graph database names;
>    - current archive-environment marker/admission model.
>
> ## Inspect the actual artifact
>
> Mount or otherwise inspect `MessageLens-latest.dmg` read-only.
>
> Determine:
>
> - app bundle name;
> - `CFBundleIdentifier`;
> - `CFBundleShortVersionString`;
> - `CFBundleVersion`;
> - signing/notarization metadata where easily available;
> - embedded database/schema/version constants where recoverable from the bundle or matching git revision;
> - any bundled defaults that indicate old persistent filenames.
>
> Do not launch the old app against any live data folder.
>
> ## Recover matching source revision if possible
>
> Use:
>
> - website metadata;
> - git history;
> - changelog/version history;
> - build scripts;
> - tags/commits;
>
> to identify the source revision that most likely produced this DMG.
>
> If exact commit identity cannot be proven, report the narrowest supported version range instead of guessing.
>
> ## Persistent-artifact inventory
>
> For the distributed build, produce a table:
>
> | Artifact | Exists in old tester build? | Name/path | Meaning | Still current? |
>
> At minimum audit:
>
> - import database;
> - working/graph database;
> - overlay database;
> - Presence database;
> - archive marker;
> - attachment archive;
> - derived media;
> - logs;
> - preferences/settings;
> - operation snapshot/onboarding state;
> - source registry;
> - any other persistent files/directories created by that build.
>
> ## Central question
>
> Determine the simplest reliable proof of:
>
> > “This MessageLens data folder belongs to the last tester-distributed legacy build and should be discarded rather than migrated.”
>
> Prefer a tiny discriminator over a generalized historical classifier.
>
> Candidate signals may include:
>
> - absence of `attachment_archive/`;
> - old database filenames;
> - old schema versions;
> - absence of `.messagelens-archive.json`;
> - presence of a specific legacy marker/file combination.
>
> Do not choose a signal until you prove it against the actual distributed build.
>
> ## False-positive audit
>
> For each candidate discriminator ask:
>
> - Could a current healthy installation legitimately satisfy this?
> - Could ordinary Start Fresh satisfy this?
> - Could a damaged current installation satisfy this?
> - Could a different historical generation satisfy this?
>
> We do not need a universal historical classifier, but we must avoid deleting a current installation merely because one folder happens to be missing.
>
> ## Preferred outcome
>
> If evidence supports it, recommend a bounded legacy gate such as:
>
> `existing production MessageLens data folder`
> +
> `specific old-build signature`
> →
> `legacyTesterInstall`
>
> and no broader taxonomy.
>
> Do not implement yet.
>
> ## Tester-cohort relevance
>
> The intended users are exactly the three early testers who briefly installed this distributed build and are not actively using MessageLens.
>
> Their old MessageLens-owned data is intentionally disposable.
>
> The future product behavior we are evaluating is:
>
> > During Onboarding, detect this known old tester installation, explain that it is from an older test version, ask permission to delete the old MessageLens data folder, and then continue through normal virgin Onboarding.
>
> No migration.
>
> No preservation of old MessageLens state.
>
> No generalized Complete Erase feature required for this cohort.
>
> ## Relationship to Prompt 16
>
> Do not modify or extend the generalized Complete Erase implementation in this audit.
>
> Instead, determine whether this narrow legacy-tester path could replace the need to expose Complete Erase as part of the tester rollout.
>
> ## Safety
>
> Do not:
>
> - launch the old distributed app;
> - mutate the DMG;
> - alter the website;
> - touch production MessageLens data;
> - touch current development archives;
> - touch Apple Messages/Contacts;
> - create migration fixtures;
> - delete anything.
>
> ## Deliverable
>
> Create:
>
> `18-LAST-DISTRIBUTED-TESTER-BUILD-LEGACY-INSTALL-SIGNATURE-AUDIT.md`
>
> Document:
>
> 1. exact distributed build identity;
> 2. evidence tying the DMG to version/source;
> 3. old persistent artifact inventory;
> 4. current-vs-old artifact comparison;
> 5. candidate legacy signatures;
> 6. false-positive analysis;
> 7. recommended smallest discriminator;
> 8. whether missing `attachment_archive/` is sufficient;
> 9. whether Prompt 16 Complete Erase is still needed for these testers;
> 10. exact recommended next implementation slice.
>
> ## Final report
>
> Return:
>
> - distributed version/build;
> - likely source commit/revision if proven;
> - exact old data-folder shape;
> - whether `attachment_archive/` existed;
> - best legacy-install discriminator;
> - false-positive risk;
> - whether the three testers can be handled by a narrow Onboarding delete-old-data gate;
> - whether generalized Complete Erase should remain, be hidden, or be removed from this rollout;
> - documentation path.
>
> Stop after the audit.
>
> Acceptance standard:
>
> > We should end this task knowing exactly what those three testers installed and exactly how the current app can recognize that old installation without inventing a generalized migration or destructive-data-management subsystem.