import 'archive_mutation_operation.dart';

final class ArchiveCheckpointRequiredException implements Exception {
  const ArchiveCheckpointRequiredException({
    required this.operation,
    required this.reason,
  });

  final ArchiveMutationOperation operation;
  final String reason;

  @override
  String toString() {
    return 'Verified archive checkpoint required for ${operation.name}: '
        '$reason';
  }
}
