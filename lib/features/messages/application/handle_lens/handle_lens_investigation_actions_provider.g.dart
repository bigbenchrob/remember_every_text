// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handle_lens_investigation_actions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$handleLensInvestigationActionsHash() =>
    r'5d125713b74c6ed65da251b6e02bfeec5ab8b462';

/// Coordinates Messages-owned handle-lens investigation transitions.
///
/// Handles owns dismissal meaning and persistence. This boundary advances the
/// navigation investigation only after Handles confirms that dismissal
/// succeeded. Center-panel visibility then follows from compatibility.
///
/// Copied from [HandleLensInvestigationActions].
@ProviderFor(HandleLensInvestigationActions)
final handleLensInvestigationActionsProvider =
    AutoDisposeNotifierProvider<HandleLensInvestigationActions, void>.internal(
      HandleLensInvestigationActions.new,
      name: r'handleLensInvestigationActionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$handleLensInvestigationActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HandleLensInvestigationActions = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
