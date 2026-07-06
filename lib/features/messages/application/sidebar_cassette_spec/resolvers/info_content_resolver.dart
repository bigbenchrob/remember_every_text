import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../config/theme/spacing/app_spacing.dart';
import '../../../domain/spec_classes/messages_info_cassette_spec.dart';

part 'info_content_resolver.g.dart';

enum MessagesInfoNavigatorKind {
  recoveredDeletedMessages,
  recoveredNoHandleMessages,
}

/// Resolved content for a messages info cassette.
class MessagesInfoContent {
  const MessagesInfoContent({
    this.title,
    this.body,
    this.navigatorKind,
    this.topSpacing = 0,
  }) : assert(
         (body != null) != (navigatorKind != null),
         'Provide exactly one of body or navigatorKind.',
       );

  final String? title;
  final String? body;
  final MessagesInfoNavigatorKind? navigatorKind;
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
              'regardless of who you were texting with.',
        );
      case MessagesInfoKey.recoveredDeletedMessages:
        return const MessagesInfoContent(
          navigatorKind: MessagesInfoNavigatorKind.recoveredDeletedMessages,
          topSpacing: AppSpacing.lg,
        );
      case MessagesInfoKey.recoveredNoHandleMessages:
        return const MessagesInfoContent(
          navigatorKind: MessagesInfoNavigatorKind.recoveredNoHandleMessages,
        );
    }
  }
}
