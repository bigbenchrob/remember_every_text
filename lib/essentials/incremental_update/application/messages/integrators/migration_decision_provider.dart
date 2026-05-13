import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/sealed_unions/migration_decision.dart';
import 'migration_decision_integrator.dart';
import 'migration_state_integrator_provider.dart';

part 'migration_decision_provider.g.dart';

@riverpod
Future<MigrationDecision> migrationDecision(Ref ref) async {
  final state = await ref.watch(messageMigrationStateProvider.future);

  return const MigrationDecisionIntegrator().integrate(state);
}
