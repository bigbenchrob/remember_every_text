import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'onboarding_environment_report_provider.dart';
import 'onboarding_operation_reconciliation.dart';
import 'onboarding_operation_snapshot_provider.dart';

part 'onboarding_operation_reconciliation_provider.g.dart';

/// Reconciles durable operation history with already-established environment
/// evidence. It does not probe databases or grant mutation authority.
@Riverpod(keepAlive: true)
Future<void> onboardingOperationReconciliation(Ref ref) async {
  final report = await ref.watch(onboardingEnvironmentReportProvider.future);
  final controller = await ref.watch(
    onboardingOperationControllerProvider.future,
  );
  await controller.reconcile(onboardingReconciliationEvidenceFrom(report));
}
