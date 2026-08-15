import 'package:flutter/widgets.dart';

/// Shared two-regime message-activity heatmap color scale.
///
/// Counts from 4-50 use a neutral sparse-activity ramp. At 51 messages the
/// scale deliberately resets to bright yellow to mark sustained activity, then
/// progresses through one sequential yellow-green-teal-blue-purple scale.
/// Thresholds are explicit, approximately logarithmic bins; no runtime
/// logarithmic normalization is required.
///
/// The governing invariant is monotonic perceived magnitude, not globally
/// monotonic physical luminance. The gray-to-yellow boundary is intentionally
/// lighter because the appearance of chromatic color signals entry into the
/// sustained-activity regime. Monotonic darkening applies within each regime,
/// especially the active yellow-green-teal-blue-purple sequence. Orange and
/// red high-end tiers are intentionally excluded because they do not preserve
/// that ordering and red introduces unrelated warning semantics.
///
/// These colors are shared by calendar heatmaps and Conversation glyphs.
Color activityHeatmapColorForMessageCount(int messageCount) {
  if (messageCount <= 3) {
    return const Color(0x00000000);
  } else if (messageCount <= 10) {
    return const Color(0xFFE8E8E8);
  } else if (messageCount <= 30) {
    return const Color(0xFFCFCFCF);
  } else if (messageCount <= 50) {
    return const Color(0xFFA5A5A5);
  } else if (messageCount <= 100) {
    return const Color(0xFFFDE725);
  } else if (messageCount <= 300) {
    return const Color(0xFFAADC32);
  } else if (messageCount <= 1000) {
    return const Color(0xFF5CC863);
  } else if (messageCount <= 3000) {
    return const Color(0xFF28AE80);
  } else if (messageCount <= 10000) {
    return const Color(0xFF2C728E);
  }
  return const Color(0xFF472D7B);
}
