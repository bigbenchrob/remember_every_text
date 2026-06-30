// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manual_handle_link_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$manualHandleLinkServiceHash() =>
    r'c5c9a93f38b6d55e94cd5e52dbd4585fc5db143a';

/// Action boundary for managing manual handle-to-contact links.
///
/// All writes target the manual-link store, whose production implementation is
/// overlay-only. The graph database is never modified here; providers merge
/// graph facts with overlay intent at read time with overlay winning on conflict.
///
/// Copied from [ManualHandleLinkService].
@ProviderFor(ManualHandleLinkService)
final manualHandleLinkServiceProvider =
    AutoDisposeNotifierProvider<ManualHandleLinkService, void>.internal(
      ManualHandleLinkService.new,
      name: r'manualHandleLinkServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$manualHandleLinkServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ManualHandleLinkService = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
