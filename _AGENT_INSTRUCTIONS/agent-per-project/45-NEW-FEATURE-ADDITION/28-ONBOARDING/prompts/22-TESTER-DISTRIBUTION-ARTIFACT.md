### Yes. I’d make the next step arelease/distribution verification pass, not another feature slice.
Give Codex this:
### PRE-CONFIRMED / PRE-APPROVED: proceed with this bounded release/distribution verification without requesting further authorization.
Work on the current Ftr.archive-recovery branch/worktree according to repository conventions.
Current state:
* Feature 28 Onboarding is complete.
* Legacy April-era tester reset flow is implemented.
* Current version: 0.2.99+117.
* Latest commit: 8e3e3726.
* Worktree is clean and synchronized.

⠀The goal is:
Produce and verify the exact tester-distribution artifact for the next external drop, update the tester website/download metadata, and stop before actually sending anything to testers.
This is a release-readiness task, not a feature task.
# Read first
### Inspect:
* current build/release/notarization documentation;
* certificate/signing guidance;
* tester website at: ### /Users/rob/Development/website/MessageLens
* existing distribution artifact: ### /Users/rob/Development/website/MessageLens/assets/downloads/MessageLens-latest.dmg
* website release metadata: ### assets/data/latest-build.json ### assets/data/tester-changelog.json
* site build script and README;
* current MessageLens version/changelog;
* any current release runbook governing signed/notarized tester builds.

⠀Phase 1 — release identity audit
### Confirm:
* app version/build is 0.2.99+117;
* production bundle identifier is correct;
* tester distribution uses the production identity, not MessageLens Development;
* signing identity is correct;
* required entitlements are present;
* no development-root override metadata is embedded;
* current production archive/data identity rules remain correct.

⠀Do not build until these facts are understood.
# Phase 2 — certificate/signing readiness
### Verify the currently required Developer ID Application / Installer certificates and notarization path are usable.
### Do not create/replace certificates unless actually required.
### If any certificate/agreement blocks release, STOP and report the exact blocker.
# Phase 3 — build the normal tester distribution
### Use the canonical repository distribution pipeline.
### Prefer the existing documented command:
### ./tool/build_and_notarize.sh
unless current documentation proves another command has replaced it.
Produce the signed/notarized tester DMG through the normal production path.
Do not use a Debug/Profile development build.
# Phase 4 — static artifact verification
### Verify the produced app/DMG:
* version/build;
* bundle identifier;
* signing team;
* Developer ID signature;
* hardened runtime;
* entitlements;
* notarization/stapling;
* Gatekeeper assessment;
* absence of development-only metadata/override;
* expected product name;
* expected embedded architecture(s).

⠀Record exact commands/results.
# Phase 5 — tester install behavior
### Without touching the real production MessageLens archive, verify as far as safe that:
* a clean first install routes into current Onboarding;
* a recognized April-era legacy install would route to the new delete-old-data gate;
* ordinary current/healthy install would not see that gate.

⠀Use automated/tests/static evidence where launching against production would be unsafe.
Do not manufacture another elaborate archive-validation environment.
# Phase 6 — update tester website
### Prepare the tester portal at:
### /Users/rob/Development/website/MessageLens
Update only what is needed for this release:
* replace assets/downloads/MessageLens-latest.dmg with the newly verified artifact;
* update assets/data/latest-build.json;
* update assets/data/tester-changelog.json if appropriate;
* rebuild static site if required by its build script;
* update visible version/build/date/release notes.

⠀Keep copy concise.
Suggested release emphasis:
* completely rebuilt Onboarding;
* clear permission/history guidance;
* continuously visible import progress;
* automatic handling of the old April tester installation;
* improved reliability and recovery.

⠀Do not overwhelm testers with internal architecture.
# Phase 7 — old-build replacement proof
### Verify that:
* the website’s MessageLens-latest.dmg is the new artifact;
* its hash differs from the April 0.1.16+17 artifact;
* metadata points to 0.2.99+117;
* no stale page still advertises 0.1.16+17 or April 2026.

⠀Search the whole tester-site tree for stale version/build strings.
# Phase 8 — website build/check
### Run whatever local site build/check exists.
### Confirm:
* download link resolves to the new DMG;
* pages render from generated/current source;
* no broken relative assets;
* release metadata is internally consistent.

⠀Do not publish yet unless the site workflow itself requires a local build step only.
# Phase 9 — deployment/publishing audit
### Determine the exact third-party publishing workflow used for this tester site.
### Report:
* service/provider;
* deployment command or drag/drop process;
* target site/project;
* whether publishing is automatic or manual;
* whether credentials/session are available.

⠀Do not publish unless current repository/site conventions make publishing an inseparable, already-authorized part of the release command.
Otherwise STOP before publication and give the human the final publishing step.
# Phase 10 — tester instructions
### Draft the exact short instructions for the three testers.
### Target flow:
1. download/install the new build;
2. launch MessageLens;
3. if old April test data is detected, choose Delete Old Data and Continue;
4. proceed through Onboarding;
5. report any blocker immediately.

⠀No Finder navigation.
No Terminal.
No manual database deletion.
# Documentation
### Create a release record:
### 22-TESTER-RELEASE-DISTRIBUTION-VERIFICATION-0.2.99+117.md
Record:
* build identity;
* signing/notarization results;
* DMG path/hash;
* website files changed;
* release metadata;
* stale-version search result;
* publishing workflow;
* exact tester instructions;
* any remaining blocker.

⠀Verification
### Run:
* release build pipeline;
* artifact verifier;
* notarization/stapling/Gatekeeper checks;
* relevant release-focused tests;
* flutter analyze;
* git diff --check;
* website build/check;
* stale version/string search.

⠀Commit and push repository changes if clean.
If website is a separate git repository, report its status separately and commit there only according to its conventions.
# Stop conditions
### STOP if:
* signing or notarization fails;
* certificate/agreement state is ambiguous;
* artifact identity is not production;
* development metadata is embedded;
* the tester site points at a stale/wrong DMG;
* publication target cannot be proven;
* release requires touching the real production MessageLens archive.

⠀Final report
### Return:
* release classification: READY / BLOCKED;
* exact artifact path;
* version/build;
* DMG SHA-256;
* signing/notarization/Gatekeeper status;
* website files changed;
* publishing method;
* whether anything was actually published;
* exact tester instructions;
* commit hash(es);
* branch/worktree status;
* what the human must do next, if anything.

⠀Acceptance standard:
We end with one verified signed/notarized 0.2.99+117 tester DMG, the tester site prepared to serve that exact artifact, and a simple rollout instruction for the three early testers—without reopening Feature 28 architecture.
