import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../resolvers/message_history_coverage_settings_resolver.dart';

part 'message_history_coverage_report_actions_provider.g.dart';

@riverpod
class MessageHistoryCoverageReportActions
    extends _$MessageHistoryCoverageReportActions {
  @override
  void build() {}

  void retry() {
    ref.invalidate(messageHistoryCoverageReportProvider);
  }
}
