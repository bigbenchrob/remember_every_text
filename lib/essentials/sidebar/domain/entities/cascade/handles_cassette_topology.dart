part of '../cassette_spec.dart';

// TOPOLOGY RULE:
// Determine ONLY the immediate next child of this spec.
// May consult flow state, but must not plan or assemble a chain.
// See cassette_child_resolver.dart for full contract.

CassetteSpec? resolveHandlesChild(HandlesCassetteSpec spec) {
  return spec.when(
    strayHandlesReview: (_, __) => null,
    strayHandlesModeSwitcher: (investigation, filter) => CassetteSpec.handles(
      HandlesCassetteSpec.strayHandlesReview(
        investigation: investigation,
        filter: filter,
      ),
    ),
    strayHandlesTypeSwitcher: (selectedFilter) => CassetteSpec.handles(
      HandlesCassetteSpec.strayHandlesModeSwitcher(
        investigation: StrayHandleInvestigation.identifySources,
        filter: selectedFilter,
      ),
    ),
    strayHandlesInvestigationSwitcher: (selectedInvestigation) {
      return switch (selectedInvestigation) {
        StrayHandleInvestigation.identifySources => const CassetteSpec.handles(
          HandlesCassetteSpec.strayHandlesTypeSwitcher(),
        ),
        StrayHandleInvestigation.numericSenderIds => const CassetteSpec.handles(
          HandlesCassetteSpec.strayHandlesModeSwitcher(
            investigation: StrayHandleInvestigation.numericSenderIds,
          ),
        ),
      };
    },
  );
}

extension HandlesCassetteSpecX on HandlesCassetteSpec {
  /// Resolve child spec for handles cassettes.
  CassetteSpec? childSpec() {
    return resolveHandlesChild(this);
  }
}
