// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_level_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dbImportMessageExtractorHash() =>
    r'cb9fa581030cfa90ef4455cfa6aa680207883dd6';

/// Provides the Rust-backed message extractor used to decode attributed blobs
/// during the database import pipeline.
///
/// Copied from [dbImportMessageExtractor].
@ProviderFor(dbImportMessageExtractor)
final dbImportMessageExtractorProvider =
    AutoDisposeProvider<MessageExtractorPort>.internal(
      dbImportMessageExtractor,
      name: r'dbImportMessageExtractorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$dbImportMessageExtractorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DbImportMessageExtractorRef =
    AutoDisposeProviderRef<MessageExtractorPort>;
String _$ledgerImportServiceHash() =>
    r'891c20e4e9eef2c4c504dc34250fb0afd311596f';

/// High-level service orchestrating the ingest into the Sqflite ledger.
///
/// Copied from [ledgerImportService].
@ProviderFor(ledgerImportService)
final ledgerImportServiceProvider =
    AutoDisposeProvider<LedgerImportService>.internal(
      ledgerImportService,
      name: r'ledgerImportServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$ledgerImportServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LedgerImportServiceRef = AutoDisposeProviderRef<LedgerImportService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
