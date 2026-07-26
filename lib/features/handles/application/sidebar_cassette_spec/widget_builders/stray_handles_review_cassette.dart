import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../../config/theme/theme_typography.dart';
import '../../../../../../essentials/sidebar/feature_level_providers.dart'
    show sidebarFlowProvider;
import '../../../../sidebar_utilities/domain/sidebar_utilities_constants.dart';
import '../../../domain/entities/stray_handle_endpoint_kind.dart';
import '../../../domain/spec_classes/handles_cassette_spec.dart';
import '../../read_models/stray_handle_summary.dart';
import '../../read_models/stray_handles_provider.dart';
import '../resolver_tools/stray_handle_sidebar_actions_provider.dart';

/// Sidebar cassette that displays a scrollable list for one unfamiliar-source
/// investigation.
///
/// Each row shows the handle value, message count, and last message date.
/// Reviewed-but-unlinked handles are visually muted. Tapping a row
/// dispatches a semantic sidebar action; center evidence derives from
/// SidebarFlowState.
///
class StrayHandlesReviewCassette extends HookConsumerWidget {
  const StrayHandlesReviewCassette({
    required this.investigation,
    required this.filter,
    required this.mode,
    super.key,
  });

  /// Fixed-width trailing gutter for the recovery action in dismissed mode.
  /// 32pt = 24pt button + 4pt padding on each side.
  static const double actionGutterWidth = 32;
  static const double _contentLaneInset = 8;

  final StrayHandleInvestigation investigation;
  final StrayHandleFilter? filter;
  final StrayHandleReviewMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final actions = ref.read(strayHandleSidebarActionsProvider.notifier);

    final asyncHandles = switch (mode) {
      StrayHandleReviewMode.active => switch (investigation) {
        StrayHandleInvestigation.identifySources => ref.watch(
          unknownSourceIdentificationHandlesProvider,
        ),
        StrayHandleInvestigation.numericSenderIds => ref.watch(
          numericSenderIdHandlesProvider,
        ),
      },
      StrayHandleReviewMode.dismissed => switch (investigation) {
        StrayHandleInvestigation.identifySources => ref.watch(
          dismissedUnknownSourceIdentificationHandlesProvider,
        ),
        StrayHandleInvestigation.numericSenderIds => ref.watch(
          dismissedNumericSenderIdHandlesProvider,
        ),
      },
    };

    return asyncHandles.when(
      data: (handles) {
        final filtered = _applyFilter(handles);
        final rowActionGutterWidth = mode == StrayHandleReviewMode.dismissed
            ? StrayHandlesReviewCassette.actionGutterWidth
            : 0.0;

        final activeHandleId = ref.watch(
          sidebarFlowProvider.select((state) {
            if (state.topMenuChoice != TopChatMenuChoice.strayHandles) {
              return null;
            }
            return state.effectiveSelectedHandleEvidenceId;
          }),
        );

        if (filtered.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
            child: Center(
              child: Text(
                _emptyMessage,
                style: typography.caption.copyWith(
                  color: colors.content.textTertiary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.separated(
          // Let ListView fill the bounded height from shouldExpand: true
          // and handle its own scrolling.
          padding: EdgeInsets.zero,
          itemCount: filtered.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            indent: _contentLaneInset,
            endIndent: rowActionGutterWidth,
          ),
          itemBuilder: (context, index) {
            final handle = filtered[index];
            return _StrayHandleRow(
              handle: handle,
              actionGutterWidth: rowActionGutterWidth,
              isSelected: handle.handleId == activeHandleId,
              onTap: () => actions.openHandleLens(handleId: handle.handleId),
              onRestore: mode == StrayHandleReviewMode.dismissed
                  ? () => actions.restoreHandle(handle)
                  : null,
            );
          },
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CupertinoActivityIndicator()),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Error loading handles: $error',
          style: typography.caption.copyWith(color: colors.accents.secondary),
        ),
      ),
    );
  }

  List<StrayHandleSummary> _applyFilter(List<StrayHandleSummary> handles) {
    final selectedFilter = filter;
    if (selectedFilter == null) {
      return handles;
    }

    return switch (selectedFilter) {
      // Business URNs start with 'urn:'
      StrayHandleFilter.businessUrns => handles.where((handle) {
        return handle.endpointKind == StrayHandleEndpointKind.businessUrn;
      }).toList(),
      // Emails contain '@'
      StrayHandleFilter.emails => handles.where((handle) {
        return handle.endpointKind == StrayHandleEndpointKind.emailAddress;
      }).toList(),
      // Phones: no '@', no 'urn:' prefix
      StrayHandleFilter.phones =>
        handles
            .where(
              (handle) =>
                  handle.endpointKind == StrayHandleEndpointKind.phoneNumber ||
                  handle.endpointKind == StrayHandleEndpointKind.other,
            )
            .toList(),
    };
  }

  String get _emptyMessage => switch (mode) {
    StrayHandleReviewMode.active => switch (investigation) {
      StrayHandleInvestigation.numericSenderIds =>
        'No numeric sender IDs require review.',
      StrayHandleInvestigation.identifySources => switch (filter) {
        StrayHandleFilter.phones =>
          'No unfamiliar phone numbers found.\nAll are linked to contacts.',
        StrayHandleFilter.emails =>
          'No unfamiliar email addresses found.\nAll are linked to contacts.',
        StrayHandleFilter.businessUrns =>
          'No unfamiliar business accounts found.\nAll are linked to contacts.',
        null => 'No unfamiliar sources require identification.',
      },
    },
    StrayHandleReviewMode.dismissed =>
      'No dismissed items.\nItems you dismiss will appear here.',
  };
}

class _StrayHandleRow extends ConsumerWidget {
  const _StrayHandleRow({
    required this.handle,
    required this.actionGutterWidth,
    required this.isSelected,
    required this.onTap,
    this.onRestore,
  });

