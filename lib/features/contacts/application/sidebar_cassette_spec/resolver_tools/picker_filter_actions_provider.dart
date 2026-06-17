import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'picker_filter_mode_provider.dart';

part 'picker_filter_actions_provider.g.dart';

@riverpod
class PickerFilterActions extends _$PickerFilterActions {
  @override
  FutureOr<void> build() {}

  Future<void> selectMode(PickerFilterMode mode) async {
    await ref.read(pickerFilterProvider.notifier).setMode(mode);
  }
}
