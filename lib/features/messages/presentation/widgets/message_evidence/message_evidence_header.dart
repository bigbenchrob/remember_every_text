import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';

class MessageEvidenceHeaderData {
  const MessageEvidenceHeaderData({
    required this.title,
    this.subtitleParts = const <String>[],
    this.statusLine,
    this.scopeIndicator,
  });

  final String title;
  final List<String> subtitleParts;
  final String? statusLine;
  final Widget? scopeIndicator;
}

class MessageEvidenceHeader extends ConsumerWidget {
  const MessageEvidenceHeader({
    required this.data,
    this.actionStrip,
    this.details,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 8),
    super.key,
  });

  final MessageEvidenceHeaderData data;
  final Widget? actionStrip;
  final Widget? details;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final subtitleParts = data.subtitleParts
        .where((part) => part.trim().isNotEmpty)
        .toList(growable: false);
    final statusLine = data.statusLine?.trim();

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.title, style: typography.title1),
          if (subtitleParts.isNotEmpty) ...[
            const SizedBox(height: 5),
            Wrap(
              spacing: 14,
              runSpacing: 4,
              children: [
                for (final part in subtitleParts)
                  Text(part, style: typography.callout),
              ],
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
          if (data.scopeIndicator != null) ...[
            const SizedBox(height: 6),
            data.scopeIndicator!,
          ],
          if (actionStrip != null) ...[const SizedBox(height: 8), actionStrip!],
          if (details != null) ...[const SizedBox(height: 10), details!],
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
