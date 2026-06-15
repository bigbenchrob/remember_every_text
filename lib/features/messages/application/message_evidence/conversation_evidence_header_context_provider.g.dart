// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_evidence_header_context_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$conversationEvidenceHeaderContextHash() =>
    r'6316d31f1f04286e6b0176034b8ae1071d6530e4';

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

/// See also [conversationEvidenceHeaderContext].
@ProviderFor(conversationEvidenceHeaderContext)
const conversationEvidenceHeaderContextProvider =
    ConversationEvidenceHeaderContextFamily();

/// See also [conversationEvidenceHeaderContext].
class ConversationEvidenceHeaderContextFamily
    extends Family<AsyncValue<ConversationEvidenceHeaderContext?>> {
  /// See also [conversationEvidenceHeaderContext].
  const ConversationEvidenceHeaderContextFamily();

  /// See also [conversationEvidenceHeaderContext].
  ConversationEvidenceHeaderContextProvider call({
    required int conversationId,
  }) {
    return ConversationEvidenceHeaderContextProvider(
      conversationId: conversationId,
    );
  }

  @override
  ConversationEvidenceHeaderContextProvider getProviderOverride(
    covariant ConversationEvidenceHeaderContextProvider provider,
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
  String? get name => r'conversationEvidenceHeaderContextProvider';
}

/// See also [conversationEvidenceHeaderContext].
class ConversationEvidenceHeaderContextProvider
    extends AutoDisposeFutureProvider<ConversationEvidenceHeaderContext?> {
  /// See also [conversationEvidenceHeaderContext].
  ConversationEvidenceHeaderContextProvider({required int conversationId})
    : this._internal(
        (ref) => conversationEvidenceHeaderContext(
          ref as ConversationEvidenceHeaderContextRef,
          conversationId: conversationId,
        ),
        from: conversationEvidenceHeaderContextProvider,
        name: r'conversationEvidenceHeaderContextProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$conversationEvidenceHeaderContextHash,
        dependencies: ConversationEvidenceHeaderContextFamily._dependencies,
        allTransitiveDependencies:
            ConversationEvidenceHeaderContextFamily._allTransitiveDependencies,
        conversationId: conversationId,
      );

  ConversationEvidenceHeaderContextProvider._internal(
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
    FutureOr<ConversationEvidenceHeaderContext?> Function(
      ConversationEvidenceHeaderContextRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ConversationEvidenceHeaderContextProvider._internal(
        (ref) => create(ref as ConversationEvidenceHeaderContextRef),
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
  AutoDisposeFutureProviderElement<ConversationEvidenceHeaderContext?>
  createElement() {
    return _ConversationEvidenceHeaderContextProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationEvidenceHeaderContextProvider &&
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
mixin ConversationEvidenceHeaderContextRef
    on AutoDisposeFutureProviderRef<ConversationEvidenceHeaderContext?> {
  /// The parameter `conversationId` of this provider.
  int get conversationId;
}

class _ConversationEvidenceHeaderContextProviderElement
    extends AutoDisposeFutureProviderElement<ConversationEvidenceHeaderContext?>
    with ConversationEvidenceHeaderContextRef {
  _ConversationEvidenceHeaderContextProviderElement(super.provider);

  @override
  int get conversationId =>
      (origin as ConversationEvidenceHeaderContextProvider).conversationId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
