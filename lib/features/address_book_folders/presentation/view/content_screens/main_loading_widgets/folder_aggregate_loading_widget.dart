import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

/// Widget displayed while the folder aggregate is loading
class FolderAggregateLoadingWidget extends StatelessWidget {
  const FolderAggregateLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ProgressCircle(radius: 20),
          const SizedBox(height: 16),
          Text(
            'Loading Address Book Folders...',
            style: MacosTheme.of(context).typography.title3,
          ),
          const SizedBox(height: 8),
          Text(
            'Scanning for AddressBook databases',
            style: MacosTheme.of(
              context,
            ).typography.body.copyWith(color: MacosColors.secondaryLabelColor),
          ),
        ],
      ),
    );
  }
}
