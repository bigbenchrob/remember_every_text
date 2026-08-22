import 'archive_mutation_operation.dart';

final class ArchiveMutationCapabilityDeniedException implements Exception {
  const ArchiveMutationCapabilityDeniedException({
    required this.requestedOperation,
    required this.capabilityOperation,
  });

  final ArchiveMutationOperation requestedOperation;
  final ArchiveMutationOperation capabilityOperation;

  @override
  String toString() {
    return 'Archive mutation capability denied: an active '
        '${requestedOperation.name} scope is required, but the supplied '
        '${capabilityOperation.name} capability is inactive or belongs to a '
        'different operation scope.';
  }
}
