## 06. Flutter & Dart Agent Rules

This document defines the extended Flutter/Dart best practices and interaction rules for AI agents working on this repository. It augments `00-code-standards.md` (authoritative for style) and MUST NOT contradict Riverpod/provider patterns in `05-riverpod-provider-patterns.md`.

### Scope

Use these rules when writing or refactoring UI, theming, routing, state management (within project‑approved patterns), testing, accessibility, and code generation tasks.

### Interaction & Guidance

- Assume user understands general programming but may be new to Dart specifics.
- Explain Dart concepts when surfaced (null safety, Futures, Streams, records, pattern matching) only when they materially affect the suggested change.
- If feature ambiguity exists: clarify expected platform (macOS desktop focus here), data flow, or persistence.
- When suggesting a new dependency: justify benefit & stability; prefer zero new deps unless clearly valuable.

### Core Principles (Complement, Do NOT Override 00 & 05)

- Immutable value types (Freezed) with abstract classes & correct private ctor ordering.
- Composition over inheritance for widgets; prefer small private widget classes over large build methods.
- Separate ephemeral UI state vs persistent/domain state; persistent logic stays in domain/application layers.
- Keep aggregates & value objects free of UI concerns.
- Navigation strictly via existing ViewSpec system (see `03-navigation-overview.md`).

### Code Quality & Structure

- Maintain line length <= 80 unless readability suffers.
- Prefer explicit, intention‑revealing names; avoid abbreviations.
- Keep functions focused (< ~20 LOC excluding trivial glue).
- No silent failures: surface errors via Either/Failure patterns (DDD) or explicit exceptions at boundaries.
- Logging: use existing logging utilities (logger) rather than print; only fall back to print in tests/debug prototypes.

### Asynchrony & Null Safety

- Always return `Future<void>` for async side‑effect methods (never bare void).
- Avoid `!` unless preceding non-null checks or enforced invariants.
- Use `unawaited()` (once introduced with proper lint allowance) intentionally; otherwise await.

### Records & Pattern Matching

- Use records for lightweight multi‑value returns where introducing a dedicated value object would add noise.
- Apply pattern matching (switch expressions / destructuring) only when it reduces branching noise.

### State Management

Project uses Riverpod (hooks_riverpod) ONLY per `05-riverpod-provider-patterns.md`:

- No manual `StateNotifierProvider` declarations; rely on `@riverpod`.
- No alternative state libs (provider, bloc, etc.).
- For tiny local widget-only state: prefer Hook + useState / ValueNotifier inside the widget.

### Routing & Navigation

- Never push routes imperatively; always declare navigation through ViewSpec sealed classes.
- Any new navigation variant requires: spec sealed class update + panel wiring.

### Theming & UI

- Centralize theme adjustments; avoid in‑line style duplication.
- Prefer const constructors & const subtrees where possible.
- Optimize rebuilds: lift state up / use selectors only when measurement shows cost.

### Performance

- Defer expensive synchronous parsing to isolates (Rust FFI or compute) if profiling shows frame jank.
- Avoid unnecessary list reallocation; leverage `const []` and spreads.
- Profile before micro‑optimizing.

### JSON & Serialization

- Use `json_serializable` + converters (see value object converters) for complex ID/value types.
- Never manually write fragile Map parsing unless performance-critical & profiled.

### Code Generation & Tooling

- After modifying annotated sources: `dart run build_runner build --delete-conflicting-outputs`.
- Keep generated files out of manual edits; regenerate instead of patching.

### Testing

- Follow Arrange / Act / Assert.
- Test domain invariants (e.g., participant uniqueness in Chat) with focused unit tests.
- Add regression tests for any bug fix affecting logic flow.

### Accessibility (A11Y)

- Maintain semantic labels on interactive controls; propagate focus states.
- Ensure color contrast; prefer theme tokens over raw hex values.

### Documentation & Comments

- Doc comments only where they add semantic or domain clarity beyond obvious naming.
- Use first sentence period summary style; avoid redundant restatement of type names.

### When to Ask vs Act

- Ask if: aggregate boundary changes, new dependency introduction, cross‑feature data coupling, or navigation system extension.
- Act directly on: lint fixes, converter additions, Freezed corrections, provider generation, test tripwire enhancements.

### Anti‑Patterns (Reject PR / Revise Immediately)

- Using `flutter_riverpod` import.
- Direct DB instantiation (bypassing database providers).
- Freezed class without `abstract` or with private ctor before primary factory.
- Adding new state management libraries.
- Inlining platform paths (must resolve via documented providers/resolution services).

### Quick Checklist Before Commit

1. All Freezed models follow project constructor ordering.
2. No `withOpacity` usage (use `withValues(alpha:)`).
3. Providers use `@riverpod` & generated base classes.
4. No manual DB connections; all via feature-level providers.
5. Navigation changes reflect ViewSpec pattern.
6. Codegen re-run; analyzer clean.
7. Added/updated tests for logic changes.

---

If any guidance here appears to conflict with earlier-numbered documents, earlier docs win. Propose adjustments via PR if alignment is needed.
