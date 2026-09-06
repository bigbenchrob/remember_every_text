// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_gate_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$onboardingGateHash() => r'86f52e196532fe65d506b286f847786f346121cb';

/// Read-only compatibility projection for established presentation consumers.
///
/// Journey transitions belong exclusively to [OnboardingJourneyCoordinator].
/// The forwarding methods preserve existing caller and test seams while every
/// intent is decided by that coordinator.
///
/// Copied from [OnboardingGate].
@ProviderFor(OnboardingGate)
final onboardingGateProvider =
    NotifierProvider<OnboardingGate, OnboardingStatus>.internal(
      OnboardingGate.new,
      name: r'onboardingGateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$onboardingGateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OnboardingGate = Notifier<OnboardingStatus>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
