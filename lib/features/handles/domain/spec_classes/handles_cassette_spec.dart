import 'package:freezed_annotation/freezed_annotation.dart';

part 'handles_cassette_spec.freezed.dart';

enum StrayHandleInvestigation { identifySources, numericSenderIds }

/// Filter for the unknown-source identification investigation.
enum StrayHandleFilter {
  /// Phone numbers (no '@', no 'urn:' prefix)
  phones,

  /// Email addresses (contains '@')
  emails,

  /// Business URNs (starts with 'urn:' - Apple Business Chat, etc.)
  businessUrns,
}

/// Visibility mode within an unknown-source investigation.
enum StrayHandleReviewMode {
  /// Show sources that remain in active review.
  active,

  /// Show dismissed handles (for "undo" / escape hatch access).
  dismissed,
}

/// Specification for the handles-related cassette types.
///
/// This file resides in the `features` folder to align with the directory
/// structure described in the essentials/sidebar domain. It mirrors the
/// existing `contacts_cassette_spec.dart` at the root but places it where
/// `cassette_spec.dart` expects to find it. The generated `.freezed.dart`
/// will live alongside this file after running build_runner.
///
/// INFO CARDS: Handles info cards are now defined in `handles_info_cassette_spec.dart`
/// following the cross-surface spec pattern. Use `HandlesInfoCassetteSpec.infoCard()`
/// instead of inline message strings.
@freezed
abstract class HandlesCassetteSpec with _$HandlesCassetteSpec {
  /// Source rows compatible with one investigation and optional endpoint filter.
  const factory HandlesCassetteSpec.strayHandlesReview({
    required StrayHandleInvestigation investigation,
    StrayHandleFilter? filter,
  }) = _HandlesStrayReviewSpec;

  /// Active/dismissed maintenance control within one investigation.
  const factory HandlesCassetteSpec.strayHandlesModeSwitcher({
    required StrayHandleInvestigation investigation,
    StrayHandleFilter? filter,
  }) = _HandlesModeSwitcherSpec;

  /// Type switcher for selecting Phone # / Email / Business URN.
  ///
  /// This sits between the menu selection and the mode switcher,
  /// allowing the user to choose which handle type to review.
  const factory HandlesCassetteSpec.strayHandlesTypeSwitcher({
    @Default(StrayHandleFilter.phones) StrayHandleFilter selectedFilter,
  }) = _HandlesTypeSwitcherSpec;

  /// Primary investigation choice. Endpoint filtering follows only when the
  /// source-identification investigation is selected.
  const factory HandlesCassetteSpec.strayHandlesInvestigationSwitcher({
    @Default(StrayHandleInvestigation.identifySources)
    StrayHandleInvestigation selectedInvestigation,
  }) = _HandlesInvestigationSwitcherSpec;
}
