import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'chat_stage_controller.dart';

part 'chat_stage_controller_provider.g.dart';

@riverpod
ChatStageController chatStageController(Ref ref) {
  return ChatStageController(ref);
}
