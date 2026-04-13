import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../view_model/shared/display_widgets/new_display_widgets.dart';

const _kContextAnchorBorderWidth = 2.0;
const _kContextAnchorHighlightPadding = 4.0;
const _kContextAnchorBadgeSize = 16.0;
const _kContextAnchorBadgeInsetTop = 10.0;
const _kContextAnchorBadgeInsetTrailing = 10.0;
const _kContextAnchorPulseDuration = Duration(milliseconds: 180);
const _kContextAnchorGlowFadeDuration = Duration(milliseconds: 220);
const _kContextAnchorPulseScaleTo = 1.012;
const _kContextAnchorShadowBlur = 8.0;
const _kContextAnchorShadowYOffset = 1.0;

class MessageContextAnchorChrome extends HookConsumerWidget {
  const MessageContextAnchorChrome({
    required this.child,
    this.isContextAnchor = false,
    this.isSelected = false,
    this.activationKey,
    this.activationDelay = Duration.zero,
    this.debugId,
    super.key,
  });

  final Widget child;
  final bool isContextAnchor;
  final bool isSelected;
  final String? activationKey;
  final Duration activationDelay;
  final String? debugId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final isPulsing = useState(false);
    final showGlow = useState(false);
    const borderRadius = MsgTheme.textRadius;

    useEffect(() {
      if (!isContextAnchor || activationKey == null) {
        isPulsing.value = false;
        showGlow.value = false;
        return null;
      }

      var disposed = false;
      Timer? activationTimer;
      Timer? pulseTimer;
      Timer? glowTimer;

      void startPulse() {
        if (disposed) {
          return;
        }

        showGlow.value = true;
        isPulsing.value = true;

        pulseTimer = Timer(_kContextAnchorPulseDuration, () {
          if (disposed) {
            return;
          }

          isPulsing.value = false;

          glowTimer = Timer(_kContextAnchorGlowFadeDuration, () {
            if (disposed) {
              return;
            }

            showGlow.value = false;
          });
        });
      }

      if (activationDelay > Duration.zero) {
        activationTimer = Timer(activationDelay, startPulse);
      } else {
        startPulse();
      }

      return () {
        disposed = true;
        activationTimer?.cancel();
        pulseTimer?.cancel();
        glowTimer?.cancel();
      };
    }, [activationDelay, activationKey, isContextAnchor]);

    final hasAnchorChrome = isContextAnchor || isSelected;
    if (!hasAnchorChrome) {
      return child;
    }

    final borderColor = isSelected
        ? colors.messagePanels.selectionBorder
        : colors.messagePanels.contextAnchorBorder;
    final backgroundColor = isContextAnchor
        ? colors.messagePanels.contextAnchorBackground
        : colors.messagePanels.selectionTint;
    final badge = isContextAnchor
        ? _ContextAnchorBadge(debugId: debugId)
        : null;

    return AnimatedScale(
      duration: _kContextAnchorPulseDuration,
      curve: Curves.easeOut,
      scale: isPulsing.value ? _kContextAnchorPulseScaleTo : 1,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            key: debugId == null
                ? null
                : ValueKey<String>('message-context-anchor-card-$debugId'),
            duration: _kContextAnchorGlowFadeDuration,
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: borderRadius,
              border: Border.all(
                color: borderColor,
                width: _kContextAnchorBorderWidth,
              ),
              boxShadow: isContextAnchor
                  ? [
                      BoxShadow(
                        color: showGlow.value
                            ? colors.messagePanels.contextAnchorGlow
                            : colors.messagePanels.contextAnchorGlow.withValues(
                                alpha: colors.isDark ? 0.18 : 0.10,
                              ),
                        blurRadius: _kContextAnchorShadowBlur,
                        offset: const Offset(0, _kContextAnchorShadowYOffset),
                      ),
                    ]
                  : const <BoxShadow>[],
            ),
            child: Padding(
              padding: const EdgeInsets.all(_kContextAnchorHighlightPadding),
              child: ClipRRect(borderRadius: borderRadius, child: child),
            ),
          ),
          if (badge != null)
            Positioned(
              top: _kContextAnchorBadgeInsetTop,
              right: _kContextAnchorBadgeInsetTrailing,
              child: badge,
            ),
        ],
      ),
    );
  }
}

class _ContextAnchorBadge extends ConsumerWidget {
  const _ContextAnchorBadge({required this.debugId});

  final String? debugId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);

    return DecoratedBox(
      key: debugId == null
          ? null
          : ValueKey<String>('message-context-anchor-badge-$debugId'),
      decoration: BoxDecoration(
        color: colors.messagePanels.contextAnchorBadgeBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colors.messagePanels.contextAnchorBorder,
          width: 1,
        ),
      ),
      child: SizedBox(
        width: _kContextAnchorBadgeSize,
        height: _kContextAnchorBadgeSize,
        child: Icon(
          Icons.search_rounded,
          size: 11,
          color: colors.messagePanels.contextAnchorBadgeForeground,
        ),
      ),
    );
  }
}
