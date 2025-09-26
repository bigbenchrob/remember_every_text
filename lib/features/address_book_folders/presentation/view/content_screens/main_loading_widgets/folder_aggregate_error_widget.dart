// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';

/// Widget displayed when folder aggregate loading fails
class FolderAggregateErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const FolderAggregateErrorWidget({
    super.key,
    required this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Address Book Error',
              style: MacosTheme.of(context).typography.title2,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Text(
                errorMessage,
                style: MacosTheme.of(context).typography.body,
                textAlign: TextAlign.center,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              PushButton(
                controlSize: ControlSize.large,
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
