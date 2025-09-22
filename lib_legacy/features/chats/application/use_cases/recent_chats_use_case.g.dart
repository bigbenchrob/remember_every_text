// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_chats_use_case.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recentChatsHash() => r'64b49b6a14ba0d4150b67dbee657dccd5e5f5403';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Use case for getting recent chats ordered by latest message
/// Application layer - orchestrates business logic
///
/// Copied from [recentChats].
@ProviderFor(recentChats)
const recentChatsProvider = RecentChatsFamily();

/// Use case for getting recent chats ordered by latest message
/// Application layer - orchestrates business logic
///
/// Copied from [recentChats].
class RecentChatsFamily
    extends Family<AsyncValue<List<ChatWithLatestMessage>>> {
  /// Use case for getting recent chats ordered by latest message
  /// Application layer - orchestrates business logic
  ///
  /// Copied from [recentChats].
  const RecentChatsFamily();

  /// Use case for getting recent chats ordered by latest message
  /// Application layer - orchestrates business logic
  ///
  /// Copied from [recentChats].
  RecentChatsProvider call({int limit = 5}) {
    return RecentChatsProvider(limit: limit);
  }

  @override
  RecentChatsProvider getProviderOverride(
    covariant RecentChatsProvider provider,
  ) {
    return call(limit: provider.limit);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recentChatsProvider';
}

/// Use case for getting recent chats ordered by latest message
/// Application layer - orchestrates business logic
///
/// Copied from [recentChats].
class RecentChatsProvider
    extends AutoDisposeFutureProvider<List<ChatWithLatestMessage>> {
  /// Use case for getting recent chats ordered by latest message
  /// Application layer - orchestrates business logic
  ///
  /// Copied from [recentChats].
  RecentChatsProvider({int limit = 5})
    : this._internal(
        (ref) => recentChats(ref as RecentChatsRef, limit: limit),
        from: recentChatsProvider,
        name: r'recentChatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$recentChatsHash,
        dependencies: RecentChatsFamily._dependencies,
        allTransitiveDependencies: RecentChatsFamily._allTransitiveDependencies,
        limit: limit,
      );

  RecentChatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.limit,
  }) : super.internal();

  final int limit;

  @override
  Override overrideWith(
    FutureOr<List<ChatWithLatestMessage>> Function(RecentChatsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecentChatsProvider._internal(
        (ref) => create(ref as RecentChatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ChatWithLatestMessage>>
  createElement() {
    return _RecentChatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecentChatsProvider && other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RecentChatsRef
    on AutoDisposeFutureProviderRef<List<ChatWithLatestMessage>> {
  /// The parameter `limit` of this provider.
  int get limit;
}

class _RecentChatsProviderElement
    extends AutoDisposeFutureProviderElement<List<ChatWithLatestMessage>>
    with RecentChatsRef {
  _RecentChatsProviderElement(super.provider);

  @override
  int get limit => (origin as RecentChatsProvider).limit;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
