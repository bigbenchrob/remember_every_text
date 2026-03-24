import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../config/theme/spacing/app_spacing.dart';
import '../../../domain/spec_classes/messages_info_cassette_spec.dart';
import '../widget_builders/recovered_no_handle_from_me_navigator_widget.dart';
import '../widget_builders/recovered_unlinked_navigator_widget.dart';

part 'info_content_resolver.g.dart';

/// Resolved content for a messages info cassette.
class MessagesInfoContent {
  const MessagesInfoContent({
    this.title,
    this.body,
    this.child,
    this.topSpacing = 0,
  }) : assert(
         (body != null) != (child != null),
         'Provide exactly one of body or child.',
       );

  final String? title;
  final String? body;
  final Widget? child;
  final double topSpacing;
}

/// Resolves content for [MessagesInfoKey] values.
@riverpod
class MessagesInfoContentResolver extends _$MessagesInfoContentResolver {
  @override
  void build() {
    // Stateless resolver
  }

  Future<MessagesInfoContent> resolve(
    MessagesInfoKey key, {
    required int cassetteIndex,
  }) async {
    switch (key) {
      case MessagesInfoKey.searchAllMessages:
        return const MessagesInfoContent(
          body:
              'The heatmap below represents all the messages in your database, '
              'regardless of who you were texting with. Messages are shown at '
              'right, listed by date. Clicking on a square in the heatmap '
              'will bring you to that month. You can enter search terms in the '
              'list header.',
        );
      case MessagesInfoKey.recoveredDeletedMessages:
        return MessagesInfoContent(
          child: RecoveredUnlinkedNavigatorWidget(cassetteIndex: cassetteIndex),
          topSpacing: AppSpacing.lg,
        );
      case MessagesInfoKey.recoveredNoHandleMessages:
        return MessagesInfoContent(
          child: RecoveredNoHandleFromMeNavigatorWidget(
            cassetteIndex: cassetteIndex,
          ),
        );
    }
  }
}
