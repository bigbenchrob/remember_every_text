// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_search_investigation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentSearchInvestigationHash() =>
    r'7d376b524d49b68cfe99e3a6fbc187d1a6d632b3';

/// Owns the identity of the current primary Search investigation.
///
/// A Search-created subordinate presentation is effective only while its
/// originating identity remains current. Navigation away does not advance the
/// identity; replacing the investigation does.
///
/// Copied from [CurrentSearchInvestigation].
@ProviderFor(CurrentSearchInvestigation)
final currentSearchInvestigationProvider =
    NotifierProvider<
      CurrentSearchInvestigation,
      SearchInvestigationId
    >.internal(
      CurrentSearchInvestigation.new,
      name: r'currentSearchInvestigationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentSearchInvestigationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurrentSearchInvestigation = Notifier<SearchInvestigationId>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
