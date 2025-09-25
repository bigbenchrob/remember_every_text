// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'migration_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dataMigrationServiceHash() =>
    r'fea4e1ef6e6b395e24088965c443aa0e5bcc344d';

/// Migration service that moves data from import database to working database
/// This properly uses the existing contact linking from import_contact_handles
///
/// Copied from [dataMigrationService].
@ProviderFor(dataMigrationService)
final dataMigrationServiceProvider =
    AutoDisposeProvider<DataMigrationService>.internal(
      dataMigrationService,
      name: r'dataMigrationServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dataMigrationServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DataMigrationServiceRef = AutoDisposeProviderRef<DataMigrationService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
