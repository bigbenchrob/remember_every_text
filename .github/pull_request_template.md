## When To Use This Template

Use this pull request template for feature additions and other release-worthy changes that should land through a feature branch and PR.

Housekeeping, maintenance, and small bug fixes that do not merit a version bump may go directly to `main` and do not need a PR just to satisfy process.

## PR Checklist

- [ ] I read `_AGENT_CONTEXT/AGENT_CONTEXT.md` and followed the required reading order
- [ ] I used `hooks_riverpod` imports only (no `flutter_riverpod`)
- [ ] I avoided `withOpacity()` and used `withValues(alpha:)` when needed
- [ ] Freezed classes are declared as `abstract class` and unnamed ctor is ordered after the primary factory
- [ ] All database access goes through `essentials/databases/feature_level_providers.dart`
- [ ] Navigation uses ViewSpec sealed classes only, no direct cross-feature calls
- [ ] If this change is significant for users or testers, I updated both `pubspec.yaml` version and `CHANGELOG.md`
- [ ] I ran `dart run build_runner build --delete-conflicting-outputs`
- [ ] Analyzer is clean locally

## Merge Gate

- [ ] Before merging, this PR will be non-draft, checks will have run, and any release-worthy changes will include both `pubspec.yaml` and `CHANGELOG.md` updates

## Release Metadata

- [ ] This PR intentionally skips version/changelog updates because it is internal-only.

## Summary

Explain what this PR changes and why.

## Architecture

Reference any ADRs or architecture rules that apply. If adding/changing aggregates or cross-boundary deps, include a new ADR in `docs/adr/`.
