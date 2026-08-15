import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/spec_classes/handles_cassette_spec.dart';

part 'stray_handle_mode_provider.g.dart';

/// Provides and controls active versus dismissed source review.
///
/// This is a global state provider that the mode switcher cassette writes to
/// and the stray handles list cassette reads from. Keeping them separate allows
/// the mode switcher to have child cassettes for additional filtering/sorting.
@Riverpod(keepAlive: true)
class StrayHandleReviewModeSetting extends _$StrayHandleReviewModeSetting {
  @override
  StrayHandleReviewMode build() => StrayHandleReviewMode.active;

  /// Switch to a new mode.
  void setMode(StrayHandleReviewMode mode) {
    state = mode;
  }

  /// Cycle to the next mode (for keyboard shortcuts).
  void cycleMode() {
    state = switch (state) {
      StrayHandleReviewMode.active => StrayHandleReviewMode.dismissed,
      StrayHandleReviewMode.dismissed => StrayHandleReviewMode.active,
    };
  }
}
