// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_level_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sqfliteImportDatabaseHash() =>
    r'55e2769da44f8cff1a868a496a7715a3080047d4';

/// Provides access to retained archive-source metadata in `macos_import.db`.
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
String _$retainedArchiveMetadataDatabaseHash() =>
    r'b44dbd6c01f3a64151102406b93e1adf77e5580d';

/// Semantic entry point for retained Historical Archives metadata.
///
/// Prefer this provider over [sqfliteImportDatabaseProvider] for new callers.
/// The returned object still wraps `macos_import.db` while archive-source
/// metadata remains in retained storage.
///
/// Copied from [retainedArchiveMetadataDatabase].
@ProviderFor(retainedArchiveMetadataDatabase)
final retainedArchiveMetadataDatabaseProvider =
    FutureProvider<SqfliteImportDatabase>.internal(
      retainedArchiveMetadataDatabase,
      name: r'retainedArchiveMetadataDatabaseProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$retainedArchiveMetadataDatabaseHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RetainedArchiveMetadataDatabaseRef =
    FutureProviderRef<SqfliteImportDatabase>;
String _$driftConversationGraphDatabaseHash() =>
    r'a24e4d5cdb2234f7185c5de114b7ad80607c414a';

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
String _$overlayDatabaseHash() => r'af7bedb84580f233fac919c553fd2df670e3e30c';

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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
