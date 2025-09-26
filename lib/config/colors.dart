import 'dart:ui';

import 'package:flutter/material.dart';

enum NamedLightColors {
  puiPrimary(Color(0xFF4254C5)),
  puiOne(Color(0xFF171717)),
  puiTwo(Color(0xFF414141)),
  puiThree(Color(0xFF808080)),
  puiFour(Color(0xFFE0E0E0)),
  puiFive(Color(0xFFF5F5F5)),
  puiSix(Color(0xFFffffff)),

  sbBackground(Color(0xFFECECEC)),
  sbOnBackground(Color(0xFF777777)),
  sbItemLabel(Color(0xFF242424)),

  red(Colors.red),
  white(Color(0xFFFFFFFF));

  final Color color;
  const NamedLightColors(this.color);
}

enum NamedDarkColors {
  puiPrimary(Color(0xFF73E6CA)),
  puiOne(Color(0xFFE5E5E5)),
  puiTwo(Color(0xFFC4CCCA)),
  puiThree(Color(0xFF9DA5A3)),
  puiFour(Color(0xFF4E5453)),
  puiFive(Color(0xFF353A39)),
  puiSix(Color(0xFF212625)),

  sbBackground(Color(0xFF383838)),
  sbOnBackground(Color(0xFFD4D4D4)),
  sbItemLabel(Color(0xFFE0E0E0)),

  red(Colors.red),
  white(Color(0xFFFFFFFF));

  final Color color;
  const NamedDarkColors(this.color);
}

enum SystemColors {
  surfaceVariant(Color(0xFFDFE2EA)),
  onSurfaceVariant(Color(0xFF44474D)),
  inverseSurface(Color(0xFF2F3033)),
  onInverseSurface(Color(0xFFF1F0F4)),
  outline(Color(0xFF73777f));

  final Color color;

  const SystemColors(this.color);
}

enum GreyLawColors {
  primary(Color(0xFF006684)),
  onPrimary(Color(0xFFFFFFFF)),
  primaryContainer(Color(0xFFBAE9FF)),
  onPrimaryContainer(Color(0xFF001F2A)),

  secondary(Color(0xFF006684)),
  onSecondary(Color(0xFFFFFFFF)),
  secondaryContainer(Color(0xFFBAE9FF)),
  onSecondaryContainer(Color(0xFF001F2A)),

  tertiary(Color(0xFF006684)),
  onTertiary(Color(0xFFFFFFFF)),
  tertiaryContainer(Color(0xFFBAE9FF)),
  onTertiaryContainer(Color(0xFF001F2A)),

  error(Color(0xFF006684)),
  onError(Color(0xFFFFFFFF)),
  errorContainer(Color(0xFFBAE9FF)),
  onErrorContainer(Color(0xFF001F2A)),

  outline(Color(0xFF73777f));

  final Color color;

  const GreyLawColors(this.color);
}
