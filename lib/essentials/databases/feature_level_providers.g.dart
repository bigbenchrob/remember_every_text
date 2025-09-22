// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_level_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$workingDatabaseHash() => r'7beff4606bfcbca0dffef5260e4232a00bcfeb31';

/// Provider for the working database that creates the actual instance
///
/// Copied from [workingDatabase].
@ProviderFor(workingDatabase)
final workingDatabaseProvider = FutureProvider<DriftDb>.internal(
  workingDatabase,
  name: r'workingDatabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$workingDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WorkingDatabaseRef = FutureProviderRef<DriftDb>;
String _$importDatabaseHash() => r'a96b8f7515fe0bbd1b35372b3734be16a617a0e6';

/// Provider for the import database - single source of truth for database name
///
/// Copied from [importDatabase].
@ProviderFor(importDatabase)
final importDatabaseProvider = Provider<ImportDatabase>.internal(
  importDatabase,
  name: r'importDatabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$importDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ImportDatabaseRef = ProviderRef<ImportDatabase>;
String _$databaseReadinessHash() => r'e5ae2aa77417d1269ff276708e6f44596886309b';

/// Provider that checks if databases are ready
///
/// Copied from [databaseReadiness].
@ProviderFor(databaseReadiness)
final databaseReadinessProvider = FutureProvider<DatabaseReadiness>.internal(
  databaseReadiness,
  name: r'databaseReadinessProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$databaseReadinessHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DatabaseReadinessRef = FutureProviderRef<DatabaseReadiness>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
