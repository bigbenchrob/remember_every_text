// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_graph_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactGraphReaderHash() =>
    r'4e0b408fb7227b26f83efc4f0814b05cde8c093d';

/// See also [contactGraphReader].
@ProviderFor(contactGraphReader)
final contactGraphReaderProvider =
    AutoDisposeFutureProvider<ContactGraphReader>.internal(
      contactGraphReader,
      name: r'contactGraphReaderProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$contactGraphReaderHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ContactGraphReaderRef =
    AutoDisposeFutureProviderRef<ContactGraphReader>;
String _$contactGraphSnapshotHash() =>
    r'edfe44cefa6b22dd4e67b8be609461598b495766';

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

/// See also [contactGraphSnapshot].
@ProviderFor(contactGraphSnapshot)
const contactGraphSnapshotProvider = ContactGraphSnapshotFamily();

/// See also [contactGraphSnapshot].
class ContactGraphSnapshotFamily
    extends Family<AsyncValue<ContactGraphSnapshot>> {
  /// See also [contactGraphSnapshot].
  const ContactGraphSnapshotFamily();

  /// See also [contactGraphSnapshot].
  ContactGraphSnapshotProvider call({required int contactId}) {
    return ContactGraphSnapshotProvider(contactId: contactId);
  }

  @override
  ContactGraphSnapshotProvider getProviderOverride(
    covariant ContactGraphSnapshotProvider provider,
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
  String? get name => r'contactGraphSnapshotProvider';
}

/// See also [contactGraphSnapshot].
class ContactGraphSnapshotProvider
    extends AutoDisposeFutureProvider<ContactGraphSnapshot> {
  /// See also [contactGraphSnapshot].
  ContactGraphSnapshotProvider({required int contactId})
    : this._internal(
        (ref) => contactGraphSnapshot(
          ref as ContactGraphSnapshotRef,
          contactId: contactId,
        ),
        from: contactGraphSnapshotProvider,
        name: r'contactGraphSnapshotProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$contactGraphSnapshotHash,
        dependencies: ContactGraphSnapshotFamily._dependencies,
        allTransitiveDependencies:
            ContactGraphSnapshotFamily._allTransitiveDependencies,
        contactId: contactId,
      );

  ContactGraphSnapshotProvider._internal(
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
    FutureOr<ContactGraphSnapshot> Function(ContactGraphSnapshotRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContactGraphSnapshotProvider._internal(
        (ref) => create(ref as ContactGraphSnapshotRef),
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
  AutoDisposeFutureProviderElement<ContactGraphSnapshot> createElement() {
    return _ContactGraphSnapshotProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactGraphSnapshotProvider &&
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
mixin ContactGraphSnapshotRef
    on AutoDisposeFutureProviderRef<ContactGraphSnapshot> {
  /// The parameter `contactId` of this provider.
  int get contactId;
}

class _ContactGraphSnapshotProviderElement
    extends AutoDisposeFutureProviderElement<ContactGraphSnapshot>
    with ContactGraphSnapshotRef {
  _ContactGraphSnapshotProviderElement(super.provider);

  @override
  int get contactId => (origin as ContactGraphSnapshotProvider).contactId;
}

String _$contactPageGraphSnapshotHash() =>
    r'e0a0439f46c059abefa8e7c9729be372bd8c7617';

/// See also [contactPageGraphSnapshot].
@ProviderFor(contactPageGraphSnapshot)
const contactPageGraphSnapshotProvider = ContactPageGraphSnapshotFamily();

/// See also [contactPageGraphSnapshot].
class ContactPageGraphSnapshotFamily
    extends Family<AsyncValue<ContactGraphSnapshot>> {
  /// See also [contactPageGraphSnapshot].
  const ContactPageGraphSnapshotFamily();

  /// See also [contactPageGraphSnapshot].
  ContactPageGraphSnapshotProvider call({required int contactId}) {
    return ContactPageGraphSnapshotProvider(contactId: contactId);
  }

  @override
  ContactPageGraphSnapshotProvider getProviderOverride(
    covariant ContactPageGraphSnapshotProvider provider,
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
  String? get name => r'contactPageGraphSnapshotProvider';
}

/// See also [contactPageGraphSnapshot].
class ContactPageGraphSnapshotProvider
    extends AutoDisposeFutureProvider<ContactGraphSnapshot> {
  /// See also [contactPageGraphSnapshot].
  ContactPageGraphSnapshotProvider({required int contactId})
    : this._internal(
        (ref) => contactPageGraphSnapshot(
          ref as ContactPageGraphSnapshotRef,
          contactId: contactId,
        ),
        from: contactPageGraphSnapshotProvider,
        name: r'contactPageGraphSnapshotProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$contactPageGraphSnapshotHash,
        dependencies: ContactPageGraphSnapshotFamily._dependencies,
        allTransitiveDependencies:
            ContactPageGraphSnapshotFamily._allTransitiveDependencies,
        contactId: contactId,
      );

  ContactPageGraphSnapshotProvider._internal(
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
    FutureOr<ContactGraphSnapshot> Function(
      ContactPageGraphSnapshotRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContactPageGraphSnapshotProvider._internal(
        (ref) => create(ref as ContactPageGraphSnapshotRef),
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
  AutoDisposeFutureProviderElement<ContactGraphSnapshot> createElement() {
    return _ContactPageGraphSnapshotProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactPageGraphSnapshotProvider &&
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
mixin ContactPageGraphSnapshotRef
    on AutoDisposeFutureProviderRef<ContactGraphSnapshot> {
  /// The parameter `contactId` of this provider.
  int get contactId;
}

class _ContactPageGraphSnapshotProviderElement
    extends AutoDisposeFutureProviderElement<ContactGraphSnapshot>
    with ContactPageGraphSnapshotRef {
  _ContactPageGraphSnapshotProviderElement(super.provider);

  @override
  int get contactId => (origin as ContactPageGraphSnapshotProvider).contactId;
}

String _$contactPageGraphMessagesHash() =>
    r'3d25d03f4199295601d2f9bd8c24e943b381d754';

/// See also [contactPageGraphMessages].
@ProviderFor(contactPageGraphMessages)
const contactPageGraphMessagesProvider = ContactPageGraphMessagesFamily();

/// See also [contactPageGraphMessages].
class ContactPageGraphMessagesFamily
    extends Family<AsyncValue<List<ConversationMessage>>> {
  /// See also [contactPageGraphMessages].
  const ContactPageGraphMessagesFamily();

  /// See also [contactPageGraphMessages].
  ContactPageGraphMessagesProvider call({
    required int contactId,
    int limit = 500,
    DateTime? monthAnchor,
  }) {
    return ContactPageGraphMessagesProvider(
      contactId: contactId,
      limit: limit,
      monthAnchor: monthAnchor,
    );
  }

  @override
  ContactPageGraphMessagesProvider getProviderOverride(
    covariant ContactPageGraphMessagesProvider provider,
  ) {
    return call(
      contactId: provider.contactId,
      limit: provider.limit,
      monthAnchor: provider.monthAnchor,
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
  String? get name => r'contactPageGraphMessagesProvider';
}

/// See also [contactPageGraphMessages].
class ContactPageGraphMessagesProvider
    extends AutoDisposeFutureProvider<List<ConversationMessage>> {
  /// See also [contactPageGraphMessages].
  ContactPageGraphMessagesProvider({
    required int contactId,
    int limit = 500,
    DateTime? monthAnchor,
  }) : this._internal(
         (ref) => contactPageGraphMessages(
           ref as ContactPageGraphMessagesRef,
           contactId: contactId,
           limit: limit,
           monthAnchor: monthAnchor,
         ),
         from: contactPageGraphMessagesProvider,
         name: r'contactPageGraphMessagesProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$contactPageGraphMessagesHash,
         dependencies: ContactPageGraphMessagesFamily._dependencies,
         allTransitiveDependencies:
             ContactPageGraphMessagesFamily._allTransitiveDependencies,
         contactId: contactId,
         limit: limit,
         monthAnchor: monthAnchor,
       );

  ContactPageGraphMessagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contactId,
    required this.limit,
    required this.monthAnchor,
  }) : super.internal();

  final int contactId;
  final int limit;
  final DateTime? monthAnchor;

  @override
  Override overrideWith(
    FutureOr<List<ConversationMessage>> Function(
      ContactPageGraphMessagesRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContactPageGraphMessagesProvider._internal(
        (ref) => create(ref as ContactPageGraphMessagesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contactId: contactId,
        limit: limit,
        monthAnchor: monthAnchor,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ConversationMessage>> createElement() {
    return _ContactPageGraphMessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactPageGraphMessagesProvider &&
        other.contactId == contactId &&
        other.limit == limit &&
        other.monthAnchor == monthAnchor;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contactId.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);
    hash = _SystemHash.combine(hash, monthAnchor.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContactPageGraphMessagesRef
    on AutoDisposeFutureProviderRef<List<ConversationMessage>> {
  /// The parameter `contactId` of this provider.
  int get contactId;

  /// The parameter `limit` of this provider.
  int get limit;

  /// The parameter `monthAnchor` of this provider.
  DateTime? get monthAnchor;
}

class _ContactPageGraphMessagesProviderElement
    extends AutoDisposeFutureProviderElement<List<ConversationMessage>>
    with ContactPageGraphMessagesRef {
  _ContactPageGraphMessagesProviderElement(super.provider);

  @override
  int get contactId => (origin as ContactPageGraphMessagesProvider).contactId;
  @override
  int get limit => (origin as ContactPageGraphMessagesProvider).limit;
  @override
  DateTime? get monthAnchor =>
      (origin as ContactPageGraphMessagesProvider).monthAnchor;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
