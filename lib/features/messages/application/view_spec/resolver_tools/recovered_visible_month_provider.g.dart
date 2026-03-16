// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recovered_visible_month_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recoveredVisibleMonthHash() =>
    r'9d0149043f1a4314b82d6a6dbb2204b74407a947';

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

abstract class _$RecoveredVisibleMonth
    extends BuildlessAutoDisposeNotifier<String?> {
  late final int? contactId;
  late final bool onlyNoHandleFromMe;

  String? build({int? contactId, required bool onlyNoHandleFromMe});
}

/// See also [RecoveredVisibleMonth].
@ProviderFor(RecoveredVisibleMonth)
const recoveredVisibleMonthProvider = RecoveredVisibleMonthFamily();

/// See also [RecoveredVisibleMonth].
class RecoveredVisibleMonthFamily extends Family<String?> {
  /// See also [RecoveredVisibleMonth].
  const RecoveredVisibleMonthFamily();

  /// See also [RecoveredVisibleMonth].
  RecoveredVisibleMonthProvider call({
    int? contactId,
    required bool onlyNoHandleFromMe,
  }) {
    return RecoveredVisibleMonthProvider(
      contactId: contactId,
      onlyNoHandleFromMe: onlyNoHandleFromMe,
    );
  }

  @override
  RecoveredVisibleMonthProvider getProviderOverride(
    covariant RecoveredVisibleMonthProvider provider,
  ) {
    return call(
      contactId: provider.contactId,
      onlyNoHandleFromMe: provider.onlyNoHandleFromMe,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recoveredVisibleMonthProvider';
}

/// See also [RecoveredVisibleMonth].
class RecoveredVisibleMonthProvider
    extends AutoDisposeNotifierProviderImpl<RecoveredVisibleMonth, String?> {
  /// See also [RecoveredVisibleMonth].
  RecoveredVisibleMonthProvider({
    int? contactId,
    required bool onlyNoHandleFromMe,
  }) : this._internal(
         () => RecoveredVisibleMonth()
           ..contactId = contactId
           ..onlyNoHandleFromMe = onlyNoHandleFromMe,
         from: recoveredVisibleMonthProvider,
         name: r'recoveredVisibleMonthProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$recoveredVisibleMonthHash,
         dependencies: RecoveredVisibleMonthFamily._dependencies,
         allTransitiveDependencies:
             RecoveredVisibleMonthFamily._allTransitiveDependencies,
         contactId: contactId,
         onlyNoHandleFromMe: onlyNoHandleFromMe,
       );

  RecoveredVisibleMonthProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contactId,
    required this.onlyNoHandleFromMe,
  }) : super.internal();

  final int? contactId;
  final bool onlyNoHandleFromMe;

  @override
  String? runNotifierBuild(covariant RecoveredVisibleMonth notifier) {
    return notifier.build(
      contactId: contactId,
      onlyNoHandleFromMe: onlyNoHandleFromMe,
    );
  }

  @override
  Override overrideWith(RecoveredVisibleMonth Function() create) {
    return ProviderOverride(
      origin: this,
      override: RecoveredVisibleMonthProvider._internal(
        () => create()
          ..contactId = contactId
          ..onlyNoHandleFromMe = onlyNoHandleFromMe,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contactId: contactId,
        onlyNoHandleFromMe: onlyNoHandleFromMe,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<RecoveredVisibleMonth, String?>
  createElement() {
    return _RecoveredVisibleMonthProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecoveredVisibleMonthProvider &&
        other.contactId == contactId &&
        other.onlyNoHandleFromMe == onlyNoHandleFromMe;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contactId.hashCode);
    hash = _SystemHash.combine(hash, onlyNoHandleFromMe.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RecoveredVisibleMonthRef on AutoDisposeNotifierProviderRef<String?> {
  /// The parameter `contactId` of this provider.
  int? get contactId;

  /// The parameter `onlyNoHandleFromMe` of this provider.
  bool get onlyNoHandleFromMe;
}

class _RecoveredVisibleMonthProviderElement
    extends AutoDisposeNotifierProviderElement<RecoveredVisibleMonth, String?>
    with RecoveredVisibleMonthRef {
  _RecoveredVisibleMonthProviderElement(super.provider);

  @override
  int? get contactId => (origin as RecoveredVisibleMonthProvider).contactId;
  @override
  bool get onlyNoHandleFromMe =>
      (origin as RecoveredVisibleMonthProvider).onlyNoHandleFromMe;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
