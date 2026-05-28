import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';

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
    this.controls,
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
  final Widget? controls;
  final Widget? actions;
  final Widget? details;
  final List<String> legacySubtitleParts;
}

class MessageEvidenceHeaderData extends MessageEvidenceHeaderModel {
  const MessageEvidenceHeaderData({
    required String title,
    List<String> subtitleParts = const <String>[],
    String? statusLine,
    Widget? scopeIndicator,
    Widget? controls,
  }) : super(
         title: title,
         statusLine: statusLine,
         activeScopeIndicator: scopeIndicator,
         controls: controls,
         legacySubtitleParts: subtitleParts,
       );
}

class MessageEvidenceHeader extends ConsumerWidget {
  const MessageEvidenceHeader({
    required this.data,
    this.actionStrip,
    this.details,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 8),
    super.key,
  });

  final MessageEvidenceHeaderModel data;
  final Widget? actionStrip;
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
    final statusLine = data.statusLine?.trim();
    final metricParts =
        [data.dateRangeLabel, data.countLabel, ...data.legacySubtitleParts]
            .whereType<String>()
            .where((part) => part.trim().isNotEmpty)
            .toList(growable: false);
    final actions = data.actions ?? actionStrip;
    final resolvedDetails = data.details ?? details;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.title, style: typography.title1),
          if (identityContextLine != null &&
              identityContextLine.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(identityContextLine, style: typography.callout),
          ],
          if (metricParts.isNotEmpty) ...[
            const SizedBox(height: 5),
            Wrap(
              spacing: 14,
              runSpacing: 4,
              children: [
                for (final part in metricParts)
                  Text(part, style: typography.callout),
              ],
            ),
          ],
          if (scopeContextLine != null && scopeContextLine.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              scopeContextLine,
              style: typography.caption.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          ],
          if (scopeNote != null && scopeNote.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              scopeNote,
              style: typography.caption.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          ],
          if (activeScopeLabel != null && activeScopeLabel.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              activeScopeLabel,
              style: typography.caption.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          ],
          if (statusLine != null && statusLine.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              statusLine,
              style: typography.caption.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          ],
          if (data.activeScopeIndicator != null) ...[
            const SizedBox(height: 6),
            data.activeScopeIndicator!,
          ],
          if (data.controls != null) ...[
            const SizedBox(height: 8),
            data.controls!,
          ],
          if (actions != null) ...[const SizedBox(height: 8), actions],
          if (resolvedDetails != null) ...[
            const SizedBox(height: 10),
            resolvedDetails,
          ],
        ],
      ),
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
