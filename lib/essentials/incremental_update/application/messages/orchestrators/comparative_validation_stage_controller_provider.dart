import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'comparative_validation_stage_controller.dart';

part 'comparative_validation_stage_controller_provider.g.dart';

@riverpod
ComparativeValidationStageController comparativeValidationStageController(
  Ref ref,
) {
  return ComparativeValidationStageController(ref);
}
