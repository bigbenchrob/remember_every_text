// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_tags_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$conversationTagsHash() => r'0e0dffec3036242864aa93550d28d120b743b550';

/// See also [conversationTags].
@ProviderFor(conversationTags)
final conversationTagsProvider =
    AutoDisposeFutureProvider<List<ConversationTagDisplay>>.internal(
      conversationTags,
      name: r'conversationTagsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$conversationTagsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConversationTagsRef =
    AutoDisposeFutureProviderRef<List<ConversationTagDisplay>>;
String _$conversationTagsByConversationIdsHash() =>
    r'0bafbbd4e898f4a6f4b0b51f9e8933974eb549bc';

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

/// See also [conversationTagsByConversationIds].
@ProviderFor(conversationTagsByConversationIds)
const conversationTagsByConversationIdsProvider =
    ConversationTagsByConversationIdsFamily();

/// See also [conversationTagsByConversationIds].
class ConversationTagsByConversationIdsFamily
    extends Family<AsyncValue<Map<int, List<ConversationTagDisplay>>>> {
  /// See also [conversationTagsByConversationIds].
  const ConversationTagsByConversationIdsFamily();

  /// See also [conversationTagsByConversationIds].
  ConversationTagsByConversationIdsProvider call({
    required ConversationTagsByConversationIdsRequest request,
  }) {
    return ConversationTagsByConversationIdsProvider(request: request);
  }

  @override
  ConversationTagsByConversationIdsProvider getProviderOverride(
    covariant ConversationTagsByConversationIdsProvider provider,
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
  String? get name => r'conversationTagsByConversationIdsProvider';
}

/// See also [conversationTagsByConversationIds].
class ConversationTagsByConversationIdsProvider
    extends AutoDisposeFutureProvider<Map<int, List<ConversationTagDisplay>>> {
  /// See also [conversationTagsByConversationIds].
  ConversationTagsByConversationIdsProvider({
    required ConversationTagsByConversationIdsRequest request,
  }) : this._internal(
         (ref) => conversationTagsByConversationIds(
           ref as ConversationTagsByConversationIdsRef,
           request: request,
         ),
         from: conversationTagsByConversationIdsProvider,
         name: r'conversationTagsByConversationIdsProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$conversationTagsByConversationIdsHash,
         dependencies: ConversationTagsByConversationIdsFamily._dependencies,
         allTransitiveDependencies:
             ConversationTagsByConversationIdsFamily._allTransitiveDependencies,
         request: request,
       );

  ConversationTagsByConversationIdsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.request,
  }) : super.internal();

  final ConversationTagsByConversationIdsRequest request;

  @override
  Override overrideWith(
    FutureOr<Map<int, List<ConversationTagDisplay>>> Function(
      ConversationTagsByConversationIdsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ConversationTagsByConversationIdsProvider._internal(
        (ref) => create(ref as ConversationTagsByConversationIdsRef),
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
  AutoDisposeFutureProviderElement<Map<int, List<ConversationTagDisplay>>>
  createElement() {
    return _ConversationTagsByConversationIdsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationTagsByConversationIdsProvider &&
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
mixin ConversationTagsByConversationIdsRef
    on AutoDisposeFutureProviderRef<Map<int, List<ConversationTagDisplay>>> {
  /// The parameter `request` of this provider.
  ConversationTagsByConversationIdsRequest get request;
}

class _ConversationTagsByConversationIdsProviderElement
    extends
        AutoDisposeFutureProviderElement<Map<int, List<ConversationTagDisplay>>>
    with ConversationTagsByConversationIdsRef {
  _ConversationTagsByConversationIdsProviderElement(super.provider);

  @override
  ConversationTagsByConversationIdsRequest get request =>
      (origin as ConversationTagsByConversationIdsProvider).request;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
