// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_gate_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$onboardingGateHash() => r'28a6824c31d49ced2498755a2fff9b57ac913383';

/// Controls the onboarding overlay lifecycle.
///
/// Gate 1 — Full Disk Access:
/// On [build], checks whether the app can read `~/Library/Messages/chat.db`.
/// If not, exposes [OnboardingStatus.awaitingFda] so the FDA instruction
/// screen is shown.  Nothing else can proceed until FDA is confirmed.
///
/// Gate 2 — Data import:
/// Once FDA is confirmed, checks whether the source-scoped import ledger and
/// app-facing conversation graph exist with data. If not, exposes
/// [OnboardingStatus.awaitingUserAction] so the import overlay appears.
///
/// [startImportAndMigration] delegates to [DbImportControlViewModel] and
/// watches its state to transition through importing → migrating → complete.
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
