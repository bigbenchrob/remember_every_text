import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'comparative_validation_orchestrator.dart';

part 'comparative_validation_orchestrator_provider.g.dart';

@Riverpod(keepAlive: true)
ComparativeValidationOrchestrator comparativeValidationOrchestrator(Ref ref) {
  return ComparativeValidationOrchestrator(ref);
}
