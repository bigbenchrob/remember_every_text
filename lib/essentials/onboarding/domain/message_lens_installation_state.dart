import 'onboarding_operation_snapshot.dart';

enum MessageLensInstallationStateKind {
  virgin,
  resumable,
  completed,
  abandoned,
  remediationRequired,
}

final class InstallationDatabaseEvidence {
  const InstallationDatabaseEvidence({
    required this.exists,
    required this.readable,
    required this.integrityOk,
    required this.schemaVersionSupported,
    this.userVersion,
    this.messageCount,
    this.chatCount,
    this.chatMessageEdgeCount,
    this.nonLiveSourceCount,
    this.failure,
  });

  const InstallationDatabaseEvidence.absent()
    : this(
        exists: false,
        readable: false,
        integrityOk: false,
        schemaVersionSupported: false,
      );

  final bool exists;
  final bool readable;
  final bool integrityOk;
  final bool schemaVersionSupported;
  final int? userVersion;
  final int? messageCount;
  final int? chatCount;
  final int? chatMessageEdgeCount;
  final int? nonLiveSourceCount;
  final String? failure;

  bool get isUsable {
    return exists && readable && integrityOk && schemaVersionSupported;
  }
}

final class MessageLensInstallationEvidence {
  const MessageLensInstallationEvidence({
    required this.sourceScopedImport,
    required this.conversationGraph,
    required this.overlay,
    required this.presence,
    required this.hasRetiredDerivedArtifacts,
    required this.operationSnapshot,
  });

  final InstallationDatabaseEvidence sourceScopedImport;
  final InstallationDatabaseEvidence conversationGraph;
  final InstallationDatabaseEvidence overlay;
  final InstallationDatabaseEvidence presence;
  final bool hasRetiredDerivedArtifacts;
  final OnboardingOperationSnapshot operationSnapshot;
}

final class MessageLensInstallationState {
  const MessageLensInstallationState({
    required this.kind,
    required this.reason,
  });

  final MessageLensInstallationStateKind kind;
  final String reason;

  bool get mayContinue {
    return kind == MessageLensInstallationStateKind.virgin ||
        kind == MessageLensInstallationStateKind.resumable ||
        kind == MessageLensInstallationStateKind.completed;
  }

  bool get mayStartFresh {
    return kind == MessageLensInstallationStateKind.resumable ||
        kind == MessageLensInstallationStateKind.abandoned;
  }

  bool get requiresStartupAttention {
    return kind == MessageLensInstallationStateKind.abandoned ||
        kind == MessageLensInstallationStateKind.remediationRequired;
  }
}
