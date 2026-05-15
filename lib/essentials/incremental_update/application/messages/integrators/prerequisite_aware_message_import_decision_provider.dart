import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/sealed_unions/prerequisite_aware_message_import_decision.dart';
import 'import_decision_provider.dart';
import 'message_import_prerequisite_assessment_provider.dart';
import 'prerequisite_aware_message_import_decision_integrator.dart';

part 'prerequisite_aware_message_import_decision_provider.g.dart';

@riverpod
Future<PrerequisiteAwareMessageImportDecision>
prerequisiteAwareMessageImportDecision(Ref ref) async {
  final baseDecision = await ref.watch(importDecisionProvider.future);
  final prerequisites = await ref.watch(
    messageImportPrerequisiteAssessmentProvider.future,
  );

  return const PrerequisiteAwareMessageImportDecisionIntegrator().integrate(
    baseDecision: baseDecision,
    prerequisites: prerequisites,
  );
}
