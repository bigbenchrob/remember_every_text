// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_reader_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$conversationReaderHash() =>
    r'35e9006b7fc559dc37724df0405a4b6e951d6923';

/// See also [conversationReader].
@ProviderFor(conversationReader)
final conversationReaderProvider =
    AutoDisposeFutureProvider<ConversationReader>.internal(
      conversationReader,
      name: r'conversationReaderProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$conversationReaderHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConversationReaderRef =
    AutoDisposeFutureProviderRef<ConversationReader>;
String _$conversationOverviewsHash() =>
    r'41ec527ca3e2a8e9fcdc0beb390d088309fd6867';

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

/// See also [conversationOverviews].
@ProviderFor(conversationOverviews)
const conversationOverviewsProvider = ConversationOverviewsFamily();

/// See also [conversationOverviews].
class ConversationOverviewsFamily
    extends Family<AsyncValue<List<ConversationOverview>>> {
  /// See also [conversationOverviews].
  const ConversationOverviewsFamily();

  /// See also [conversationOverviews].
  ConversationOverviewsProvider call({int limit = 100}) {
    return ConversationOverviewsProvider(limit: limit);
  }

  @override
  ConversationOverviewsProvider getProviderOverride(
    covariant ConversationOverviewsProvider provider,
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
  String? get name => r'conversationOverviewsProvider';
}

/// See also [conversationOverviews].
class ConversationOverviewsProvider
    extends AutoDisposeFutureProvider<List<ConversationOverview>> {
  /// See also [conversationOverviews].
  ConversationOverviewsProvider({int limit = 100})
    : this._internal(
        (ref) => conversationOverviews(
          ref as ConversationOverviewsRef,
          limit: limit,
        ),
        from: conversationOverviewsProvider,
        name: r'conversationOverviewsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$conversationOverviewsHash,
        dependencies: ConversationOverviewsFamily._dependencies,
        allTransitiveDependencies:
            ConversationOverviewsFamily._allTransitiveDependencies,
        limit: limit,
      );

  ConversationOverviewsProvider._internal(
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
    FutureOr<List<ConversationOverview>> Function(
      ConversationOverviewsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ConversationOverviewsProvider._internal(
        (ref) => create(ref as ConversationOverviewsRef),
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
  AutoDisposeFutureProviderElement<List<ConversationOverview>> createElement() {
    return _ConversationOverviewsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationOverviewsProvider && other.limit == limit;
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
mixin ConversationOverviewsRef
    on AutoDisposeFutureProviderRef<List<ConversationOverview>> {
  /// The parameter `limit` of this provider.
  int get limit;
}

class _ConversationOverviewsProviderElement
    extends AutoDisposeFutureProviderElement<List<ConversationOverview>>
    with ConversationOverviewsRef {
  _ConversationOverviewsProviderElement(super.provider);

  @override
  int get limit => (origin as ConversationOverviewsProvider).limit;
}

String _$conversationOverviewByIdHash() =>
    r'45cb90caf8075ea15b4d24bbcb9882f29dcd4685';

/// See also [conversationOverviewById].
@ProviderFor(conversationOverviewById)
const conversationOverviewByIdProvider = ConversationOverviewByIdFamily();

/// See also [conversationOverviewById].
class ConversationOverviewByIdFamily
    extends Family<AsyncValue<ConversationOverview?>> {
  /// See also [conversationOverviewById].
  const ConversationOverviewByIdFamily();

  /// See also [conversationOverviewById].
  ConversationOverviewByIdProvider call({required int conversationId}) {
    return ConversationOverviewByIdProvider(conversationId: conversationId);
  }

  @override
  ConversationOverviewByIdProvider getProviderOverride(
    covariant ConversationOverviewByIdProvider provider,
  ) {
    return call(conversationId: provider.conversationId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'conversationOverviewByIdProvider';
}

/// See also [conversationOverviewById].
class ConversationOverviewByIdProvider
    extends AutoDisposeFutureProvider<ConversationOverview?> {
  /// See also [conversationOverviewById].
  ConversationOverviewByIdProvider({required int conversationId})
    : this._internal(
        (ref) => conversationOverviewById(
          ref as ConversationOverviewByIdRef,
          conversationId: conversationId,
        ),
        from: conversationOverviewByIdProvider,
        name: r'conversationOverviewByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$conversationOverviewByIdHash,
        dependencies: ConversationOverviewByIdFamily._dependencies,
        allTransitiveDependencies:
            ConversationOverviewByIdFamily._allTransitiveDependencies,
        conversationId: conversationId,
      );

  ConversationOverviewByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversationId,
  }) : super.internal();

  final int conversationId;

  @override
  Override overrideWith(
    FutureOr<ConversationOverview?> Function(
      ConversationOverviewByIdRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ConversationOverviewByIdProvider._internal(
        (ref) => create(ref as ConversationOverviewByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversationId: conversationId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ConversationOverview?> createElement() {
    return _ConversationOverviewByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationOverviewByIdProvider &&
        other.conversationId == conversationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ConversationOverviewByIdRef
    on AutoDisposeFutureProviderRef<ConversationOverview?> {
  /// The parameter `conversationId` of this provider.
  int get conversationId;
}

class _ConversationOverviewByIdProviderElement
    extends AutoDisposeFutureProviderElement<ConversationOverview?>
    with ConversationOverviewByIdRef {
  _ConversationOverviewByIdProviderElement(super.provider);

  @override
  int get conversationId =>
      (origin as ConversationOverviewByIdProvider).conversationId;
}

String _$conversationMessagesHash() =>
    r'1eb6fa335178c45ca945fa7b16f5dd6580cb78b8';

/// See also [conversationMessages].
@ProviderFor(conversationMessages)
const conversationMessagesProvider = ConversationMessagesFamily();

/// See also [conversationMessages].
class ConversationMessagesFamily
    extends Family<AsyncValue<List<ConversationMessage>>> {
  /// See also [conversationMessages].
  const ConversationMessagesFamily();

  /// See also [conversationMessages].
  ConversationMessagesProvider call({
    required int conversationId,
    int limit = 100,
  }) {
    return ConversationMessagesProvider(
      conversationId: conversationId,
      limit: limit,
    );
  }

  @override
  ConversationMessagesProvider getProviderOverride(
    covariant ConversationMessagesProvider provider,
  ) {
    return call(conversationId: provider.conversationId, limit: provider.limit);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'conversationMessagesProvider';
}

/// See also [conversationMessages].
class ConversationMessagesProvider
    extends AutoDisposeFutureProvider<List<ConversationMessage>> {
  /// See also [conversationMessages].
  ConversationMessagesProvider({required int conversationId, int limit = 100})
    : this._internal(
        (ref) => conversationMessages(
          ref as ConversationMessagesRef,
          conversationId: conversationId,
          limit: limit,
        ),
        from: conversationMessagesProvider,
        name: r'conversationMessagesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$conversationMessagesHash,
        dependencies: ConversationMessagesFamily._dependencies,
        allTransitiveDependencies:
            ConversationMessagesFamily._allTransitiveDependencies,
        conversationId: conversationId,
        limit: limit,
      );

  ConversationMessagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversationId,
    required this.limit,
  }) : super.internal();

  final int conversationId;
  final int limit;

  @override
  Override overrideWith(
    FutureOr<List<ConversationMessage>> Function(
      ConversationMessagesRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ConversationMessagesProvider._internal(
        (ref) => create(ref as ConversationMessagesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversationId: conversationId,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ConversationMessage>> createElement() {
    return _ConversationMessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationMessagesProvider &&
        other.conversationId == conversationId &&
        other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversationId.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ConversationMessagesRef
    on AutoDisposeFutureProviderRef<List<ConversationMessage>> {
  /// The parameter `conversationId` of this provider.
  int get conversationId;

  /// The parameter `limit` of this provider.
  int get limit;
}

class _ConversationMessagesProviderElement
    extends AutoDisposeFutureProviderElement<List<ConversationMessage>>
    with ConversationMessagesRef {
  _ConversationMessagesProviderElement(super.provider);

  @override
  int get conversationId =>
      (origin as ConversationMessagesProvider).conversationId;
  @override
  int get limit => (origin as ConversationMessagesProvider).limit;
}

String _$conversationIdsMatchingMessageTextHash() =>
    r'006c0f8c9a5e9e094a0e3edcfa745244f0f6a91e';

/// See also [conversationIdsMatchingMessageText].
@ProviderFor(conversationIdsMatchingMessageText)
const conversationIdsMatchingMessageTextProvider =
    ConversationIdsMatchingMessageTextFamily();

/// See also [conversationIdsMatchingMessageText].
class ConversationIdsMatchingMessageTextFamily
    extends Family<AsyncValue<Set<int>>> {
  /// See also [conversationIdsMatchingMessageText].
  const ConversationIdsMatchingMessageTextFamily();

  /// See also [conversationIdsMatchingMessageText].
  ConversationIdsMatchingMessageTextProvider call({
    required String query,
    int limit = 500,
  }) {
    return ConversationIdsMatchingMessageTextProvider(
      query: query,
      limit: limit,
    );
  }

  @override
  ConversationIdsMatchingMessageTextProvider getProviderOverride(
    covariant ConversationIdsMatchingMessageTextProvider provider,
  ) {
    return call(query: provider.query, limit: provider.limit);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'conversationIdsMatchingMessageTextProvider';
}

/// See also [conversationIdsMatchingMessageText].
class ConversationIdsMatchingMessageTextProvider
    extends AutoDisposeFutureProvider<Set<int>> {
  /// See also [conversationIdsMatchingMessageText].
  ConversationIdsMatchingMessageTextProvider({
    required String query,
    int limit = 500,
  }) : this._internal(
         (ref) => conversationIdsMatchingMessageText(
           ref as ConversationIdsMatchingMessageTextRef,
           query: query,
           limit: limit,
         ),
         from: conversationIdsMatchingMessageTextProvider,
         name: r'conversationIdsMatchingMessageTextProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$conversationIdsMatchingMessageTextHash,
         dependencies: ConversationIdsMatchingMessageTextFamily._dependencies,
         allTransitiveDependencies: ConversationIdsMatchingMessageTextFamily
             ._allTransitiveDependencies,
         query: query,
         limit: limit,
       );

  ConversationIdsMatchingMessageTextProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
    required this.limit,
  }) : super.internal();

  final String query;
  final int limit;

  @override
  Override overrideWith(
    FutureOr<Set<int>> Function(ConversationIdsMatchingMessageTextRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ConversationIdsMatchingMessageTextProvider._internal(
        (ref) => create(ref as ConversationIdsMatchingMessageTextRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Set<int>> createElement() {
    return _ConversationIdsMatchingMessageTextProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationIdsMatchingMessageTextProvider &&
        other.query == query &&
        other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ConversationIdsMatchingMessageTextRef
    on AutoDisposeFutureProviderRef<Set<int>> {
  /// The parameter `query` of this provider.
  String get query;

  /// The parameter `limit` of this provider.
  int get limit;
}

class _ConversationIdsMatchingMessageTextProviderElement
    extends AutoDisposeFutureProviderElement<Set<int>>
    with ConversationIdsMatchingMessageTextRef {
  _ConversationIdsMatchingMessageTextProviderElement(super.provider);

  @override
  String get query =>
      (origin as ConversationIdsMatchingMessageTextProvider).query;
  @override
  int get limit => (origin as ConversationIdsMatchingMessageTextProvider).limit;
}

String _$conversationMessageTextMatchesHash() =>
    r'c0b6d08d28ef654522ac191d5df0f10d4475701b';

/// See also [conversationMessageTextMatches].
@ProviderFor(conversationMessageTextMatches)
const conversationMessageTextMatchesProvider =
    ConversationMessageTextMatchesFamily();

/// See also [conversationMessageTextMatches].
class ConversationMessageTextMatchesFamily
    extends Family<AsyncValue<Map<int, ConversationMessageTextMatch>>> {
  /// See also [conversationMessageTextMatches].
  const ConversationMessageTextMatchesFamily();

  /// See also [conversationMessageTextMatches].
  ConversationMessageTextMatchesProvider call({
    required String query,
    int limit = 500,
    int snippetsPerConversation = 3,
  }) {
    return ConversationMessageTextMatchesProvider(
      query: query,
      limit: limit,
      snippetsPerConversation: snippetsPerConversation,
    );
  }

  @override
  ConversationMessageTextMatchesProvider getProviderOverride(
    covariant ConversationMessageTextMatchesProvider provider,
  ) {
    return call(
      query: provider.query,
      limit: provider.limit,
      snippetsPerConversation: provider.snippetsPerConversation,
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
  String? get name => r'conversationMessageTextMatchesProvider';
}

/// See also [conversationMessageTextMatches].
class ConversationMessageTextMatchesProvider
    extends AutoDisposeFutureProvider<Map<int, ConversationMessageTextMatch>> {
  /// See also [conversationMessageTextMatches].
  ConversationMessageTextMatchesProvider({
    required String query,
    int limit = 500,
    int snippetsPerConversation = 3,
  }) : this._internal(
         (ref) => conversationMessageTextMatches(
           ref as ConversationMessageTextMatchesRef,
           query: query,
           limit: limit,
           snippetsPerConversation: snippetsPerConversation,
         ),
         from: conversationMessageTextMatchesProvider,
         name: r'conversationMessageTextMatchesProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$conversationMessageTextMatchesHash,
         dependencies: ConversationMessageTextMatchesFamily._dependencies,
         allTransitiveDependencies:
             ConversationMessageTextMatchesFamily._allTransitiveDependencies,
         query: query,
         limit: limit,
         snippetsPerConversation: snippetsPerConversation,
       );

  ConversationMessageTextMatchesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
    required this.limit,
    required this.snippetsPerConversation,
  }) : super.internal();

  final String query;
  final int limit;
  final int snippetsPerConversation;

  @override
  Override overrideWith(
    FutureOr<Map<int, ConversationMessageTextMatch>> Function(
      ConversationMessageTextMatchesRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ConversationMessageTextMatchesProvider._internal(
        (ref) => create(ref as ConversationMessageTextMatchesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
        limit: limit,
        snippetsPerConversation: snippetsPerConversation,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<int, ConversationMessageTextMatch>>
  createElement() {
    return _ConversationMessageTextMatchesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationMessageTextMatchesProvider &&
        other.query == query &&
        other.limit == limit &&
        other.snippetsPerConversation == snippetsPerConversation;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);
    hash = _SystemHash.combine(hash, snippetsPerConversation.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ConversationMessageTextMatchesRef
    on AutoDisposeFutureProviderRef<Map<int, ConversationMessageTextMatch>> {
  /// The parameter `query` of this provider.
  String get query;

  /// The parameter `limit` of this provider.
  int get limit;

  /// The parameter `snippetsPerConversation` of this provider.
  int get snippetsPerConversation;
}

class _ConversationMessageTextMatchesProviderElement
    extends
        AutoDisposeFutureProviderElement<Map<int, ConversationMessageTextMatch>>
    with ConversationMessageTextMatchesRef {
  _ConversationMessageTextMatchesProviderElement(super.provider);

  @override
  String get query => (origin as ConversationMessageTextMatchesProvider).query;
  @override
  int get limit => (origin as ConversationMessageTextMatchesProvider).limit;
  @override
  int get snippetsPerConversation =>
      (origin as ConversationMessageTextMatchesProvider)
          .snippetsPerConversation;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
