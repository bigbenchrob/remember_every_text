import '../domain/archive_build_identity.dart';
import '../domain/archive_environment.dart';
import '../domain/native_archive_claim.dart';

/// Decodes the narrow native bootstrap payload without adding fallback values.
final class NativeArchiveClaimPayloadDecoder {
  const NativeArchiveClaimPayloadDecoder();

  NativeArchiveClaim decode(Map<Object?, Object?> payload) {
    final environment = _requiredString(payload, 'environment');
    final buildIdentity = _requiredString(payload, 'buildIdentity');

    return NativeArchiveClaim(
      environment: ArchiveEnvironment.parse(environment),
      buildIdentity: ArchiveBuildIdentity.parse(buildIdentity),
      bundleIdentifier: _requiredString(payload, 'bundleIdentifier'),
      productName: _requiredString(payload, 'productName'),
      canonicalRootPath: _requiredString(payload, 'canonicalRootPath'),
      productionSignatureIsValid: _requiredBool(
        payload,
        'productionSignatureIsValid',
      ),
    );
  }

  String _requiredString(Map<Object?, Object?> payload, String key) {
    final value = payload[key];
    if (value is! String || value.isEmpty) {
      throw FormatException('Native archive claim $key must be a string.');
    }
    return value;
  }

  bool _requiredBool(Map<Object?, Object?> payload, String key) {
    final value = payload[key];
    if (value is! bool) {
      throw FormatException('Native archive claim $key must be a boolean.');
    }
    return value;
  }
}