  final StrayHandleSummary handle;
  final double actionGutterWidth;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onRestore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    final isReviewed = handle.reviewedAt != null;
    final contentAlpha = isReviewed ? 0.5 : 1.0;

    final showRestore = onRestore != null;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          // Selection highlight — inset to match divider width
          // (stops before the action gutter).
          if (isSelected)
            Positioned.fill(
              left: StrayHandlesReviewCassette._contentLaneInset,
              right: actionGutterWidth,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.accents.primary.withValues(alpha: 0.12),
                ),
              ),
            ),
          // Data container: no left padding (card wrapper provides inset)
          // Dismissed rows reserve a recovery-action gutter.
          Padding(
            padding: EdgeInsets.only(
              left: StrayHandlesReviewCassette._contentLaneInset,
              right: actionGutterWidth,
              top: 8,
              bottom: 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    handle.handleValue,
                    style: typography.body.copyWith(
                      color: colors.content.textPrimary.withValues(
                        alpha: contentAlpha,
                      ),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(width: 8),

                // Metadata (message count + date) - flows naturally, right-aligned
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Message count badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaces.hover,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${handle.totalMessages}',
                        style: typography.caption.copyWith(
                          color: colors.content.textSecondary.withValues(
                            alpha: contentAlpha,
                          ),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    // Last message date (reduced visual prominence)
                    if (handle.lastMessageDate != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(handle.lastMessageDate!),
                        style: typography.caption.copyWith(
                          color: colors.content.textTertiary.withValues(
                            alpha: contentAlpha * 0.8,
                          ),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Action button overlay (outside data flow)
          // Nudged up 2pt to align with count/date cluster
          if (showRestore)
            Positioned(
              right: 0,
              top: 0,
              bottom: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: _RestoreButton(onPressed: onRestore!, colors: colors),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return DateFormat.jm().format(date);
    } else if (diff.inDays < 7) {
      return DateFormat.E().format(date);
    } else if (diff.inDays < 365) {
      return DateFormat.MMMd().format(date);
    } else {
      return DateFormat.yMMMd().format(date);
    }
  }
}

/// Restore button with hover state.
class _RestoreButton extends StatefulWidget {
  const _RestoreButton({required this.onPressed, required this.colors});

  final VoidCallback onPressed;
  final ThemeColors colors;

  @override
  State<_RestoreButton> createState() => _RestoreButtonState();
}

class _RestoreButtonState extends State<_RestoreButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.colors.accents.tertiary;
    final bgAlpha = _isPressed ? 0.25 : (_isHovered ? 0.15 : 0.08);
    final iconAlpha = _isPressed ? 1.0 : (_isHovered ? 0.9 : 0.6);

    return Tooltip(
      message: 'Restore',
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onPressed,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: bgAlpha),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              CupertinoIcons.arrow_uturn_left,
              size: 12,
              color: baseColor.withValues(alpha: iconAlpha),
            ),
          ),
        ),
      ),
    );
  }
}
