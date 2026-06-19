// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_level_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$retainedArchiveMetadataStoreHash() =>
    r'1ec2902256e0ad9e46c715b2fb4b6bdaef1d8eec';

/// Provides access to retained archive-source metadata storage.
///
/// Copied from [retainedArchiveMetadataStore].
@ProviderFor(retainedArchiveMetadataStore)
final retainedArchiveMetadataStoreProvider =
    FutureProvider<RetainedArchiveMetadataStore>.internal(
      retainedArchiveMetadataStore,
      name: r'retainedArchiveMetadataStoreProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$retainedArchiveMetadataStoreHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RetainedArchiveMetadataStoreRef =
    FutureProviderRef<RetainedArchiveMetadataStore>;
String _$driftConversationGraphDatabaseHash() =>
    r'6b5758ced4eddacc44e4c709b6363adf0603ed2d';

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
String _$overlayDatabaseHash() => r'9ebaf6ae0ce04b419b092445b7076a0d81819857';

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
    r'96c80b0449a23741f9d7942beb47aa9bdfcb8f92';

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
