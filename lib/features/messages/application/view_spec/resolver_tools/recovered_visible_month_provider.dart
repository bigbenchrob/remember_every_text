import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recovered_visible_month_provider.g.dart';

@riverpod
class RecoveredVisibleMonth extends _$RecoveredVisibleMonth {
  @override
  String? build({int? contactId, required bool onlyNoHandleFromMe}) {
    return null;
  }

  void setMonthKey(String? monthKey) {
    state = monthKey;
  }
}
