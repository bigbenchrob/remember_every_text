import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../infrastructure/repositories/handle_projection_repository_provider.dart';
import 'handle_projector.dart';

part 'handle_projector_provider.g.dart';

@riverpod
Future<HandleProjector> handleProjector(Ref ref) async {
  final repository = await ref.watch(handleProjectionRepositoryProvider.future);
  return HandleProjector(repository: repository);
}
