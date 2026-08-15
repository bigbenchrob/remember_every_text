final class ArchiveCheckpointException implements Exception {
  const ArchiveCheckpointException(this.message);

  final String message;

  @override
  String toString() => 'ArchiveCheckpointException: $message';
}
