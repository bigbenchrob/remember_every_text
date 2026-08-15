// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db_maintenance_lock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dbMaintenanceLockHash() => r'c8ef5a47e1ee4aabc8c8d1a993f1f7a0f5897d7c';

/// Compatibility read model for consumers that must not re-open databases
/// during destructive archive mutations.
///
/// Operation admission is owned exclusively by ArchiveMutationCoordinator.
/// This provider exposes only the derived read-suppression decision.
///
/// Copied from [dbMaintenanceLock].
@ProviderFor(dbMaintenanceLock)
final dbMaintenanceLockProvider = AutoDisposeProvider<bool>.internal(
  dbMaintenanceLock,
  name: r'dbMaintenanceLockProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dbMaintenanceLockHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DbMaintenanceLockRef = AutoDisposeProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
