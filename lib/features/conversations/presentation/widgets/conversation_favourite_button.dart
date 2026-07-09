import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Tooltip;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../essentials/conversation_graph/feature_level_providers.dart'
    show
        conversationFavouriteActionsProvider,
        conversationFavouritesControllerProvider;

class ConversationFavouriteButton extends ConsumerStatefulWidget {
  const ConversationFavouriteButton({
    required this.conversationId,
    this.size = 24,
    this.iconSize = 13,
    super.key,
  });

  final int conversationId;
  final double size;
  final double iconSize;

  @override
  ConsumerState<ConversationFavouriteButton> createState() =>
      _ConversationFavouriteButtonState();
}

class _ConversationFavouriteButtonState
    extends ConsumerState<ConversationFavouriteButton> {
  var _isHovered = false;

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final favourites = ref.watch(conversationFavouritesControllerProvider);
    final hints = colors.interactiveHints;
    final isFavourite = favourites.isCoreFavourite(widget.conversationId);
    final iconColor = isFavourite
        ? hints.favoriteStar
        : _isHovered
        ? colors.content.iconSecondary
        : colors.content.textTertiary.withValues(alpha: 0.62);
    final background = _isHovered
        ? colors.surfaces.hover
        : colors.surfaces.canvas.withValues(alpha: 0);

    return Tooltip(
      message: isFavourite ? 'Remove from Favourites' : 'Add to Favourites',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          setState(() {
            _isHovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            _isHovered = false;
          });
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            unawaited(
              ref
                  .read(conversationFavouriteActionsProvider.notifier)
                  .toggleCoreFavourite(widget.conversationId),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            width: widget.size,
            height: widget.size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(
              isFavourite ? CupertinoIcons.star_fill : CupertinoIcons.star,
              size: widget.iconSize,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
