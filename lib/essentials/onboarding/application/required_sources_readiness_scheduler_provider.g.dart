// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'required_sources_readiness_scheduler_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$requiredSourcesReadinessRepositoryHash() =>
    r'394f754e63b61696e506aa70295e582c0c7810af';

/// Retired Presence laboratory composition for required-source readiness.
///
/// Production Onboarding no longer consumes this provider. The single active
/// prerequisite authority is `OnboardingJourneyCoordinator`; this composition
/// remains only for historical fixtures and developer experiments.
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

/// Retired laboratory acceptance established by Schedule completion.
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
    r'94f29d8ab6487f70d2657b6fc2735d3e608a22ad';

/// Retired laboratory composition root for the required-sources Schedule.
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
