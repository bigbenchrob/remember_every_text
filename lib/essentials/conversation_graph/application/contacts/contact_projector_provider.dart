import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'contact_projection_repository_provider.dart';
import 'contact_projector.dart';

part 'contact_projector_provider.g.dart';

@riverpod
Future<ContactProjector> contactProjector(Ref ref) async {
  final repository = await ref.watch(
    contactProjectionRepositoryProvider.future,
  );
  return ContactProjector(repository: repository);
}
