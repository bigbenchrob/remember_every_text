// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handle_lens_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$handleLensSessionHash() => r'2423e3cde8cb8aae8cc786c1f04b7704d4eacabe';

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

abstract class _$HandleLensSession
    extends BuildlessNotifier<HandleLensSessionState> {
  late final int handleId;

  HandleLensSessionState build({required int handleId});
}

/// Owns the interaction state for one unfamiliar-source evidence lens.
///
/// Copied from [HandleLensSession].
@ProviderFor(HandleLensSession)
const handleLensSessionProvider = HandleLensSessionFamily();

/// Owns the interaction state for one unfamiliar-source evidence lens.
///
/// Copied from [HandleLensSession].
class HandleLensSessionFamily extends Family<HandleLensSessionState> {
  /// Owns the interaction state for one unfamiliar-source evidence lens.
  ///
  /// Copied from [HandleLensSession].
  const HandleLensSessionFamily();

  /// Owns the interaction state for one unfamiliar-source evidence lens.
  ///
  /// Copied from [HandleLensSession].
  HandleLensSessionProvider call({required int handleId}) {
    return HandleLensSessionProvider(handleId: handleId);
  }

  @override
  HandleLensSessionProvider getProviderOverride(
    covariant HandleLensSessionProvider provider,
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
  String? get name => r'handleLensSessionProvider';
}

/// Owns the interaction state for one unfamiliar-source evidence lens.
///
/// Copied from [HandleLensSession].
class HandleLensSessionProvider
    extends NotifierProviderImpl<HandleLensSession, HandleLensSessionState> {
  /// Owns the interaction state for one unfamiliar-source evidence lens.
  ///
  /// Copied from [HandleLensSession].
  HandleLensSessionProvider({required int handleId})
    : this._internal(
        () => HandleLensSession()..handleId = handleId,
        from: handleLensSessionProvider,
        name: r'handleLensSessionProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$handleLensSessionHash,
        dependencies: HandleLensSessionFamily._dependencies,
        allTransitiveDependencies:
            HandleLensSessionFamily._allTransitiveDependencies,
        handleId: handleId,
      );

  HandleLensSessionProvider._internal(
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
  HandleLensSessionState runNotifierBuild(
    covariant HandleLensSession notifier,
  ) {
    return notifier.build(handleId: handleId);
  }

  @override
  Override overrideWith(HandleLensSession Function() create) {
    return ProviderOverride(
      origin: this,
      override: HandleLensSessionProvider._internal(
        () => create()..handleId = handleId,
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
  NotifierProviderElement<HandleLensSession, HandleLensSessionState>
  createElement() {
    return _HandleLensSessionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HandleLensSessionProvider && other.handleId == handleId;
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
mixin HandleLensSessionRef on NotifierProviderRef<HandleLensSessionState> {
  /// The parameter `handleId` of this provider.
  int get handleId;
}

class _HandleLensSessionProviderElement
    extends NotifierProviderElement<HandleLensSession, HandleLensSessionState>
    with HandleLensSessionRef {
  _HandleLensSessionProviderElement(super.provider);

  @override
  int get handleId => (origin as HandleLensSessionProvider).handleId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
