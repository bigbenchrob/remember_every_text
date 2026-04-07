// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heatmap_resolver.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$heatmapResolverHash() => r'ae1a43c869d93d6afd1fa9a57d427663a64ee000';

/// Resolves a messages heatmap cassette.
///
/// This resolver returns an inert payload for the calendar heatmap cassette.
///
/// ## Contract (from 00-cross-surface-spec-system.md)
///
/// - Receives explicit parameters (not specs)
/// - Returns `Future<SidebarCassettePayload>`
/// - Owns all decision-making for this cassette
/// - Does NOT construct widgets itself
///
/// Copied from [HeatmapResolver].
@ProviderFor(HeatmapResolver)
final heatmapResolverProvider =
    AutoDisposeNotifierProvider<HeatmapResolver, void>.internal(
      HeatmapResolver.new,
      name: r'heatmapResolverProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$heatmapResolverHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HeatmapResolver = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
