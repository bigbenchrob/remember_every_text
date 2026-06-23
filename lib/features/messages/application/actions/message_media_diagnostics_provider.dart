import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/logging/feature_level_providers.dart';

part 'message_media_diagnostics_provider.g.dart';

@riverpod
class MessageMediaDiagnostics extends _$MessageMediaDiagnostics {
  @override
  FutureOr<void> build() {}

  void reportVideoTileFailure({
    required String stage,
    required Object error,
    required StackTrace stackTrace,
    required String? attachmentLocalPath,
    required String? attachmentResolvedDisplayPath,
    required String? mimeType,
    String? filePath,
  }) {
    ref
        .read(appLoggerProvider.notifier)
        .warn(
          'Video message tile operation failed',
          source: 'VideoMessageTile',
          context: <String, Object?>{
            'stage': stage,
            'filePath': filePath,
            'attachmentLocalPath': attachmentLocalPath,
            'attachmentResolvedDisplayPath': attachmentResolvedDisplayPath,
            'mimeType': mimeType,
            'error': error.toString(),
            'stackTrace': stackTrace.toString(),
          },
        );
  }
}
