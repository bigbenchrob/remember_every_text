import 'package:flutter/widgets.dart';

/// Wraps evidence lists with a scroll-driven top fade.
///
/// The fade is a shared center-panel affordance: it softens header/list
/// collision during scroll without becoming persistent chrome.
class MessageEvidenceFadeOverlay extends StatefulWidget {
  const MessageEvidenceFadeOverlay({
    required this.backgroundColor,
    required this.child,
    super.key,
  });

  final Color backgroundColor;
  final Widget child;

  @override
  State<MessageEvidenceFadeOverlay> createState() =>
      _MessageEvidenceFadeOverlayState();
}

class _MessageEvidenceFadeOverlayState extends State<MessageEvidenceFadeOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 300),
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      _controller.forward();
    } else if (notification is ScrollEndNotification) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: widget.backgroundColor,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          _handleScrollNotification(notification);
          return false;
        },
        child: Stack(
          children: [
            widget.child,
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 20,
              child: IgnorePointer(
                child: FadeTransition(
                  opacity: _opacity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.4, 1.0],
                        colors: [
                          widget.backgroundColor,
                          widget.backgroundColor.withValues(alpha: 0.6),
                          widget.backgroundColor.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
