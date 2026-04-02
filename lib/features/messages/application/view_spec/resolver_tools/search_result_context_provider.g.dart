// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_result_context_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$searchResultContextHash() =>
    r'689f9c27ff02c5932d636702bc7d909171cd707a';

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

/// See also [searchResultContext].
@ProviderFor(searchResultContext)
const searchResultContextProvider = SearchResultContextFamily();

/// See also [searchResultContext].
class SearchResultContextFamily
    extends Family<AsyncValue<SearchResultContextState>> {
  /// See also [searchResultContext].
  const SearchResultContextFamily();

  /// See also [searchResultContext].
  SearchResultContextProvider call({
    required int messageId,
    required int chatId,
    required int beforeCount,
    required int afterCount,
  }) {
    return SearchResultContextProvider(
      messageId: messageId,
      chatId: chatId,
      beforeCount: beforeCount,
      afterCount: afterCount,
    );
  }

  @override
  SearchResultContextProvider getProviderOverride(
    covariant SearchResultContextProvider provider,
  ) {
    return call(
      messageId: provider.messageId,
      chatId: provider.chatId,
      beforeCount: provider.beforeCount,
      afterCount: provider.afterCount,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'searchResultContextProvider';
}

/// See also [searchResultContext].
class SearchResultContextProvider
    extends AutoDisposeFutureProvider<SearchResultContextState> {
  /// See also [searchResultContext].
  SearchResultContextProvider({
    required int messageId,
    required int chatId,
    required int beforeCount,
    required int afterCount,
  }) : this._internal(
         (ref) => searchResultContext(
           ref as SearchResultContextRef,
           messageId: messageId,
           chatId: chatId,
           beforeCount: beforeCount,
           afterCount: afterCount,
         ),
         from: searchResultContextProvider,
         name: r'searchResultContextProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$searchResultContextHash,
         dependencies: SearchResultContextFamily._dependencies,
         allTransitiveDependencies:
             SearchResultContextFamily._allTransitiveDependencies,
         messageId: messageId,
         chatId: chatId,
         beforeCount: beforeCount,
         afterCount: afterCount,
       );

  SearchResultContextProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.messageId,
    required this.chatId,
    required this.beforeCount,
    required this.afterCount,
  }) : super.internal();

  final int messageId;
  final int chatId;
  final int beforeCount;
  final int afterCount;

  @override
  Override overrideWith(
    FutureOr<SearchResultContextState> Function(SearchResultContextRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchResultContextProvider._internal(
        (ref) => create(ref as SearchResultContextRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        messageId: messageId,
        chatId: chatId,
        beforeCount: beforeCount,
        afterCount: afterCount,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<SearchResultContextState> createElement() {
    return _SearchResultContextProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchResultContextProvider &&
        other.messageId == messageId &&
        other.chatId == chatId &&
        other.beforeCount == beforeCount &&
        other.afterCount == afterCount;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, messageId.hashCode);
    hash = _SystemHash.combine(hash, chatId.hashCode);
    hash = _SystemHash.combine(hash, beforeCount.hashCode);
    hash = _SystemHash.combine(hash, afterCount.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchResultContextRef
    on AutoDisposeFutureProviderRef<SearchResultContextState> {
  /// The parameter `messageId` of this provider.
  int get messageId;

  /// The parameter `chatId` of this provider.
  int get chatId;

  /// The parameter `beforeCount` of this provider.
  int get beforeCount;

  /// The parameter `afterCount` of this provider.
  int get afterCount;
}

class _SearchResultContextProviderElement
    extends AutoDisposeFutureProviderElement<SearchResultContextState>
    with SearchResultContextRef {
  _SearchResultContextProviderElement(super.provider);

  @override
  int get messageId => (origin as SearchResultContextProvider).messageId;
  @override
  int get chatId => (origin as SearchResultContextProvider).chatId;
  @override
  int get beforeCount => (origin as SearchResultContextProvider).beforeCount;
  @override
  int get afterCount => (origin as SearchResultContextProvider).afterCount;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
