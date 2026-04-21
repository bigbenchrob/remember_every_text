part of '../cassette_spec.dart';

// TOPOLOGY RULE:
// Determine ONLY the immediate next child of this spec.
// May consult flow state, but must not plan or assemble a chain.
// See cassette_child_resolver.dart for full contract.

CassetteSpec? resolveHandlesInfoChild(HandlesInfoCassetteSpec spec) {
  return spec.when(
    infoCard: (key, childVariant) {
      // After the info card, show the mode switcher which cascades to the list.
      return switch (childVariant) {
        HandlesCassetteChildVariant.strayPhoneNumbers =>
          const CassetteSpec.handles(
            HandlesCassetteSpec.strayHandlesModeSwitcher(
              filter: StrayHandleFilter.phones,
            ),
          ),
        HandlesCassetteChildVariant.strayEmails => const CassetteSpec.handles(
          HandlesCassetteSpec.strayHandlesModeSwitcher(
            filter: StrayHandleFilter.emails,
          ),
        ),
      };
    },
  );
}

extension HandlesInfoCassetteSpecX on HandlesInfoCassetteSpec {
  CassetteSpec? childSpec() {
    return resolveHandlesInfoChild(this);
  }
}
