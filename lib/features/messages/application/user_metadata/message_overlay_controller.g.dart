// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_overlay_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageOverlayHash() => r'0cef6ce2b9384778fe17c4ee1c56c302d4915ff3';

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

abstract class _$MessageOverlay
    extends BuildlessAutoDisposeAsyncNotifier<MessageOverlayState> {
  late final int messageSsId;

  FutureOr<MessageOverlayState> build(int messageSsId);
}

/// Graph-keyed controller for message user intent.
///
/// This is the graph-era application boundary. It accepts canonical
/// `message_ss_id` values and delegates old overlay-key compatibility to the
/// infrastructure bridge.
///
/// Copied from [MessageOverlay].
@ProviderFor(MessageOverlay)
const messageOverlayProvider = MessageOverlayFamily();

/// Graph-keyed controller for message user intent.
///
/// This is the graph-era application boundary. It accepts canonical
/// `message_ss_id` values and delegates old overlay-key compatibility to the
/// infrastructure bridge.
///
/// Copied from [MessageOverlay].
class MessageOverlayFamily extends Family<AsyncValue<MessageOverlayState>> {
  /// Graph-keyed controller for message user intent.
  ///
  /// This is the graph-era application boundary. It accepts canonical
  /// `message_ss_id` values and delegates old overlay-key compatibility to the
  /// infrastructure bridge.
  ///
  /// Copied from [MessageOverlay].
  const MessageOverlayFamily();

  /// Graph-keyed controller for message user intent.
  ///
  /// This is the graph-era application boundary. It accepts canonical
  /// `message_ss_id` values and delegates old overlay-key compatibility to the
  /// infrastructure bridge.
  ///
  /// Copied from [MessageOverlay].
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

/// Graph-keyed controller for message user intent.
///
/// This is the graph-era application boundary. It accepts canonical
/// `message_ss_id` values and delegates old overlay-key compatibility to the
/// infrastructure bridge.
///
/// Copied from [MessageOverlay].
class MessageOverlayProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          MessageOverlay,
          MessageOverlayState
        > {
  /// Graph-keyed controller for message user intent.
  ///
  /// This is the graph-era application boundary. It accepts canonical
  /// `message_ss_id` values and delegates old overlay-key compatibility to the
  /// infrastructure bridge.
  ///
  /// Copied from [MessageOverlay].
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
