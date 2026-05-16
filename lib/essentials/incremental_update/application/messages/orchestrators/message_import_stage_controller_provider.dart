import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'message_import_stage_controller.dart';

part 'message_import_stage_controller_provider.g.dart';

@riverpod
MessageImportStageController messageImportStageController(Ref ref) {
  return MessageImportStageController(ref);
}
