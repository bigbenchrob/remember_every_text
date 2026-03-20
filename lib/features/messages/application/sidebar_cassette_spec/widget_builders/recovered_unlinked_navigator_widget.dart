import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/spacing/app_spacing.dart';
import '../../../../../config/theme/theme_typography.dart';

/// Sidebar cassette content for the recovered-unlinked-messages feature entry.
class RecoveredUnlinkedNavigatorWidget extends ConsumerWidget {
  const RecoveredUnlinkedNavigatorWidget({
    required this.cassetteIndex,
    super.key,
  });

  final int cassetteIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Some messages in the iMessage database on your computer couldn't be linked to a chat conversation with a particular contact from your AddressBook. In many (but not all) cases, orphaned messages like these belong to conversations that you swiped left on in iMessage and deleted.",
          style: typography.cassetteCardSubtitle,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'However, they can be associated with a particular phone number or email address (a "handle") that belongs to a known contact. When you choose a contact, you will be given the option to view all the unlinked messages of this type. But they are listed together here for your convenience.',
          style: typography.cassetteCardSubtitle,
        ),
      ],
    );
  }
}
