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
            _SidebarInfoBody(text: bodyText, style: typography.infoCardBody),
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

class _SidebarInfoBody extends StatelessWidget {
  const _SidebarInfoBody({required this.text, required this.style});

  final String text;
  final TextStyle style;

  static final RegExp _bulletPattern = RegExp(r'^([•*])\s+(.*)$');

  @override
  Widget build(BuildContext context) {
    final blocks = text.split('\n\n');
    final children = <Widget>[];

    for (var index = 0; index < blocks.length; index++) {
      final block = blocks[index].trim();
      if (block.isEmpty) {
        continue;
      }

      if (children.isNotEmpty) {
        children.add(const SizedBox(height: AppSpacing.sm));
      }

      children.add(_buildBlock(block));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Widget _buildBlock(String block) {
    final lines = block.split('\n');
    final bulletMatches = lines
        .map((line) => _bulletPattern.firstMatch(line.trimRight()))
        .toList();
    final allBulletLines =
        bulletMatches.isNotEmpty &&
        bulletMatches.every((match) => match != null);

    if (!allBulletLines) {
      return Text(block, style: style, textAlign: TextAlign.start);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < bulletMatches.length; index++) ...[
          if (index > 0) const SizedBox(height: AppSpacing.xs),
          _SidebarBulletLine(
            marker: bulletMatches[index]!.group(1)!,
            text: bulletMatches[index]!.group(2)!,
            style: style,
          ),
        ],
      ],
    );
  }
}

class _SidebarBulletLine extends StatelessWidget {
  const _SidebarBulletLine({
    required this.marker,
    required this.text,
    required this.style,
  });

  final String marker;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.xs),
          child: Text(marker, style: style, textAlign: TextAlign.start),
        ),
        Expanded(
          child: Text(text, style: style, textAlign: TextAlign.start),
        ),
      ],
    );
  }
}
