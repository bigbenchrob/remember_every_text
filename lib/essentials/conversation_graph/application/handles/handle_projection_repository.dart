class HandleProjectionResult {
  const HandleProjectionResult({
    required this.examinedHandleCount,
    required this.insertedHandleCount,
  });

  final int examinedHandleCount;
  final int insertedHandleCount;
}

abstract interface class HandleProjectionRepository {
  Future<HandleProjectionResult> projectHandles();
}
