// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_evidence_spine_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageEvidenceTimelineSkeletonHash() =>
    r'b5dfba0e198c6f19a4177574ed8946e7bb081462';

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

String _$graphMessageEvidenceRowHash() =>
    r'3eb451f9aa11c5420424a535def0b9e2d08d27fe';

/// See also [graphMessageEvidenceRow].
@ProviderFor(graphMessageEvidenceRow)
const graphMessageEvidenceRowProvider = GraphMessageEvidenceRowFamily();

/// See also [graphMessageEvidenceRow].
class GraphMessageEvidenceRowFamily
    extends Family<AsyncValue<ConversationMessage?>> {
  /// See also [graphMessageEvidenceRow].
  const GraphMessageEvidenceRowFamily();

  /// See also [graphMessageEvidenceRow].
  GraphMessageEvidenceRowProvider call({
    required MessageEvidenceScope scope,
    required int messageId,
  }) {
    return GraphMessageEvidenceRowProvider(scope: scope, messageId: messageId);
  }

  @override
  GraphMessageEvidenceRowProvider getProviderOverride(
    covariant GraphMessageEvidenceRowProvider provider,
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
  String? get name => r'graphMessageEvidenceRowProvider';
}

/// See also [graphMessageEvidenceRow].
class GraphMessageEvidenceRowProvider
    extends AutoDisposeFutureProvider<ConversationMessage?> {
  /// See also [graphMessageEvidenceRow].
  GraphMessageEvidenceRowProvider({
    required MessageEvidenceScope scope,
    required int messageId,
  }) : this._internal(
         (ref) => graphMessageEvidenceRow(
           ref as GraphMessageEvidenceRowRef,
           scope: scope,
           messageId: messageId,
         ),
         from: graphMessageEvidenceRowProvider,
         name: r'graphMessageEvidenceRowProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$graphMessageEvidenceRowHash,
         dependencies: GraphMessageEvidenceRowFamily._dependencies,
         allTransitiveDependencies:
             GraphMessageEvidenceRowFamily._allTransitiveDependencies,
         scope: scope,
         messageId: messageId,
       );

  GraphMessageEvidenceRowProvider._internal(
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
    FutureOr<ConversationMessage?> Function(GraphMessageEvidenceRowRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GraphMessageEvidenceRowProvider._internal(
        (ref) => create(ref as GraphMessageEvidenceRowRef),
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
  AutoDisposeFutureProviderElement<ConversationMessage?> createElement() {
    return _GraphMessageEvidenceRowProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GraphMessageEvidenceRowProvider &&
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
mixin GraphMessageEvidenceRowRef
    on AutoDisposeFutureProviderRef<ConversationMessage?> {
  /// The parameter `scope` of this provider.
  MessageEvidenceScope get scope;

  /// The parameter `messageId` of this provider.
  int get messageId;
}

class _GraphMessageEvidenceRowProviderElement
    extends AutoDisposeFutureProviderElement<ConversationMessage?>
    with GraphMessageEvidenceRowRef {
  _GraphMessageEvidenceRowProviderElement(super.provider);

  @override
  MessageEvidenceScope get scope =>
      (origin as GraphMessageEvidenceRowProvider).scope;
  @override
  int get messageId => (origin as GraphMessageEvidenceRowProvider).messageId;
}

String _$messageEvidenceAttachmentsHash() =>
    r'ac5e7fc77d2b4c4e366145167257cc2809df9f99';

/// See also [messageEvidenceAttachments].
@ProviderFor(messageEvidenceAttachments)
const messageEvidenceAttachmentsProvider = MessageEvidenceAttachmentsFamily();

/// See also [messageEvidenceAttachments].
class MessageEvidenceAttachmentsFamily
    extends Family<AsyncValue<List<GraphAttachmentEvidence>>> {
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
    extends AutoDisposeFutureProvider<List<GraphAttachmentEvidence>> {
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
    FutureOr<List<GraphAttachmentEvidence>> Function(
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
  AutoDisposeFutureProviderElement<List<GraphAttachmentEvidence>>
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
    on AutoDisposeFutureProviderRef<List<GraphAttachmentEvidence>> {
  /// The parameter `scope` of this provider.
  MessageEvidenceScope get scope;

  /// The parameter `messageId` of this provider.
  int get messageId;
}

class _MessageEvidenceAttachmentsProviderElement
    extends AutoDisposeFutureProviderElement<List<GraphAttachmentEvidence>>
    with MessageEvidenceAttachmentsRef {
  _MessageEvidenceAttachmentsProviderElement(super.provider);

  @override
  MessageEvidenceScope get scope =>
      (origin as MessageEvidenceAttachmentsProvider).scope;
  @override
  int get messageId => (origin as MessageEvidenceAttachmentsProvider).messageId;
}

String _$messageEvidenceTextMatchIdsHash() =>
    r'd666b11bd8807a69a6dc4ceb70d27c3cdcd85827';

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
  }) {
    return MessageEvidenceTextMatchIdsProvider(scope: scope, query: query);
  }

  @override
  MessageEvidenceTextMatchIdsProvider getProviderOverride(
    covariant MessageEvidenceTextMatchIdsProvider provider,
  ) {
    return call(scope: provider.scope, query: provider.query);
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
  }) : this._internal(
         (ref) => messageEvidenceTextMatchIds(
           ref as MessageEvidenceTextMatchIdsRef,
           scope: scope,
           query: query,
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
  }) : super.internal();

  final MessageEvidenceScope scope;
  final String query;

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
        other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scope.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

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
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
