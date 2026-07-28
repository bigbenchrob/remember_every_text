import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  late Directory tempRoot;

  setUp(() async {
    tempRoot = await Directory.systemTemp.createTemp('artifact_identity_test_');
  });

  tearDown(() async {
    if (tempRoot.existsSync()) {
      await tempRoot.delete(recursive: true);
    }
  });

  test('accepts matching production metadata without launching app', () async {
    final appPath = await _createFixtureApp(
      tempRoot,
      environment: 'production',
      buildIdentity: 'productionRelease',
      bundleIdentifier: 'com.bigbenchsoftware.MessageLens',
      productName: 'MessageLens',
    );

    final result = await Process.run(
      'tool/verify_macos_archive_identity.sh',
      <String>[
        '--app',
        appPath,
        '--environment',
        'production',
        '--metadata-only',
      ],
    );

    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
  });

  test('rejects development artifact from production packaging', () async {
    final appPath = await _createFixtureApp(
      tempRoot,
      environment: 'development',
      buildIdentity: 'developmentRelease',
      bundleIdentifier: 'com.bigbenchsoftware.MessageLens.development',
      productName: 'MessageLens Development',
    );

    final result = await Process.run(
      'tool/verify_macos_archive_identity.sh',
      <String>[
        '--app',
        appPath,
        '--environment',
        'production',
        '--metadata-only',
      ],
    );

    expect(result.exitCode, isNot(0));
    expect(result.stderr, contains('expected production environment'));
  });

  test('accepts matching development metadata', () async {
    final appPath = await _createFixtureApp(
      tempRoot,
      environment: 'development',
      buildIdentity: 'developmentProfile',
      bundleIdentifier: 'com.bigbenchsoftware.MessageLens.development',
      productName: 'MessageLens Development',
    );

    final result = await Process.run(
      'tool/verify_macos_archive_identity.sh',
      <String>[
        '--app',
        appPath,
        '--environment',
        'development',
        '--metadata-only',
      ],
    );

    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
  });

  test('production build script invokes archive identity verifier', () async {
    final script = await File('tool/build_and_notarize.sh').readAsString();

    expect(script, contains('verify_macos_archive_identity.sh'));
    expect(script, contains('--environment production'));
    expect(script, contains('--metadata-only'));
  });

  test('artifact-only packaging stops before tester publication', () async {
    final script = await File('tool/build_and_notarize.sh').readAsString();
    final artifactOnlyExit = script.indexOf(
      r'if [[ "$ARTIFACT_ONLY" == "true" ]]',
    );
    final testerPortalBuild = script.indexOf(
      '# ── Step 8: Build tester portal pages',
    );

    expect(artifactOnlyExit, greaterThan(0));
    expect(testerPortalBuild, greaterThan(artifactOnlyExit));
    expect(
      script,
      contains(
        'No tester-portal build, metadata update, publication, '
        'installation, or launch was performed.',
      ),
    );
  });

  test(
    'artifact verifier keeps recursive verification production-only',
    () async {
      final script = await File(
        'tool/verify_macos_archive_identity.sh',
      ).readAsString();

      expect(
        script,
        contains(r'codesign --verify --deep --strict "$APP_PATH"'),
      );
      expect(script, contains(r'codesign --verify --strict "$APP_PATH"'));
    },
  );
}

Future<String> _createFixtureApp(
  Directory root, {
  required String environment,
  required String buildIdentity,
  required String bundleIdentifier,
  required String productName,
}) async {
  final expectedSigningIdentity = environment == 'production'
      ? 'Developer ID Application: Robert Campbell (FQHT2QP3NE)'
      : '';
  final appRoot = Directory(path.join(root.path, '$productName.app'));
  final contents = Directory(path.join(appRoot.path, 'Contents'));
  await contents.create(recursive: true);
  final plistPath = path.join(contents.path, 'Info.plist');
  await File(plistPath).writeAsString('''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleIdentifier</key>
  <string>$bundleIdentifier</string>
  <key>CFBundleDisplayName</key>
  <string>$productName</string>
  <key>MessageLensArchiveEnvironment</key>
  <string>$environment</string>
  <key>MessageLensArchiveBuildIdentity</key>
  <string>$buildIdentity</string>
  <key>MessageLensExpectedSigningIdentity</key>
  <string>$expectedSigningIdentity</string>
</dict>
</plist>
''');
  return appRoot.path;
}
