// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'archive_access_authority_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$admittedArchiveAccessAuthorityHash() =>
    r'567620d232ed162f5c6dc5e9f0ec9f64c831a0f1';

/// Non-persistent admission signal for infrastructure that can operate without
/// archive access.
///
/// Ordinary persistent consumers must use [archiveAccessAuthorityProvider].
/// This nullable seam exists for facades such as the application logger that
/// can retain in-memory behavior before admission while withholding their
/// persistent writer.
///
/// Copied from [admittedArchiveAccessAuthority].
@ProviderFor(admittedArchiveAccessAuthority)
final admittedArchiveAccessAuthorityProvider =
    Provider<ArchiveAccessAuthority?>.internal(
      admittedArchiveAccessAuthority,
      name: r'admittedArchiveAccessAuthorityProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$admittedArchiveAccessAuthorityHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdmittedArchiveAccessAuthorityRef =
    ProviderRef<ArchiveAccessAuthority?>;
String _$archiveAccessAuthorityHash() =>
    r'0412bf9aff81f6eed9de2cbc11a4973c4b498c97';

/// Required root capability. The application bootstrap must override this
/// provider's admission source before persistent providers are read.
///
/// Copied from [archiveAccessAuthority].
@ProviderFor(archiveAccessAuthority)
final archiveAccessAuthorityProvider =
    Provider<ArchiveAccessAuthority>.internal(
      archiveAccessAuthority,
      name: r'archiveAccessAuthorityProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$archiveAccessAuthorityHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ArchiveAccessAuthorityRef = ProviderRef<ArchiveAccessAuthority>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
