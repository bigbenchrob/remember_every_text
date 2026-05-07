// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'working_db_populated_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$workingDbPopulatedHash() =>
    r'7dcecf4f85ee4a36a891b28af40de1245b38c919';

/// Whether `working.db` contains a completed projection.
///
/// Watches [messageDataVersionProvider] so it re-evaluates after migration
/// bumps that signal. Used to gate sidebar cascades and the top menu prompt
/// on first launch.
///
/// Copied from [WorkingDbPopulated].
@ProviderFor(WorkingDbPopulated)
final workingDbPopulatedProvider =
    NotifierProvider<WorkingDbPopulated, bool>.internal(
      WorkingDbPopulated.new,
      name: r'workingDbPopulatedProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$workingDbPopulatedHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WorkingDbPopulated = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
