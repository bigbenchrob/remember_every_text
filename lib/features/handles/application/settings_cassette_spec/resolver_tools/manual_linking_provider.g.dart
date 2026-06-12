// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manual_linking_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unlinkedHandlesHash() => r'972f0d2c19b616c28fd15c3323eb5e8c698c537a';

/// Provider that finds handles not linked to any participant.
///
/// A handle is considered linked if it has a graph contact link OR an overlay
/// manual link (participant or virtual participant). Overlay visibility
/// overrides (blacklisted) are also applied by the read repository.
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
    r'48f85f661ada58447cc10e10c51a758c2dace953';

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
String _$manualLinkingHash() => r'6d3394330c60bd83efceba89c3b68425a40e91c5';

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
