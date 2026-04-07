enum SidebarTopMenuChoice {
  contacts,
  strayHandles,
  searchAllMessages,
  recoveredUnlinkedMessages,
  recoveredNoHandleFromMeMessages,
}

enum SidebarSettingsMenuChoice { actions, attachmentArchive }

enum SidebarSettingsActionChoice { sendLogs, reimportData }

enum SidebarMessageScope { regular, recoveredDeleted }

enum SidebarStrayHandleFilter { phones, emails, businessUrns }

enum SidebarStrayHandleMode { allStrays, spamCandidates, dismissed }

enum SidebarActionTone { neutral, primary, destructive }

/// Typed semantic action intent transported through sidebar payload data.
///
/// LAW: Intents may describe meaning across the boundary, but they must not
/// execute behavior themselves.
sealed class SidebarActionIntent {
  const SidebarActionIntent();
}

/// Immutable action descriptor for render-edge wiring.
///
/// This type may carry copy, tone, iconography, and a typed intent only.
/// Callback fields, dispatcher objects, refs, and UI runtime state are not
/// allowed here.
final class SidebarActionDescriptor {
  const SidebarActionDescriptor({
    required this.label,
    required this.intent,
    this.tone = SidebarActionTone.neutral,
    this.icon,
    this.isEnabled = true,
  });

  final String label;
  final SidebarActionIntent intent;
  final SidebarActionTone tone;
  final String? icon;
  final bool isEnabled;
}

final class TopMenuChanged extends SidebarActionIntent {
  const TopMenuChanged({required this.choice});

  final SidebarTopMenuChoice choice;
}

final class SettingsMenuChanged extends SidebarActionIntent {
  const SettingsMenuChanged({required this.choice});

  final SidebarSettingsMenuChoice choice;
}

final class SettingsActionChosen extends SidebarActionIntent {
  const SettingsActionChosen({required this.choice});

  final SidebarSettingsActionChoice choice;
}

final class ContactChosen extends SidebarActionIntent {
  const ContactChosen({required this.contactId});

  final int contactId;
}

final class ChooseAnotherContact extends SidebarActionIntent {
  const ChooseAnotherContact();
}

final class ContactHandleSelected extends SidebarActionIntent {
  const ContactHandleSelected({
    required this.contactId,
    required this.handleId,
  });

  final int contactId;
  final int? handleId;
}

final class ContactMessageScopeChanged extends SidebarActionIntent {
  const ContactMessageScopeChanged({
    required this.contactId,
    required this.scope,
  });

  final int contactId;
  final SidebarMessageScope scope;
}

final class HeatMapMonthFocused extends SidebarActionIntent {
  const HeatMapMonthFocused({this.monthAnchor, this.contactId});

  final int? contactId;
  final DateTime? monthAnchor;
}

final class RecoveredMonthFocused extends SidebarActionIntent {
  const RecoveredMonthFocused({
    required this.monthAnchor,
    this.contactId,
    this.onlyNoHandleFromMe = false,
  });

  final int? contactId;
  final DateTime monthAnchor;
  final bool onlyNoHandleFromMe;
}

final class StrayHandleFilterChanged extends SidebarActionIntent {
  const StrayHandleFilterChanged({required this.filter});

  final SidebarStrayHandleFilter filter;
}

final class StrayHandleModeChanged extends SidebarActionIntent {
  const StrayHandleModeChanged({required this.mode});

  final SidebarStrayHandleMode mode;
}

final class StrayHandleOpened extends SidebarActionIntent {
  const StrayHandleOpened({required this.handleId});

  final int handleId;
}

final class StrayHandleDismissed extends SidebarActionIntent {
  const StrayHandleDismissed({required this.normalizedHandle});

  final String normalizedHandle;
}

final class StrayHandleRestored extends SidebarActionIntent {
  const StrayHandleRestored({required this.normalizedHandle});

  final String normalizedHandle;
}

final class ReimportDataRequested extends SidebarActionIntent {
  const ReimportDataRequested();
}

final class SendLogsRequested extends SidebarActionIntent {
  const SendLogsRequested();
}
