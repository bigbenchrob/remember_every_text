import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/sealed_unions/message_migration_state.dart';
import 'migration_delta_integrator_provider.dart';
import 'migration_state_integrator.dart';

part 'migration_state_integrator_provider.g.dart';

@riverpod
Future<MessageMigrationState> messageMigrationState(Ref ref) async {
  final delta = await ref.watch(messageMigrationDeltaProvider.future);

  return const MessageMigrationStateIntegrator().integrate(delta);
}
