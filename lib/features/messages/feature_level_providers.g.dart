// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_level_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$conversationSignaturePreferencesStoreHash() =>
    r'694e15c7511d359dc17b41096233c4b8e3fb5b77';

/// See also [conversationSignaturePreferencesStore].
@ProviderFor(conversationSignaturePreferencesStore)
final conversationSignaturePreferencesStoreProvider =
    AutoDisposeFutureProvider<ConversationSignaturePreferencesStore>.internal(
      conversationSignaturePreferencesStore,
      name: r'conversationSignaturePreferencesStoreProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$conversationSignaturePreferencesStoreHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConversationSignaturePreferencesStoreRef =
    AutoDisposeFutureProviderRef<ConversationSignaturePreferencesStore>;
String _$messageOverlayRepositoryHash() =>
    r'ec23a04cd482f5ede89fe62066cac4557275448b';

/// See also [messageOverlayRepository].
@ProviderFor(messageOverlayRepository)
final messageOverlayRepositoryProvider =
    AutoDisposeFutureProvider<MessageOverlayRepository>.internal(
      messageOverlayRepository,
      name: r'messageOverlayRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$messageOverlayRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MessageOverlayRepositoryRef =
    AutoDisposeFutureProviderRef<MessageOverlayRepository>;
String _$recoveredMessageEvidenceRepositoryHash() =>
    r'8ad8a79c3c02d098884e2d6bea2070527533c2a4';

/// See also [recoveredMessageEvidenceRepository].
@ProviderFor(recoveredMessageEvidenceRepository)
final recoveredMessageEvidenceRepositoryProvider =
    AutoDisposeFutureProvider<RecoveredMessageEvidenceRepository>.internal(
      recoveredMessageEvidenceRepository,
      name: r'recoveredMessageEvidenceRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recoveredMessageEvidenceRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecoveredMessageEvidenceRepositoryRef =
    AutoDisposeFutureProviderRef<RecoveredMessageEvidenceRepository>;
String _$recoveredUnlinkedMessagesHash() =>
    r'7ba659a1ee3cd785f307691037ad14465ec53d02';

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

/// See also [recoveredUnlinkedMessages].
@ProviderFor(recoveredUnlinkedMessages)
const recoveredUnlinkedMessagesProvider = RecoveredUnlinkedMessagesFamily();

/// See also [recoveredUnlinkedMessages].
class RecoveredUnlinkedMessagesFamily
    extends Family<AsyncValue<List<RecoveredUnlinkedMessageItem>>> {
  /// See also [recoveredUnlinkedMessages].
  const RecoveredUnlinkedMessagesFamily();

  /// See also [recoveredUnlinkedMessages].
  RecoveredUnlinkedMessagesProvider call({int? contactId}) {
    return RecoveredUnlinkedMessagesProvider(contactId: contactId);
  }

  @override
  RecoveredUnlinkedMessagesProvider getProviderOverride(
    covariant RecoveredUnlinkedMessagesProvider provider,
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
  String? get name => r'recoveredUnlinkedMessagesProvider';
}

/// See also [recoveredUnlinkedMessages].
class RecoveredUnlinkedMessagesProvider
    extends AutoDisposeStreamProvider<List<RecoveredUnlinkedMessageItem>> {
  /// See also [recoveredUnlinkedMessages].
  RecoveredUnlinkedMessagesProvider({int? contactId})
    : this._internal(
        (ref) => recoveredUnlinkedMessages(
          ref as RecoveredUnlinkedMessagesRef,
          contactId: contactId,
        ),
        from: recoveredUnlinkedMessagesProvider,
        name: r'recoveredUnlinkedMessagesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$recoveredUnlinkedMessagesHash,
        dependencies: RecoveredUnlinkedMessagesFamily._dependencies,
        allTransitiveDependencies:
            RecoveredUnlinkedMessagesFamily._allTransitiveDependencies,
        contactId: contactId,
      );

  RecoveredUnlinkedMessagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contactId,
  }) : super.internal();

  final int? contactId;

  @override
  Override overrideWith(
    Stream<List<RecoveredUnlinkedMessageItem>> Function(
      RecoveredUnlinkedMessagesRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecoveredUnlinkedMessagesProvider._internal(
        (ref) => create(ref as RecoveredUnlinkedMessagesRef),
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
  AutoDisposeStreamProviderElement<List<RecoveredUnlinkedMessageItem>>
  createElement() {
    return _RecoveredUnlinkedMessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecoveredUnlinkedMessagesProvider &&
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
mixin RecoveredUnlinkedMessagesRef
    on AutoDisposeStreamProviderRef<List<RecoveredUnlinkedMessageItem>> {
  /// The parameter `contactId` of this provider.
  int? get contactId;
}

class _RecoveredUnlinkedMessagesProviderElement
    extends AutoDisposeStreamProviderElement<List<RecoveredUnlinkedMessageItem>>
    with RecoveredUnlinkedMessagesRef {
  _RecoveredUnlinkedMessagesProviderElement(super.provider);

  @override
  int? get contactId => (origin as RecoveredUnlinkedMessagesProvider).contactId;
}

String _$messageOverlayHash() => r'c9c6f88aa7d091a511bdce419f460722866dc4dd';

abstract class _$MessageOverlay
    extends BuildlessAutoDisposeAsyncNotifier<MessageOverlayState> {
  late final int messageSsId;

  FutureOr<MessageOverlayState> build(int messageSsId);
}

/// See also [MessageOverlay].
@ProviderFor(MessageOverlay)
const messageOverlayProvider = MessageOverlayFamily();

/// See also [MessageOverlay].
class MessageOverlayFamily extends Family<AsyncValue<MessageOverlayState>> {
  /// See also [MessageOverlay].
  const MessageOverlayFamily();

  /// See also [MessageOverlay].
  MessageOverlayProvider call(int messageSsId) {
    return MessageOverlayProvider(messageSsId);
  }

  @override
  MessageOverlayProvider getProviderOverride(
    covariant MessageOverlayProvider provider,
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
  String? get name => r'messageOverlayProvider';
}

/// See also [MessageOverlay].
class MessageOverlayProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          MessageOverlay,
          MessageOverlayState
        > {
  /// See also [MessageOverlay].
  MessageOverlayProvider(int messageSsId)
    : this._internal(
        () => MessageOverlay()..messageSsId = messageSsId,
        from: messageOverlayProvider,
        name: r'messageOverlayProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messageOverlayHash,
        dependencies: MessageOverlayFamily._dependencies,
        allTransitiveDependencies:
            MessageOverlayFamily._allTransitiveDependencies,
        messageSsId: messageSsId,
      );

  MessageOverlayProvider._internal(
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
  FutureOr<MessageOverlayState> runNotifierBuild(
    covariant MessageOverlay notifier,
  ) {
    return notifier.build(messageSsId);
  }

  @override
  Override overrideWith(MessageOverlay Function() create) {
    return ProviderOverride(
      origin: this,
      override: MessageOverlayProvider._internal(
        () => create()..messageSsId = messageSsId,
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
  AutoDisposeAsyncNotifierProviderElement<MessageOverlay, MessageOverlayState>
  createElement() {
    return _MessageOverlayProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageOverlayProvider && other.messageSsId == messageSsId;
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
mixin MessageOverlayRef
    on AutoDisposeAsyncNotifierProviderRef<MessageOverlayState> {
  /// The parameter `messageSsId` of this provider.
  int get messageSsId;
}

class _MessageOverlayProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          MessageOverlay,
          MessageOverlayState
        >
    with MessageOverlayRef {
  _MessageOverlayProviderElement(super.provider);

  @override
  int get messageSsId => (origin as MessageOverlayProvider).messageSsId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
