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

final class _ArchiveMutationAsyncContext {
  const _ArchiveMutationAsyncContext({
    required this.ownerId,
    required this.operation,
  });

  final String ownerId;
  final ArchiveMutationOperation operation;
}

class ArchiveMutationCoordinatorState {
  const ArchiveMutationCoordinatorState({
    this.operation,
    this.ownerId,
    this.ownerLabel,
    this.activeOperations = const <ArchiveMutationOperation>[],
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
  final List<ArchiveMutationOperation> activeOperations;
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
  bool get blocksDatabaseReopen {
    if (activeOperations.isEmpty) {
      return operation?.blocksDatabaseReopen ?? false;
    }
    return activeOperations.any((operation) => operation.blocksDatabaseReopen);
  }
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
  var _nextScopeSequence = 0;
  var _isDisposed = false;
  final Map<int, ArchiveMutationOperation> _activeScopes = {};

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
    final inheritedContext =
        Zone.current[_archiveMutationOwnerZoneKey]
            as _ArchiveMutationAsyncContext?;
    final ownerId =
        inheritedContext?.ownerId ?? '$ownerLabel#${++_nextOwnerSequence}';
    final scopeId = _tryAcquire(
      operation: operation,
      ownerId: ownerId,
      ownerLabel: ownerLabel,
    );
    if (scopeId == null) {
      throw ArchiveMutationDeniedException(
        requestedOperation: operation,
        requestedOwner: ownerLabel,
        currentOperation: state.operation,
        currentOwner: state.ownerLabel,
      );
    }

    try {
      await _requireVerifiedCheckpointWhenApplicable(operation);
      return await runZoned(
        action,
        zoneValues: {
          _archiveMutationOwnerZoneKey: _ArchiveMutationAsyncContext(
            ownerId: ownerId,
            operation: operation,
          ),
        },
      );
    } finally {
      _release(ownerId: ownerId, scopeId: scopeId);
    }
  }

  ArchiveMutationResourceAdmission resourceAdmissionForCurrentCaller(
    ArchiveMutationResourceAction action,
  ) {
    if (!state.blocksDatabaseReopen) {
      return ArchiveMutationResourceAdmission.unrestricted;
    }

    final context =
        Zone.current[_archiveMutationOwnerZoneKey]
            as _ArchiveMutationAsyncContext?;
    final callerOwnsMutation =
        context != null && context.ownerId == state.ownerId;
    if (!callerOwnsMutation ||
        !context.operation.permitsOwnerResourceAction(action)) {
      return ArchiveMutationResourceAdmission.deniedByActiveMutation;
    }

    final strongerScopeForbidsAction = _activeScopes.values
        .where((operation) => operation.blocksDatabaseReopen)
        .any((operation) => !operation.permitsOwnerResourceAction(action));
    if (strongerScopeForbidsAction) {
      return ArchiveMutationResourceAdmission.deniedByActiveMutation;
    }

    return ArchiveMutationResourceAdmission.admittedOwner;
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

  int? _tryAcquire({
    required ArchiveMutationOperation operation,
    required String ownerId,
    required String ownerLabel,
  }) {
    final now = DateTime.now().toUtc();
    if (!state.isLocked) {
      final authority = ref.read(archiveAccessAuthorityProvider);
      final scopeId = ++_nextScopeSequence;
      _activeScopes[scopeId] = operation;
      state = ArchiveMutationCoordinatorState(
        operation: operation,
        ownerId: ownerId,
        ownerLabel: ownerLabel,
        activeOperations: List.unmodifiable(_activeScopes.values),
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
      return scopeId;
    }

    if (state.ownerId == ownerId) {
      final scopeId = ++_nextScopeSequence;
      _activeScopes[scopeId] = operation;
      state = ArchiveMutationCoordinatorState(
        operation: state.operation,
        ownerId: state.ownerId,
        ownerLabel: state.ownerLabel,
        activeOperations: List.unmodifiable(_activeScopes.values),
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
      return scopeId;
    }

    state = ArchiveMutationCoordinatorState(
      operation: state.operation,
      ownerId: state.ownerId,
      ownerLabel: state.ownerLabel,
      activeOperations: state.activeOperations,
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
    return null;
  }

  void _release({required String ownerId, required int scopeId}) {
    if (_isDisposed) {
      return;
    }
    if (!state.isLocked || state.ownerId != ownerId) {
      return;
    }

    _activeScopes.remove(scopeId);
    final nextHoldCount = _activeScopes.length;
    if (nextHoldCount > 0) {
      state = ArchiveMutationCoordinatorState(
        operation: state.operation,
        ownerId: state.ownerId,
        ownerLabel: state.ownerLabel,
        activeOperations: List.unmodifiable(_activeScopes.values),
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

    _activeScopes.clear();
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
