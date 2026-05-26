// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_signature_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$conversationSignatureReaderHash() =>
    r'81ce9212fd4ddcf226a9f4f8c4bcfb6c8b8dcf9a';

/// See also [conversationSignatureReader].
@ProviderFor(conversationSignatureReader)
final conversationSignatureReaderProvider =
    AutoDisposeFutureProvider<ConversationSignatureReader>.internal(
      conversationSignatureReader,
      name: r'conversationSignatureReaderProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$conversationSignatureReaderHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConversationSignatureReaderRef =
    AutoDisposeFutureProviderRef<ConversationSignatureReader>;
String _$conversationSignaturesHash() =>
    r'7dc909ed0b2b37dcec8a7ec589834015f9f71a3f';

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

/// See also [conversationSignatures].
@ProviderFor(conversationSignatures)
const conversationSignaturesProvider = ConversationSignaturesFamily();

/// See also [conversationSignatures].
class ConversationSignaturesFamily
    extends Family<AsyncValue<List<ConversationSignature>>> {
  /// See also [conversationSignatures].
  const ConversationSignaturesFamily();

  /// See also [conversationSignatures].
  ConversationSignaturesProvider call({int limit = 100}) {
    return ConversationSignaturesProvider(limit: limit);
  }

  @override
  ConversationSignaturesProvider getProviderOverride(
    covariant ConversationSignaturesProvider provider,
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
  String? get name => r'conversationSignaturesProvider';
}

/// See also [conversationSignatures].
class ConversationSignaturesProvider
    extends AutoDisposeFutureProvider<List<ConversationSignature>> {
  /// See also [conversationSignatures].
  ConversationSignaturesProvider({int limit = 100})
    : this._internal(
        (ref) => conversationSignatures(
          ref as ConversationSignaturesRef,
          limit: limit,
        ),
        from: conversationSignaturesProvider,
        name: r'conversationSignaturesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$conversationSignaturesHash,
        dependencies: ConversationSignaturesFamily._dependencies,
        allTransitiveDependencies:
            ConversationSignaturesFamily._allTransitiveDependencies,
        limit: limit,
      );

  ConversationSignaturesProvider._internal(
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
    FutureOr<List<ConversationSignature>> Function(
      ConversationSignaturesRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ConversationSignaturesProvider._internal(
        (ref) => create(ref as ConversationSignaturesRef),
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
  AutoDisposeFutureProviderElement<List<ConversationSignature>>
  createElement() {
    return _ConversationSignaturesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationSignaturesProvider && other.limit == limit;
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
mixin ConversationSignaturesRef
    on AutoDisposeFutureProviderRef<List<ConversationSignature>> {
  /// The parameter `limit` of this provider.
  int get limit;
}

class _ConversationSignaturesProviderElement
    extends AutoDisposeFutureProviderElement<List<ConversationSignature>>
    with ConversationSignaturesRef {
  _ConversationSignaturesProviderElement(super.provider);

  @override
  int get limit => (origin as ConversationSignaturesProvider).limit;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
