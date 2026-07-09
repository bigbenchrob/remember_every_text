import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'column_band_debug_margins_provider.g.dart';

@riverpod
class ColumnBandDebugMargins extends _$ColumnBandDebugMargins {
  @override
  bool build() {
    return true;
  }

  void toggle() {
    state = !state;
  }

  void setVisible({required bool visible}) {
    state = visible;
  }
}
