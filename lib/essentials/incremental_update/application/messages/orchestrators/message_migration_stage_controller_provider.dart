import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'message_migration_stage_controller.dart';

part 'message_migration_stage_controller_provider.g.dart';

@Riverpod(keepAlive: true)
MessageMigrationStageController messageMigrationStageController(Ref ref) {
  return MessageMigrationStageController(ref);
}
