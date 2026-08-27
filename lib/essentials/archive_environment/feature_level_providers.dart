/// Public provider seam for admitted archive access.
///
/// Consumers may resolve app-owned paths only through the authority exposed
/// here. Physical environment-root discovery remains private to admission.
export 'application/archive_access_authority_provider.dart';
export 'application/archive_mutation_coordinator_provider.dart';
export 'application/archive_owned_resource_registry_provider.dart';
export 'application/verified_archive_checkpoint_provider.dart';
