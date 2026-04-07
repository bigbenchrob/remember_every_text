// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_timeline_index_coordinator_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageTimelineIndexCoordinatorHash() =>
    r'e49e32a2c07c232c371f59db6b075aaa781ddb91';

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

abstract class _$MessageTimelineIndexCoordinator
    extends BuildlessAutoDisposeNotifier<MessageTimelineIndexCoordinatorState> {
  late final MessageTimelineScope scope;

  MessageTimelineIndexCoordinatorState build({
    required MessageTimelineScope scope,
  });
}

/// See also [MessageTimelineIndexCoordinator].
@ProviderFor(MessageTimelineIndexCoordinator)
const messageTimelineIndexCoordinatorProvider =
    MessageTimelineIndexCoordinatorFamily();

/// See also [MessageTimelineIndexCoordinator].
class MessageTimelineIndexCoordinatorFamily
    extends Family<MessageTimelineIndexCoordinatorState> {
  /// See also [MessageTimelineIndexCoordinator].
  const MessageTimelineIndexCoordinatorFamily();

  /// See also [MessageTimelineIndexCoordinator].
  MessageTimelineIndexCoordinatorProvider call({
    required MessageTimelineScope scope,
  }) {
    return MessageTimelineIndexCoordinatorProvider(scope: scope);
  }

  @override
  MessageTimelineIndexCoordinatorProvider getProviderOverride(
    covariant MessageTimelineIndexCoordinatorProvider provider,
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
  String? get name => r'messageTimelineIndexCoordinatorProvider';
}

/// See also [MessageTimelineIndexCoordinator].
class MessageTimelineIndexCoordinatorProvider
    extends
        AutoDisposeNotifierProviderImpl<
          MessageTimelineIndexCoordinator,
          MessageTimelineIndexCoordinatorState
        > {
  /// See also [MessageTimelineIndexCoordinator].
  MessageTimelineIndexCoordinatorProvider({required MessageTimelineScope scope})
    : this._internal(
        () => MessageTimelineIndexCoordinator()..scope = scope,
        from: messageTimelineIndexCoordinatorProvider,
        name: r'messageTimelineIndexCoordinatorProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messageTimelineIndexCoordinatorHash,
        dependencies: MessageTimelineIndexCoordinatorFamily._dependencies,
        allTransitiveDependencies:
            MessageTimelineIndexCoordinatorFamily._allTransitiveDependencies,
        scope: scope,
      );

  MessageTimelineIndexCoordinatorProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scope,
  }) : super.internal();

  final MessageTimelineScope scope;

  @override
  MessageTimelineIndexCoordinatorState runNotifierBuild(
    covariant MessageTimelineIndexCoordinator notifier,
  ) {
    return notifier.build(scope: scope);
  }

  @override
  Override overrideWith(MessageTimelineIndexCoordinator Function() create) {
    return ProviderOverride(
      origin: this,
      override: MessageTimelineIndexCoordinatorProvider._internal(
        () => create()..scope = scope,
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
  AutoDisposeNotifierProviderElement<
    MessageTimelineIndexCoordinator,
    MessageTimelineIndexCoordinatorState
  >
  createElement() {
    return _MessageTimelineIndexCoordinatorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageTimelineIndexCoordinatorProvider &&
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
mixin MessageTimelineIndexCoordinatorRef
    on AutoDisposeNotifierProviderRef<MessageTimelineIndexCoordinatorState> {
  /// The parameter `scope` of this provider.
  MessageTimelineScope get scope;
}

class _MessageTimelineIndexCoordinatorProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          MessageTimelineIndexCoordinator,
          MessageTimelineIndexCoordinatorState
        >
    with MessageTimelineIndexCoordinatorRef {
  _MessageTimelineIndexCoordinatorProviderElement(super.provider);

  @override
  MessageTimelineScope get scope =>
      (origin as MessageTimelineIndexCoordinatorProvider).scope;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
