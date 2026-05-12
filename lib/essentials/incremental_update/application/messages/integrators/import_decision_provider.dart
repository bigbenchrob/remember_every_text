import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/sealed_unions/import_decision.dart';
import './import_decision_integrator.dart';
import 'sync_assessment_integrator_provider.dart';

part 'import_decision_provider.g.dart';

@riverpod
Future<ImportDecision> importDecision(Ref ref) async {
  final syncState = await ref.watch(messageSyncStateProvider.future);
  final integrator = ImportDecisionIntegrator();
  return integrator.integrate(syncState);
}
