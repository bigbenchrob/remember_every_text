import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'chat_message_join_stage_controller.dart';

part 'chat_message_join_stage_controller_provider.g.dart';

@riverpod
ChatMessageJoinStageController chatMessageJoinStageController(Ref ref) {
  return ChatMessageJoinStageController(ref);
}
