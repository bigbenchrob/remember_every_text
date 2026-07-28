import 'package:flutter/services.dart';

import '../application/native_archive_claim_reader.dart';
import '../domain/native_archive_claim.dart';
import 'native_archive_claim_payload_decoder.dart';

/// Reads the claim already validated and frozen by macOS bootstrap.
final class MethodChannelNativeArchiveClaimReader
    implements NativeArchiveClaimReader {
  const MethodChannelNativeArchiveClaimReader({
    MethodChannel channel = const MethodChannel(
      'com.bigbenchsoftware.MessageLens/archive_identity',
    ),
    NativeArchiveClaimPayloadDecoder decoder =
        const NativeArchiveClaimPayloadDecoder(),
  }) : _channel = channel,
       _decoder = decoder;

  final MethodChannel _channel;
  final NativeArchiveClaimPayloadDecoder _decoder;

  @override
  Future<NativeArchiveClaim> read() async {
    final payload = await _channel.invokeMethod<Map<Object?, Object?>>(
      'getNativeArchiveClaim',
    );
    if (payload == null) {
      throw const FormatException('Native archive claim is missing.');
    }
    return _decoder.decode(payload);
  }
}

/// Presents a Dart-side archive-admission failure through the native startup
/// surface that owns fail-closed termination.
final class MethodChannelArchiveAdmissionFailurePresenter {
  const MethodChannelArchiveAdmissionFailurePresenter({
    MethodChannel channel = const MethodChannel(
      'com.bigbenchsoftware.MessageLens/archive_identity',
    ),
  }) : _channel = channel;

  final MethodChannel _channel;

  Future<void> present(Object error) async {
    await _channel.invokeMethod<void>(
      'showArchiveAdmissionFailure',
      <String, Object?>{'message': error.toString()},
    );
  }
}
