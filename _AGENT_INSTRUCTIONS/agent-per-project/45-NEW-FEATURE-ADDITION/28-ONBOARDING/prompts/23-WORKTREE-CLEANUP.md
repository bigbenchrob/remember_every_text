Use this as the cleanup/isolation prompt before we touch deletion behavior:

> **PRE-CONFIRMED / PRE-APPROVED: proceed with this bounded worktree-isolation and commit-preparation pass without requesting further authorization.**
>
> Work on the current `Ftr.archive-recovery` branch/worktree according to repository conventions.
>
> This task is NOT a new feature slice.
>
> The goal is:
>
> > Isolate the Prompt 22 legacy-tester-recognition implementation from unrelated/stale uncommitted work, restore the worktree to a comprehensible state, and commit Prompt 22 as one narrow coherent change if safe.
>
> Do not implement deletion behavior yet.
>
> Do not extend generalized Complete Erase.
>
> Do not alter production/tester data.
>
> Do not make speculative cleanup changes.
>
> ## Known Prompt 22 result
>
> Prompt 22 implemented:
>
> - typed outcomes:
>   - `legacyTesterInstall`
>   - `notLegacy`
>   - `inspectionFailed`
> - exact legacy `4/3/3` database-version recognition;
> - complete legacy table fingerprints;
> - read-only SQLite inspection;
> - current-marker/current-store exclusion;
> - removal/narrowing of broad arbitrary-unmarked-root `completeEraseOnly` authority;
> - startup recognition before current persistent stores open;
> - `legacy_tester_install_detected_view.dart`;
> - no deletion;
> - no mutation authority for the recognized legacy state.
>
> Verification already reported:
>
> - 19 focused inspector tests passed;
> - 119 broader focused tests passed;
> - 385 architecture tripwires passed;
> - full suite 2,152 passed;
> - analyzer clean;
> - debug macOS build succeeded;
> - `git diff --check` clean.
>
> Prompt 22 was not committed because the worktree contained substantial unrelated changes.
>
> ## Known worktree contamination/history
>
> Earlier work accumulated uncommitted or partially overlapping edits around:
>
> - Prompt 15 documentation correction;
> - Prompt 16 generalized Complete Erase;
> - Prompt 17 containment audit;
> - development-only Complete Erase relaunch investigation;
> - later read-only audits;
> - shared files including `main.dart`, `CHANGELOG.md`, and architecture tests.
>
> Some of those changes may be intentional and already committed elsewhere.
>
> Some may be stale working-copy edits.
>
> Some may belong to Prompt 22.
>
> Do not infer ownership from timestamp alone.
>
> ## Phase 1 — inventory the entire dirty worktree
>
> Produce a complete table of every modified/untracked file:
>
> | File | Diff summary | Likely origin | Prompt 22 required? | Action |
>
> Classify each as one of:
>
> ### A — Prompt 22 required
> Necessary for the legacy inspector/startup-recognition slice.
>
> ### B — Earlier intentional but uncommitted
> Legitimate work from Prompt 15/16/17/etc. that should be preserved but committed separately or restored from a known intended version.
>
> ### C — Stale/accidental working-copy contamination
> Examples may include the previously identified incorrect Prompt 15 replacement containing Complete Erase material.
>
> ### D — Unknown
> Stop before discarding.
>
> Use:
>
> - `git status`;
> - `git diff`;
> - `git diff --staged`;
> - relevant recent commits;
> - Feature 28 response docs;
> - prompt/history files;
>
> to establish provenance.
>
> ## Phase 2 — establish committed baseline
>
> Identify the exact current HEAD and recent relevant commits, including:
>
> - `460d571e` final Feature 28 conformance;
> - `a35f3edb` Complete Erase implementation;
> - any subsequent committed work, if present.
>
> Do not assume the current HEAD is still one of those commits.
>
> Report the actual branch history relevant to the dirty files.
>
> ## Phase 3 — Prompt 22 patch boundary
>
> Construct the exact logical patch belonging to Prompt 22.
>
> At minimum inspect whether Prompt 22 legitimately touches:
>
> - legacy inspector implementation;
> - startup/archive admission;
> - onboarding legacy-detected presentation;
> - typed archive/startup state;
> - focused tests;
> - architecture tripwires;
> - Feature 28 Response 19;
> - Feature 28 index/documentation log;
> - version/changelog if repository rules required them.
>
> For shared files such as `main.dart`, `CHANGELOG.md`, and architecture tests:
>
> separate Prompt 22 hunks from unrelated hunks.
>
> Do not discard an entire file merely because it contains mixed changes.
>
> ## Phase 4 — preserve intentional earlier work
>
> If earlier legitimate uncommitted work exists:
>
> - preserve it exactly;
> - use patch/stash/temp-file techniques as needed;
> - do not silently fold it into Prompt 22;
> - do not commit unrelated runtime changes under the Prompt 22 commit.
>
> If the only earlier change is documentation that is clearly intended and independent, prepare it as a separate commit if mechanically safe.
>
> If provenance is uncertain, STOP and report rather than guessing.
>
> ## Phase 5 — repair known stale Prompt 15 working copy
>
> Inspect the Prompt 15 working-copy diff specifically.
>
> The known approved state is:
>
> - six-node human Journey:
>   `Messages → History → Contacts → Ready → Import → Start`
> - durable verification is internal;
> - Prompt 15 must not contain the later ~700-line Complete Erase material.
>
> If the current Prompt 15 working copy is still the known accidental replacement:
>
> restore it to the approved six-node correction only.
>
> Do not rewrite Prompt 15 beyond that known correction.
>
> If it no longer matches that situation, report exact current state before editing.
>
> ## Phase 6 — documentation provenance
>
> Ensure these remain distinct:
>
> - Prompt 15 final conformance;
> - Prompt 16 Complete Erase;
> - Prompt 17 containment audit;
> - Response 18 legacy distributed-build audit;
> - Response 19 Prompt 22 recognition implementation.
>
> Do not overwrite one response/prompt with another feature's content.
>
> ## Phase 7 — commit strategy
>
> Preferred outcome:
>
> ### Commit 1, if needed
> Documentation-only restoration/correction for Prompt 15 or other clearly independent stale-doc repair.
>
> ### Commit 2
> Prompt 22 legacy-tester recognition slice only.
>
> Do not create unnecessary micro-commits.
>
> If the earlier documentation correction was already committed in substance, do not duplicate it.
>
> ## Phase 8 — Prompt 22 verification after isolation
>
> After isolating the intended patch, rerun enough verification to prove nothing was lost during hunk separation:
>
> - legacy inspector focused tests;
> - archive/startup focused tests;
> - Onboarding startup tests;
> - relevant Complete Erase regressions;
> - architecture tripwires;
> - `flutter analyze`;
> - `git diff --check`;
>
> Run the full suite only if needed by repository rules or if shared production files were materially reconstructed during isolation.
>
> Run a macOS debug build if Prompt 22 production code changed from the already-verified state during cleanup.
>
> ## Phase 9 — final worktree state
>
> Goal:
>
> - Prompt 22 committed and pushed;
> - no Prompt 22 changes left dirty;
> - unrelated intentional work either:
>   - committed separately,
>   - explicitly preserved but still dirty with a precise explanation,
>   - or restored if proven stale;
> - no mystery modifications.
>
> A clean worktree is preferred, but do not achieve cleanliness by discarding legitimate unknown work.
>
> ## Safety
>
> Do not:
>
> - touch any MessageLens archive/database;
> - launch old tester build;
> - run Complete Erase;
> - modify production/tester data;
> - alter Apple Messages/Contacts;
> - implement the legacy deletion action;
> - add new architecture.
>
> ## Documentation
>
> Create a short record:
>
> `20-PROMPT-22-WORKTREE-ISOLATION-AND-COMMIT-RECONCILIATION.md`
>
> Record:
>
> - initial dirty files;
> - provenance classification;
> - stale edits repaired;
> - Prompt 22 patch boundary;
> - commit strategy;
> - verification;
> - final worktree status.
>
> ## Stop conditions
>
> STOP if:
>
> - any dirty hunk's ownership cannot be determined confidently;
> - isolating Prompt 22 would require guessing between two plausible implementations;
> - restoring Prompt 15 would destroy legitimate later edits;
> - shared-file hunks cannot be separated mechanically;
> - branch history conflicts with the assumed Prompt 22 baseline.
>
> ## Final report
>
> Return:
>
> - current HEAD before cleanup;
> - initial dirty-file inventory;
> - which changes belonged to Prompt 22;
> - which changes belonged elsewhere;
> - any stale edits restored;
> - Prompt 22 commit hash;
> - any separate documentation commit hash;
> - verification results;
> - final `git status`;
> - whether the branch is now ready for the final tiny legacy-delete authorization slice.
>
> Acceptance standard:
>
> > We should end with a worktree whose history makes sense: Prompt 22 exists as a narrow reviewable commit, stale rabbit-hole debris is not mixed into it, and nothing legitimate was discarded merely to make `git status` look clean.

Once that comes back clean, the next prompt really should be tiny: detect legacy → ask → delete that arm’s old data → continue Onboarding.