// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'required_sources_readiness_scheduler_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$requiredSourcesReadinessRepositoryHash() =>
    r'c9d36e192ff788950661a7dff80c59ebedce8556';

/// Onboarding-owned repository composition for required-source readiness.
///
/// Copied from [requiredSourcesReadinessRepository].
@ProviderFor(requiredSourcesReadinessRepository)
final requiredSourcesReadinessRepositoryProvider =
    FutureProvider<PresenceScheduleRepository>.internal(
      requiredSourcesReadinessRepository,
      name: r'requiredSourcesReadinessRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$requiredSourcesReadinessRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RequiredSourcesReadinessRepositoryRef =
    FutureProviderRef<PresenceScheduleRepository>;
String _$requiredSourcesReadinessAcceptedHash() =>
    r'15e12f8a890a9f91607aab2b47773288ef191cd2';

/// Durable acceptance established by completion of the required-sources run.
///
/// Copied from [requiredSourcesReadinessAccepted].
@ProviderFor(requiredSourcesReadinessAccepted)
final requiredSourcesReadinessAcceptedProvider = StreamProvider<bool>.internal(
  requiredSourcesReadinessAccepted,
  name: r'requiredSourcesReadinessAcceptedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$requiredSourcesReadinessAcceptedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RequiredSourcesReadinessAcceptedRef = StreamProviderRef<bool>;
String _$requiredSourcesReadinessSchedulerHash() =>
    r'd7b77663c88f05cef3a4807c17f00ee3f59d1ab3';

/// Production composition root for the required-sources Presence Schedule.
///
/// Copied from [requiredSourcesReadinessScheduler].
@ProviderFor(requiredSourcesReadinessScheduler)
final requiredSourcesReadinessSchedulerProvider =
    FutureProvider<PresenceScheduler>.internal(
      requiredSourcesReadinessScheduler,
      name: r'requiredSourcesReadinessSchedulerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$requiredSourcesReadinessSchedulerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RequiredSourcesReadinessSchedulerRef =
    FutureProviderRef<PresenceScheduler>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
