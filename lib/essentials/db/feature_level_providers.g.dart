// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_level_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sqfliteImportDatabaseHash() =>
    r'8e2038b49e14aac1df5f4e0a6b2fb7793b8a8f4b';

/// Provides access to the Sqflite-powered import ledger database.
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
String _$driftWorkingDatabaseHash() =>
    r'af65334f60b9da88a0e231207d60a98e7c2fdd8d';

/// Provides access to the Drift projection database used by the UI.
///
/// Copied from [driftWorkingDatabase].
@ProviderFor(driftWorkingDatabase)
final driftWorkingDatabaseProvider = FutureProvider<WorkingDatabase>.internal(
  driftWorkingDatabase,
  name: r'driftWorkingDatabaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$driftWorkingDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DriftWorkingDatabaseRef = FutureProviderRef<WorkingDatabase>;
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
