import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';

void main() {
  final authority = ArchiveAccessAuthority(
    identity: ResolvedArchiveIdentity(
      environment: ArchiveEnvironment.test,
      buildIdentity: ArchiveBuildIdentity.testHarness,
      archiveInstanceId: ArchiveInstanceId(
        '123e4567-e89b-42d3-a456-426614174000',
      ),
      canonicalRootPath: '/tmp/message_lens_test',
      bundleIdentifier: 'com.bigbenchsoftware.MessageLens.tests',
      productName: 'MessageLens Tests',
    ),
  );

  test('resolves paths inside the admitted root', () {
    expect(
      authority.resolvePath('attachment_archive/item'),
      '/tmp/message_lens_test/attachment_archive/item',
    );
  });

  test('rejects absolute and escaping paths', () {
    expect(() => authority.resolvePath('/tmp/other'), throwsArgumentError);
    expect(() => authority.resolvePath('../production'), throwsArgumentError);
  });
}
