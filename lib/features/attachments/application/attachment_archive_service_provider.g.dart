// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_archive_service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$attachmentArchiveMessagesDatabasePathHash() =>
    r'c20562b40f4c8f0d64822ea05e53bf9f913e2e5a';

/// See also [attachmentArchiveMessagesDatabasePath].
@ProviderFor(attachmentArchiveMessagesDatabasePath)
final attachmentArchiveMessagesDatabasePathProvider =
    AutoDisposeFutureProvider<String>.internal(
      attachmentArchiveMessagesDatabasePath,
      name: r'attachmentArchiveMessagesDatabasePathProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$attachmentArchiveMessagesDatabasePathHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AttachmentArchiveMessagesDatabasePathRef =
    AutoDisposeFutureProviderRef<String>;
String _$attachmentArchiveServiceHash() =>
    r'6f94a31d163704dd8f22330335ba2b261a0c8de0';

/// Service that copies attachment files into the MessageLens archive and
/// records them in the overlay database.
///
/// Archiving is idempotent: if an overlay record already exists for the
/// given (messageGuid, importAttachmentId) pair, the file is not re-copied.
///
/// Copied from [AttachmentArchiveService].
@ProviderFor(AttachmentArchiveService)
final attachmentArchiveServiceProvider =
    NotifierProvider<AttachmentArchiveService, BulkArchiveProgress>.internal(
      AttachmentArchiveService.new,
      name: r'attachmentArchiveServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$attachmentArchiveServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AttachmentArchiveService = Notifier<BulkArchiveProgress>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
