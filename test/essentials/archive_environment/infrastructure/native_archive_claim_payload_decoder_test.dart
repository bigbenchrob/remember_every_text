import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_build_identity.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_environment.dart';
import 'package:remember_this_text/essentials/archive_environment/infrastructure/native_archive_claim_payload_decoder.dart';

void main() {
  const decoder = NativeArchiveClaimPayloadDecoder();

  test('decodes a complete native claim', () {
    final claim = decoder.decode({
      'environment': 'development',
      'buildIdentity': 'developmentDebug',
      'bundleIdentifier': 'com.bigbenchsoftware.MessageLens.development',
      'productName': 'MessageLens Development',
      'canonicalRootPath': '/tmp/development',
      'productionSignatureIsValid': true,
    });

    expect(claim.environment, ArchiveEnvironment.development);
    expect(claim.buildIdentity, ArchiveBuildIdentity.developmentDebug);
    expect(claim.canonicalRootPath, '/tmp/development');
  });

  test('does not supply fallback values for missing native facts', () {
    expect(
      () => decoder.decode({
        'environment': 'development',
        'buildIdentity': 'developmentDebug',
      }),
      throwsFormatException,
    );
  });
}
