// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_graph_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$contactGraphReaderHash() =>
    r'dc423114234e80b3cbce806e09b6a81ad256c739';

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
    r'59db870261c17bbabc3027444f2faf0eadca19b3';

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
    r'c7ecc1f74cc82e3a5a15b3c6453618fe05fdb967';

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
    r'372186bb8d7158425b488fc0430a3eeefc2fc2e5';

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

String _$contactPageGraphMessageTimelineHash() =>
    r'bf29db88cecc153cc7459e56a730842417aa25a3';

/// See also [contactPageGraphMessageTimeline].
@ProviderFor(contactPageGraphMessageTimeline)
const contactPageGraphMessageTimelineProvider =
    ContactPageGraphMessageTimelineFamily();

/// See also [contactPageGraphMessageTimeline].
class ContactPageGraphMessageTimelineFamily
    extends Family<AsyncValue<List<ContactGraphMessageTimelineEntry>>> {
  /// See also [contactPageGraphMessageTimeline].
  const ContactPageGraphMessageTimelineFamily();

  /// See also [contactPageGraphMessageTimeline].
  ContactPageGraphMessageTimelineProvider call({required int contactId}) {
    return ContactPageGraphMessageTimelineProvider(contactId: contactId);
  }

  @override
  ContactPageGraphMessageTimelineProvider getProviderOverride(
    covariant ContactPageGraphMessageTimelineProvider provider,
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
  String? get name => r'contactPageGraphMessageTimelineProvider';
}

/// See also [contactPageGraphMessageTimeline].
class ContactPageGraphMessageTimelineProvider
    extends AutoDisposeFutureProvider<List<ContactGraphMessageTimelineEntry>> {
  /// See also [contactPageGraphMessageTimeline].
  ContactPageGraphMessageTimelineProvider({required int contactId})
    : this._internal(
        (ref) => contactPageGraphMessageTimeline(
          ref as ContactPageGraphMessageTimelineRef,
          contactId: contactId,
        ),
        from: contactPageGraphMessageTimelineProvider,
        name: r'contactPageGraphMessageTimelineProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$contactPageGraphMessageTimelineHash,
        dependencies: ContactPageGraphMessageTimelineFamily._dependencies,
        allTransitiveDependencies:
            ContactPageGraphMessageTimelineFamily._allTransitiveDependencies,
        contactId: contactId,
      );

  ContactPageGraphMessageTimelineProvider._internal(
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
    FutureOr<List<ContactGraphMessageTimelineEntry>> Function(
      ContactPageGraphMessageTimelineRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContactPageGraphMessageTimelineProvider._internal(
        (ref) => create(ref as ContactPageGraphMessageTimelineRef),
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
  AutoDisposeFutureProviderElement<List<ContactGraphMessageTimelineEntry>>
  createElement() {
    return _ContactPageGraphMessageTimelineProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactPageGraphMessageTimelineProvider &&
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
mixin ContactPageGraphMessageTimelineRef
    on AutoDisposeFutureProviderRef<List<ContactGraphMessageTimelineEntry>> {
  /// The parameter `contactId` of this provider.
  int get contactId;
}

class _ContactPageGraphMessageTimelineProviderElement
    extends
        AutoDisposeFutureProviderElement<List<ContactGraphMessageTimelineEntry>>
    with ContactPageGraphMessageTimelineRef {
  _ContactPageGraphMessageTimelineProviderElement(super.provider);

  @override
  int get contactId =>
      (origin as ContactPageGraphMessageTimelineProvider).contactId;
}

String _$contactPageGraphMessageByIdHash() =>
    r'9c7e3b187fcfb3556a6e22b3f4280bf2cb563798';

/// See also [contactPageGraphMessageById].
@ProviderFor(contactPageGraphMessageById)
const contactPageGraphMessageByIdProvider = ContactPageGraphMessageByIdFamily();

/// See also [contactPageGraphMessageById].
class ContactPageGraphMessageByIdFamily
    extends Family<AsyncValue<ConversationMessage?>> {
  /// See also [contactPageGraphMessageById].
  const ContactPageGraphMessageByIdFamily();

  /// See also [contactPageGraphMessageById].
  ContactPageGraphMessageByIdProvider call({
    required int contactId,
    required int messageId,
  }) {
    return ContactPageGraphMessageByIdProvider(
      contactId: contactId,
      messageId: messageId,
    );
  }

  @override
  ContactPageGraphMessageByIdProvider getProviderOverride(
    covariant ContactPageGraphMessageByIdProvider provider,
  ) {
    return call(contactId: provider.contactId, messageId: provider.messageId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'contactPageGraphMessageByIdProvider';
}

/// See also [contactPageGraphMessageById].
class ContactPageGraphMessageByIdProvider
    extends AutoDisposeFutureProvider<ConversationMessage?> {
  /// See also [contactPageGraphMessageById].
  ContactPageGraphMessageByIdProvider({
    required int contactId,
    required int messageId,
  }) : this._internal(
         (ref) => contactPageGraphMessageById(
           ref as ContactPageGraphMessageByIdRef,
           contactId: contactId,
           messageId: messageId,
         ),
         from: contactPageGraphMessageByIdProvider,
         name: r'contactPageGraphMessageByIdProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$contactPageGraphMessageByIdHash,
         dependencies: ContactPageGraphMessageByIdFamily._dependencies,
         allTransitiveDependencies:
             ContactPageGraphMessageByIdFamily._allTransitiveDependencies,
         contactId: contactId,
         messageId: messageId,
       );

  ContactPageGraphMessageByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contactId,
    required this.messageId,
  }) : super.internal();

  final int contactId;
  final int messageId;

  @override
  Override overrideWith(
    FutureOr<ConversationMessage?> Function(
      ContactPageGraphMessageByIdRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContactPageGraphMessageByIdProvider._internal(
        (ref) => create(ref as ContactPageGraphMessageByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contactId: contactId,
        messageId: messageId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ConversationMessage?> createElement() {
    return _ContactPageGraphMessageByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactPageGraphMessageByIdProvider &&
        other.contactId == contactId &&
        other.messageId == messageId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contactId.hashCode);
    hash = _SystemHash.combine(hash, messageId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContactPageGraphMessageByIdRef
    on AutoDisposeFutureProviderRef<ConversationMessage?> {
  /// The parameter `contactId` of this provider.
  int get contactId;

  /// The parameter `messageId` of this provider.
  int get messageId;
}

class _ContactPageGraphMessageByIdProviderElement
    extends AutoDisposeFutureProviderElement<ConversationMessage?>
    with ContactPageGraphMessageByIdRef {
  _ContactPageGraphMessageByIdProviderElement(super.provider);

  @override
  int get contactId =>
      (origin as ContactPageGraphMessageByIdProvider).contactId;
  @override
  int get messageId =>
      (origin as ContactPageGraphMessageByIdProvider).messageId;
}

String _$contactPageGraphHandleMessageTimelineHash() =>
    r'5dc56206337a3ee06a1fdd16471153c15f05aead';

/// See also [contactPageGraphHandleMessageTimeline].
@ProviderFor(contactPageGraphHandleMessageTimeline)
const contactPageGraphHandleMessageTimelineProvider =
    ContactPageGraphHandleMessageTimelineFamily();

/// See also [contactPageGraphHandleMessageTimeline].
class ContactPageGraphHandleMessageTimelineFamily
    extends Family<AsyncValue<List<ContactGraphMessageTimelineEntry>>> {
  /// See also [contactPageGraphHandleMessageTimeline].
  const ContactPageGraphHandleMessageTimelineFamily();

  /// See also [contactPageGraphHandleMessageTimeline].
  ContactPageGraphHandleMessageTimelineProvider call({
    required int contactId,
    required int handleId,
  }) {
    return ContactPageGraphHandleMessageTimelineProvider(
      contactId: contactId,
      handleId: handleId,
    );
  }

  @override
  ContactPageGraphHandleMessageTimelineProvider getProviderOverride(
    covariant ContactPageGraphHandleMessageTimelineProvider provider,
  ) {
    return call(contactId: provider.contactId, handleId: provider.handleId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'contactPageGraphHandleMessageTimelineProvider';
}

/// See also [contactPageGraphHandleMessageTimeline].
class ContactPageGraphHandleMessageTimelineProvider
    extends AutoDisposeFutureProvider<List<ContactGraphMessageTimelineEntry>> {
  /// See also [contactPageGraphHandleMessageTimeline].
  ContactPageGraphHandleMessageTimelineProvider({
    required int contactId,
    required int handleId,
  }) : this._internal(
         (ref) => contactPageGraphHandleMessageTimeline(
           ref as ContactPageGraphHandleMessageTimelineRef,
           contactId: contactId,
           handleId: handleId,
         ),
         from: contactPageGraphHandleMessageTimelineProvider,
         name: r'contactPageGraphHandleMessageTimelineProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$contactPageGraphHandleMessageTimelineHash,
         dependencies:
             ContactPageGraphHandleMessageTimelineFamily._dependencies,
         allTransitiveDependencies: ContactPageGraphHandleMessageTimelineFamily
             ._allTransitiveDependencies,
         contactId: contactId,
         handleId: handleId,
       );

  ContactPageGraphHandleMessageTimelineProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contactId,
    required this.handleId,
  }) : super.internal();

  final int contactId;
  final int handleId;

  @override
  Override overrideWith(
    FutureOr<List<ContactGraphMessageTimelineEntry>> Function(
      ContactPageGraphHandleMessageTimelineRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContactPageGraphHandleMessageTimelineProvider._internal(
        (ref) => create(ref as ContactPageGraphHandleMessageTimelineRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contactId: contactId,
        handleId: handleId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ContactGraphMessageTimelineEntry>>
  createElement() {
    return _ContactPageGraphHandleMessageTimelineProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactPageGraphHandleMessageTimelineProvider &&
        other.contactId == contactId &&
        other.handleId == handleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contactId.hashCode);
    hash = _SystemHash.combine(hash, handleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContactPageGraphHandleMessageTimelineRef
    on AutoDisposeFutureProviderRef<List<ContactGraphMessageTimelineEntry>> {
  /// The parameter `contactId` of this provider.
  int get contactId;

  /// The parameter `handleId` of this provider.
  int get handleId;
}

class _ContactPageGraphHandleMessageTimelineProviderElement
    extends
        AutoDisposeFutureProviderElement<List<ContactGraphMessageTimelineEntry>>
    with ContactPageGraphHandleMessageTimelineRef {
  _ContactPageGraphHandleMessageTimelineProviderElement(super.provider);

  @override
  int get contactId =>
      (origin as ContactPageGraphHandleMessageTimelineProvider).contactId;
  @override
  int get handleId =>
      (origin as ContactPageGraphHandleMessageTimelineProvider).handleId;
}

String _$contactPageGraphHandleMessageByIdHash() =>
    r'ea0422f1b54d2232a7e36bdc6d77c4da162afbe0';

/// See also [contactPageGraphHandleMessageById].
@ProviderFor(contactPageGraphHandleMessageById)
const contactPageGraphHandleMessageByIdProvider =
    ContactPageGraphHandleMessageByIdFamily();

/// See also [contactPageGraphHandleMessageById].
class ContactPageGraphHandleMessageByIdFamily
    extends Family<AsyncValue<ConversationMessage?>> {
  /// See also [contactPageGraphHandleMessageById].
  const ContactPageGraphHandleMessageByIdFamily();

  /// See also [contactPageGraphHandleMessageById].
  ContactPageGraphHandleMessageByIdProvider call({
    required int contactId,
    required int handleId,
    required int messageId,
  }) {
    return ContactPageGraphHandleMessageByIdProvider(
      contactId: contactId,
      handleId: handleId,
      messageId: messageId,
    );
  }

  @override
  ContactPageGraphHandleMessageByIdProvider getProviderOverride(
    covariant ContactPageGraphHandleMessageByIdProvider provider,
  ) {
    return call(
      contactId: provider.contactId,
      handleId: provider.handleId,
      messageId: provider.messageId,
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
  String? get name => r'contactPageGraphHandleMessageByIdProvider';
}

/// See also [contactPageGraphHandleMessageById].
class ContactPageGraphHandleMessageByIdProvider
    extends AutoDisposeFutureProvider<ConversationMessage?> {
  /// See also [contactPageGraphHandleMessageById].
  ContactPageGraphHandleMessageByIdProvider({
    required int contactId,
    required int handleId,
    required int messageId,
  }) : this._internal(
         (ref) => contactPageGraphHandleMessageById(
           ref as ContactPageGraphHandleMessageByIdRef,
           contactId: contactId,
           handleId: handleId,
           messageId: messageId,
         ),
         from: contactPageGraphHandleMessageByIdProvider,
         name: r'contactPageGraphHandleMessageByIdProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$contactPageGraphHandleMessageByIdHash,
         dependencies: ContactPageGraphHandleMessageByIdFamily._dependencies,
         allTransitiveDependencies:
             ContactPageGraphHandleMessageByIdFamily._allTransitiveDependencies,
         contactId: contactId,
         handleId: handleId,
         messageId: messageId,
       );

  ContactPageGraphHandleMessageByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contactId,
    required this.handleId,
    required this.messageId,
  }) : super.internal();

  final int contactId;
  final int handleId;
  final int messageId;

  @override
  Override overrideWith(
    FutureOr<ConversationMessage?> Function(
      ContactPageGraphHandleMessageByIdRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContactPageGraphHandleMessageByIdProvider._internal(
        (ref) => create(ref as ContactPageGraphHandleMessageByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contactId: contactId,
        handleId: handleId,
        messageId: messageId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ConversationMessage?> createElement() {
    return _ContactPageGraphHandleMessageByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactPageGraphHandleMessageByIdProvider &&
        other.contactId == contactId &&
        other.handleId == handleId &&
        other.messageId == messageId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contactId.hashCode);
    hash = _SystemHash.combine(hash, handleId.hashCode);
    hash = _SystemHash.combine(hash, messageId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContactPageGraphHandleMessageByIdRef
    on AutoDisposeFutureProviderRef<ConversationMessage?> {
  /// The parameter `contactId` of this provider.
  int get contactId;

  /// The parameter `handleId` of this provider.
  int get handleId;

  /// The parameter `messageId` of this provider.
  int get messageId;
}

class _ContactPageGraphHandleMessageByIdProviderElement
    extends AutoDisposeFutureProviderElement<ConversationMessage?>
    with ContactPageGraphHandleMessageByIdRef {
  _ContactPageGraphHandleMessageByIdProviderElement(super.provider);

  @override
  int get contactId =>
      (origin as ContactPageGraphHandleMessageByIdProvider).contactId;
  @override
  int get handleId =>
      (origin as ContactPageGraphHandleMessageByIdProvider).handleId;
  @override
  int get messageId =>
      (origin as ContactPageGraphHandleMessageByIdProvider).messageId;
}

String _$contactPageGraphHandleMessagesHash() =>
    r'916e1fca90a8b5e059eb25d2b107027bac63bac8';

/// See also [contactPageGraphHandleMessages].
@ProviderFor(contactPageGraphHandleMessages)
const contactPageGraphHandleMessagesProvider =
    ContactPageGraphHandleMessagesFamily();

/// See also [contactPageGraphHandleMessages].
class ContactPageGraphHandleMessagesFamily
    extends Family<AsyncValue<List<ConversationMessage>>> {
  /// See also [contactPageGraphHandleMessages].
  const ContactPageGraphHandleMessagesFamily();

  /// See also [contactPageGraphHandleMessages].
  ContactPageGraphHandleMessagesProvider call({
    required int contactId,
    required int handleId,
    int limit = 500,
    DateTime? monthAnchor,
  }) {
    return ContactPageGraphHandleMessagesProvider(
      contactId: contactId,
      handleId: handleId,
      limit: limit,
      monthAnchor: monthAnchor,
    );
  }

  @override
  ContactPageGraphHandleMessagesProvider getProviderOverride(
    covariant ContactPageGraphHandleMessagesProvider provider,
  ) {
    return call(
      contactId: provider.contactId,
      handleId: provider.handleId,
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
  String? get name => r'contactPageGraphHandleMessagesProvider';
}

/// See also [contactPageGraphHandleMessages].
class ContactPageGraphHandleMessagesProvider
    extends AutoDisposeFutureProvider<List<ConversationMessage>> {
  /// See also [contactPageGraphHandleMessages].
  ContactPageGraphHandleMessagesProvider({
    required int contactId,
    required int handleId,
    int limit = 500,
    DateTime? monthAnchor,
  }) : this._internal(
         (ref) => contactPageGraphHandleMessages(
           ref as ContactPageGraphHandleMessagesRef,
           contactId: contactId,
           handleId: handleId,
           limit: limit,
           monthAnchor: monthAnchor,
         ),
         from: contactPageGraphHandleMessagesProvider,
         name: r'contactPageGraphHandleMessagesProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$contactPageGraphHandleMessagesHash,
         dependencies: ContactPageGraphHandleMessagesFamily._dependencies,
         allTransitiveDependencies:
             ContactPageGraphHandleMessagesFamily._allTransitiveDependencies,
         contactId: contactId,
         handleId: handleId,
         limit: limit,
         monthAnchor: monthAnchor,
       );

  ContactPageGraphHandleMessagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contactId,
    required this.handleId,
    required this.limit,
    required this.monthAnchor,
  }) : super.internal();

  final int contactId;
  final int handleId;
  final int limit;
  final DateTime? monthAnchor;

  @override
  Override overrideWith(
    FutureOr<List<ConversationMessage>> Function(
      ContactPageGraphHandleMessagesRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContactPageGraphHandleMessagesProvider._internal(
        (ref) => create(ref as ContactPageGraphHandleMessagesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contactId: contactId,
        handleId: handleId,
        limit: limit,
        monthAnchor: monthAnchor,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ConversationMessage>> createElement() {
    return _ContactPageGraphHandleMessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactPageGraphHandleMessagesProvider &&
        other.contactId == contactId &&
        other.handleId == handleId &&
        other.limit == limit &&
        other.monthAnchor == monthAnchor;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contactId.hashCode);
    hash = _SystemHash.combine(hash, handleId.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);
    hash = _SystemHash.combine(hash, monthAnchor.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContactPageGraphHandleMessagesRef
    on AutoDisposeFutureProviderRef<List<ConversationMessage>> {
  /// The parameter `contactId` of this provider.
  int get contactId;

  /// The parameter `handleId` of this provider.
  int get handleId;

  /// The parameter `limit` of this provider.
  int get limit;

  /// The parameter `monthAnchor` of this provider.
  DateTime? get monthAnchor;
}

class _ContactPageGraphHandleMessagesProviderElement
    extends AutoDisposeFutureProviderElement<List<ConversationMessage>>
    with ContactPageGraphHandleMessagesRef {
  _ContactPageGraphHandleMessagesProviderElement(super.provider);

  @override
  int get contactId =>
      (origin as ContactPageGraphHandleMessagesProvider).contactId;
  @override
  int get handleId =>
      (origin as ContactPageGraphHandleMessagesProvider).handleId;
  @override
  int get limit => (origin as ContactPageGraphHandleMessagesProvider).limit;
  @override
  DateTime? get monthAnchor =>
      (origin as ContactPageGraphHandleMessagesProvider).monthAnchor;
}

String _$contactPageGraphMessageIdsMatchingTextHash() =>
    r'0e828d2cc1a8d62158b6361cd7317c7803444384';

/// See also [contactPageGraphMessageIdsMatchingText].
@ProviderFor(contactPageGraphMessageIdsMatchingText)
const contactPageGraphMessageIdsMatchingTextProvider =
    ContactPageGraphMessageIdsMatchingTextFamily();

/// See also [contactPageGraphMessageIdsMatchingText].
class ContactPageGraphMessageIdsMatchingTextFamily
    extends Family<AsyncValue<List<int>>> {
  /// See also [contactPageGraphMessageIdsMatchingText].
  const ContactPageGraphMessageIdsMatchingTextFamily();

  /// See also [contactPageGraphMessageIdsMatchingText].
  ContactPageGraphMessageIdsMatchingTextProvider call({
    required int contactId,
    required String query,
    bool matchAnyTerm = false,
    int? handleId,
  }) {
    return ContactPageGraphMessageIdsMatchingTextProvider(
      contactId: contactId,
      query: query,
      matchAnyTerm: matchAnyTerm,
      handleId: handleId,
    );
  }

  @override
  ContactPageGraphMessageIdsMatchingTextProvider getProviderOverride(
    covariant ContactPageGraphMessageIdsMatchingTextProvider provider,
  ) {
    return call(
      contactId: provider.contactId,
      query: provider.query,
      matchAnyTerm: provider.matchAnyTerm,
      handleId: provider.handleId,
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
  String? get name => r'contactPageGraphMessageIdsMatchingTextProvider';
}

/// See also [contactPageGraphMessageIdsMatchingText].
class ContactPageGraphMessageIdsMatchingTextProvider
    extends AutoDisposeFutureProvider<List<int>> {
  /// See also [contactPageGraphMessageIdsMatchingText].
  ContactPageGraphMessageIdsMatchingTextProvider({
    required int contactId,
    required String query,
    bool matchAnyTerm = false,
    int? handleId,
  }) : this._internal(
         (ref) => contactPageGraphMessageIdsMatchingText(
           ref as ContactPageGraphMessageIdsMatchingTextRef,
           contactId: contactId,
           query: query,
           matchAnyTerm: matchAnyTerm,
           handleId: handleId,
         ),
         from: contactPageGraphMessageIdsMatchingTextProvider,
         name: r'contactPageGraphMessageIdsMatchingTextProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$contactPageGraphMessageIdsMatchingTextHash,
         dependencies:
             ContactPageGraphMessageIdsMatchingTextFamily._dependencies,
         allTransitiveDependencies: ContactPageGraphMessageIdsMatchingTextFamily
             ._allTransitiveDependencies,
         contactId: contactId,
         query: query,
         matchAnyTerm: matchAnyTerm,
         handleId: handleId,
       );

  ContactPageGraphMessageIdsMatchingTextProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contactId,
    required this.query,
    required this.matchAnyTerm,
    required this.handleId,
  }) : super.internal();

  final int contactId;
  final String query;
  final bool matchAnyTerm;
  final int? handleId;

  @override
  Override overrideWith(
    FutureOr<List<int>> Function(
      ContactPageGraphMessageIdsMatchingTextRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ContactPageGraphMessageIdsMatchingTextProvider._internal(
        (ref) => create(ref as ContactPageGraphMessageIdsMatchingTextRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contactId: contactId,
        query: query,
        matchAnyTerm: matchAnyTerm,
        handleId: handleId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<int>> createElement() {
    return _ContactPageGraphMessageIdsMatchingTextProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ContactPageGraphMessageIdsMatchingTextProvider &&
        other.contactId == contactId &&
        other.query == query &&
        other.matchAnyTerm == matchAnyTerm &&
        other.handleId == handleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contactId.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);
    hash = _SystemHash.combine(hash, matchAnyTerm.hashCode);
    hash = _SystemHash.combine(hash, handleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ContactPageGraphMessageIdsMatchingTextRef
    on AutoDisposeFutureProviderRef<List<int>> {
  /// The parameter `contactId` of this provider.
  int get contactId;

  /// The parameter `query` of this provider.
  String get query;

  /// The parameter `matchAnyTerm` of this provider.
  bool get matchAnyTerm;

  /// The parameter `handleId` of this provider.
  int? get handleId;
}

class _ContactPageGraphMessageIdsMatchingTextProviderElement
    extends AutoDisposeFutureProviderElement<List<int>>
    with ContactPageGraphMessageIdsMatchingTextRef {
  _ContactPageGraphMessageIdsMatchingTextProviderElement(super.provider);

  @override
  int get contactId =>
      (origin as ContactPageGraphMessageIdsMatchingTextProvider).contactId;
  @override
  String get query =>
      (origin as ContactPageGraphMessageIdsMatchingTextProvider).query;
  @override
  bool get matchAnyTerm =>
      (origin as ContactPageGraphMessageIdsMatchingTextProvider).matchAnyTerm;
  @override
  int? get handleId =>
      (origin as ContactPageGraphMessageIdsMatchingTextProvider).handleId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
