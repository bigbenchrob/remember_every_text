import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../presentation/widgets/recovered_messages_heatmap_sidebar.dart';

part 'recovered_messages_sidebar_provider.g.dart';

@riverpod
Widget recoveredMessagesSidebar(
  Ref ref, {
  int? contactId,
  DateTime? scrollToDate,
  bool onlyNoHandleFromMe = false,
}) {
  return RecoveredMessagesHeatmapSidebar(
    contactId: contactId,
    scrollToDate: scrollToDate,
    onlyNoHandleFromMe: onlyNoHandleFromMe,
  );
}
