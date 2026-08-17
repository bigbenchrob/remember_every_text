// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'persistent_database_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sourceScopedImportDatabaseHash() =>
    r'c8b8aecfb1180d926ffc901f7582e605df49502e';

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
    r'a9f4140892bb0e85f52277d90e5a9fa45ac75682';

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
String _$overlayDatabaseHash() => r'c508b771f81fc04d6bdec98e003912f80e078b6c';

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
String _$presenceDatabaseHash() => r'235e6a89c9ccc79a1605f7621fe3f41f712a360f';

/// Provides the durable Schedule/Trip experiment database.
///
/// Copied from [presenceDatabase].
@ProviderFor(presenceDatabase)
final presenceDatabaseProvider = FutureProvider<PresenceDatabase>.internal(
  presenceDatabase,
  name: r'presenceDatabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$presenceDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PresenceDatabaseRef = FutureProviderRef<PresenceDatabase>;
String _$attachmentArchiveDirectoryHash() =>
    r'6f38c8d253932232572f43db5df683c9459ddd2d';

/// Root path for the content-addressable attachment archive.
///
/// Lives inside the admitted archive root alongside its databases.
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
