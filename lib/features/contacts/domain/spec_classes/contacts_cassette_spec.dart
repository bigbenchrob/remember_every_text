import 'package:freezed_annotation/freezed_annotation.dart';

part 'contacts_cassette_spec.freezed.dart';

/// Specification for the contacts-related cassette types.
///
/// The generated `.freezed.dart` lives alongside this file after running
/// build_runner.
@freezed
abstract class ContactsCassetteSpec with _$ContactsCassetteSpec {
  /// A contact chooser that adapts its UI based on contact count.
  /// The contacts feature decides whether to show a flat list or grouped
  /// picker based on the number of contacts.
  const factory ContactsCassetteSpec.contactChooser({int? chosenContactId}) =
      _ContactChooserSpec;

  /// A compact "Change contact" control that appears after selection.
  ///
  /// This cassette displays the selected contact name and provides a
  /// "Change" affordance to return to the picker. It sits directly beneath
  /// the top menu selector and above the Hero Card so it reads as part of
  /// the primary contact-selection cluster.
  ///
  /// ## Visual Role
  /// - Visually lightweight (compact height ~44px)
  /// - Navigation/selection context only
  /// - Triggers re-entry into picker mode on tap
  ///
  /// ## Cascade
  /// This spec cascades to [contactHeroSummary] which provides identity context.
  const factory ContactsCassetteSpec.contactSelectionControl({
    required int chosenContactId,
  }) = _ContactSelectionControlSpec;

  /// A detailed summary view for a selected contact.
  const factory ContactsCassetteSpec.contactHeroSummary({
    required int chosenContactId,
  }) = _ContactHeroSummarySpec;

  /// Toggle between the regular chat-related view and recovered deleted
  /// messages for the selected contact.
  const factory ContactsCassetteSpec.messageScopeToggle({
    required int contactId,
  }) = _MessageScopeToggleSpec;

  /// Dropdown to filter messages by a specific handle (phone/email) linked
  /// to this contact. Defaults to showing all handles.
  ///
  /// When [selectedHandleId] is non-null, the center panel shows only
  /// messages from that handle, and an "Unlink" action becomes available.
  const factory ContactsCassetteSpec.handleFilter({
    required int contactId,
    int? selectedHandleId,
  }) = _HandleFilterSpec;
}
