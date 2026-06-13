import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../feature_level_providers.dart';
import 'handle_projector.dart';

part 'handle_projector_provider.g.dart';

@riverpod
Future<HandleProjector> handleProjector(Ref ref) async {
  final repository = await ref.watch(handleProjectionRepositoryProvider.future);
  return HandleProjector(repository: repository);
}
