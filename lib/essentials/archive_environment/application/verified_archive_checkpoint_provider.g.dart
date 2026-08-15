// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verified_archive_checkpoint_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$archiveCheckpointReceiptValidatorHash() =>
    r'cdc8af42aa4d3df6528a3ae1704ee2db1fe15142';

/// See also [archiveCheckpointReceiptValidator].
@ProviderFor(archiveCheckpointReceiptValidator)
final archiveCheckpointReceiptValidatorProvider =
    AutoDisposeProvider<ArchiveCheckpointReceiptValidator>.internal(
      archiveCheckpointReceiptValidator,
      name: r'archiveCheckpointReceiptValidatorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$archiveCheckpointReceiptValidatorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ArchiveCheckpointReceiptValidatorRef =
    AutoDisposeProviderRef<ArchiveCheckpointReceiptValidator>;
String _$verifiedArchiveCheckpointHash() =>
    r'43d7b4adc3491912b7d400441daa4746d597cf25';

/// See also [VerifiedArchiveCheckpoint].
@ProviderFor(VerifiedArchiveCheckpoint)
final verifiedArchiveCheckpointProvider =
    NotifierProvider<
      VerifiedArchiveCheckpoint,
      ArchiveCheckpointReceipt?
    >.internal(
      VerifiedArchiveCheckpoint.new,
      name: r'verifiedArchiveCheckpointProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$verifiedArchiveCheckpointHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$VerifiedArchiveCheckpoint = Notifier<ArchiveCheckpointReceipt?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
