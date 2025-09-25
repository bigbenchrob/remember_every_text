## PR Checklist

- [ ] I read `_AGENT_CONTEXT/AGENT_CONTEXT.md` and followed the required reading order
- [ ] I used `hooks_riverpod` imports only (no `flutter_riverpod`)
- [ ] I avoided `withOpacity()` and used `withValues(alpha:)` when needed
- [ ] Freezed classes are declared as `abstract class` and unnamed ctor is ordered after the primary factory
- [ ] All database access goes through `essentials/databases/feature_level_providers.dart`
- [ ] Navigation uses ViewSpec sealed classes only, no direct cross-feature calls
- [ ] I ran `dart run build_runner build --delete-conflicting-outputs`
- [ ] Analyzer is clean locally

## Summary

Explain what this PR changes and why.

## Architecture

Reference any ADRs or architecture rules that apply. If adding/changing aggregates or cross-boundary deps, include a new ADR in `docs/adr/`.
