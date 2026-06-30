// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handle_display_name_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$handleDisplayNameReaderHash() =>
    r'51bbb68ccdc067ef0bbd425a7cbdf9ba6bcde86a';

/// See also [handleDisplayNameReader].
@ProviderFor(handleDisplayNameReader)
final handleDisplayNameReaderProvider =
    AutoDisposeFutureProvider<HandleDisplayNameReader>.internal(
      handleDisplayNameReader,
      name: r'handleDisplayNameReaderProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$handleDisplayNameReaderHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HandleDisplayNameReaderRef =
    AutoDisposeFutureProviderRef<HandleDisplayNameReader>;
String _$handleDisplayNameHash() => r'f6685677a3f13d53d52bf64bc8f48ca41c82000e';

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

/// See also [handleDisplayName].
@ProviderFor(handleDisplayName)
const handleDisplayNameProvider = HandleDisplayNameFamily();

/// See also [handleDisplayName].
class HandleDisplayNameFamily extends Family<AsyncValue<String>> {
  /// See also [handleDisplayName].
  const HandleDisplayNameFamily();

  /// See also [handleDisplayName].
  HandleDisplayNameProvider call({required int handleId}) {
    return HandleDisplayNameProvider(handleId: handleId);
  }

  @override
  HandleDisplayNameProvider getProviderOverride(
    covariant HandleDisplayNameProvider provider,
  ) {
    return call(handleId: provider.handleId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'handleDisplayNameProvider';
}

/// See also [handleDisplayName].
class HandleDisplayNameProvider extends AutoDisposeFutureProvider<String> {
  /// See also [handleDisplayName].
  HandleDisplayNameProvider({required int handleId})
    : this._internal(
        (ref) =>
            handleDisplayName(ref as HandleDisplayNameRef, handleId: handleId),
        from: handleDisplayNameProvider,
        name: r'handleDisplayNameProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$handleDisplayNameHash,
        dependencies: HandleDisplayNameFamily._dependencies,
        allTransitiveDependencies:
            HandleDisplayNameFamily._allTransitiveDependencies,
        handleId: handleId,
      );

  HandleDisplayNameProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.handleId,
  }) : super.internal();

  final int handleId;

  @override
  Override overrideWith(
    FutureOr<String> Function(HandleDisplayNameRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HandleDisplayNameProvider._internal(
        (ref) => create(ref as HandleDisplayNameRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        handleId: handleId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String> createElement() {
    return _HandleDisplayNameProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HandleDisplayNameProvider && other.handleId == handleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, handleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HandleDisplayNameRef on AutoDisposeFutureProviderRef<String> {
  /// The parameter `handleId` of this provider.
  int get handleId;
}

class _HandleDisplayNameProviderElement
    extends AutoDisposeFutureProviderElement<String>
    with HandleDisplayNameRef {
  _HandleDisplayNameProviderElement(super.provider);

  @override
  int get handleId => (origin as HandleDisplayNameProvider).handleId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
