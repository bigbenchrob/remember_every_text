import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/archive_checkpoint_required_exception.dart';
import '../domain/archive_environment.dart';
import '../domain/archive_instance_id.dart';
import '../domain/archive_mutation_denied_exception.dart';
import '../domain/archive_mutation_operation.dart';
import 'archive_access_authority_provider.dart';
import 'verified_archive_checkpoint_provider.dart';

part 'archive_mutation_coordinator_provider.g.dart';

final Object _archiveMutationOwnerZoneKey = Object();

class ArchiveMutationCoordinatorState {
  const ArchiveMutationCoordinatorState({
    this.operation,
    this.ownerId,
    this.ownerLabel,
    this.environment,
    this.archiveInstanceId,
    this.holdCount = 0,
    this.acquiredAtUtc,
    this.lastReleasedAtUtc,
    this.lastDeniedOperation,
    this.lastDeniedOwner,
    this.lastDeniedAtUtc,
    this.deniedRequests = 0,
  });

  final ArchiveMutationOperation? operation;
  final String? ownerId;
  final String? ownerLabel;
  final ArchiveEnvironment? environment;
  final ArchiveInstanceId? archiveInstanceId;
  final int holdCount;
  final DateTime? acquiredAtUtc;
  final DateTime? lastReleasedAtUtc;
  final ArchiveMutationOperation? lastDeniedOperation;
  final String? lastDeniedOwner;
  final DateTime? lastDeniedAtUtc;
  final int deniedRequests;

  bool get isLocked => ownerId != null;
  bool get blocksDatabaseReopen => operation?.blocksDatabaseReopen ?? false;
}

/// Single process-local admission authority for every archive mutation.
///
/// Feature owners retain their business logic. They request a named operation
/// here before mutating an admitted archive. Nested stages inherit the same
/// owner through the async Zone and may re-enter without creating another
/// authority source.
@Riverpod(keepAlive: true)
class ArchiveMutationCoordinator extends _$ArchiveMutationCoordinator {
  var _nextOwnerSequence = 0;
  var _isDisposed = false;

  @override
  ArchiveMutationCoordinatorState build() {
    ref.onDispose(() {
      _isDisposed = true;
    });
    return const ArchiveMutationCoordinatorState();
  }

  Future<T> run<T>({
    required ArchiveMutationOperation operation,
    required String ownerLabel,
    required Future<T> Function() action,
  }) async {
    final inheritedOwnerId =
        Zone.current[_archiveMutationOwnerZoneKey] as String?;
    final ownerId = inheritedOwnerId ?? '$ownerLabel#${++_nextOwnerSequence}';
    if (!_tryAcquire(
      operation: operation,
      ownerId: ownerId,
      ownerLabel: ownerLabel,
    )) {
      throw ArchiveMutationDeniedException(
        requestedOperation: operation,
        requestedOwner: ownerLabel,
        currentOperation: state.operation,
        currentOwner: state.ownerLabel,
      );
    }

    try {
      if (inheritedOwnerId == null) {
        await _requireVerifiedCheckpointWhenApplicable(operation);
      }
      if (inheritedOwnerId != null) {
        return await action();
      }
      return await runZoned(
        action,
        zoneValues: {_archiveMutationOwnerZoneKey: ownerId},
      );
    } finally {
      _release(ownerId);
    }
  }

  Future<void> _requireVerifiedCheckpointWhenApplicable(
    ArchiveMutationOperation operation,
  ) async {
    final authority = ref.read(archiveAccessAuthorityProvider);
    if (authority.identity.environment != ArchiveEnvironment.production ||
        !operation.requiresVerifiedCheckpoint) {
      return;
    }

    final receipt = ref.read(verifiedArchiveCheckpointProvider);
    if (receipt == null) {
      throw ArchiveCheckpointRequiredException(
        operation: operation,
        reason: 'no verified checkpoint receipt is registered.',
      );
    }
    final validator = ref.read(archiveCheckpointReceiptValidatorProvider);
    if (!await validator.validates(receipt: receipt, authority: authority)) {
      throw ArchiveCheckpointRequiredException(
        operation: operation,
        reason:
            'the registered checkpoint no longer matches this archive identity and file inventory.',
      );
    }
  }

