// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_messages_search_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$globalMessagesSearchSessionHash() =>
    r'128a151217c921d44c415ef9b7dbb49012b8a073';

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

abstract class _$GlobalMessagesSearchSession
    extends BuildlessAutoDisposeNotifier<GlobalMessagesSearchSessionState> {
  late final DateTime? monthAnchor;

  GlobalMessagesSearchSessionState build({DateTime? monthAnchor});
}

/// Owns one global-message Search interaction for the selected month context.
///
/// The month is a family key so changing the center-panel context preserves
/// the previous behavior of starting a fresh Search interaction.
///
/// Copied from [GlobalMessagesSearchSession].
@ProviderFor(GlobalMessagesSearchSession)
const globalMessagesSearchSessionProvider = GlobalMessagesSearchSessionFamily();

/// Owns one global-message Search interaction for the selected month context.
///
/// The month is a family key so changing the center-panel context preserves
/// the previous behavior of starting a fresh Search interaction.
///
/// Copied from [GlobalMessagesSearchSession].
class GlobalMessagesSearchSessionFamily
    extends Family<GlobalMessagesSearchSessionState> {
  /// Owns one global-message Search interaction for the selected month context.
  ///
  /// The month is a family key so changing the center-panel context preserves
  /// the previous behavior of starting a fresh Search interaction.
  ///
  /// Copied from [GlobalMessagesSearchSession].
  const GlobalMessagesSearchSessionFamily();

  /// Owns one global-message Search interaction for the selected month context.
  ///
  /// The month is a family key so changing the center-panel context preserves
  /// the previous behavior of starting a fresh Search interaction.
  ///
  /// Copied from [GlobalMessagesSearchSession].
  GlobalMessagesSearchSessionProvider call({DateTime? monthAnchor}) {
    return GlobalMessagesSearchSessionProvider(monthAnchor: monthAnchor);
  }

  @override
  GlobalMessagesSearchSessionProvider getProviderOverride(
    covariant GlobalMessagesSearchSessionProvider provider,
  ) {
    return call(monthAnchor: provider.monthAnchor);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'globalMessagesSearchSessionProvider';
}

/// Owns one global-message Search interaction for the selected month context.
///
/// The month is a family key so changing the center-panel context preserves
/// the previous behavior of starting a fresh Search interaction.
///
/// Copied from [GlobalMessagesSearchSession].
class GlobalMessagesSearchSessionProvider
    extends
        AutoDisposeNotifierProviderImpl<
          GlobalMessagesSearchSession,
          GlobalMessagesSearchSessionState
        > {
  /// Owns one global-message Search interaction for the selected month context.
  ///
  /// The month is a family key so changing the center-panel context preserves
  /// the previous behavior of starting a fresh Search interaction.
  ///
  /// Copied from [GlobalMessagesSearchSession].
  GlobalMessagesSearchSessionProvider({DateTime? monthAnchor})
    : this._internal(
        () => GlobalMessagesSearchSession()..monthAnchor = monthAnchor,
        from: globalMessagesSearchSessionProvider,
        name: r'globalMessagesSearchSessionProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$globalMessagesSearchSessionHash,
        dependencies: GlobalMessagesSearchSessionFamily._dependencies,
        allTransitiveDependencies:
            GlobalMessagesSearchSessionFamily._allTransitiveDependencies,
        monthAnchor: monthAnchor,
      );

  GlobalMessagesSearchSessionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.monthAnchor,
  }) : super.internal();

  final DateTime? monthAnchor;

  @override
  GlobalMessagesSearchSessionState runNotifierBuild(
    covariant GlobalMessagesSearchSession notifier,
  ) {
    return notifier.build(monthAnchor: monthAnchor);
  }

  @override
  Override overrideWith(GlobalMessagesSearchSession Function() create) {
    return ProviderOverride(
      origin: this,
      override: GlobalMessagesSearchSessionProvider._internal(
        () => create()..monthAnchor = monthAnchor,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        monthAnchor: monthAnchor,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<
    GlobalMessagesSearchSession,
    GlobalMessagesSearchSessionState
  >
  createElement() {
    return _GlobalMessagesSearchSessionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GlobalMessagesSearchSessionProvider &&
        other.monthAnchor == monthAnchor;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, monthAnchor.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GlobalMessagesSearchSessionRef
    on AutoDisposeNotifierProviderRef<GlobalMessagesSearchSessionState> {
  /// The parameter `monthAnchor` of this provider.
  DateTime? get monthAnchor;
}

class _GlobalMessagesSearchSessionProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          GlobalMessagesSearchSession,
          GlobalMessagesSearchSessionState
        >
    with GlobalMessagesSearchSessionRef {
  _GlobalMessagesSearchSessionProviderElement(super.provider);

  @override
  DateTime? get monthAnchor =>
      (origin as GlobalMessagesSearchSessionProvider).monthAnchor;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
