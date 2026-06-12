// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'graph_maintenance_execution_gate_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$graphMaintenanceExecutionGateHash() =>
    r'd11ccd3802a91e6d195cf4c0f1ebfe915fafaf6c';

/// Global graph-maintenance execution gate.
///
/// This acts as a single source of truth for who currently owns derived-data
/// maintenance. Only one owner may run source import, graph build, or archive
/// import/removal work at a time. Re-entrant acquisition by the same owner is
/// allowed.
///
/// Copied from [GraphMaintenanceExecutionGate].
@ProviderFor(GraphMaintenanceExecutionGate)
final graphMaintenanceExecutionGateProvider =
    NotifierProvider<
      GraphMaintenanceExecutionGate,
      GraphMaintenanceExecutionGateState
    >.internal(
      GraphMaintenanceExecutionGate.new,
      name: r'graphMaintenanceExecutionGateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$graphMaintenanceExecutionGateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GraphMaintenanceExecutionGate =
    Notifier<GraphMaintenanceExecutionGateState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
