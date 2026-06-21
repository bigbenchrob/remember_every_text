// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attachment_archive_service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$attachmentArchiveServiceHash() =>
    r'7cbc3b3961d07d42304a38e0eae7636be3e27acd';

/// Service that copies attachment files into the MessageLens archive and
/// records them through the attachment archive store.
///
/// Archiving is idempotent: if an archive record already exists for the
/// derived archive compatibility key, the file is not re-copied.
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