  bool _tryAcquire({
    required ArchiveMutationOperation operation,
    required String ownerId,
    required String ownerLabel,
  }) {
    final now = DateTime.now().toUtc();
    if (!state.isLocked) {
      final authority = ref.read(archiveAccessAuthorityProvider);
      state = ArchiveMutationCoordinatorState(
        operation: operation,
        ownerId: ownerId,
        ownerLabel: ownerLabel,
        environment: authority.identity.environment,
        archiveInstanceId: authority.identity.archiveInstanceId,
        holdCount: 1,
        acquiredAtUtc: now,
        lastReleasedAtUtc: state.lastReleasedAtUtc,
        lastDeniedOperation: state.lastDeniedOperation,
        lastDeniedOwner: state.lastDeniedOwner,
        lastDeniedAtUtc: state.lastDeniedAtUtc,
        deniedRequests: state.deniedRequests,
      );
      return true;
    }

    if (state.ownerId == ownerId) {
      state = ArchiveMutationCoordinatorState(
        operation: state.operation,
        ownerId: state.ownerId,
        ownerLabel: state.ownerLabel,
        environment: state.environment,
        archiveInstanceId: state.archiveInstanceId,
        holdCount: state.holdCount + 1,
        acquiredAtUtc: state.acquiredAtUtc,
        lastReleasedAtUtc: state.lastReleasedAtUtc,
        lastDeniedOperation: state.lastDeniedOperation,
        lastDeniedOwner: state.lastDeniedOwner,
        lastDeniedAtUtc: state.lastDeniedAtUtc,
        deniedRequests: state.deniedRequests,
      );
      return true;
    }

    state = ArchiveMutationCoordinatorState(
      operation: state.operation,
      ownerId: state.ownerId,
      ownerLabel: state.ownerLabel,
      environment: state.environment,
      archiveInstanceId: state.archiveInstanceId,
      holdCount: state.holdCount,
      acquiredAtUtc: state.acquiredAtUtc,
      lastReleasedAtUtc: state.lastReleasedAtUtc,
      lastDeniedOperation: operation,
      lastDeniedOwner: ownerLabel,
      lastDeniedAtUtc: now,
      deniedRequests: state.deniedRequests + 1,
    );
    return false;
  }

  void _release(String ownerId) {
    if (_isDisposed) {
      return;
    }
    if (!state.isLocked || state.ownerId != ownerId) {
      return;
    }

    final nextHoldCount = state.holdCount - 1;
    if (nextHoldCount > 0) {
      state = ArchiveMutationCoordinatorState(
        operation: state.operation,
        ownerId: state.ownerId,
        ownerLabel: state.ownerLabel,
        environment: state.environment,
        archiveInstanceId: state.archiveInstanceId,
        holdCount: nextHoldCount,
        acquiredAtUtc: state.acquiredAtUtc,
        lastReleasedAtUtc: state.lastReleasedAtUtc,
        lastDeniedOperation: state.lastDeniedOperation,
        lastDeniedOwner: state.lastDeniedOwner,
        lastDeniedAtUtc: state.lastDeniedAtUtc,
        deniedRequests: state.deniedRequests,
      );
      return;
    }

    state = ArchiveMutationCoordinatorState(
      lastReleasedAtUtc: DateTime.now().toUtc(),
      lastDeniedOperation: state.lastDeniedOperation,
      lastDeniedOwner: state.lastDeniedOwner,
      lastDeniedAtUtc: state.lastDeniedAtUtc,
      deniedRequests: state.deniedRequests,
    );
  }
}

@riverpod
bool archiveDatabaseReopenBlocked(Ref ref) {
  return ref.watch(
    archiveMutationCoordinatorProvider.select(
      (state) => state.blocksDatabaseReopen,
    ),
  );
}
