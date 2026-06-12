// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_level_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sourceScopedMessageExtractorHash() =>
    r'9c497d7fdc8f6044fe181ef36976d7b4ba4d58c3';

/// Provides the Rust-backed attributed-body extractor used by source-scoped
/// message enrichment and archive import.
///
/// Copied from [sourceScopedMessageExtractor].
@ProviderFor(sourceScopedMessageExtractor)
final sourceScopedMessageExtractorProvider =
    AutoDisposeProvider<MessageExtractorPort>.internal(
      sourceScopedMessageExtractor,
      name: r'sourceScopedMessageExtractorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sourceScopedMessageExtractorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SourceScopedMessageExtractorRef =
    AutoDisposeProviderRef<MessageExtractorPort>;
String _$sourceDatabaseOpenerHash() =>
    r'05fc64984032058fee8b34e502709b4b7c471698';

/// See also [sourceDatabaseOpener].
@ProviderFor(sourceDatabaseOpener)
final sourceDatabaseOpenerProvider =
    AutoDisposeProvider<SourceDatabaseOpener>.internal(
      sourceDatabaseOpener,
      name: r'sourceDatabaseOpenerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sourceDatabaseOpenerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SourceDatabaseOpenerRef = AutoDisposeProviderRef<SourceDatabaseOpener>;
String _$sourceScopedImportLedgerHash() =>
    r'fb78a5c5cac730d7204e70e8e94956efc5c94298';

/// See also [sourceScopedImportLedger].
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
String _$sourceScopedImportDatabaseHash() =>
    r'8106535fb88e35c3d1830d74210c5d7186f86f43';

/// Provides concrete source-scoped import database access for graph projection
/// infrastructure that still needs import-ledger queries not yet modeled by a
/// narrower port.
///
/// Copied from [sourceScopedImportDatabase].
@ProviderFor(sourceScopedImportDatabase)
final sourceScopedImportDatabaseProvider =
    AutoDisposeFutureProvider<ImportDatabase>.internal(
      sourceScopedImportDatabase,
      name: r'sourceScopedImportDatabaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sourceScopedImportDatabaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SourceScopedImportDatabaseRef =
    AutoDisposeFutureProviderRef<ImportDatabase>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
