// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_signature_display_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$conversationSignatureDisplayHash() =>
    r'95959f0e1c44a7bf8fdc80ecc8d471de97dfc434';

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

/// See also [conversationSignatureDisplay].
@ProviderFor(conversationSignatureDisplay)
const conversationSignatureDisplayProvider =
    ConversationSignatureDisplayFamily();

/// See also [conversationSignatureDisplay].
class ConversationSignatureDisplayFamily
    extends Family<AsyncValue<List<ConversationSignatureDisplayModel>>> {
  /// See also [conversationSignatureDisplay].
  const ConversationSignatureDisplayFamily();

  /// See also [conversationSignatureDisplay].
  ConversationSignatureDisplayProvider call({
    int limit = 500,
    String searchQuery = '',
    ConversationSignatureFilter filter = ConversationSignatureFilter.recent,
    ConversationSignatureSort sort = ConversationSignatureSort.recent,
    List<int> excludedFavouriteConversationIds = const <int>[],
  }) {
    return ConversationSignatureDisplayProvider(
      limit: limit,
      searchQuery: searchQuery,
      filter: filter,
      sort: sort,
      excludedFavouriteConversationIds: excludedFavouriteConversationIds,
    );
  }

  @override
  ConversationSignatureDisplayProvider getProviderOverride(
    covariant ConversationSignatureDisplayProvider provider,
  ) {
    return call(
      limit: provider.limit,
      searchQuery: provider.searchQuery,
      filter: provider.filter,
      sort: provider.sort,
      excludedFavouriteConversationIds:
          provider.excludedFavouriteConversationIds,
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
  String? get name => r'conversationSignatureDisplayProvider';
}

/// See also [conversationSignatureDisplay].
class ConversationSignatureDisplayProvider
    extends AutoDisposeFutureProvider<List<ConversationSignatureDisplayModel>> {
  /// See also [conversationSignatureDisplay].
  ConversationSignatureDisplayProvider({
    int limit = 500,
    String searchQuery = '',
    ConversationSignatureFilter filter = ConversationSignatureFilter.recent,
    ConversationSignatureSort sort = ConversationSignatureSort.recent,
    List<int> excludedFavouriteConversationIds = const <int>[],
  }) : this._internal(
         (ref) => conversationSignatureDisplay(
           ref as ConversationSignatureDisplayRef,
           limit: limit,
           searchQuery: searchQuery,
           filter: filter,
           sort: sort,
           excludedFavouriteConversationIds: excludedFavouriteConversationIds,
         ),
         from: conversationSignatureDisplayProvider,
         name: r'conversationSignatureDisplayProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$conversationSignatureDisplayHash,
         dependencies: ConversationSignatureDisplayFamily._dependencies,
         allTransitiveDependencies:
             ConversationSignatureDisplayFamily._allTransitiveDependencies,
         limit: limit,
         searchQuery: searchQuery,
         filter: filter,
         sort: sort,
         excludedFavouriteConversationIds: excludedFavouriteConversationIds,
       );

  ConversationSignatureDisplayProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.limit,
    required this.searchQuery,
    required this.filter,
    required this.sort,
    required this.excludedFavouriteConversationIds,
  }) : super.internal();

  final int limit;
  final String searchQuery;
  final ConversationSignatureFilter filter;
  final ConversationSignatureSort sort;
  final List<int> excludedFavouriteConversationIds;

  @override
  Override overrideWith(
    FutureOr<List<ConversationSignatureDisplayModel>> Function(
      ConversationSignatureDisplayRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ConversationSignatureDisplayProvider._internal(
        (ref) => create(ref as ConversationSignatureDisplayRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        limit: limit,
        searchQuery: searchQuery,
        filter: filter,
        sort: sort,
        excludedFavouriteConversationIds: excludedFavouriteConversationIds,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ConversationSignatureDisplayModel>>
  createElement() {
    return _ConversationSignatureDisplayProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationSignatureDisplayProvider &&
        other.limit == limit &&
        other.searchQuery == searchQuery &&
        other.filter == filter &&
        other.sort == sort &&
        other.excludedFavouriteConversationIds ==
            excludedFavouriteConversationIds;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);
    hash = _SystemHash.combine(hash, searchQuery.hashCode);
    hash = _SystemHash.combine(hash, filter.hashCode);
    hash = _SystemHash.combine(hash, sort.hashCode);
    hash = _SystemHash.combine(hash, excludedFavouriteConversationIds.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ConversationSignatureDisplayRef
    on AutoDisposeFutureProviderRef<List<ConversationSignatureDisplayModel>> {
  /// The parameter `limit` of this provider.
  int get limit;

  /// The parameter `searchQuery` of this provider.
  String get searchQuery;

  /// The parameter `filter` of this provider.
  ConversationSignatureFilter get filter;

  /// The parameter `sort` of this provider.
  ConversationSignatureSort get sort;

  /// The parameter `excludedFavouriteConversationIds` of this provider.
  List<int> get excludedFavouriteConversationIds;
}

class _ConversationSignatureDisplayProviderElement
    extends
        AutoDisposeFutureProviderElement<
          List<ConversationSignatureDisplayModel>
        >
    with ConversationSignatureDisplayRef {
  _ConversationSignatureDisplayProviderElement(super.provider);

  @override
  int get limit => (origin as ConversationSignatureDisplayProvider).limit;
  @override
  String get searchQuery =>
      (origin as ConversationSignatureDisplayProvider).searchQuery;
  @override
  ConversationSignatureFilter get filter =>
      (origin as ConversationSignatureDisplayProvider).filter;
  @override
  ConversationSignatureSort get sort =>
      (origin as ConversationSignatureDisplayProvider).sort;
  @override
  List<int> get excludedFavouriteConversationIds =>
      (origin as ConversationSignatureDisplayProvider)
          .excludedFavouriteConversationIds;
}

String _$conversationSignatureDisplayByIdsHash() =>
    r'e67983d10f688acce24132a6d4d9748e9726adc2';

/// See also [conversationSignatureDisplayByIds].
@ProviderFor(conversationSignatureDisplayByIds)
const conversationSignatureDisplayByIdsProvider =
    ConversationSignatureDisplayByIdsFamily();

/// See also [conversationSignatureDisplayByIds].
class ConversationSignatureDisplayByIdsFamily
    extends Family<AsyncValue<List<ConversationSignatureDisplayModel>>> {
  /// See also [conversationSignatureDisplayByIds].
  const ConversationSignatureDisplayByIdsFamily();

  /// See also [conversationSignatureDisplayByIds].
  ConversationSignatureDisplayByIdsProvider call({
    required ConversationSignatureDisplayByIdsRequest request,
  }) {
    return ConversationSignatureDisplayByIdsProvider(request: request);
  }

  @override
  ConversationSignatureDisplayByIdsProvider getProviderOverride(
    covariant ConversationSignatureDisplayByIdsProvider provider,
  ) {
    return call(request: provider.request);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'conversationSignatureDisplayByIdsProvider';
}

/// See also [conversationSignatureDisplayByIds].
class ConversationSignatureDisplayByIdsProvider
    extends AutoDisposeFutureProvider<List<ConversationSignatureDisplayModel>> {
  /// See also [conversationSignatureDisplayByIds].
  ConversationSignatureDisplayByIdsProvider({
    required ConversationSignatureDisplayByIdsRequest request,
  }) : this._internal(
         (ref) => conversationSignatureDisplayByIds(
           ref as ConversationSignatureDisplayByIdsRef,
           request: request,
         ),
         from: conversationSignatureDisplayByIdsProvider,
         name: r'conversationSignatureDisplayByIdsProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$conversationSignatureDisplayByIdsHash,
         dependencies: ConversationSignatureDisplayByIdsFamily._dependencies,
         allTransitiveDependencies:
             ConversationSignatureDisplayByIdsFamily._allTransitiveDependencies,
         request: request,
       );

  ConversationSignatureDisplayByIdsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.request,
  }) : super.internal();

  final ConversationSignatureDisplayByIdsRequest request;

  @override
  Override overrideWith(
    FutureOr<List<ConversationSignatureDisplayModel>> Function(
      ConversationSignatureDisplayByIdsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ConversationSignatureDisplayByIdsProvider._internal(
        (ref) => create(ref as ConversationSignatureDisplayByIdsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        request: request,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ConversationSignatureDisplayModel>>
  createElement() {
    return _ConversationSignatureDisplayByIdsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationSignatureDisplayByIdsProvider &&
        other.request == request;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, request.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ConversationSignatureDisplayByIdsRef
    on AutoDisposeFutureProviderRef<List<ConversationSignatureDisplayModel>> {
  /// The parameter `request` of this provider.
  ConversationSignatureDisplayByIdsRequest get request;
}

class _ConversationSignatureDisplayByIdsProviderElement
    extends
        AutoDisposeFutureProviderElement<
          List<ConversationSignatureDisplayModel>
        >
    with ConversationSignatureDisplayByIdsRef {
  _ConversationSignatureDisplayByIdsProviderElement(super.provider);

  @override
  ConversationSignatureDisplayByIdsRequest get request =>
      (origin as ConversationSignatureDisplayByIdsProvider).request;
}

String _$favouriteConversationSignatureDisplayHash() =>
    r'620568f5cd7b6908abea3cc5e0a9f991d7f8d550';

/// See also [favouriteConversationSignatureDisplay].
@ProviderFor(favouriteConversationSignatureDisplay)
const favouriteConversationSignatureDisplayProvider =
    FavouriteConversationSignatureDisplayFamily();

/// See also [favouriteConversationSignatureDisplay].
class FavouriteConversationSignatureDisplayFamily
    extends Family<AsyncValue<List<ConversationSignatureDisplayModel>>> {
  /// See also [favouriteConversationSignatureDisplay].
  const FavouriteConversationSignatureDisplayFamily();

  /// See also [favouriteConversationSignatureDisplay].
  FavouriteConversationSignatureDisplayProvider call({
    required List<int> conversationIds,
  }) {
    return FavouriteConversationSignatureDisplayProvider(
      conversationIds: conversationIds,
    );
  }

  @override
  FavouriteConversationSignatureDisplayProvider getProviderOverride(
    covariant FavouriteConversationSignatureDisplayProvider provider,
  ) {
    return call(conversationIds: provider.conversationIds);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'favouriteConversationSignatureDisplayProvider';
}

/// See also [favouriteConversationSignatureDisplay].
class FavouriteConversationSignatureDisplayProvider
    extends AutoDisposeFutureProvider<List<ConversationSignatureDisplayModel>> {
  /// See also [favouriteConversationSignatureDisplay].
  FavouriteConversationSignatureDisplayProvider({
    required List<int> conversationIds,
  }) : this._internal(
         (ref) => favouriteConversationSignatureDisplay(
           ref as FavouriteConversationSignatureDisplayRef,
           conversationIds: conversationIds,
         ),
         from: favouriteConversationSignatureDisplayProvider,
         name: r'favouriteConversationSignatureDisplayProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$favouriteConversationSignatureDisplayHash,
         dependencies:
             FavouriteConversationSignatureDisplayFamily._dependencies,
         allTransitiveDependencies: FavouriteConversationSignatureDisplayFamily
             ._allTransitiveDependencies,
         conversationIds: conversationIds,
       );

  FavouriteConversationSignatureDisplayProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversationIds,
  }) : super.internal();

  final List<int> conversationIds;

  @override
  Override overrideWith(
    FutureOr<List<ConversationSignatureDisplayModel>> Function(
      FavouriteConversationSignatureDisplayRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FavouriteConversationSignatureDisplayProvider._internal(
        (ref) => create(ref as FavouriteConversationSignatureDisplayRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversationIds: conversationIds,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ConversationSignatureDisplayModel>>
  createElement() {
    return _FavouriteConversationSignatureDisplayProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FavouriteConversationSignatureDisplayProvider &&
        other.conversationIds == conversationIds;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversationIds.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FavouriteConversationSignatureDisplayRef
    on AutoDisposeFutureProviderRef<List<ConversationSignatureDisplayModel>> {
  /// The parameter `conversationIds` of this provider.
  List<int> get conversationIds;
}

class _FavouriteConversationSignatureDisplayProviderElement
    extends
        AutoDisposeFutureProviderElement<
          List<ConversationSignatureDisplayModel>
        >
    with FavouriteConversationSignatureDisplayRef {
  _FavouriteConversationSignatureDisplayProviderElement(super.provider);

  @override
  List<int> get conversationIds =>
      (origin as FavouriteConversationSignatureDisplayProvider).conversationIds;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
