---
tier: project
scope: release-record
owner: onboarding
last_reviewed: 2026-09-06
source_of_truth: record
links:
  - ../34-WHOLE-ROOT-REPLACEMENT-AND-COMPLETE-ERASE-REMOVAL-IMPLEMENTATION.md
  - ../../../60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md
tests:
  - test/architecture
  - test/architecture/virgin_onboarding_boundary_test.dart
  - test/architecture/whole_root_replacement_absence_test.dart
---

# Tester Release After Archive-Regime Removal

## Result

**READY.** MessageLens `0.2.104+122` was built from commit
`a0d5bfd2a43ab606be9c7f94c751b0c016d6a498`, signed, notarized, published to
the established Render tester portal, and verified from the public download.

## Release Identity

- Source branch: `Ftr.archive-recovery`
- Source commit: `a0d5bfd2a43ab606be9c7f94c751b0c016d6a498`
- Version: `0.2.104`
- Build: `122`
- Bundle identifier: `com.bigbenchsoftware.MessageLens`
- Team identifier: `FQHT2QP3NE`
- Signing identity: `Developer ID Application: Robert Campbell (FQHT2QP3NE)`
- Architectures: `x86_64 arm64`
- Hardened runtime: present
- Local DMG: `/Users/rob/Desktop/MessageLens-latest.dmg`
- SHA-256: `85b23bc123a24a76056f90455cf284a0433b34af994143ff122bbbaa814488d9`

Apple notarization accepted submission
`ba869168-885d-42eb-9dbc-f29d15eaea6d`. Stapler validation succeeded and
Gatekeeper accepted the application as `Notarized Developer ID`.

The production archive-identity verifier confirmed the canonical production
root contract:

```text
~/Library/Application Support/com.bigbenchsoftware.MessageLens
```

No development-root override or development identity was used.

## Regression Evidence

- Focused startup, Virgin import, Onboarding, Start Fresh, marker, stale-journal,
  attachment-preservation, and migration boundary: **113 passed**.
- Architecture suite, including no-whole-root-replacement and no Virgin
  reset/checkpoint call edge: **431 passed**.
- Complete Flutter suite: **2,142 passed**.
- `flutter analyze`: **no issues found**.
- Website build: **passed**.
- Application and website `git diff --check`: **passed**.

The verified behavior boundary is:

- No MessageLens state, including after an April tester manually removes the
  obsolete folder: ordinary Virgin initialization, Onboarding, Import, Start.
- Current marker and stores: ordinary current-installation startup.
- No active tester fingerprint, legacy application-version admission, Complete
  Erase, or whole-root replacement path participates.
- The temporary stale Complete-Erase journal reader remains fail-closed and may
  remove only its one proven obsolete journal file.

## Tester Portal

Website repository commit:
`cc58a8b` (`publish MessageLens 0.2.104 tester build`).

The commit was pushed to `main`, the established Render publishing branch.
Render deployed it successfully.

- Public site: <https://message-lens-site.onrender.com/>
- Public DMG:
  <https://message-lens-site.onrender.com/assets/downloads/MessageLens-latest.dmg>

The public DMG was downloaded after deployment. Its SHA-256 matched the local
artifact exactly, and `cmp` confirmed byte identity. Live metadata showed
`0.2.104+122` and `September 6, 2026`. The live portal contained no stale
`Delete Old Data and Continue`, `Complete Erase`, or automatic legacy-deletion
instruction.

Website files changed:

- `assets/downloads/MessageLens-latest.dmg`
- `assets/data/latest-build.json`
- `assets/data/tester-changelog.json`
- `src/pages/index.html`
- generated `index.html`

## Instructions For Remaining April Testers

1. Quit MessageLens if it is running.
2. In Finder choose **Go -> Go to Folder...**
3. Enter `~/Library/Application Support/`.
4. Move `com.bigbenchsoftware.MessageLens` to the Trash.
5. Install the new MessageLens build.
6. Launch MessageLens and complete Onboarding.
7. If anything blocks progress, stop and send a screenshot rather than trying
   to repair it manually.

## Instructions For New Testers

1. Install MessageLens.
2. Launch it.
3. Complete Onboarding.

Nothing else is required.
