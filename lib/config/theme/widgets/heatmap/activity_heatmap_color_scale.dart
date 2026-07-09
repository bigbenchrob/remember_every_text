import 'package:flutter/widgets.dart';

/// Shared message-activity heatmap color scale.
///
/// These colors encode activity-count data and are shared by contact heatmaps
/// and Conversation glyphs.
Color activityHeatmapColorForMessageCount(int messageCount) {
  if (messageCount <= 3) {
    return const Color(0x00000000);
  } else if (messageCount <= 10) {
    return const Color(0xFFE0E0E0);
  } else if (messageCount <= 30) {
    return const Color(0xFFB0B0B0);
  } else if (messageCount <= 50) {
    return const Color(0xFF808080);
  } else if (messageCount <= 75) {
    return const Color(0xFFFFF176);
  } else if (messageCount <= 100) {
    return const Color(0xFFFFEE58);
  } else if (messageCount <= 150) {
    return const Color(0xFFFDD835);
  } else if (messageCount <= 200) {
    return const Color(0xFFFBC02D);
  } else if (messageCount <= 500) {
    return const Color(0xFFC8E6C9);
  } else if (messageCount <= 1000) {
    return const Color(0xFF66BB6A);
  } else if (messageCount <= 2000) {
    return const Color(0xFF2E7D32);
  } else if (messageCount <= 3000) {
    return const Color(0xFFB3E5FC);
  } else if (messageCount <= 5000) {
    return const Color(0xFF42A5F5);
  } else if (messageCount <= 8000) {
    return const Color(0xFF1565C0);
  } else if (messageCount <= 12000) {
    return const Color(0xFFFFE0B2);
  } else if (messageCount <= 20000) {
    return const Color(0xFFFB8C00);
  } else if (messageCount <= 30000) {
    return const Color(0xFFE1BEE7);
  } else if (messageCount <= 50000) {
    return const Color(0xFF8E24AA);
  }
  return const Color(0xFFD32F2F);
}
