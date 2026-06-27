// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handles_for_contact_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

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

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
