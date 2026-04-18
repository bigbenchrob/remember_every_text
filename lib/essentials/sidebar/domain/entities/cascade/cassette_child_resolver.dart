part of '../cassette_spec.dart';

// ============================================================================
// TOPOLOGY CONTRACT — READ BEFORE MODIFYING
//
// This file defines cassette-spec topology. It is the ONLY place where the
// sidebar cassette chain is derived.
//
// CORE RULE:
//
// Topology must operate as a sequence of local, single-step decisions.
//
// For any given cassette spec:
//   - determine ONLY the immediate next child
//   - based ONLY on:
//       (a) the current spec
//       (b) the minimal required durable flow state
//
// The topology rule answers exactly one question:
//
//   "What is the next child of this spec?"
//
// NOTHING MORE.
//
// ----------------------------------------------------------------------------
// ALLOWED:
//
//   final scope = ref.read(sidebarFlowProvider).messageScope;
//
//   switch (scope) {
//     case MessageScope.regular:
//       return CassetteSpec.handleFilter(...);
//     case MessageScope.recoveredDeleted:
//       return CassetteSpec.messagesInfo(...);
//   }
//
// ----------------------------------------------------------------------------
// STRICTLY FORBIDDEN:
//
// ❌ Branch planning
//     - deciding multiple future steps
//     - reasoning about "the whole branch"
//
// ❌ Chain assembly
//     - building lists of specs
//     - setRack([...])
//     - constructing partial or full chains
//
// ❌ Conditional omission
//     - "omit heatmap"
//     - "stop before X"
//     - "append Y only if condition"
//
// ❌ Lookahead / lookbehind
//     - inspecting previous or future specs
//     - deriving meaning from other specs
//
// ❌ Flow-layer topology
//     - ANY chain construction outside topology (e.g. sidebar_flow_state_provider)
//
// ----------------------------------------------------------------------------
// CORRECT MODEL:
//
//   next = f(currentSpec, durableFlowState)
//
//   repeat until next == null
//
// ----------------------------------------------------------------------------
// KEY PRINCIPLE:
//
// There is exactly ONE valid cassette-spec chain for any given durable flow state.
// That chain must emerge solely from repeated application of local topology rules.
//
// If you find yourself writing code that:
//   - builds a list
//   - skips a node
//   - truncates a branch
//   - or decides more than one step
//
// you are violating the architecture.
//
// STOP and fix the topology instead.
//
// ============================================================================

/// Resolve the child cassette spec for the given cassette spec, if any.
///
/// This function delegates to each inner spec's `childSpec()` extension method.
/// All inner spec families define their own `childSpec()` in their topology file.
///
/// Pattern (Option A):
/// - Each inner spec type has an extension with `childSpec()`.
/// - This outer resolver simply calls `inner.childSpec()` for each variant.
/// - The `resolveXChild(innerSpec)` functions remain as implementation details
///   called only from within the inner extensions.
CassetteSpec? resolveCassetteChild(CassetteSpec spec) {
  return spec.when(
    sidebarUtility: (inner) => inner.childSpec(),
    contacts: (inner) => inner.childSpec(),
    contactsInfo: (inner) => inner.childSpec(),
    handles: (inner) => inner.childSpec(),
    handlesInfo: (inner) => inner.childSpec(),
    messages: (inner) => inner.childSpec(),
    messagesInfo: (inner) => inner.childSpec(),
    settings: (inner) => inner.childSpec(),
  );
}
