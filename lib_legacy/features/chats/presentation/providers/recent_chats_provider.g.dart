// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_chats_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recentChatsHash() => r'4a8dfa7d5e0dcdf4f07776a6ff3ef6a1eb31e0c0';

/// Provides the 5 most recent chats with contact information for the sidebar
///
/// Copied from [recentChats].
@ProviderFor(recentChats)
final recentChatsProvider =
    AutoDisposeFutureProvider<List<RecentChatInfo>>.internal(
      recentChats,
      name: r'recentChatsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recentChatsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentChatsRef = AutoDisposeFutureProviderRef<List<RecentChatInfo>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
