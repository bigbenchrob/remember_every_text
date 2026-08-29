---
tier: project
scope: onboarding
owner: agent-per-project
last_reviewed: 2026-08-29
source_of_truth: release-verification-record
---

# Tester Release Distribution Verification 0.2.99+117

## Release Decision

**READY FOR MANUAL PUBLICATION.**

The exact tester artifact is built, signed, notarized, stapled, independently
verified, and installed in a locally verified tester-portal worktree. Neither
the app nor the portal was published or sent to testers in this pass.

The tester portal is a separate private Git repository. No deployment workflow,
hosting target, or provider configuration is present in its worktree, and the
available environment could not authenticate a GitHub deployment-settings
query. Its deployment target therefore remains a human-controlled publication
boundary. The local portal commit must not be pushed until the established
hosting workflow is confirmed.

## Build Identity

| Property | Verified value |
| --- | --- |
| Product | `MessageLens` |
| Version | `0.2.99` |
| Build | `117` |
| Portal release label | `0.2.99+117` |
| Bundle identifier | `com.bigbenchsoftware.MessageLens` |
| Archive environment | `production` |
| Archive build identity | `productionRelease` |
| Canonical archive root | `~/Library/Application Support/com.bigbenchsoftware.MessageLens` |
| Signing team | `FQHT2QP3NE` |
| Signing identity | `Developer ID Application: Robert Campbell (FQHT2QP3NE)` |
| Architectures | `arm64`, `x86_64` |

`tool/verify_macos_archive_identity.sh` passed both before signing in
metadata-only mode and after signing in full production mode. The production
`Info.plist` contains no `MessageLensDevelopmentArchiveRoot`. Shared executable
code retains development-mode strings because the same implementation supports
separately identified development builds; production metadata and admission
remain mechanically fixed to the production contract.

## Signing And Notarization

The canonical command was:

```bash
./tool/build_and_notarize.sh --artifact-only
```

The release app was signed with hardened runtime and the repository's release
entitlements. Recursive strict signature verification passed. Gatekeeper
reported:

```text
accepted
source=Notarized Developer ID
```

Apple notarization:

- submission: `788b2c96-9f19-4de3-bb3b-07bc7e7905cd`;
- created: `2026-08-29T16:45:19.982Z`;
- status: `Accepted`;
- DMG staple: valid.

The signed entitlements match `macos/Runner/Release.entitlements`:

- app sandbox disabled;
- JIT allowed for Flutter;
- library validation disabled for embedded media/runtime components;
- network client and server enabled;
- Contacts access enabled.

## Artifact

Canonical release artifact:

```text
/Users/rob/Desktop/MessageLens-latest.dmg
```

Tester-portal copy:

```text
/Users/rob/Development/website/MessageLens/assets/downloads/MessageLens-latest.dmg
```

Both files have:

```text
SHA-256: 76888964d10f4ad0513d29d6ef410788e21c0815266262214f167a2c9ec682a7
Size: 47,771,962 bytes
```

The replaced April artifact had SHA-256:

```text
f679faf410dd8d691e51993716153f141beceea71063b44a43ad546c8dcfbb02
```

The hashes differ, and the portal copy is byte-identical to the newly verified
DMG.

## Tester Install Behavior

No release app was launched against the real production archive.

Static and automated evidence proves:

- a clean/virgin production archive enters the current six-node Onboarding
  Journey;
- the exact April-era 4/3/3 tester fingerprint alone exposes **Delete Old Data
  and Continue**;
- authorization deletes only that admitted obsolete MessageLens root, installs
  and verifies a new virgin identity, and relaunches into Onboarding;
- neighboring, unknown, current, damaged, and healthy completed installations
  cannot enter the legacy deletion path;
- a healthy current installation proceeds to ordinary application
  presentation.

The release-focused suite passed 66 tests after the release-metadata check was
added. All 385 architecture tripwires passed, and `flutter analyze` reported no
issues.

## Tester Portal

Prepared files:

- `assets/downloads/MessageLens-latest.dmg`;
- `assets/data/latest-build.json`;
- `assets/data/tester-changelog.json`;
- `src/pages/index.html`;
- generated `index.html`.

The release metadata and visible fallback identify `0.2.99+117`, built August
29, 2026. The tester changelog emphasizes rebuilt Onboarding, readable import
progress, exact April-install handling, and improved recovery. Older versions
remain only as intentional historical changelog entries; no current-build
surface advertises `0.1.16` or the April date.

`npm run build` passed. Local HTTP checks returned `200` for all generated
pages, both JSON feeds, and the DMG. JSON contracts passed, all generated
relative assets exist, and the download URL resolves to the verified artifact.

## Publishing Boundary

Known facts:

- source repository:
  `https://github.com/bigbenchrob/message-lens-site.git`;
- branch: `main`;
- repository worktree was clean before this release;
- no in-repository deployment configuration or automation is present;
- no publication occurred in this pass.

The external hosting provider, target project, and deployment trigger could not
be proven from local evidence. Pushing `main` may be a deployment trigger, so
the local portal commit `fa0749a` remains unpushed. The human release step is to
confirm the established hosting target and then publish that exact commit
through its normal workflow.

## Tester Instructions

1. Download and install the new MessageLens build.
2. Launch MessageLens.
3. If MessageLens recognizes old April test data, choose **Delete Old Data and
   Continue**.
4. Complete the guided Onboarding steps.
5. Report any blocker immediately.

No Finder data-folder navigation, Terminal command, or manual database deletion
is required.

## Verification Commands

The pass included:

- canonical release build/sign/notarize pipeline;
- read-only DMG mounting;
- `codesign --verify --deep --strict --verbose=2`;
- `codesign -dvvv` and signed-entitlement inspection;
- `spctl --assess --type execute --verbose=4`;
- `xcrun stapler validate`;
- `xcrun notarytool info`;
- `tool/verify_macos_archive_identity.sh --environment production`;
- architecture and release-focused Flutter tests;
- `flutter analyze`;
- tester-portal build, HTTP endpoint checks, JSON checks, relative-asset checks,
  stale-current-version search, hash comparison, and `git diff --check`.
