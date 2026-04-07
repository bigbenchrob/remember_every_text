# Temporary Exceptions

This file is the single tracking point for any temporary migration exception
introduced during the authorship refactor.

Rules:

- A temporary exception must be explicit, narrow, and phase-scoped.
- A temporary exception must not become an alternate semantic writer.
- A temporary exception must not retain hidden UI state or executable behavior.
- If removing the exception changes user-visible behavior, the exception was
  carrying meaning and is invalid.
- Untracked exceptions are not allowed.

## Current Status

### Exception: Legacy widget-carrying sidebar payloads

- Location: `lib/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart`
- Reason: standard/info/navigation cassette payloads still carry widget fields while Phase 1 removes transported UI subtrees incrementally.
- Scope: `SidebarCassetteCardViewModel`, `SidebarInfoCassetteViewModel`, and `SidebarNavigationCassetteViewModel` remain available through the temporary `LegacyWidgetSidebarCassettePayload` branch.
- Removal phase: Phase 1 - Eliminate Widget Transport
- Why it is not a semantic writer: feature and app-level coordinators still route through `SidebarCassettePayload`; these legacy payloads do not author sidebar flow or panel meaning.
- Why it does not retain hidden state: the exception only preserves existing render-edge inputs already consumed synchronously by the sidebar host; it does not add new callback transport, coordinator state, or alternate persistence.
- What test/assertion/check will fail if it survives too long: Phase 1 completion requires sidebar payload transport to contain no `Widget` or builder transport, and runtime `featureComplex` usage must reach zero.

### Exception: Legacy sidebar semantic-layer presentation imports

- Location: `lib/features/**/application/{sidebar_cassette_spec,settings_cassette_spec,info_cassette_spec}/{resolvers,resolver_tools}/*.dart`
- Reason: several sidebar resolvers still construct legacy widget-carrying payloads or pull presentation/view-model helpers directly while the Phase 1 transport cleanup is incomplete.
- Scope: the exact current offender set is frozen by `test/architecture/forbidden_imports_test.dart`; new presentation or widget-builder imports in sidebar semantic/application files are not allowed.
- Removal phase: Phase 1 - Eliminate Widget Transport
- Why it is not a semantic writer: these files still route through the same cassette coordinator and payload boundary; the exception preserves existing render dependencies but does not create a second source of sidebar or panel meaning.
- Why it does not retain hidden state: the imports are structural dependencies only; hidden state risk remains confined to the already-tracked legacy widget payload pathway and will surface if the offender set grows.
- What test/assertion/check will fail if it survives too long: the architecture tripwire in `test/architecture/forbidden_imports_test.dart` will fail if the exception set grows, and the Phase 1 gate requires removing widget transport and builder-based behavior from sidebar payload flow.

## Required Entry Format

When an exception is introduced, add one entry using this structure:

### Exception: <short conspicuous name>

- Location:
- Reason:
- Scope:
- Removal phase:
- Why it is not a semantic writer:
- Why it does not retain hidden state:
- What test/assertion/check will fail if it survives too long:
