import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/spacing/app_spacing.dart';
import '../../../../config/theme/theme_typography.dart';

/// A “soft” informational card for explanatory text.
///
/// Intent:
/// - Lives in the cassette flow (so it *is* a card)
/// - Lighter than SidebarCassetteCard (no shadow, subtle tint)
/// - Optional title + body + footnote
/// - Optional [action] widget rendered below body as a footnote-action
///   (mutually exclusive with [footnote])
class SidebarInfoCard extends ConsumerWidget {
  const SidebarInfoCard({
    super.key,
    this.title,
    required this.bodyText,
    this.footnote,
    this.content,
    this.margin = const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    this.padding = const EdgeInsets.symmetric(vertical: AppSpacing.md),
  }) : assert(true);

  final String? title;
  final String bodyText;
  final String? footnote;

  /// Optional supplemental widget rendered below the text block.
  final Widget? content;

  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);

    final hasTitle = title != null && title!.trim().isNotEmpty;
    final hasFootnote = footnote != null && footnote!.trim().isNotEmpty;

    return Padding(
      padding: margin,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasTitle) ...[
              Text(title!, style: typography.infoCardTitle),
              const SizedBox(height: AppSpacing.sm),
            ],
            Text(
              bodyText,
              style: typography.infoCardBody,
              textAlign: TextAlign.justify,
            ),
            if (hasFootnote) ...[
              const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
              Text(footnote!, style: typography.infoCardFootnote),
            ],
            if (content != null) ...[
              const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
              content!,
            ],
          ],
        ),
      ),
    );
  }
}
