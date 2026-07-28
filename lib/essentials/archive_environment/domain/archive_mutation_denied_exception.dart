import 'archive_mutation_operation.dart';

final class ArchiveMutationDeniedException implements Exception {
  const ArchiveMutationDeniedException({
    required this.requestedOperation,
    required this.requestedOwner,
    required this.currentOperation,
    required this.currentOwner,
  });

  final ArchiveMutationOperation requestedOperation;
  final String requestedOwner;
  final ArchiveMutationOperation? currentOperation;
  final String? currentOwner;

  @override
  String toString() {
    return 'Archive mutation denied: $requestedOwner requested '
        '${requestedOperation.name} while ${currentOwner ?? 'another owner'} '
        'held ${currentOperation?.name ?? 'archive mutation authority'}.';
  }
}
