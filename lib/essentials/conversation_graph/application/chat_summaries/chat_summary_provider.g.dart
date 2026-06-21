// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_summary_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatSummariesHash() => r'381c5722cafc1fb89937b0c2c93fc4d72ebfb85b';

/// See also [chatSummaries].
@ProviderFor(chatSummaries)
final chatSummariesProvider =
    AutoDisposeFutureProvider<List<ChatSummary>>.internal(
      chatSummaries,
      name: r'chatSummariesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chatSummariesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChatSummariesRef = AutoDisposeFutureProviderRef<List<ChatSummary>>;
String _$chatSummarySanityCountsHash() =>
    r'f2f08361b7f9ff7e5dc603187d9c9d4145bf5023';

/// See also [chatSummarySanityCounts].
@ProviderFor(chatSummarySanityCounts)
final chatSummarySanityCountsProvider =
    AutoDisposeFutureProvider<ChatSummarySanityCounts>.internal(
      chatSummarySanityCounts,
      name: r'chatSummarySanityCountsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chatSummarySanityCountsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChatSummarySanityCountsRef =
    AutoDisposeFutureProviderRef<ChatSummarySanityCounts>;
String _$recentChatMessagesHash() =>
    r'7365995bea87d29f1bbf276b174632f004978662';

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

/// See also [recentChatMessages].
@ProviderFor(recentChatMessages)
const recentChatMessagesProvider = RecentChatMessagesFamily();

/// See also [recentChatMessages].
class RecentChatMessagesFamily
    extends Family<AsyncValue<List<RecentChatMessage>>> {
  /// See also [recentChatMessages].
  const RecentChatMessagesFamily();

  /// See also [recentChatMessages].
  RecentChatMessagesProvider call(int chatSsId) {
    return RecentChatMessagesProvider(chatSsId);
  }

  @override
  RecentChatMessagesProvider getProviderOverride(
    covariant RecentChatMessagesProvider provider,
  ) {
    return call(provider.chatSsId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recentChatMessagesProvider';
}

/// See also [recentChatMessages].
class RecentChatMessagesProvider
    extends AutoDisposeFutureProvider<List<RecentChatMessage>> {
  /// See also [recentChatMessages].
  RecentChatMessagesProvider(int chatSsId)
    : this._internal(
        (ref) => recentChatMessages(ref as RecentChatMessagesRef, chatSsId),
        from: recentChatMessagesProvider,
        name: r'recentChatMessagesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$recentChatMessagesHash,
        dependencies: RecentChatMessagesFamily._dependencies,
        allTransitiveDependencies:
            RecentChatMessagesFamily._allTransitiveDependencies,
        chatSsId: chatSsId,
      );

  RecentChatMessagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chatSsId,
  }) : super.internal();

  final int chatSsId;

  @override
  Override overrideWith(
    FutureOr<List<RecentChatMessage>> Function(RecentChatMessagesRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecentChatMessagesProvider._internal(
        (ref) => create(ref as RecentChatMessagesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chatSsId: chatSsId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<RecentChatMessage>> createElement() {
    return _RecentChatMessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecentChatMessagesProvider && other.chatSsId == chatSsId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chatSsId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RecentChatMessagesRef
    on AutoDisposeFutureProviderRef<List<RecentChatMessage>> {
  /// The parameter `chatSsId` of this provider.
  int get chatSsId;
}

class _RecentChatMessagesProviderElement
    extends AutoDisposeFutureProviderElement<List<RecentChatMessage>>
    with RecentChatMessagesRef {
  _RecentChatMessagesProviderElement(super.provider);

  @override
  int get chatSsId => (origin as RecentChatMessagesProvider).chatSsId;
}

String _$recentTextChatMessagesHash() =>
    r'c71d885466f9a93656f466002ff7f84643e2a7a8';

/// See also [recentTextChatMessages].
@ProviderFor(recentTextChatMessages)
const recentTextChatMessagesProvider = RecentTextChatMessagesFamily();

/// See also [recentTextChatMessages].
class RecentTextChatMessagesFamily
    extends Family<AsyncValue<List<RecentChatMessage>>> {
  /// See also [recentTextChatMessages].
  const RecentTextChatMessagesFamily();

  /// See also [recentTextChatMessages].
  RecentTextChatMessagesProvider call(int chatSsId) {
    return RecentTextChatMessagesProvider(chatSsId);
  }

  @override
  RecentTextChatMessagesProvider getProviderOverride(
    covariant RecentTextChatMessagesProvider provider,
  ) {
    return call(provider.chatSsId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recentTextChatMessagesProvider';
}

/// See also [recentTextChatMessages].
class RecentTextChatMessagesProvider
    extends AutoDisposeFutureProvider<List<RecentChatMessage>> {
  /// See also [recentTextChatMessages].
  RecentTextChatMessagesProvider(int chatSsId)
    : this._internal(
        (ref) =>
            recentTextChatMessages(ref as RecentTextChatMessagesRef, chatSsId),
        from: recentTextChatMessagesProvider,
        name: r'recentTextChatMessagesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$recentTextChatMessagesHash,
        dependencies: RecentTextChatMessagesFamily._dependencies,
        allTransitiveDependencies:
            RecentTextChatMessagesFamily._allTransitiveDependencies,
        chatSsId: chatSsId,
      );

  RecentTextChatMessagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chatSsId,
  }) : super.internal();

  final int chatSsId;

  @override
  Override overrideWith(
    FutureOr<List<RecentChatMessage>> Function(
      RecentTextChatMessagesRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecentTextChatMessagesProvider._internal(
        (ref) => create(ref as RecentTextChatMessagesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chatSsId: chatSsId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<RecentChatMessage>> createElement() {
    return _RecentTextChatMessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecentTextChatMessagesProvider &&
        other.chatSsId == chatSsId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chatSsId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RecentTextChatMessagesRef
    on AutoDisposeFutureProviderRef<List<RecentChatMessage>> {
  /// The parameter `chatSsId` of this provider.
  int get chatSsId;
}

class _RecentTextChatMessagesProviderElement
    extends AutoDisposeFutureProviderElement<List<RecentChatMessage>>
    with RecentTextChatMessagesRef {
  _RecentTextChatMessagesProviderElement(super.provider);

  @override
  int get chatSsId => (origin as RecentTextChatMessagesProvider).chatSsId;
}

String _$chatMessageTextStatsHash() =>
    r'5f54552d138aac81d29993fdcbdab8839c3e90b4';

/// See also [chatMessageTextStats].
@ProviderFor(chatMessageTextStats)
const chatMessageTextStatsProvider = ChatMessageTextStatsFamily();

/// See also [chatMessageTextStats].
class ChatMessageTextStatsFamily
    extends Family<AsyncValue<ChatMessageTextStats>> {
  /// See also [chatMessageTextStats].
  const ChatMessageTextStatsFamily();

  /// See also [chatMessageTextStats].
  ChatMessageTextStatsProvider call(int chatSsId) {
    return ChatMessageTextStatsProvider(chatSsId);
  }

  @override
  ChatMessageTextStatsProvider getProviderOverride(
    covariant ChatMessageTextStatsProvider provider,
  ) {
    return call(provider.chatSsId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chatMessageTextStatsProvider';
}

/// See also [chatMessageTextStats].
class ChatMessageTextStatsProvider
    extends AutoDisposeFutureProvider<ChatMessageTextStats> {
  /// See also [chatMessageTextStats].
  ChatMessageTextStatsProvider(int chatSsId)
    : this._internal(
        (ref) => chatMessageTextStats(ref as ChatMessageTextStatsRef, chatSsId),
        from: chatMessageTextStatsProvider,
        name: r'chatMessageTextStatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$chatMessageTextStatsHash,
        dependencies: ChatMessageTextStatsFamily._dependencies,
        allTransitiveDependencies:
            ChatMessageTextStatsFamily._allTransitiveDependencies,
        chatSsId: chatSsId,
      );

  ChatMessageTextStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chatSsId,
  }) : super.internal();

  final int chatSsId;

  @override
  Override overrideWith(
    FutureOr<ChatMessageTextStats> Function(ChatMessageTextStatsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChatMessageTextStatsProvider._internal(
        (ref) => create(ref as ChatMessageTextStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chatSsId: chatSsId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ChatMessageTextStats> createElement() {
    return _ChatMessageTextStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatMessageTextStatsProvider && other.chatSsId == chatSsId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chatSsId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChatMessageTextStatsRef
    on AutoDisposeFutureProviderRef<ChatMessageTextStats> {
  /// The parameter `chatSsId` of this provider.
  int get chatSsId;
}

class _ChatMessageTextStatsProviderElement
    extends AutoDisposeFutureProviderElement<ChatMessageTextStats>
    with ChatMessageTextStatsRef {
  _ChatMessageTextStatsProviderElement(super.provider);

  @override
  int get chatSsId => (origin as ChatMessageTextStatsProvider).chatSsId;
}

String _$chatAttachmentStatsHash() =>
    r'3349775e2e587672b832c0f9dd1af7f730f39ab7';

/// See also [chatAttachmentStats].
@ProviderFor(chatAttachmentStats)
const chatAttachmentStatsProvider = ChatAttachmentStatsFamily();

/// See also [chatAttachmentStats].
class ChatAttachmentStatsFamily
    extends Family<AsyncValue<ChatAttachmentStats>> {
  /// See also [chatAttachmentStats].
  const ChatAttachmentStatsFamily();

  /// See also [chatAttachmentStats].
  ChatAttachmentStatsProvider call(int chatSsId) {
    return ChatAttachmentStatsProvider(chatSsId);
  }

  @override
  ChatAttachmentStatsProvider getProviderOverride(
    covariant ChatAttachmentStatsProvider provider,
  ) {
    return call(provider.chatSsId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chatAttachmentStatsProvider';
}

/// See also [chatAttachmentStats].
class ChatAttachmentStatsProvider
    extends AutoDisposeFutureProvider<ChatAttachmentStats> {
  /// See also [chatAttachmentStats].
  ChatAttachmentStatsProvider(int chatSsId)
    : this._internal(
        (ref) => chatAttachmentStats(ref as ChatAttachmentStatsRef, chatSsId),
        from: chatAttachmentStatsProvider,
        name: r'chatAttachmentStatsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$chatAttachmentStatsHash,
        dependencies: ChatAttachmentStatsFamily._dependencies,
        allTransitiveDependencies:
            ChatAttachmentStatsFamily._allTransitiveDependencies,
        chatSsId: chatSsId,
      );

  ChatAttachmentStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chatSsId,
  }) : super.internal();

  final int chatSsId;

  @override
  Override overrideWith(
    FutureOr<ChatAttachmentStats> Function(ChatAttachmentStatsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChatAttachmentStatsProvider._internal(
        (ref) => create(ref as ChatAttachmentStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chatSsId: chatSsId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ChatAttachmentStats> createElement() {
    return _ChatAttachmentStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatAttachmentStatsProvider && other.chatSsId == chatSsId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chatSsId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChatAttachmentStatsRef
    on AutoDisposeFutureProviderRef<ChatAttachmentStats> {
  /// The parameter `chatSsId` of this provider.
  int get chatSsId;
}

class _ChatAttachmentStatsProviderElement
    extends AutoDisposeFutureProviderElement<ChatAttachmentStats>
    with ChatAttachmentStatsRef {
  _ChatAttachmentStatsProviderElement(super.provider);

  @override
  int get chatSsId => (origin as ChatAttachmentStatsProvider).chatSsId;
}

String _$messageAttachmentsHash() =>
    r'4911812086ae901c3bfcd6ce231609fd60924a83';

/// See also [messageAttachments].
@ProviderFor(messageAttachments)
const messageAttachmentsProvider = MessageAttachmentsFamily();

/// See also [messageAttachments].
class MessageAttachmentsFamily
    extends Family<AsyncValue<List<MessageAttachment>>> {
  /// See also [messageAttachments].
  const MessageAttachmentsFamily();

  /// See also [messageAttachments].
  MessageAttachmentsProvider call(int messageSsId) {
    return MessageAttachmentsProvider(messageSsId);
  }

  @override
  MessageAttachmentsProvider getProviderOverride(
    covariant MessageAttachmentsProvider provider,
  ) {
    return call(provider.messageSsId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messageAttachmentsProvider';
}

/// See also [messageAttachments].
class MessageAttachmentsProvider
    extends AutoDisposeFutureProvider<List<MessageAttachment>> {
  /// See also [messageAttachments].
  MessageAttachmentsProvider(int messageSsId)
    : this._internal(
        (ref) => messageAttachments(ref as MessageAttachmentsRef, messageSsId),
        from: messageAttachmentsProvider,
        name: r'messageAttachmentsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messageAttachmentsHash,
        dependencies: MessageAttachmentsFamily._dependencies,
        allTransitiveDependencies:
            MessageAttachmentsFamily._allTransitiveDependencies,
        messageSsId: messageSsId,
      );

  MessageAttachmentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.messageSsId,
  }) : super.internal();

  final int messageSsId;

  @override
  Override overrideWith(
    FutureOr<List<MessageAttachment>> Function(MessageAttachmentsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessageAttachmentsProvider._internal(
        (ref) => create(ref as MessageAttachmentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        messageSsId: messageSsId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MessageAttachment>> createElement() {
    return _MessageAttachmentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageAttachmentsProvider &&
        other.messageSsId == messageSsId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, messageSsId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageAttachmentsRef
    on AutoDisposeFutureProviderRef<List<MessageAttachment>> {
  /// The parameter `messageSsId` of this provider.
  int get messageSsId;
}

class _MessageAttachmentsProviderElement
    extends AutoDisposeFutureProviderElement<List<MessageAttachment>>
    with MessageAttachmentsRef {
  _MessageAttachmentsProviderElement(super.provider);

  @override
  int get messageSsId => (origin as MessageAttachmentsProvider).messageSsId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
