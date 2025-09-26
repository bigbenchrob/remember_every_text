// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_level_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sqfliteImportDatabaseHash() =>
    r'e86c29a0c49f1040bb6a5eb3d1eb0607e6e299df';

/// Provides access to the Sqflite-powered import ledger database.
///
/// Copied from [sqfliteImportDatabase].
@ProviderFor(sqfliteImportDatabase)
final sqfliteImportDatabaseProvider =
    FutureProvider<SqfliteImportDatabase>.internal(
      sqfliteImportDatabase,
      name: r'sqfliteImportDatabaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sqfliteImportDatabaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SqfliteImportDatabaseRef = FutureProviderRef<SqfliteImportDatabase>;
String _$driftWorkingDatabaseHash() =>
    r'126434ba4cece1d24a8420fe8b65197e207529fb';

/// Provides access to the Drift projection database used by the UI.
///
/// Copied from [driftWorkingDatabase].
@ProviderFor(driftWorkingDatabase)
final driftWorkingDatabaseProvider = FutureProvider<WorkingDatabase>.internal(
  driftWorkingDatabase,
  name: r'driftWorkingDatabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$driftWorkingDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DriftWorkingDatabaseRef = FutureProviderRef<WorkingDatabase>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
