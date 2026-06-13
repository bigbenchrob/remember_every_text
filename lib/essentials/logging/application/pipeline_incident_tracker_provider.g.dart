// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pipeline_incident_tracker_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeBlockingPipelineIncidentHash() =>
    r'9ebd6069213f5a02895b7dc6fd6d9d8a6c001935';

/// See also [activeBlockingPipelineIncident].
@ProviderFor(activeBlockingPipelineIncident)
final activeBlockingPipelineIncidentProvider =
    AutoDisposeFutureProvider<PipelineIncidentReport?>.internal(
      activeBlockingPipelineIncident,
      name: r'activeBlockingPipelineIncidentProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeBlockingPipelineIncidentHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveBlockingPipelineIncidentRef =
    AutoDisposeFutureProviderRef<PipelineIncidentReport?>;
String _$pipelineIncidentTrackerHash() =>
    r'2a1fa7b07c00ab7b5d39214ceff51af61b760c65';

/// See also [PipelineIncidentTracker].
@ProviderFor(PipelineIncidentTracker)
final pipelineIncidentTrackerProvider =
    AsyncNotifierProvider<
      PipelineIncidentTracker,
      PipelineIncidentReport?
    >.internal(
      PipelineIncidentTracker.new,
      name: r'pipelineIncidentTrackerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pipelineIncidentTrackerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PipelineIncidentTracker = AsyncNotifier<PipelineIncidentReport?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
