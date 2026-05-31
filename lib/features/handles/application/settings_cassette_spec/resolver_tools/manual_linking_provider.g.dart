// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manual_linking_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unlinkedHandlesHash() => r'8a2654e50a4ac6adfa7be858069c170827c25baf';

/// Provider that finds handles not linked to any participant.
///
/// A handle is considered linked if it has a graph contact link OR an overlay
/// manual link (participant or virtual participant). Overlay visibility
/// overrides (blacklisted) are also applied here.
///
/// Copied from [unlinkedHandles].
@ProviderFor(unlinkedHandles)
final unlinkedHandlesProvider =
    AutoDisposeFutureProvider<List<UnlinkedHandle>>.internal(
      unlinkedHandles,
      name: r'unlinkedHandlesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$unlinkedHandlesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnlinkedHandlesRef = AutoDisposeFutureProviderRef<List<UnlinkedHandle>>;
String _$availableParticipantsHash() =>
    r'b9ae3573ab8ff62fa04e37fd0bb1f5526da7457f';

/// Provider that gets all available participants for linking.
///
/// Handle counts merge graph contact links with overlay manual links.
///
/// Copied from [availableParticipants].
@ProviderFor(availableParticipants)
final availableParticipantsProvider =
    AutoDisposeFutureProvider<List<AvailableParticipant>>.internal(
      availableParticipants,
      name: r'availableParticipantsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$availableParticipantsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AvailableParticipantsRef =
    AutoDisposeFutureProviderRef<List<AvailableParticipant>>;
String _$manualLinkingHash() => r'5abe04e00c0e4f63bfd5e250f4ce160165bc7d2c';

/// Provider for manual linking operations
///
/// Copied from [ManualLinking].
@ProviderFor(ManualLinking)
final manualLinkingProvider =
    AutoDisposeAsyncNotifierProvider<ManualLinking, void>.internal(
      ManualLinking.new,
      name: r'manualLinkingProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$manualLinkingHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ManualLinking = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
