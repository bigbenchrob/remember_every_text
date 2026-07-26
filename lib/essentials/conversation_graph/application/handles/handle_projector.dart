import 'handle_projection_repository.dart';

class HandleProjector {
  const HandleProjector({required this.repository});

  final HandleProjectionRepository repository;

  Future<HandleProjectionResult> projectHandles() =>
      repository.projectHandles();

  Future<HandleIdentityProjectionResult> projectLocalAccountIdentity() =>
      repository.projectLocalAccountIdentity();
}
