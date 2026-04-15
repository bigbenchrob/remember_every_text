enum EnvironmentReadinessStepKey {
  fullDiskAccess,
  messagesDatabase,
  contactsDatabase,
  importReadiness,
}

enum EnvironmentReadinessStepStatus { pending, active, success }

enum EnvironmentReadinessTone { primary, warning, success }

enum EnvironmentReadinessActionKind {
  openSettings,
  recheck,
  startImport,
  sendReport,
}

class EnvironmentReadinessAction {
  const EnvironmentReadinessAction({required this.kind, required this.label});

  final EnvironmentReadinessActionKind kind;
  final String label;
}

class EnvironmentReadinessStepViewModel {
  const EnvironmentReadinessStepViewModel({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.status,
  });

  final EnvironmentReadinessStepKey key;
  final String title;
  final String subtitle;
  final EnvironmentReadinessStepStatus status;
}

class EnvironmentReadinessDetailViewModel {
  const EnvironmentReadinessDetailViewModel({
    required this.stepKey,
    required this.title,
    required this.body,
    required this.instructions,
    required this.actions,
    required this.tone,
  });

  final EnvironmentReadinessStepKey stepKey;
  final String title;
  final String body;
  final List<String> instructions;
  final List<EnvironmentReadinessAction> actions;
  final EnvironmentReadinessTone tone;
}

class EnvironmentReadinessSurfaceViewModel {
  const EnvironmentReadinessSurfaceViewModel({
    required this.activeStepKey,
    required this.steps,
    required this.detailsByStep,
    required this.detail,
  });

  final EnvironmentReadinessStepKey activeStepKey;
  final List<EnvironmentReadinessStepViewModel> steps;
  final Map<EnvironmentReadinessStepKey, EnvironmentReadinessDetailViewModel>
  detailsByStep;
  final EnvironmentReadinessDetailViewModel detail;
}
