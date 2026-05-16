import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'handle_stage_controller.dart';

part 'handle_stage_controller_provider.g.dart';

@riverpod
HandleStageController handleStageController(Ref ref) {
  return HandleStageController(ref);
}
