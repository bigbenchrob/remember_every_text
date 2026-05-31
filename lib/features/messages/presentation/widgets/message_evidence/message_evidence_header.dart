import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart' as macos_ui;

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../essentials/debug/application/developer_mode_provider.dart';
import '../../../domain/message_evidence/message_evidence_search_mode.dart';

class MessageEvidenceHeaderModel {
  const MessageEvidenceHeaderModel({
    required this.title,
    this.identityContextLine,
    this.scopeContextLine,
    this.dateRangeLabel,
    this.countLabel,
    this.scopeNote,
    this.activeScopeLabel,
    this.statusLine,
    this.activeScopeIndicator,
    this.searchConfig,
    this.actions,
    this.details,
    this.legacySubtitleParts = const <String>[],
  });

  final String title;
  final String? identityContextLine;
  final String? scopeContextLine;
  final String? dateRangeLabel;
  final String? countLabel;
  final String? scopeNote;
  final String? activeScopeLabel;
  final String? statusLine;
  final Widget? activeScopeIndicator;
  final MessageEvidenceHeaderSearchConfig? searchConfig;
  final Widget? actions;
  final Widget? details;
  final List<String> legacySubtitleParts;
}

class MessageEvidenceHeaderSearchConfig {
  const MessageEvidenceHeaderSearchConfig({
    required this.controller,
    required this.placeholder,
    this.mode,
    this.onModeChanged,
  });

  final TextEditingController controller;
  final String placeholder;
  final MessageEvidenceSearchMode? mode;
  final ValueChanged<MessageEvidenceSearchMode>? onModeChanged;
}

class MessageEvidenceHeader extends ConsumerWidget {
  const MessageEvidenceHeader({
    required this.data,
    this.details,
    this.padding = const EdgeInsets.fromLTRB(32, 24, 32, 28),
    super.key,
  });

  final MessageEvidenceHeaderModel data;
  final Widget? details;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final identityContextLine = data.identityContextLine?.trim();
    final scopeContextLine = data.scopeContextLine?.trim();
    final scopeNote = data.scopeNote?.trim();
    final activeScopeLabel = data.activeScopeLabel?.trim();
    final developerMode = ref.watch(developerModeProvider).valueOrNull;
    final shouldShowDeveloperStatus =
        developerMode == DeveloperModeValue.developer;
    final statusLine = shouldShowDeveloperStatus
        ? data.statusLine?.trim()
        : null;
    final hasIdentityContext =
        identityContextLine != null && identityContextLine.isNotEmpty;
    final metricParts =
        [data.dateRangeLabel, data.countLabel, ...data.legacySubtitleParts]
            .whereType<String>()
            .where((part) => part.trim().isNotEmpty)
            .toList(growable: false);
    final resolvedDetails = data.details ?? details;

    return ColoredBox(
      color: colors.messagePanels.coolPanelSurface,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data.title, style: typography.title1),
            if (hasIdentityContext) ...[
              const SizedBox(height: 10),
              Text(
                identityContextLine,
                style: typography.callout.copyWith(
                  color: colors.content.textSecondary,
                ),
              ),
            ],
            if (metricParts.isNotEmpty) ...[
              SizedBox(height: hasIdentityContext ? 8 : 13),
              Wrap(
                spacing: 14,
                runSpacing: 4,
                children: [
                  for (final part in metricParts)
                    Text(
                      part,
                      style: typography.callout.copyWith(
                        color: colors.content.textSecondary,
                      ),
                    ),
                ],
              ),
            ],
            if (scopeContextLine != null && scopeContextLine.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                scopeContextLine,
                style: typography.caption.copyWith(
                  color: colors.content.textSecondary,
                ),
              ),
            ],
            if (scopeNote != null && scopeNote.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                scopeNote,
                style: typography.caption.copyWith(
                  color: colors.content.textSecondary,
                ),
              ),
            ],
            if (activeScopeLabel != null && activeScopeLabel.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                activeScopeLabel,
                style: typography.caption.copyWith(
                  color: colors.content.textSecondary,
                ),
              ),
            ],
            if (statusLine != null && statusLine.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                statusLine,
                style: typography.caption.copyWith(
                  color: colors.content.textSecondary,
                ),
              ),
            ],
            if (data.activeScopeIndicator != null) ...[
              const SizedBox(height: 10),
              data.activeScopeIndicator!,
            ],
            if (data.searchConfig != null) ...[
              const SizedBox(height: 18),
              _MessageEvidenceHeaderSearchRow(config: data.searchConfig!),
            ],
            if (data.actions != null) ...[
              const SizedBox(height: 14),
              _MessageEvidenceHeaderActionRow(child: data.actions!),
            ],
            if (resolvedDetails != null) ...[
              const SizedBox(height: 12),
              resolvedDetails,
            ],
          ],
        ),
      ),
    );
  }
}

class _MessageEvidenceHeaderSearchRow extends ConsumerWidget {
  const _MessageEvidenceHeaderSearchRow({required this.config});

  final MessageEvidenceHeaderSearchConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.search,
            size: 15,
            color: colors.content.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: macos_ui.MacosTextField(
              controller: config.controller,
              placeholder: config.placeholder,
              clearButtonMode: macos_ui.OverlayVisibilityMode.editing,
            ),
          ),
          if (config.mode != null && config.onModeChanged != null) ...[
            const SizedBox(width: 8),
            _MessageEvidenceSearchModeToggle(
              mode: config.mode!,
              onModeChanged: config.onModeChanged!,
            ),
          ],
        ],
      ),
    );
  }
}

class _MessageEvidenceSearchModeToggle extends ConsumerWidget {
  const _MessageEvidenceSearchModeToggle({
    required this.mode,
    required this.onModeChanged,
  });

  final MessageEvidenceSearchMode mode;
  final ValueChanged<MessageEvidenceSearchMode> onModeChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.control,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SearchModeSegment(
              label: 'AND',
              isSelected: mode == MessageEvidenceSearchMode.allTerms,
              onPressed: () {
                onModeChanged(MessageEvidenceSearchMode.allTerms);
              },
            ),
            _SearchModeSegment(
              label: 'OR',
              isSelected: mode == MessageEvidenceSearchMode.anyTerm,
              onPressed: () {
                onModeChanged(MessageEvidenceSearchMode.anyTerm);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchModeSegment extends ConsumerWidget {
  const _SearchModeSegment({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return GestureDetector(
      onTap: onPressed,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isSelected
              ? colors.surfaces.selected
              : colors.surfaces.control.withValues(alpha: 0),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Text(
            label,
            style: typography.caption.copyWith(
              color: isSelected
                  ? colors.content.textPrimary
                  : colors.content.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageEvidenceHeaderActionRow extends StatelessWidget {
  const _MessageEvidenceHeaderActionRow({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      child: child,
    );
  }
}

class MessageEvidenceDisclosureButton extends ConsumerWidget {
  const MessageEvidenceDisclosureButton({
    required this.label,
    required this.isExpanded,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool isExpanded;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return GestureDetector(
      onTap: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isExpanded
                ? CupertinoIcons.chevron_down
                : CupertinoIcons.chevron_right,
            size: 13,
            color: colors.content.textSecondary,
          ),
          const SizedBox(width: 5),
          Text(label, style: typography.caption),
        ],
      ),
    );
  }
}
