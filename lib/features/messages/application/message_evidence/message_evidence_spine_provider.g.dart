// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_evidence_spine_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageEvidenceTimelineSkeletonHash() =>
    r'e6f615c145bd8b020abc757af1c0f7688ec7658e';

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

/// See also [messageEvidenceTimelineSkeleton].
@ProviderFor(messageEvidenceTimelineSkeleton)
const messageEvidenceTimelineSkeletonProvider =
    MessageEvidenceTimelineSkeletonFamily();

/// See also [messageEvidenceTimelineSkeleton].
class MessageEvidenceTimelineSkeletonFamily
    extends Family<AsyncValue<MessageEvidenceTimelineSkeleton>> {
  /// See also [messageEvidenceTimelineSkeleton].
  const MessageEvidenceTimelineSkeletonFamily();

  /// See also [messageEvidenceTimelineSkeleton].
  MessageEvidenceTimelineSkeletonProvider call({
    required MessageEvidenceScope scope,
  }) {
    return MessageEvidenceTimelineSkeletonProvider(scope: scope);
  }

  @override
  MessageEvidenceTimelineSkeletonProvider getProviderOverride(
    covariant MessageEvidenceTimelineSkeletonProvider provider,
  ) {
    return call(scope: provider.scope);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messageEvidenceTimelineSkeletonProvider';
}

/// See also [messageEvidenceTimelineSkeleton].
class MessageEvidenceTimelineSkeletonProvider
    extends AutoDisposeFutureProvider<MessageEvidenceTimelineSkeleton> {
  /// See also [messageEvidenceTimelineSkeleton].
  MessageEvidenceTimelineSkeletonProvider({required MessageEvidenceScope scope})
    : this._internal(
        (ref) => messageEvidenceTimelineSkeleton(
          ref as MessageEvidenceTimelineSkeletonRef,
          scope: scope,
        ),
        from: messageEvidenceTimelineSkeletonProvider,
        name: r'messageEvidenceTimelineSkeletonProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messageEvidenceTimelineSkeletonHash,
        dependencies: MessageEvidenceTimelineSkeletonFamily._dependencies,
        allTransitiveDependencies:
            MessageEvidenceTimelineSkeletonFamily._allTransitiveDependencies,
        scope: scope,
      );

  MessageEvidenceTimelineSkeletonProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scope,
  }) : super.internal();

  final MessageEvidenceScope scope;

  @override
  Override overrideWith(
    FutureOr<MessageEvidenceTimelineSkeleton> Function(
      MessageEvidenceTimelineSkeletonRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessageEvidenceTimelineSkeletonProvider._internal(
        (ref) => create(ref as MessageEvidenceTimelineSkeletonRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        scope: scope,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<MessageEvidenceTimelineSkeleton>
  createElement() {
    return _MessageEvidenceTimelineSkeletonProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageEvidenceTimelineSkeletonProvider &&
        other.scope == scope;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scope.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageEvidenceTimelineSkeletonRef
    on AutoDisposeFutureProviderRef<MessageEvidenceTimelineSkeleton> {
  /// The parameter `scope` of this provider.
  MessageEvidenceScope get scope;
}

class _MessageEvidenceTimelineSkeletonProviderElement
    extends AutoDisposeFutureProviderElement<MessageEvidenceTimelineSkeleton>
    with MessageEvidenceTimelineSkeletonRef {
  _MessageEvidenceTimelineSkeletonProviderElement(super.provider);

  @override
  MessageEvidenceScope get scope =>
      (origin as MessageEvidenceTimelineSkeletonProvider).scope;
}

String _$messageEvidenceRowHash() =>
    r'c970725f4b42554fb8fc5ac30b5c3d9599285fca';

/// See also [messageEvidenceRow].
@ProviderFor(messageEvidenceRow)
const messageEvidenceRowProvider = MessageEvidenceRowFamily();

/// See also [messageEvidenceRow].
class MessageEvidenceRowFamily
    extends Family<AsyncValue<MessageEvidenceRowData?>> {
  /// See also [messageEvidenceRow].
  const MessageEvidenceRowFamily();

  /// See also [messageEvidenceRow].
  MessageEvidenceRowProvider call({
    required MessageEvidenceScope scope,
    required int messageId,
  }) {
    return MessageEvidenceRowProvider(scope: scope, messageId: messageId);
  }

  @override
  MessageEvidenceRowProvider getProviderOverride(
    covariant MessageEvidenceRowProvider provider,
  ) {
    return call(scope: provider.scope, messageId: provider.messageId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messageEvidenceRowProvider';
}

/// See also [messageEvidenceRow].
class MessageEvidenceRowProvider
    extends AutoDisposeFutureProvider<MessageEvidenceRowData?> {
  /// See also [messageEvidenceRow].
  MessageEvidenceRowProvider({
    required MessageEvidenceScope scope,
    required int messageId,
  }) : this._internal(
         (ref) => messageEvidenceRow(
           ref as MessageEvidenceRowRef,
           scope: scope,
           messageId: messageId,
         ),
         from: messageEvidenceRowProvider,
         name: r'messageEvidenceRowProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$messageEvidenceRowHash,
         dependencies: MessageEvidenceRowFamily._dependencies,
         allTransitiveDependencies:
             MessageEvidenceRowFamily._allTransitiveDependencies,
         scope: scope,
         messageId: messageId,
       );

  MessageEvidenceRowProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scope,
    required this.messageId,
  }) : super.internal();

  final MessageEvidenceScope scope;
  final int messageId;

  @override
  Override overrideWith(
    FutureOr<MessageEvidenceRowData?> Function(MessageEvidenceRowRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessageEvidenceRowProvider._internal(
        (ref) => create(ref as MessageEvidenceRowRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        scope: scope,
        messageId: messageId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<MessageEvidenceRowData?> createElement() {
    return _MessageEvidenceRowProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageEvidenceRowProvider &&
        other.scope == scope &&
        other.messageId == messageId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scope.hashCode);
    hash = _SystemHash.combine(hash, messageId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageEvidenceRowRef
    on AutoDisposeFutureProviderRef<MessageEvidenceRowData?> {
  /// The parameter `scope` of this provider.
  MessageEvidenceScope get scope;

  /// The parameter `messageId` of this provider.
  int get messageId;
}

class _MessageEvidenceRowProviderElement
    extends AutoDisposeFutureProviderElement<MessageEvidenceRowData?>
    with MessageEvidenceRowRef {
  _MessageEvidenceRowProviderElement(super.provider);

  @override
  MessageEvidenceScope get scope =>
      (origin as MessageEvidenceRowProvider).scope;
  @override
  int get messageId => (origin as MessageEvidenceRowProvider).messageId;
}

String _$messageEvidenceAttachmentsHash() =>
    r'3cb218222c03351c1d17f69313048217da129278';

/// See also [messageEvidenceAttachments].
@ProviderFor(messageEvidenceAttachments)
const messageEvidenceAttachmentsProvider = MessageEvidenceAttachmentsFamily();

/// See also [messageEvidenceAttachments].
class MessageEvidenceAttachmentsFamily
    extends Family<AsyncValue<List<MessageAttachmentEvidence>>> {
  /// See also [messageEvidenceAttachments].
  const MessageEvidenceAttachmentsFamily();

  /// See also [messageEvidenceAttachments].
  MessageEvidenceAttachmentsProvider call({
    required MessageEvidenceScope scope,
    required int messageId,
  }) {
    return MessageEvidenceAttachmentsProvider(
      scope: scope,
      messageId: messageId,
    );
  }

  @override
  MessageEvidenceAttachmentsProvider getProviderOverride(
    covariant MessageEvidenceAttachmentsProvider provider,
  ) {
    return call(scope: provider.scope, messageId: provider.messageId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messageEvidenceAttachmentsProvider';
}

/// See also [messageEvidenceAttachments].
class MessageEvidenceAttachmentsProvider
    extends AutoDisposeFutureProvider<List<MessageAttachmentEvidence>> {
  /// See also [messageEvidenceAttachments].
  MessageEvidenceAttachmentsProvider({
    required MessageEvidenceScope scope,
    required int messageId,
  }) : this._internal(
         (ref) => messageEvidenceAttachments(
           ref as MessageEvidenceAttachmentsRef,
           scope: scope,
           messageId: messageId,
         ),
         from: messageEvidenceAttachmentsProvider,
         name: r'messageEvidenceAttachmentsProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$messageEvidenceAttachmentsHash,
         dependencies: MessageEvidenceAttachmentsFamily._dependencies,
         allTransitiveDependencies:
             MessageEvidenceAttachmentsFamily._allTransitiveDependencies,
         scope: scope,
         messageId: messageId,
       );

  MessageEvidenceAttachmentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scope,
    required this.messageId,
  }) : super.internal();

  final MessageEvidenceScope scope;
  final int messageId;

  @override
  Override overrideWith(
    FutureOr<List<MessageAttachmentEvidence>> Function(
      MessageEvidenceAttachmentsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessageEvidenceAttachmentsProvider._internal(
        (ref) => create(ref as MessageEvidenceAttachmentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        scope: scope,
        messageId: messageId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MessageAttachmentEvidence>>
  createElement() {
    return _MessageEvidenceAttachmentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageEvidenceAttachmentsProvider &&
        other.scope == scope &&
        other.messageId == messageId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scope.hashCode);
    hash = _SystemHash.combine(hash, messageId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageEvidenceAttachmentsRef
    on AutoDisposeFutureProviderRef<List<MessageAttachmentEvidence>> {
  /// The parameter `scope` of this provider.
  MessageEvidenceScope get scope;

  /// The parameter `messageId` of this provider.
  int get messageId;
}

class _MessageEvidenceAttachmentsProviderElement
    extends AutoDisposeFutureProviderElement<List<MessageAttachmentEvidence>>
    with MessageEvidenceAttachmentsRef {
  _MessageEvidenceAttachmentsProviderElement(super.provider);

  @override
  MessageEvidenceScope get scope =>
      (origin as MessageEvidenceAttachmentsProvider).scope;
  @override
  int get messageId => (origin as MessageEvidenceAttachmentsProvider).messageId;
}

String _$messageEvidenceInitialRowsHash() =>
    r'5fb1898609f685c2c33e5a6eb15a364df85d1f0d';

/// See also [messageEvidenceInitialRows].
@ProviderFor(messageEvidenceInitialRows)
const messageEvidenceInitialRowsProvider = MessageEvidenceInitialRowsFamily();

/// See also [messageEvidenceInitialRows].
class MessageEvidenceInitialRowsFamily
    extends Family<AsyncValue<Map<int, MessageEvidenceRowData>>> {
  /// See also [messageEvidenceInitialRows].
  const MessageEvidenceInitialRowsFamily();

  /// See also [messageEvidenceInitialRows].
  MessageEvidenceInitialRowsProvider call({
    required MessageEvidenceScope scope,
    DateTime? monthAnchor,
    int limit = 80,
  }) {
    return MessageEvidenceInitialRowsProvider(
      scope: scope,
      monthAnchor: monthAnchor,
      limit: limit,
    );
  }

  @override
  MessageEvidenceInitialRowsProvider getProviderOverride(
    covariant MessageEvidenceInitialRowsProvider provider,
  ) {
    return call(
      scope: provider.scope,
      monthAnchor: provider.monthAnchor,
      limit: provider.limit,
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
  String? get name => r'messageEvidenceInitialRowsProvider';
}

/// See also [messageEvidenceInitialRows].
class MessageEvidenceInitialRowsProvider
    extends AutoDisposeFutureProvider<Map<int, MessageEvidenceRowData>> {
  /// See also [messageEvidenceInitialRows].
  MessageEvidenceInitialRowsProvider({
    required MessageEvidenceScope scope,
    DateTime? monthAnchor,
    int limit = 80,
  }) : this._internal(
         (ref) => messageEvidenceInitialRows(
           ref as MessageEvidenceInitialRowsRef,
           scope: scope,
           monthAnchor: monthAnchor,
           limit: limit,
         ),
         from: messageEvidenceInitialRowsProvider,
         name: r'messageEvidenceInitialRowsProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$messageEvidenceInitialRowsHash,
         dependencies: MessageEvidenceInitialRowsFamily._dependencies,
         allTransitiveDependencies:
             MessageEvidenceInitialRowsFamily._allTransitiveDependencies,
         scope: scope,
         monthAnchor: monthAnchor,
         limit: limit,
       );

  MessageEvidenceInitialRowsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scope,
    required this.monthAnchor,
    required this.limit,
  }) : super.internal();

  final MessageEvidenceScope scope;
  final DateTime? monthAnchor;
  final int limit;

  @override
  Override overrideWith(
    FutureOr<Map<int, MessageEvidenceRowData>> Function(
      MessageEvidenceInitialRowsRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessageEvidenceInitialRowsProvider._internal(
        (ref) => create(ref as MessageEvidenceInitialRowsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        scope: scope,
        monthAnchor: monthAnchor,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<int, MessageEvidenceRowData>>
  createElement() {
    return _MessageEvidenceInitialRowsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageEvidenceInitialRowsProvider &&
        other.scope == scope &&
        other.monthAnchor == monthAnchor &&
        other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scope.hashCode);
    hash = _SystemHash.combine(hash, monthAnchor.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageEvidenceInitialRowsRef
    on AutoDisposeFutureProviderRef<Map<int, MessageEvidenceRowData>> {
  /// The parameter `scope` of this provider.
  MessageEvidenceScope get scope;

  /// The parameter `monthAnchor` of this provider.
  DateTime? get monthAnchor;

  /// The parameter `limit` of this provider.
  int get limit;
}

class _MessageEvidenceInitialRowsProviderElement
    extends AutoDisposeFutureProviderElement<Map<int, MessageEvidenceRowData>>
    with MessageEvidenceInitialRowsRef {
  _MessageEvidenceInitialRowsProviderElement(super.provider);

  @override
  MessageEvidenceScope get scope =>
      (origin as MessageEvidenceInitialRowsProvider).scope;
  @override
  DateTime? get monthAnchor =>
      (origin as MessageEvidenceInitialRowsProvider).monthAnchor;
  @override
  int get limit => (origin as MessageEvidenceInitialRowsProvider).limit;
}

String _$messageEvidenceTextMatchIdsHash() =>
    r'517bd5b36989491c27378d1444811bd3458b9b66';

/// See also [messageEvidenceTextMatchIds].
@ProviderFor(messageEvidenceTextMatchIds)
const messageEvidenceTextMatchIdsProvider = MessageEvidenceTextMatchIdsFamily();

/// See also [messageEvidenceTextMatchIds].
class MessageEvidenceTextMatchIdsFamily extends Family<AsyncValue<List<int>>> {
  /// See also [messageEvidenceTextMatchIds].
  const MessageEvidenceTextMatchIdsFamily();

  /// See also [messageEvidenceTextMatchIds].
  MessageEvidenceTextMatchIdsProvider call({
    required MessageEvidenceScope scope,
    required String query,
    MessageEvidenceSearchMode mode = MessageEvidenceSearchMode.allTerms,
  }) {
    return MessageEvidenceTextMatchIdsProvider(
      scope: scope,
      query: query,
      mode: mode,
    );
  }

  @override
  MessageEvidenceTextMatchIdsProvider getProviderOverride(
    covariant MessageEvidenceTextMatchIdsProvider provider,
  ) {
    return call(
      scope: provider.scope,
      query: provider.query,
      mode: provider.mode,
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
  String? get name => r'messageEvidenceTextMatchIdsProvider';
}

/// See also [messageEvidenceTextMatchIds].
class MessageEvidenceTextMatchIdsProvider
    extends AutoDisposeFutureProvider<List<int>> {
  /// See also [messageEvidenceTextMatchIds].
  MessageEvidenceTextMatchIdsProvider({
    required MessageEvidenceScope scope,
    required String query,
    MessageEvidenceSearchMode mode = MessageEvidenceSearchMode.allTerms,
  }) : this._internal(
         (ref) => messageEvidenceTextMatchIds(
           ref as MessageEvidenceTextMatchIdsRef,
           scope: scope,
           query: query,
           mode: mode,
         ),
         from: messageEvidenceTextMatchIdsProvider,
         name: r'messageEvidenceTextMatchIdsProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$messageEvidenceTextMatchIdsHash,
         dependencies: MessageEvidenceTextMatchIdsFamily._dependencies,
         allTransitiveDependencies:
             MessageEvidenceTextMatchIdsFamily._allTransitiveDependencies,
         scope: scope,
         query: query,
         mode: mode,
       );

  MessageEvidenceTextMatchIdsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scope,
    required this.query,
    required this.mode,
  }) : super.internal();

  final MessageEvidenceScope scope;
  final String query;
  final MessageEvidenceSearchMode mode;

  @override
  Override overrideWith(
    FutureOr<List<int>> Function(MessageEvidenceTextMatchIdsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessageEvidenceTextMatchIdsProvider._internal(
        (ref) => create(ref as MessageEvidenceTextMatchIdsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        scope: scope,
        query: query,
        mode: mode,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<int>> createElement() {
    return _MessageEvidenceTextMatchIdsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageEvidenceTextMatchIdsProvider &&
        other.scope == scope &&
        other.query == query &&
        other.mode == mode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scope.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);
    hash = _SystemHash.combine(hash, mode.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageEvidenceTextMatchIdsRef
    on AutoDisposeFutureProviderRef<List<int>> {
  /// The parameter `scope` of this provider.
  MessageEvidenceScope get scope;

  /// The parameter `query` of this provider.
  String get query;

  /// The parameter `mode` of this provider.
  MessageEvidenceSearchMode get mode;
}

class _MessageEvidenceTextMatchIdsProviderElement
    extends AutoDisposeFutureProviderElement<List<int>>
    with MessageEvidenceTextMatchIdsRef {
  _MessageEvidenceTextMatchIdsProviderElement(super.provider);

  @override
  MessageEvidenceScope get scope =>
      (origin as MessageEvidenceTextMatchIdsProvider).scope;
  @override
  String get query => (origin as MessageEvidenceTextMatchIdsProvider).query;
  @override
  MessageEvidenceSearchMode get mode =>
      (origin as MessageEvidenceTextMatchIdsProvider).mode;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
