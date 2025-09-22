// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_level_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chosenChatIdHash() => r'82ff4ccaaf049a18cb22fffa8b33df193d69e2ae';

/// Holds the currently selected chat ID across the app. -1 means none.
///
/// Copied from [ChosenChatId].
@ProviderFor(ChosenChatId)
final chosenChatIdProvider =
    AutoDisposeNotifierProvider<ChosenChatId, int>.internal(
      ChosenChatId.new,
      name: r'chosenChatIdProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chosenChatIdHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChosenChatId = AutoDisposeNotifier<int>;
String _$chatsCoordinatorHash() => r'91d1c752829e79045dbb8edded2d3a4e700fc95b';

/// Coordinator that maps ChatsSpec to appropriate widget builders
///
/// Copied from [ChatsCoordinator].
@ProviderFor(ChatsCoordinator)
final chatsCoordinatorProvider =
    AutoDisposeNotifierProvider<ChatsCoordinator, void>.internal(
      ChatsCoordinator.new,
      name: r'chatsCoordinatorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chatsCoordinatorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChatsCoordinator = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
