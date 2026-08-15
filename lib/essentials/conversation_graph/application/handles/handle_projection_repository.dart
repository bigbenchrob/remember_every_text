class HandleProjectionResult {
  const HandleProjectionResult({
    required this.examinedHandleCount,
    required this.insertedHandleCount,
  });

  final int examinedHandleCount;
  final int insertedHandleCount;
}

class HandleIdentityProjectionResult {
  const HandleIdentityProjectionResult({
    required this.examinedHandleCount,
    required this.updatedHandleCount,
  });

  final int examinedHandleCount;
  final int updatedHandleCount;
}

abstract interface class HandleProjectionRepository {
  Future<HandleProjectionResult> projectHandles();

  Future<HandleIdentityProjectionResult> projectLocalAccountIdentity();
}
