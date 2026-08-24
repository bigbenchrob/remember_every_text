class HandleProjectionResult {
  const HandleProjectionResult({
    required this.examinedHandleCount,
    required this.insertedHandleCount,
    this.normalizedHandleCount = 0,
    this.preservedUnnormalizedHandleCount = 0,
  });

  final int examinedHandleCount;
  final int insertedHandleCount;
  final int normalizedHandleCount;
  final int preservedUnnormalizedHandleCount;
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
