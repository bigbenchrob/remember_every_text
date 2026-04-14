// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_user_metadata_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageTagSuggestionsHash() =>
    r'5669c6c285ce67b597a3c6fc88f788fb883e12ea';

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

/// See also [messageTagSuggestions].
@ProviderFor(messageTagSuggestions)
const messageTagSuggestionsProvider = MessageTagSuggestionsFamily();

/// See also [messageTagSuggestions].
class MessageTagSuggestionsFamily extends Family<AsyncValue<List<String>>> {
  /// See also [messageTagSuggestions].
  const MessageTagSuggestionsFamily();

  /// See also [messageTagSuggestions].
  MessageTagSuggestionsProvider call({String query = ''}) {
    return MessageTagSuggestionsProvider(query: query);
  }

  @override
  MessageTagSuggestionsProvider getProviderOverride(
    covariant MessageTagSuggestionsProvider provider,
  ) {
    return call(query: provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messageTagSuggestionsProvider';
}

/// See also [messageTagSuggestions].
class MessageTagSuggestionsProvider
    extends AutoDisposeFutureProvider<List<String>> {
  /// See also [messageTagSuggestions].
  MessageTagSuggestionsProvider({String query = ''})
    : this._internal(
        (ref) => messageTagSuggestions(
          ref as MessageTagSuggestionsRef,
          query: query,
        ),
        from: messageTagSuggestionsProvider,
        name: r'messageTagSuggestionsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messageTagSuggestionsHash,
        dependencies: MessageTagSuggestionsFamily._dependencies,
        allTransitiveDependencies:
            MessageTagSuggestionsFamily._allTransitiveDependencies,
        query: query,
      );

  MessageTagSuggestionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<String>> Function(MessageTagSuggestionsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessageTagSuggestionsProvider._internal(
        (ref) => create(ref as MessageTagSuggestionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<String>> createElement() {
    return _MessageTagSuggestionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageTagSuggestionsProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageTagSuggestionsRef on AutoDisposeFutureProviderRef<List<String>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _MessageTagSuggestionsProviderElement
    extends AutoDisposeFutureProviderElement<List<String>>
    with MessageTagSuggestionsRef {
  _MessageTagSuggestionsProviderElement(super.provider);

  @override
  String get query => (origin as MessageTagSuggestionsProvider).query;
}

String _$messageUserMetadataControllerHash() =>
    r'e984178286ae268ca60ac8914215baf190d69fa9';

abstract class _$MessageUserMetadataController
    extends BuildlessAutoDisposeAsyncNotifier<MessageUserMetadata> {
  late final String messageGuid;

  FutureOr<MessageUserMetadata> build({required String messageGuid});
}

/// See also [MessageUserMetadataController].
@ProviderFor(MessageUserMetadataController)
const messageUserMetadataControllerProvider =
    MessageUserMetadataControllerFamily();

/// See also [MessageUserMetadataController].
class MessageUserMetadataControllerFamily
    extends Family<AsyncValue<MessageUserMetadata>> {
  /// See also [MessageUserMetadataController].
  const MessageUserMetadataControllerFamily();

  /// See also [MessageUserMetadataController].
  MessageUserMetadataControllerProvider call({required String messageGuid}) {
    return MessageUserMetadataControllerProvider(messageGuid: messageGuid);
  }

  @override
  MessageUserMetadataControllerProvider getProviderOverride(
    covariant MessageUserMetadataControllerProvider provider,
  ) {
    return call(messageGuid: provider.messageGuid);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messageUserMetadataControllerProvider';
}

/// See also [MessageUserMetadataController].
class MessageUserMetadataControllerProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          MessageUserMetadataController,
          MessageUserMetadata
        > {
  /// See also [MessageUserMetadataController].
  MessageUserMetadataControllerProvider({required String messageGuid})
    : this._internal(
        () => MessageUserMetadataController()..messageGuid = messageGuid,
        from: messageUserMetadataControllerProvider,
        name: r'messageUserMetadataControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messageUserMetadataControllerHash,
        dependencies: MessageUserMetadataControllerFamily._dependencies,
        allTransitiveDependencies:
            MessageUserMetadataControllerFamily._allTransitiveDependencies,
        messageGuid: messageGuid,
      );

  MessageUserMetadataControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.messageGuid,
  }) : super.internal();

  final String messageGuid;

  @override
  FutureOr<MessageUserMetadata> runNotifierBuild(
    covariant MessageUserMetadataController notifier,
  ) {
    return notifier.build(messageGuid: messageGuid);
  }

  @override
  Override overrideWith(MessageUserMetadataController Function() create) {
    return ProviderOverride(
      origin: this,
      override: MessageUserMetadataControllerProvider._internal(
        () => create()..messageGuid = messageGuid,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        messageGuid: messageGuid,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    MessageUserMetadataController,
    MessageUserMetadata
  >
  createElement() {
    return _MessageUserMetadataControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageUserMetadataControllerProvider &&
        other.messageGuid == messageGuid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, messageGuid.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageUserMetadataControllerRef
    on AutoDisposeAsyncNotifierProviderRef<MessageUserMetadata> {
  /// The parameter `messageGuid` of this provider.
  String get messageGuid;
}

class _MessageUserMetadataControllerProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          MessageUserMetadataController,
          MessageUserMetadata
        >
    with MessageUserMetadataControllerRef {
  _MessageUserMetadataControllerProviderElement(super.provider);

  @override
  String get messageGuid =>
      (origin as MessageUserMetadataControllerProvider).messageGuid;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
