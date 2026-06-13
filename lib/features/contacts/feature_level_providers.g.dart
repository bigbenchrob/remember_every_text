// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_level_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactDisplayNameOverrideStoreHash() =>
    r'1f9481034af9b5921bd1226457a2b5b09159bab9';

/// See also [contactDisplayNameOverrideStore].
@ProviderFor(contactDisplayNameOverrideStore)
final contactDisplayNameOverrideStoreProvider =
    AutoDisposeFutureProvider<ContactDisplayNameOverrideStore>.internal(
      contactDisplayNameOverrideStore,
      name: r'contactDisplayNameOverrideStoreProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contactDisplayNameOverrideStoreHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContactDisplayNameOverrideStoreRef =
    AutoDisposeFutureProviderRef<ContactDisplayNameOverrideStore>;
String _$displayIdentityResolverHash() =>
    r'100f9a3065d28c7804b0ac7e8c3aed56b542367e';

/// Semantic display-identity boundary.
///
/// This resolver answers "what should the user see?", not "which database row
/// owns this information?". Row ids and handle values are inputs/provenance;
/// the output is an app-facing identity label.
///
/// Copied from [displayIdentityResolver].
@ProviderFor(displayIdentityResolver)
final displayIdentityResolverProvider =
    AutoDisposeFutureProvider<DisplayIdentityResolver>.internal(
      displayIdentityResolver,
      name: r'displayIdentityResolverProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$displayIdentityResolverHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DisplayIdentityResolverRef =
    AutoDisposeFutureProviderRef<DisplayIdentityResolver>;
String _$favoriteContactsRepositoryHash() =>
    r'24be60859246ea526b8fcd5403d51c4f8ba6b37a';

/// See also [favoriteContactsRepository].
@ProviderFor(favoriteContactsRepository)
final favoriteContactsRepositoryProvider =
    AutoDisposeFutureProvider<FavoriteContactsRepository>.internal(
      favoriteContactsRepository,
      name: r'favoriteContactsRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$favoriteContactsRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FavoriteContactsRepositoryRef =
    AutoDisposeFutureProviderRef<FavoriteContactsRepository>;
String _$manualHandleLinkStoreHash() =>
    r'a72d90c110e628a491160ffe8d15a0c140dddf9b';

/// See also [manualHandleLinkStore].
@ProviderFor(manualHandleLinkStore)
final manualHandleLinkStoreProvider =
    AutoDisposeFutureProvider<ManualHandleLinkStore>.internal(
      manualHandleLinkStore,
      name: r'manualHandleLinkStoreProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$manualHandleLinkStoreHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ManualHandleLinkStoreRef =
    AutoDisposeFutureProviderRef<ManualHandleLinkStore>;
String _$pickerFilterModeStoreHash() =>
    r'8ad99ebc9d81477b8d5d93ccb3bae658302972fe';

/// See also [pickerFilterModeStore].
@ProviderFor(pickerFilterModeStore)
final pickerFilterModeStoreProvider =
    AutoDisposeFutureProvider<PickerFilterModeStore>.internal(
      pickerFilterModeStore,
      name: r'pickerFilterModeStoreProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pickerFilterModeStoreHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PickerFilterModeStoreRef =
    AutoDisposeFutureProviderRef<PickerFilterModeStore>;
String _$contactProfileReaderHash() =>
    r'8c5fe1e92baa43c37a673e02da609869e3caea02';

/// See also [contactProfileReader].
@ProviderFor(contactProfileReader)
final contactProfileReaderProvider =
    AutoDisposeFutureProvider<ContactProfileReader>.internal(
      contactProfileReader,
      name: r'contactProfileReaderProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contactProfileReaderHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContactProfileReaderRef =
    AutoDisposeFutureProviderRef<ContactProfileReader>;
String _$contactProfileHash() => r'34dee5b01e189ad79653376de18981dbcd6ce3e4';

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

/// See also [contactProfile].
@ProviderFor(contactProfile)
const contactProfileProvider = ContactProfileFamily();

/// See also [contactProfile].
class ContactProfileFamily extends Family<AsyncValue<ContactProfileSummary?>> {
  /// See also [contactProfile].
  const ContactProfileFamily();

  /// See also [contactProfile].
  ContactProfileProvider call({required int contactId}) {
    return ContactProfileProvider(contactId: contactId);
  }

  @override
  ContactProfileProvider getProviderOverride(
    covariant ContactProfileProvider provider,
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
  String? get name => r'contactProfileProvider';
}

/// See also [contactProfile].
class ContactProfileProvider
    extends AutoDisposeFutureProvider<ContactProfileSummary?> {
  /// See also [contactProfile].
  ContactProfileProvider({required int contactId})
    : this._internal(
        (ref) => contactProfile(ref as ContactProfileRef, contactId: contactId),
        from: contactProfileProvider,
        name: r'contactProfileProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$contactProfileHash,
        dependencies: ContactProfileFamily._dependencies,
        allTransitiveDependencies:
            ContactProfileFamily._allTransitiveDependencies,
        contactId: contactId,
      );

  ContactProfileProvider._internal(
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
    FutureOr<ContactProfileSummary?> Function(ContactProfileRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContactProfileProvider._internal(
        (ref) => create(ref as ContactProfileRef),
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
  AutoDisposeFutureProviderElement<ContactProfileSummary?> createElement() {
    return _ContactProfileProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactProfileProvider && other.contactId == contactId;
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
mixin ContactProfileRef
    on AutoDisposeFutureProviderRef<ContactProfileSummary?> {
  /// The parameter `contactId` of this provider.
  int get contactId;
}

class _ContactProfileProviderElement
    extends AutoDisposeFutureProviderElement<ContactProfileSummary?>
    with ContactProfileRef {
  _ContactProfileProviderElement(super.provider);

  @override
  int get contactId => (origin as ContactProfileProvider).contactId;
}

String _$handlesForContactReaderHash() =>
    r'c2da5593787da3cfe6c10bb6950c22c2814e2e9c';

/// See also [handlesForContactReader].
@ProviderFor(handlesForContactReader)
final handlesForContactReaderProvider =
    AutoDisposeFutureProvider<HandlesForContactReader>.internal(
      handlesForContactReader,
      name: r'handlesForContactReaderProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$handlesForContactReaderHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HandlesForContactReaderRef =
    AutoDisposeFutureProviderRef<HandlesForContactReader>;
String _$handlesForContactHash() => r'e07b2f661d1125e2cdbf6d334ba1866f38b0e0f8';

/// See also [handlesForContact].
@ProviderFor(handlesForContact)
const handlesForContactProvider = HandlesForContactFamily();

/// See also [handlesForContact].
class HandlesForContactFamily extends Family<AsyncValue<List<LinkedHandle>>> {
  /// See also [handlesForContact].
  const HandlesForContactFamily();

  /// See also [handlesForContact].
  HandlesForContactProvider call({required int contactId}) {
    return HandlesForContactProvider(contactId: contactId);
  }

  @override
  HandlesForContactProvider getProviderOverride(
    covariant HandlesForContactProvider provider,
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
  String? get name => r'handlesForContactProvider';
}

/// See also [handlesForContact].
class HandlesForContactProvider
    extends AutoDisposeFutureProvider<List<LinkedHandle>> {
  /// See also [handlesForContact].
  HandlesForContactProvider({required int contactId})
    : this._internal(
        (ref) => handlesForContact(
          ref as HandlesForContactRef,
          contactId: contactId,
        ),
        from: handlesForContactProvider,
        name: r'handlesForContactProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$handlesForContactHash,
        dependencies: HandlesForContactFamily._dependencies,
        allTransitiveDependencies:
            HandlesForContactFamily._allTransitiveDependencies,
        contactId: contactId,
      );

  HandlesForContactProvider._internal(
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
    FutureOr<List<LinkedHandle>> Function(HandlesForContactRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HandlesForContactProvider._internal(
        (ref) => create(ref as HandlesForContactRef),
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
  AutoDisposeFutureProviderElement<List<LinkedHandle>> createElement() {
    return _HandlesForContactProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HandlesForContactProvider && other.contactId == contactId;
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
mixin HandlesForContactRef on AutoDisposeFutureProviderRef<List<LinkedHandle>> {
  /// The parameter `contactId` of this provider.
  int get contactId;
}

class _HandlesForContactProviderElement
    extends AutoDisposeFutureProviderElement<List<LinkedHandle>>
    with HandlesForContactRef {
  _HandlesForContactProviderElement(super.provider);

  @override
  int get contactId => (origin as HandlesForContactProvider).contactId;
}

String _$contactAccessStoreHash() =>
    r'1a4625bbca2fe58b754e703a5f5c979ef7a96868';

/// See also [contactAccessStore].
@ProviderFor(contactAccessStore)
final contactAccessStoreProvider =
    AutoDisposeFutureProvider<ContactAccessStore>.internal(
      contactAccessStore,
      name: r'contactAccessStoreProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contactAccessStoreHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContactAccessStoreRef =
    AutoDisposeFutureProviderRef<ContactAccessStore>;
String _$contactAccessActionsHash() =>
    r'ba263402be70515126981272a21b1e75d8657530';

/// See also [ContactAccessActions].
@ProviderFor(ContactAccessActions)
final contactAccessActionsProvider =
    AutoDisposeAsyncNotifierProvider<ContactAccessActions, void>.internal(
      ContactAccessActions.new,
      name: r'contactAccessActionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contactAccessActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ContactAccessActions = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
