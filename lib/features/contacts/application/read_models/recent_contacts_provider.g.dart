// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_contacts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$recentContactsReaderHash() =>
    r'638bf4fec97cd230f6d463bd1fd463b104e4132a';

/// See also [recentContactsReader].
@ProviderFor(recentContactsReader)
final recentContactsReaderProvider =
    AutoDisposeFutureProvider<RecentContactsReader>.internal(
      recentContactsReader,
      name: r'recentContactsReaderProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recentContactsReaderHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentContactsReaderRef =
    AutoDisposeFutureProviderRef<RecentContactsReader>;
String _$recentContactsHash() => r'165c51d4a128562dbc367481cf15f4a199b45c86';

/// See also [recentContacts].
@ProviderFor(recentContacts)
final recentContactsProvider =
    AutoDisposeFutureProvider<List<RecentContactSummary>>.internal(
      recentContacts,
      name: r'recentContactsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recentContactsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentContactsRef =
    AutoDisposeFutureProviderRef<List<RecentContactSummary>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
