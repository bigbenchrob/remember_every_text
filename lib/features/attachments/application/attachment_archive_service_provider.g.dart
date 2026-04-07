// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_archive_service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$attachmentArchiveServiceHash() =>
    r'23e1332796111b2e96b92cab339267154fde134e';

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
