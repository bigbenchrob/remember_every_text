import 'package:flutter/widgets.dart';

import '../../../config/theme/theme_typography.dart';

abstract final class PresencePresentationTokens {
  const PresencePresentationTokens._();

  static const double maximumReadableWidth = 560;
  static const double pageMargin = 48;
  static const double paragraphSpacing = 24;
  static const double quotationInset = 24;

  static TextStyle primaryTellStyle(ThemeTypography typography) {
    return typography.title1.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      height: 1.3,
    );
  }

  static TextStyle supportingParagraphStyle(ThemeTypography typography) {
    return typography.callout.copyWith(fontSize: 17, height: 1.45);
  }

  static TextStyle quotationStyle(ThemeTypography typography) {
    return typography.callout.copyWith(
      fontSize: 17,
      fontStyle: FontStyle.italic,
      height: 1.45,
    );
  }
}
