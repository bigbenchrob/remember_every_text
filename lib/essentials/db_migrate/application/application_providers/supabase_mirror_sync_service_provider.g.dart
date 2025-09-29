// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supabase_mirror_sync_service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$supabaseMirrorSyncServiceHash() =>
    r'70007dda826488642aaa72dedf3013d1241085a5';

/// Provides the application-layer service responsible for mirroring batches
/// into Supabase once the working database is populated.
///
/// Copied from [supabaseMirrorSyncService].
@ProviderFor(supabaseMirrorSyncService)
final supabaseMirrorSyncServiceProvider =
    AutoDisposeFutureProvider<SupabaseMirrorSyncService>.internal(
      supabaseMirrorSyncService,
      name: r'supabaseMirrorSyncServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$supabaseMirrorSyncServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SupabaseMirrorSyncServiceRef =
    AutoDisposeFutureProviderRef<SupabaseMirrorSyncService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
