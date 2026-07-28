import 'dart:convert';
import 'dart:io';

import 'package:remember_this_text/essentials/archive_environment/domain.dart';

/// Disposable, explicitly marked archive for provider and integration tests.
///
/// Test code must use this fixture (or an in-memory database) rather than
/// resolving platform Application Support.
final class TestArchiveFixture {
  TestArchiveFixture._({required this.root, required this.authority});

  static const _instanceId = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';

  final Directory root;
  final ArchiveAccessAuthority authority;

  static Future<TestArchiveFixture> create({String? prefix}) async {
    final createdRoot = await Directory.systemTemp.createTemp(
      prefix ?? 'messagelens_test_archive_',
    );
    final root = Directory(await createdRoot.resolveSymbolicLinks());
    final instanceId = ArchiveInstanceId(_instanceId);
    final marker = ArchiveMarker(
      formatVersion: ArchiveMarker.currentFormatVersion,
      environment: ArchiveEnvironment.test,
      archiveInstanceId: instanceId,
      createdAtUtc: DateTime.now().toUtc(),
    );
    await File(
      '${root.path}/.messagelens-archive.json',
    ).writeAsString('${jsonEncode(marker.toJson())}\n', flush: true);

    return TestArchiveFixture._(
      root: root,
      authority: ArchiveAccessAuthority(
        identity: ResolvedArchiveIdentity(
          environment: ArchiveEnvironment.test,
          buildIdentity: ArchiveBuildIdentity.testHarness,
          archiveInstanceId: instanceId,
          canonicalRootPath: root.path,
          bundleIdentifier: 'com.bigbenchsoftware.MessageLens.tests',
          productName: 'MessageLens Tests',
        ),
      ),
    );
  }

  Future<void> dispose() async {
    if (root.existsSync()) {
      await root.delete(recursive: true);
    }
  }
}
