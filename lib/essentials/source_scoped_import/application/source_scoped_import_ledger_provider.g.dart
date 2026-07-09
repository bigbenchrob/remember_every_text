// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'source_scoped_import_ledger_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sourceScopedImportLedgerHash() =>
    r'3c871867f0de7b248819ea0f000f07d4a5bfb612';

/// Semantic access to the source-scoped import ledger.
///
/// Physical database construction stays in `essentials/db`; import/projection
/// code consumes this port-shaped provider instead of database file details.
///
/// Copied from [sourceScopedImportLedger].
@ProviderFor(sourceScopedImportLedger)
final sourceScopedImportLedgerProvider =
    AutoDisposeFutureProvider<ImportLedger>.internal(
      sourceScopedImportLedger,
      name: r'sourceScopedImportLedgerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sourceScopedImportLedgerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SourceScopedImportLedgerRef =
    AutoDisposeFutureProviderRef<ImportLedger>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
