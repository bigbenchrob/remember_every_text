// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_grouping_metadata_by_ordinal_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageGroupingMetadataByTimelineOrdinalHash() =>
    r'4787703b731b6d0608ee69e7e1eb5fa40cff3c84';

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

/// See also [messageGroupingMetadataByTimelineOrdinal].
@ProviderFor(messageGroupingMetadataByTimelineOrdinal)
const messageGroupingMetadataByTimelineOrdinalProvider =
    MessageGroupingMetadataByTimelineOrdinalFamily();

/// See also [messageGroupingMetadataByTimelineOrdinal].
class MessageGroupingMetadataByTimelineOrdinalFamily
    extends Family<AsyncValue<MessageGroupingMetadata?>> {
  /// See also [messageGroupingMetadataByTimelineOrdinal].
  const MessageGroupingMetadataByTimelineOrdinalFamily();

  /// See also [messageGroupingMetadataByTimelineOrdinal].
  MessageGroupingMetadataByTimelineOrdinalProvider call({
    required MessageTimelineScope scope,
    required int ordinal,
  }) {
    return MessageGroupingMetadataByTimelineOrdinalProvider(
      scope: scope,
      ordinal: ordinal,
    );
  }

  @override
  MessageGroupingMetadataByTimelineOrdinalProvider getProviderOverride(
    covariant MessageGroupingMetadataByTimelineOrdinalProvider provider,
  ) {
    return call(scope: provider.scope, ordinal: provider.ordinal);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messageGroupingMetadataByTimelineOrdinalProvider';
}

/// See also [messageGroupingMetadataByTimelineOrdinal].
class MessageGroupingMetadataByTimelineOrdinalProvider
    extends AutoDisposeFutureProvider<MessageGroupingMetadata?> {
  /// See also [messageGroupingMetadataByTimelineOrdinal].
  MessageGroupingMetadataByTimelineOrdinalProvider({
    required MessageTimelineScope scope,
    required int ordinal,
  }) : this._internal(
         (ref) => messageGroupingMetadataByTimelineOrdinal(
           ref as MessageGroupingMetadataByTimelineOrdinalRef,
           scope: scope,
           ordinal: ordinal,
         ),
         from: messageGroupingMetadataByTimelineOrdinalProvider,
         name: r'messageGroupingMetadataByTimelineOrdinalProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$messageGroupingMetadataByTimelineOrdinalHash,
         dependencies:
             MessageGroupingMetadataByTimelineOrdinalFamily._dependencies,
         allTransitiveDependencies:
             MessageGroupingMetadataByTimelineOrdinalFamily
                 ._allTransitiveDependencies,
         scope: scope,
         ordinal: ordinal,
       );

  MessageGroupingMetadataByTimelineOrdinalProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scope,
    required this.ordinal,
  }) : super.internal();

  final MessageTimelineScope scope;
  final int ordinal;

  @override
  Override overrideWith(
    FutureOr<MessageGroupingMetadata?> Function(
      MessageGroupingMetadataByTimelineOrdinalRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessageGroupingMetadataByTimelineOrdinalProvider._internal(
        (ref) => create(ref as MessageGroupingMetadataByTimelineOrdinalRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        scope: scope,
        ordinal: ordinal,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<MessageGroupingMetadata?> createElement() {
    return _MessageGroupingMetadataByTimelineOrdinalProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageGroupingMetadataByTimelineOrdinalProvider &&
        other.scope == scope &&
        other.ordinal == ordinal;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scope.hashCode);
    hash = _SystemHash.combine(hash, ordinal.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageGroupingMetadataByTimelineOrdinalRef
    on AutoDisposeFutureProviderRef<MessageGroupingMetadata?> {
  /// The parameter `scope` of this provider.
  MessageTimelineScope get scope;

  /// The parameter `ordinal` of this provider.
  int get ordinal;
}

class _MessageGroupingMetadataByTimelineOrdinalProviderElement
    extends AutoDisposeFutureProviderElement<MessageGroupingMetadata?>
    with MessageGroupingMetadataByTimelineOrdinalRef {
  _MessageGroupingMetadataByTimelineOrdinalProviderElement(super.provider);

  @override
  MessageTimelineScope get scope =>
      (origin as MessageGroupingMetadataByTimelineOrdinalProvider).scope;
  @override
  int get ordinal =>
      (origin as MessageGroupingMetadataByTimelineOrdinalProvider).ordinal;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
