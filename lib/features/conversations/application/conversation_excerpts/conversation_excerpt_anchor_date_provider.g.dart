// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_excerpt_anchor_date_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$conversationExcerptAnchorDateHash() =>
    r'64ae976cf802476f1fbbbf5553ce1a2ca1179dea';

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

/// Reads the graph fact used to orient a Conversation excerpt in time.
///
/// Copied from [conversationExcerptAnchorDate].
@ProviderFor(conversationExcerptAnchorDate)
const conversationExcerptAnchorDateProvider =
    ConversationExcerptAnchorDateFamily();

/// Reads the graph fact used to orient a Conversation excerpt in time.
///
/// Copied from [conversationExcerptAnchorDate].
class ConversationExcerptAnchorDateFamily
    extends Family<AsyncValue<DateTime?>> {
  /// Reads the graph fact used to orient a Conversation excerpt in time.
  ///
  /// Copied from [conversationExcerptAnchorDate].
  const ConversationExcerptAnchorDateFamily();

  /// Reads the graph fact used to orient a Conversation excerpt in time.
  ///
  /// Copied from [conversationExcerptAnchorDate].
  ConversationExcerptAnchorDateProvider call({
    required int conversationId,
    required int anchorMessageId,
  }) {
    return ConversationExcerptAnchorDateProvider(
      conversationId: conversationId,
      anchorMessageId: anchorMessageId,
    );
  }

  @override
  ConversationExcerptAnchorDateProvider getProviderOverride(
    covariant ConversationExcerptAnchorDateProvider provider,
  ) {
    return call(
      conversationId: provider.conversationId,
      anchorMessageId: provider.anchorMessageId,
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
  String? get name => r'conversationExcerptAnchorDateProvider';
}

/// Reads the graph fact used to orient a Conversation excerpt in time.
///
/// Copied from [conversationExcerptAnchorDate].
class ConversationExcerptAnchorDateProvider
    extends AutoDisposeFutureProvider<DateTime?> {
  /// Reads the graph fact used to orient a Conversation excerpt in time.
  ///
  /// Copied from [conversationExcerptAnchorDate].
  ConversationExcerptAnchorDateProvider({
    required int conversationId,
    required int anchorMessageId,
  }) : this._internal(
         (ref) => conversationExcerptAnchorDate(
           ref as ConversationExcerptAnchorDateRef,
           conversationId: conversationId,
           anchorMessageId: anchorMessageId,
         ),
         from: conversationExcerptAnchorDateProvider,
         name: r'conversationExcerptAnchorDateProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$conversationExcerptAnchorDateHash,
         dependencies: ConversationExcerptAnchorDateFamily._dependencies,
         allTransitiveDependencies:
             ConversationExcerptAnchorDateFamily._allTransitiveDependencies,
         conversationId: conversationId,
         anchorMessageId: anchorMessageId,
       );

  ConversationExcerptAnchorDateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversationId,
    required this.anchorMessageId,
  }) : super.internal();

  final int conversationId;
  final int anchorMessageId;

  @override
  Override overrideWith(
    FutureOr<DateTime?> Function(ConversationExcerptAnchorDateRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ConversationExcerptAnchorDateProvider._internal(
        (ref) => create(ref as ConversationExcerptAnchorDateRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversationId: conversationId,
        anchorMessageId: anchorMessageId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<DateTime?> createElement() {
    return _ConversationExcerptAnchorDateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationExcerptAnchorDateProvider &&
        other.conversationId == conversationId &&
        other.anchorMessageId == anchorMessageId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversationId.hashCode);
    hash = _SystemHash.combine(hash, anchorMessageId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ConversationExcerptAnchorDateRef
    on AutoDisposeFutureProviderRef<DateTime?> {
  /// The parameter `conversationId` of this provider.
  int get conversationId;

  /// The parameter `anchorMessageId` of this provider.
  int get anchorMessageId;
}

class _ConversationExcerptAnchorDateProviderElement
    extends AutoDisposeFutureProviderElement<DateTime?>
    with ConversationExcerptAnchorDateRef {
  _ConversationExcerptAnchorDateProviderElement(super.provider);

  @override
  int get conversationId =>
      (origin as ConversationExcerptAnchorDateProvider).conversationId;
  @override
  int get anchorMessageId =>
      (origin as ConversationExcerptAnchorDateProvider).anchorMessageId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
