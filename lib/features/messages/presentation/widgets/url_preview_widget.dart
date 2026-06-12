import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../essentials/external_links/feature_level_providers.dart';
import '../../../../essentials/services/native_link_preview_service.dart';
import '../view_model/shared/display_widgets/new_display_widgets.dart';

const double _previewAspectRatio = 2.0;
const Duration _fallbackDelay = Duration(seconds: 10);
const Duration _transitionDuration = Duration(milliseconds: 180);

/// Rich URL preview widget for displaying link metadata in messages.
/// Shows image, title, and site name with a clean, tappable design while
/// keeping the layout stable when previews load asynchronously.
class UrlPreviewWidget extends ConsumerStatefulWidget {
  const UrlPreviewWidget({
    required this.url,
    required this.isFromMe,
    this.maxWidth = 400,
    super.key,
  });

  final String url;
  final bool isFromMe;
  final double maxWidth;

  @override
  ConsumerState<UrlPreviewWidget> createState() => _UrlPreviewWidgetState();
}

class _UrlPreviewWidgetState extends ConsumerState<UrlPreviewWidget> {
  final _previewService = NativeLinkPreviewService();

  NativeLinkMetadata? _metadata;
  bool _showFallback = false;
  Timer? _fallbackTimer;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_loadMetadata(resetState: false));
  }

  @override
  void didUpdateWidget(covariant UrlPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      unawaited(_loadMetadata(resetState: true));
    }
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadMetadata({required bool resetState}) async {
    _fallbackTimer?.cancel();
    final requestId = ++_requestId;

    if (resetState && mounted) {
      setState(() {
        _metadata = null;
        _showFallback = false;
      });
    } else {
      _metadata = null;
      _showFallback = false;
    }

    _fallbackTimer = Timer(_fallbackDelay, () {
      if (!mounted || requestId != _requestId || _metadata != null) {
        return;
      }
      setState(() {
        _showFallback = true;
      });
    });

    try {
      final metadata = await _previewService.fetchMetadata(widget.url);
      if (!mounted || requestId != _requestId) {
        return;
      }

      _fallbackTimer?.cancel();

      if (metadata != null) {
        setState(() {
          _metadata = metadata;
          _showFallback = false;
        });
      } else {
        setState(() {
          _showFallback = true;
        });
      }
    } catch (_) {
      if (!mounted || requestId != _requestId) {
        return;
      }

      _fallbackTimer?.cancel();
      setState(() {
        _showFallback = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final child = _metadata != null
        ? _buildNativePreview(_metadata!, colors)
        : _showFallback
        ? _buildLinkFallback(colors)
        : _buildLoadingWidget(colors);

    return AnimatedSwitcher(
      duration: _transitionDuration,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: child,
    );
  }

  Widget _buildLoadingWidget(ThemeColors colors) {
    return _buildCompactPlaceholder(
      key: const ValueKey('loading'),
      colors: colors,
      title: widget.url,
      subtitle: _extractDomain(widget.url),
      statusText: 'Loading preview',
    );
  }

  Widget _buildLinkFallback(ThemeColors colors) {
    return _buildCompactPlaceholder(
      key: const ValueKey('fallback'),
      colors: colors,
      title: _extractDomain(widget.url),
      subtitle: widget.url,
      statusText: 'Open in browser',
    );
  }

  Widget _buildNativePreview(NativeLinkMetadata metadata, ThemeColors colors) {
    final normalizedTitle = _normalizedTitle(metadata);

    if (!metadata.hasAnyImage) {
      return _buildCompactPlaceholder(
        key: const ValueKey('native-compact'),
        colors: colors,
        title: normalizedTitle ?? widget.url,
        subtitle: _extractDomain(metadata.url ?? widget.url),
      );
    }

    return _buildSurface(
      key: const ValueKey('native'),
      colors: colors,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PreviewMedia(
            metadata: metadata,
            aspectRatio: _previewAspectRatio,
            placeholderColor: colors.messagePanels.supportSurface,
          ),
          DecoratedBox(
            decoration: BoxDecoration(gradient: _footerGradient(colors)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 7, 12, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AdaptivePreviewText(
                    text: normalizedTitle ?? widget.url,
                    baseStyle: TextStyle(
                      fontSize: normalizedTitle != null ? 15.25 : 13.75,
                      fontWeight: normalizedTitle != null
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: colors.content.textPrimary,
                      height: 1.14,
                    ),
                    maxLines: 2,
                    minFontSize: normalizedTitle != null ? 10.5 : 11,
                  ),
                  const SizedBox(height: 0.5),
                  Text(
                    _extractDomain(metadata.url ?? widget.url),
                    style: TextStyle(
                      fontSize: 10.5,
                      color: colors.content.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurface({
    required Key key,
    required ThemeColors colors,
    required Widget child,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.maxWidth),
      child: GestureDetector(
        key: key,
        onTap: () => _launchUrl(widget.url),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: ClipRRect(
            borderRadius: MsgTheme.textRadius,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _surfaceBackground(colors),
                borderRadius: MsgTheme.textRadius,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactPlaceholder({
    required Key key,
    required ThemeColors colors,
    required String title,
    required String subtitle,
    String? statusText,
  }) {
    final compactMaxWidth = widget.maxWidth < 240 ? widget.maxWidth : 240.0;

    return Align(
      alignment: Alignment.centerLeft,
      widthFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: compactMaxWidth),
        child: GestureDetector(
          onTap: () => _launchUrl(widget.url),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ClipRRect(
              borderRadius: MsgTheme.textRadius,
              child: DecoratedBox(
                key: key,
                decoration: BoxDecoration(
                  color: _surfaceBackground(colors),
                  borderRadius: MsgTheme.textRadius,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.messagePanels.accentTint,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: const SizedBox(
                              width: 34,
                              height: 34,
                              child: Icon(Icons.link_rounded, size: 18),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: colors.content.textPrimary,
                                    height: 1.14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 1.5),
                                Text(
                                  subtitle,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: colors.content.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (statusText != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: colors.content.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _normalizedTitle(NativeLinkMetadata metadata) {
    final rawTitle = metadata.title?.trim();
    if (rawTitle == null || rawTitle.isEmpty) {
      return null;
    }
    return rawTitle;
  }

  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (_) {
      return url;
    }
  }

  Color _surfaceBackground(ThemeColors colors) {
    if (!widget.isFromMe) {
      return Color.alphaBlend(
        colors.messagePanels.mutedTint.withValues(alpha: 0.9),
        colors.messagePanels.receivedSurface,
      );
    }

    final neutralBase = Color.alphaBlend(
      colors.messagePanels.mutedTint.withValues(alpha: 0.84),
      colors.messagePanels.receivedSurface,
    );

    return Color.alphaBlend(
      colors.messagePanels.accentTintSoft.withValues(alpha: 0.18),
      neutralBase,
    );
  }

  LinearGradient _footerGradient(ThemeColors colors) {
    final base = _surfaceBackground(colors);
    final lifted = Color.lerp(
      base,
      colors.messagePanels.supportSurface,
      widget.isFromMe ? 0.18 : 0.24,
    )!;

    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [base, lifted],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    await ref.read(externalUriOpenerProvider).open(uri);
  }
}

class _PreviewMedia extends StatelessWidget {
  const _PreviewMedia({
    required this.metadata,
    required this.aspectRatio,
    required this.placeholderColor,
  });

  final NativeLinkMetadata metadata;
  final double aspectRatio;
  final Color placeholderColor;

  @override
  Widget build(BuildContext context) {
    final previewBytes = metadata.imageData ?? metadata.iconData;
    final isIconFallback =
        metadata.imageData == null && metadata.iconData != null;

    if (previewBytes == null) {
      return AspectRatio(
        aspectRatio: aspectRatio,
        child: ColoredBox(color: placeholderColor),
      );
    }

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        decoration: isIconFallback
            ? const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFE9ECF5), Color(0xFFD5DAE8)],
                ),
              )
            : null,
        clipBehavior: isIconFallback ? Clip.antiAlias : Clip.none,
        child: Image.memory(
          previewBytes,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          filterQuality: isIconFallback
              ? FilterQuality.high
              : FilterQuality.low,
          errorBuilder: (context, error, stackTrace) {
            return ColoredBox(color: placeholderColor);
          },
        ),
      ),
    );
  }
}

class _AdaptivePreviewText extends StatelessWidget {
  const _AdaptivePreviewText({
    required this.text,
    required this.baseStyle,
    required this.maxLines,
    required this.minFontSize,
  });

  final String text;
  final TextStyle baseStyle;
  final int maxLines;
  final double minFontSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final direction = Directionality.of(context);
        final painter = TextPainter(
          textDirection: direction,
          maxLines: maxLines,
        );

        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : double.infinity;

        var tryFontSize = baseStyle.fontSize ?? 14;
        const decrement = 0.5;

        while (tryFontSize >= minFontSize) {
          painter.text = TextSpan(
            text: text,
            style: baseStyle.copyWith(fontSize: tryFontSize),
          );
          painter.layout(maxWidth: maxWidth);

          final exceedsHeight =
              maxHeight != double.infinity && painter.height > maxHeight;
          if (!painter.didExceedMaxLines && !exceedsHeight) {
            return Text(
              text,
              style: baseStyle.copyWith(fontSize: tryFontSize),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            );
          }

          tryFontSize -= decrement;
        }

        return Text(
          text,
          style: baseStyle.copyWith(fontSize: minFontSize),
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
        );
      },
    );
  }
}
