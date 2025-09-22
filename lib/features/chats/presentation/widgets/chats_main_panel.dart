import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../contacts/feature_level_providers.dart';

class ChatsMainPanel extends ConsumerWidget {
  const ChatsMainPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chosenId = ref.watch(chosenContactIdProvider);
    final text = chosenId == -1
        ? 'No contact chosen'
        : 'Contact $chosenId chats:';
    return Center(
      child: Text(
        text,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }
}
