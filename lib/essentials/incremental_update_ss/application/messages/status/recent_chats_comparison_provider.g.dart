// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_chats_comparison_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recentChatsComparisonHash() =>
    r'a95d0230f3ec37988d52e3ca7b13b195075fa9b7';

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

/// See also [recentChatsComparison].
@ProviderFor(recentChatsComparison)
const recentChatsComparisonProvider = RecentChatsComparisonFamily();

/// See also [recentChatsComparison].
class RecentChatsComparisonFamily
    extends Family<AsyncValue<RecentChatsComparison>> {
  /// See also [recentChatsComparison].
  const RecentChatsComparisonFamily();

  /// See also [recentChatsComparison].
  RecentChatsComparisonProvider call({int sampleLimit = 8}) {
    return RecentChatsComparisonProvider(sampleLimit: sampleLimit);
  }

  @override
  RecentChatsComparisonProvider getProviderOverride(
    covariant RecentChatsComparisonProvider provider,
  ) {
    return call(sampleLimit: provider.sampleLimit);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recentChatsComparisonProvider';
}

/// See also [recentChatsComparison].
class RecentChatsComparisonProvider
    extends AutoDisposeFutureProvider<RecentChatsComparison> {
  /// See also [recentChatsComparison].
  RecentChatsComparisonProvider({int sampleLimit = 8})
    : this._internal(
        (ref) => recentChatsComparison(
          ref as RecentChatsComparisonRef,
          sampleLimit: sampleLimit,
        ),
        from: recentChatsComparisonProvider,
        name: r'recentChatsComparisonProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$recentChatsComparisonHash,
        dependencies: RecentChatsComparisonFamily._dependencies,
        allTransitiveDependencies:
            RecentChatsComparisonFamily._allTransitiveDependencies,
        sampleLimit: sampleLimit,
      );

  RecentChatsComparisonProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.sampleLimit,
  }) : super.internal();

  final int sampleLimit;

  @override
  Override overrideWith(
    FutureOr<RecentChatsComparison> Function(RecentChatsComparisonRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecentChatsComparisonProvider._internal(
        (ref) => create(ref as RecentChatsComparisonRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        sampleLimit: sampleLimit,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<RecentChatsComparison> createElement() {
    return _RecentChatsComparisonProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecentChatsComparisonProvider &&
        other.sampleLimit == sampleLimit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, sampleLimit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RecentChatsComparisonRef
    on AutoDisposeFutureProviderRef<RecentChatsComparison> {
  /// The parameter `sampleLimit` of this provider.
  int get sampleLimit;
}

class _RecentChatsComparisonProviderElement
    extends AutoDisposeFutureProviderElement<RecentChatsComparison>
    with RecentChatsComparisonRef {
  _RecentChatsComparisonProviderElement(super.provider);

  @override
  int get sampleLimit => (origin as RecentChatsComparisonProvider).sampleLimit;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
