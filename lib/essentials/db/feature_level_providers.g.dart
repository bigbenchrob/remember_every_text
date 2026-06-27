// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_level_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sourceScopedImportDatabaseHash() =>
    r'7631fed00f517ce895584158cc03ae71013940a0';

/// Provides access to the source-scoped import ledger database.
///
/// Copied from [sourceScopedImportDatabase].
@ProviderFor(sourceScopedImportDatabase)
final sourceScopedImportDatabaseProvider =
    FutureProvider<ImportDatabase>.internal(
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
typedef SourceScopedImportDatabaseRef = FutureProviderRef<ImportDatabase>;
String _$driftConversationGraphDatabaseHash() =>
    r'2b4677b6c0727a557452bb10f1c12e0156caf0f2';

/// Provides access to the source-scoped conversation graph projection database.
///
/// Copied from [driftConversationGraphDatabase].
@ProviderFor(driftConversationGraphDatabase)
final driftConversationGraphDatabaseProvider =
    FutureProvider<ConversationGraphDatabase>.internal(
      driftConversationGraphDatabase,
      name: r'driftConversationGraphDatabaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$driftConversationGraphDatabaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DriftConversationGraphDatabaseRef =
    FutureProviderRef<ConversationGraphDatabase>;
String _$overlayDatabaseHash() => r'd190fb7e00474a396c98687a85b3028ea93a6fcb';

/// Provides access to the overlay database for user preferences and customizations.
///
/// Copied from [overlayDatabase].
@ProviderFor(overlayDatabase)
final overlayDatabaseProvider = FutureProvider<OverlayDatabase>.internal(
  overlayDatabase,
  name: r'overlayDatabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$overlayDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OverlayDatabaseRef = FutureProviderRef<OverlayDatabase>;
String _$attachmentArchiveDirectoryHash() =>
    r'58ef7cbc08da3f9b14f9e4ec324effd9c9204c40';

/// Root path for the content-addressable attachment archive.
///
/// Lives alongside the databases under Application Support:
/// `~/Library/Application Support/com.bigbenchsoftware.MessageLens/attachment_archive/`
///
/// Copied from [attachmentArchiveDirectory].
@ProviderFor(attachmentArchiveDirectory)
final attachmentArchiveDirectoryProvider = Provider<String>.internal(
  attachmentArchiveDirectory,
  name: r'attachmentArchiveDirectoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$attachmentArchiveDirectoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AttachmentArchiveDirectoryRef = ProviderRef<String>;
String _$databaseHealthAuditServiceHash() =>
    r'a7f1fe16e14f16f95f24e5f975d694f12a471ff8';

/// See also [databaseHealthAuditService].
@ProviderFor(databaseHealthAuditService)
final databaseHealthAuditServiceProvider =
    FutureProvider<DatabaseHealthAuditService>.internal(
      databaseHealthAuditService,
      name: r'databaseHealthAuditServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$databaseHealthAuditServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DatabaseHealthAuditServiceRef =
    FutureProviderRef<DatabaseHealthAuditService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
