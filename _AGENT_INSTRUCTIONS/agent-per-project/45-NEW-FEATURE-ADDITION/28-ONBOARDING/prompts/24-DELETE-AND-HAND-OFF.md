Use this for the final narrow slice:

> **PRE-CONFIRMED / PRE-APPROVED: proceed with this bounded implementation without requesting further authorization.**
>
> Work on the current `Ftr.archive-recovery` branch/worktree according to repository conventions.
>
> Read first:
>
> - Response 18: last distributed tester build legacy signature audit
> - Response 19: legacy tester install inspector/startup classification
> - Response 20: worktree isolation and reconciliation
>
> The worktree is clean. Prompt 22 recognition is committed at:
>
> `71dd2a65`
>
> This task is intentionally tiny.
>
> ## Product goal
>
> Solve one specific rollout problem:
>
> > Three early testers briefly installed the April 2026 tester build. Their old MessageLens-owned data is disposable. When current MessageLens positively recognizes that exact legacy generation during startup, ask permission to delete the old MessageLens data and then continue through normal current Onboarding.
>
> No migration.
>
> No preservation of old MessageLens state.
>
> No generalized destructive-data-management feature.
>
> No user-facing Complete Erase workflow for this rollout.
>
> ## Existing recognition contract
>
> Prompt 22 already provides a typed:
>
> `legacyTesterInstall`
>
> result only when the exact audited pre-source-scoped signature is positively proven:
>
> - legacy `macos_import.db` v4 with complete expected table fingerprint;
> - legacy `working.db` v3 with complete expected table fingerprint;
> - legacy `user_overlays.db` v3 with complete expected table fingerprint;
> - no `.messagelens-archive.json`;
> - no `macos_import_ss.db`;
> - no `working_ss.db`;
> - no `presence.db`;
> - canonical production identity/root;
> - no current-store admission before recognition.
>
> Keep that contract unchanged unless a small integration correction is mechanically required.
>
> ## Desired user journey
>
> On launch:
>
> `legacyTesterInstall proven`
> →
> one focused Onboarding-owned compatibility surface
> →
> human explicitly authorizes deletion
> →
> old MessageLens-owned production data folder is deleted
> →
> normal virgin initialization occurs
> →
> current `OnboardingJourneyCoordinator` takes ownership
> →
> ordinary six-node Journey begins:
>
> `Messages → History → Contacts → Ready → Import → Start`
>
> That is the complete feature.
>
> ## Presentation
>
> Use restrained copy suitable for exactly this situation.
>
> Recommended intent:
>
> **This is data from an older MessageLens test version**
>
> > This version of MessageLens needs to start with a clean setup. I can remove the old MessageLens data on this Mac and start again.
>
> Then make the safety boundary explicit:
>
> > Your Apple Messages and Contacts will not be changed.
>
> Actions:
>
> - **Cancel**
> - **Delete Old Data and Continue**
>
> Use final wording consistent with current MessageLens product voice.
>
> Do not expose:
>
> - schema versions;
> - database names;
> - archive terminology;
> - source-scoping;
> - “Complete Erase”;
> - migration language.
>
> ## Cancel behavior
>
> Cancel means:
>
> - delete nothing;
> - create nothing;
> - migrate nothing;
> - do not open current persistent stores;
> - remain in a safe blocked/exit state.
>
> A reasonable outcome is to leave the compatibility surface visible or allow quitting.
>
> Do not silently continue into current Onboarding over the legacy folder.
>
> ## Authorization
>
> Deletion must be impossible until:
>
> 1. Prompt 22 has positively proven `legacyTesterInstall`;
> 2. the human explicitly presses **Delete Old Data and Continue**.
>
> Do not broaden this operation so arbitrary unmarked roots can use it.
>
> ## Deletion scope
>
> After authorization, delete the canonical legacy MessageLens-owned production data root for that installation.
>
> This old tester state is intentionally disposable.
>
> It is acceptable and expected to remove everything inside that old MessageLens-owned folder, including:
>
> - legacy databases;
> - old overlays;
> - optional attachment archive if one exists;
> - derived media if present;
> - logs;
> - unknown legacy files;
> - old preferences/state stored within that root.
>
> The purpose is to leave no old MessageLens installation state requiring migration.
>
> ## Absolute external boundary
>
> Never modify or delete:
>
> - Apple `chat.db`;
> - Apple Messages attachments;
> - Contacts databases/files;
> - iCloud data;
> - Historical Archive source folders;
> - recovery donor folders;
> - arbitrary external paths.
>
> The operation may act only on the exact canonical legacy MessageLens production root already positively identified by startup admission.
>
> ## Do not reuse generalized semantics blindly
>
> Existing Prompt 16 Complete Erase machinery may contain useful low-level primitives.
>
> Reuse only if doing so makes this path smaller and clearer.
>
> Do not make this compatibility gate depend conceptually on the generalized Settings Complete Erase product feature.
>
> The authority should remain:
>
> `legacyTesterInstall proof`
> +
> explicit compatibility authorization
> →
> exact old-root deletion.
>
> ## Mutation authority
>
> Route deletion through existing canonical mutation authority if required by architecture.
>
> Use the narrowest exact capability possible.
>
> Do not grant normal store access to the legacy root merely to perform deletion.
>
> Do not migrate/open legacy DBs through current repositories first.
>
> ## UI handoff before deletion
>
> After the user confirms:
>
> - the compatibility surface should immediately own presentation;
> - show a brief truthful operation state if deletion/reinitialization is perceptible;
> - let at least one frame paint before destructive filesystem work if current architecture requires it.
>
> Do not recreate the old Start Fresh “button closes and nothing appears” failure.
>
> No fake progress or arbitrary dwell.
>
> ## Post-delete behavior
>
> After old data is removed:
>
> 1. establish the normal current production archive root through canonical virgin initialization;
> 2. install whatever current archive marker/identity virgin startup normally requires;
> 3. mechanically verify the installation is now `virgin`;
> 4. clear/reconcile startup compatibility state;
> 5. hand ownership to `OnboardingJourneyCoordinator`;
> 6. begin at the correct first Episode.
>
> Do not make the user quit/relaunch manually unless the existing production architecture makes in-process continuation impossible.
>
> Prefer direct continuation.
>
> ## Failure behavior
>
> If deletion fails:
>
> - do not claim a clean install;
> - do not enter ordinary Onboarding;
> - show a bounded typed failure;
> - provide Retry if mechanically safe;
> - provide Quit/Cancel as appropriate.
>
> Be truthful that MessageLens could not finish removing the old test setup.
>
> Do not attempt migration as fallback.
>
> ## Crash/interruption behavior
>
> Keep this proportional to the actual problem.
>
> We do not need a new generalized transaction system.
>
> But ensure a crash partway through deletion cannot make MessageLens classify a partially deleted old root as a valid current completed installation.
>
> On next launch it should converge to one of:
>
> - still positively recognizable legacy state;
> - virgin/current initialization;
> - existing fail-closed/remediation state.
>
> Never fake success.
>
> ## Generalized Complete Erase rollout
>
> For this tester rollout:
>
> - hide/remove the ordinary user-facing generalized **Erase MessageLens setup and start over…** entry if it remains exposed solely because of Prompt 16;
> - keep any useful internal implementation/history only if harmless;
> - do not require the three testers to discover a Settings action.
>
> Their path should be automatic:
>
> `launch old install`
> →
> `legacy detected`
> →
> `ask once`
> →
> `delete`
> →
> `Onboarding`.
>
> If removing/hiding the generalized Settings entry would create broad churn, report the smallest safe product-boundary change and keep the underlying code dormant.
>
> ## Tests — recognition integration
>
> Prove:
>
> 1. exact legacy signature presents the compatibility gate;
> 2. healthy current install does not;
> 3. Start Fresh virgin install does not;
> 4. damaged current install does not;
> 5. arbitrary unmarked root does not.
>
> ## Tests — authorization
>
> Prove:
>
> 6. Cancel performs zero mutation;
> 7. deletion cannot begin without exact `legacyTesterInstall`;
> 8. deletion cannot begin without explicit human confirmation;
> 9. stale UI/action occurrence cannot delete after startup state changes.
>
> ## Tests — deletion
>
> Build a small isolated fixture representing the exact legacy signature.
>
> Prove authorization removes:
>
> 10. `macos_import.db`;
> 11. `working.db`;
> 12. `user_overlays.db`;
> 13. optional `attachment_archive/`;
> 14. optional `derived_media/`;
> 15. legacy logs/unknown files inside the owned root.
>
> Prove it does NOT touch representative external source fixtures.
>
> ## Tests — continuation
>
> Prove:
>
> 16. successful delete produces/verifies canonical `virgin`;
> 17. current archive identity/marker is established through normal initialization;
> 18. Journey Coordinator assumes ownership;
> 19. first current Onboarding Episode is correct;
> 20. no old DB migration occurs;
> 21. no current store opens before legacy deletion/virgin handoff.
>
> ## Tests — failure
>
> Prove:
>
> 22. filesystem deletion failure remains visible and typed;
> 23. failure never enters ordinary Onboarding;
> 24. retry cannot target anything except the originally admitted legacy root;
> 25. partial deletion cannot produce false completed state.
>
> ## Architecture tripwires
>
> Protect:
>
> - only positive `legacyTesterInstall` proof can expose this destructive path;
> - human authorization mandatory;
> - no `unmarked == deletable` shortcut;
> - no migration before deletion;
> - no current-store admission before deletion;
> - exact canonical root only;
> - external Apple/source data never in deletion target set;
> - ordinary Start Fresh semantics unchanged;
> - current Onboarding Journey remains sole post-delete authority.
>
> ## Manual Development validation
>
> Prompt 22 reported that ordinary Development GUI reproduction of the *production-identity recognition* is intentionally unavailable.
>
> Do not reintroduce arbitrary-root gymnastics merely to make the manual test look identical.
>
> Instead provide the simplest safe validation supported by current architecture:
>
> - automated exact legacy fixture for recognition/deletion;
> - then one bounded production-shaped/manual rehearsal only if it can be done without risking real production data.
>
> If a faithful manual production-identity rehearsal requires elaborate root overrides/clones again, STOP and rely on the exact fixture tests plus read-only production-root recognition evidence.
>
> Do not recreate the rabbit hole.
>
> ## Documentation
>
> Create:
>
> `21-LEGACY-TESTER-DATA-DELETION-AUTHORIZATION-AND-ONBOARDING-HANDOFF-IMPLEMENTATION.md`
>
> Document:
>
> - narrow problem statement;
> - exact recognized cohort;
> - final dialog copy;
> - authorization contract;
> - deletion scope;
> - external safety boundary;
> - mutation authority;
> - post-delete virgin verification;
> - Onboarding handoff;
> - generalized Complete Erase rollout decision;
> - failure behavior;
> - tests;
> - tester rollout instructions.
>
> Update Feature 28 index/documentation log.
>
> Update version/changelog according to repository rules.
>
> ## Verification
>
> Run:
>
> - legacy inspector tests;
> - compatibility-gate presentation tests;
> - authorization/deletion tests;
> - archive admission/mutation tests;
> - installation classifier;
> - Onboarding Journey;
> - Start Fresh regressions;
> - Complete Erase regressions if shared primitives remain;
> - architecture tripwires;
> - full Flutter suite;
> - `flutter analyze`;
> - formatting;
> - `git diff --check`;
> - macOS debug build.
>
> Commit and push if clean.
>
> ## Stop conditions
>
> STOP if:
>
> - deleting the admitted production MessageLens root cannot be bounded without broad destructive authority;
> - this requires migrating old stores before deletion;
> - exact legacy proof can be bypassed;
> - current/healthy installations can reach the destructive gate;
> - external source paths can overlap the deletion target;
> - in-process virgin handoff requires major relaunch redesign;
> - generalized Complete Erase must be expanded rather than reduced.
>
> Do not solve those by adding architecture.
>
> ## Final tester rollout
>
> The intended instruction to the three testers should be approximately:
>
> 1. install the new MessageLens build;
> 2. launch it;
> 3. MessageLens recognizes data from the older test version;
> 4. choose **Delete Old Data and Continue**;
> 5. proceed through normal Onboarding.
>
> No Finder navigation.
>
> No Terminal.
>
> No database upgrade.
>
> No Settings reset procedure.
>
> ## Final report
>
> Return:
>
> - exact user-visible copy;
> - exact deletion authority/scope;
> - proof Cancel is non-mutating;
> - proof external source data is unreachable by deletion;
> - post-delete virgin classification result;
> - Onboarding handoff behavior;
> - generalized Complete Erase rollout decision;
> - tests/verification;
> - documentation record;
> - commit hash;
> - branch/worktree status;
> - exact instructions for the three testers.
>
> Acceptance standard:
>
> > A tester with the positively recognized April-era MessageLens data folder sees one understandable question, authorizes throwing that obsolete MessageLens data away, and immediately enters the same current Onboarding Journey as a brand-new user. Nothing else is migrated, generalized, or made more complicated than that.