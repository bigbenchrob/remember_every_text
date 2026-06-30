part of '../cassette_spec.dart';

// TOPOLOGY RULE:
// Determine ONLY the immediate next child of this spec.
// May consult flow state, but must not plan or assemble a chain.
// See cassette_child_resolver.dart for full contract.

CassetteSpec? resolveHandlesChild(HandlesCassetteSpec spec) {
  return spec.when(
    strayHandlesReview: (_, __) => null,
    // Mode switcher cascades to the stray handles review list
    strayHandlesModeSwitcher: (filter) => CassetteSpec.handles(
      HandlesCassetteSpec.strayHandlesReview(filter: filter),
    ),
    // Type switcher cascades to the mode switcher with selected filter
    strayHandlesTypeSwitcher: (selectedFilter) => CassetteSpec.handles(
      HandlesCassetteSpec.strayHandlesModeSwitcher(filter: selectedFilter),
    ),
  );
}

extension HandlesCassetteSpecX on HandlesCassetteSpec {
  /// Resolve child spec for handles cassettes.
  CassetteSpec? childSpec() {
    return resolveHandlesChild(this);
  }
}
