import 'sidebar_utilities_constants.dart';

sealed class SettingsTopMenuRow {
  const SettingsTopMenuRow();
}

enum SettingsTopMenuActionSemantic { persistentContext, transientAction }

final class SettingsTopMenuGroupHeaderRow extends SettingsTopMenuRow {
  const SettingsTopMenuGroupHeaderRow({required this.label});

  final String label;
}

final class SettingsTopMenuActionRow extends SettingsTopMenuRow {
  const SettingsTopMenuActionRow({
    required this.label,
    required this.actionId,
    required this.semantic,
  });

  const SettingsTopMenuActionRow.persistentContext({
    required this.label,
    required this.actionId,
  }) : semantic = SettingsTopMenuActionSemantic.persistentContext;

  const SettingsTopMenuActionRow.transientAction({
    required this.label,
    required this.actionId,
  }) : semantic = SettingsTopMenuActionSemantic.transientAction;

  final String label;
  final SettingsMenuActionId actionId;
  final SettingsTopMenuActionSemantic semantic;

  bool get isPersistentContext {
    return semantic == SettingsTopMenuActionSemantic.persistentContext;
  }
}
