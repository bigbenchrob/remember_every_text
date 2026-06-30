// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_evidence_header_context_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactEvidenceHeaderContextHash() =>
    r'2d76cd84b1838864a1629786c89edb0190ba25c3';

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

/// See also [contactEvidenceHeaderContext].
@ProviderFor(contactEvidenceHeaderContext)
const contactEvidenceHeaderContextProvider =
    ContactEvidenceHeaderContextFamily();

/// See also [contactEvidenceHeaderContext].
class ContactEvidenceHeaderContextFamily
    extends Family<AsyncValue<ContactEvidenceHeaderContext>> {
  /// See also [contactEvidenceHeaderContext].
  const ContactEvidenceHeaderContextFamily();

  /// See also [contactEvidenceHeaderContext].
  ContactEvidenceHeaderContextProvider call({
    required int contactId,
    int? filterHandleId,
  }) {
    return ContactEvidenceHeaderContextProvider(
      contactId: contactId,
      filterHandleId: filterHandleId,
    );
  }

  @override
  ContactEvidenceHeaderContextProvider getProviderOverride(
    covariant ContactEvidenceHeaderContextProvider provider,
  ) {
    return call(
      contactId: provider.contactId,
      filterHandleId: provider.filterHandleId,
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
  String? get name => r'contactEvidenceHeaderContextProvider';
}

/// See also [contactEvidenceHeaderContext].
class ContactEvidenceHeaderContextProvider
    extends AutoDisposeFutureProvider<ContactEvidenceHeaderContext> {
  /// See also [contactEvidenceHeaderContext].
  ContactEvidenceHeaderContextProvider({
    required int contactId,
    int? filterHandleId,
  }) : this._internal(
         (ref) => contactEvidenceHeaderContext(
           ref as ContactEvidenceHeaderContextRef,
           contactId: contactId,
           filterHandleId: filterHandleId,
         ),
         from: contactEvidenceHeaderContextProvider,
         name: r'contactEvidenceHeaderContextProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$contactEvidenceHeaderContextHash,
         dependencies: ContactEvidenceHeaderContextFamily._dependencies,
         allTransitiveDependencies:
             ContactEvidenceHeaderContextFamily._allTransitiveDependencies,
         contactId: contactId,
         filterHandleId: filterHandleId,
       );

  ContactEvidenceHeaderContextProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contactId,
    required this.filterHandleId,
  }) : super.internal();

  final int contactId;
  final int? filterHandleId;

  @override
  Override overrideWith(
    FutureOr<ContactEvidenceHeaderContext> Function(
      ContactEvidenceHeaderContextRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContactEvidenceHeaderContextProvider._internal(
        (ref) => create(ref as ContactEvidenceHeaderContextRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contactId: contactId,
        filterHandleId: filterHandleId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ContactEvidenceHeaderContext>
  createElement() {
    return _ContactEvidenceHeaderContextProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactEvidenceHeaderContextProvider &&
        other.contactId == contactId &&
        other.filterHandleId == filterHandleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contactId.hashCode);
    hash = _SystemHash.combine(hash, filterHandleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContactEvidenceHeaderContextRef
    on AutoDisposeFutureProviderRef<ContactEvidenceHeaderContext> {
  /// The parameter `contactId` of this provider.
  int get contactId;

  /// The parameter `filterHandleId` of this provider.
  int? get filterHandleId;
}

class _ContactEvidenceHeaderContextProviderElement
    extends AutoDisposeFutureProviderElement<ContactEvidenceHeaderContext>
    with ContactEvidenceHeaderContextRef {
  _ContactEvidenceHeaderContextProviderElement(super.provider);

  @override
  int get contactId =>
      (origin as ContactEvidenceHeaderContextProvider).contactId;
  @override
  int? get filterHandleId =>
      (origin as ContactEvidenceHeaderContextProvider).filterHandleId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
