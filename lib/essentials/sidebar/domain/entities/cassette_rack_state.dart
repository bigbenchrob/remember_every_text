// A value object representing the current stack of cassettes in the sidebar.
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../features/sidebar_utilities/domain/spec_classes/sidebar_utility_cassette_spec.dart';
import 'cassette_spec.dart';

part 'cassette_rack_state.freezed.dart';

///
/// It uses the `freezed` package to generate the immutable data class
/// implementation along with copyWith, equality, and debugging utilities.  A
/// convenience factory [CassetteRack.initialTopChatMenu] is provided to
/// generate the default top chat menu cassette.
@freezed
abstract class CassetteRack with _$CassetteRack {
  /// Creates a new [CassetteRack] with the given list of [cassettes].  The
  /// default value is an empty list.  The list is immutable, as the
  /// generated copyWith will always create new lists when updating.
  const factory CassetteRack({
    @Default(<CassetteSpec>[]) List<CassetteSpec> cassettes,
  }) = _CassetteRack;

  /// Private constructor used by the `freezed` mixin.  Required to be able
  /// to add custom methods to the class.
  const CassetteRack._();

  /// Returns a fresh [CassetteRack] containing a single top chat menu
  /// cassette.  This is the initial messages sidebar state used by
  /// [CassetteRackState.build].
  factory CassetteRack.initialTopChatMenu() {
    return CassetteRack(
      cassettes: List<CassetteSpec>.unmodifiable([
        const CassetteSpec.sidebarUtility(
          SidebarUtilityCassetteSpec.topChatMenu(),
        ),
      ]),
    );
  }
}
