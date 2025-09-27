// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_level_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ledgerToWorkingMigrationServiceHash() =>
    r'97256f55f01ae226558bfae24b269cef11a56e17';

/// Provides the ledger-to-working database migration orchestrator.
///
/// Copied from [ledgerToWorkingMigrationService].
@ProviderFor(ledgerToWorkingMigrationService)
final ledgerToWorkingMigrationServiceProvider =
    AutoDisposeProvider<LedgerToWorkingMigrationService>.internal(
      ledgerToWorkingMigrationService,
      name: r'ledgerToWorkingMigrationServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$ledgerToWorkingMigrationServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LedgerToWorkingMigrationServiceRef =
    AutoDisposeProviderRef<LedgerToWorkingMigrationService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
