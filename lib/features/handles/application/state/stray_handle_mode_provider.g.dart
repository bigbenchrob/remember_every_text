// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stray_handle_mode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$strayHandleReviewModeSettingHash() =>
    r'0f59a16cdd5b044aaec3a0123b9879ce361bed9e';

/// Provides and controls active versus dismissed source review.
///
/// This is a global state provider that the mode switcher cassette writes to
/// and the stray handles list cassette reads from. Keeping them separate allows
/// the mode switcher to have child cassettes for additional filtering/sorting.
///
/// Copied from [StrayHandleReviewModeSetting].
@ProviderFor(StrayHandleReviewModeSetting)
final strayHandleReviewModeSettingProvider =
    NotifierProvider<
      StrayHandleReviewModeSetting,
      StrayHandleReviewMode
    >.internal(
      StrayHandleReviewModeSetting.new,
      name: r'strayHandleReviewModeSettingProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$strayHandleReviewModeSettingHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$StrayHandleReviewModeSetting = Notifier<StrayHandleReviewMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
