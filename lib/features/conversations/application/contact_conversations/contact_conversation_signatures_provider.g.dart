// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_conversation_signatures_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactConversationSignaturesHash() =>
    r'eb376c0c03950a85a2214300f3cc1d81f93e375e';

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

/// See also [contactConversationSignatures].
@ProviderFor(contactConversationSignatures)
const contactConversationSignaturesProvider =
    ContactConversationSignaturesFamily();

/// See also [contactConversationSignatures].
class ContactConversationSignaturesFamily
    extends Family<AsyncValue<List<ConversationSignatureDisplayModel>>> {
  /// See also [contactConversationSignatures].
  const ContactConversationSignaturesFamily();

  /// See also [contactConversationSignatures].
  ContactConversationSignaturesProvider call({required int contactId}) {
    return ContactConversationSignaturesProvider(contactId: contactId);
  }

  @override
  ContactConversationSignaturesProvider getProviderOverride(
    covariant ContactConversationSignaturesProvider provider,
  ) {
    return call(contactId: provider.contactId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'contactConversationSignaturesProvider';
}

/// See also [contactConversationSignatures].
class ContactConversationSignaturesProvider
    extends AutoDisposeFutureProvider<List<ConversationSignatureDisplayModel>> {
  /// See also [contactConversationSignatures].
  ContactConversationSignaturesProvider({required int contactId})
    : this._internal(
        (ref) => contactConversationSignatures(
          ref as ContactConversationSignaturesRef,
          contactId: contactId,
        ),
        from: contactConversationSignaturesProvider,
        name: r'contactConversationSignaturesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$contactConversationSignaturesHash,
        dependencies: ContactConversationSignaturesFamily._dependencies,
        allTransitiveDependencies:
            ContactConversationSignaturesFamily._allTransitiveDependencies,
        contactId: contactId,
      );

  ContactConversationSignaturesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contactId,
  }) : super.internal();

  final int contactId;

  @override
  Override overrideWith(
    FutureOr<List<ConversationSignatureDisplayModel>> Function(
      ContactConversationSignaturesRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContactConversationSignaturesProvider._internal(
        (ref) => create(ref as ContactConversationSignaturesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contactId: contactId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ConversationSignatureDisplayModel>>
  createElement() {
    return _ContactConversationSignaturesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactConversationSignaturesProvider &&
        other.contactId == contactId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contactId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContactConversationSignaturesRef
    on AutoDisposeFutureProviderRef<List<ConversationSignatureDisplayModel>> {
  /// The parameter `contactId` of this provider.
  int get contactId;
}

class _ContactConversationSignaturesProviderElement
    extends
        AutoDisposeFutureProviderElement<
          List<ConversationSignatureDisplayModel>
        >
    with ContactConversationSignaturesRef {
  _ContactConversationSignaturesProviderElement(super.provider);

  @override
  int get contactId =>
      (origin as ContactConversationSignaturesProvider).contactId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
