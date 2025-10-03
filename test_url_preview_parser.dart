#!/usr/bin/env dart
// Test script to verify Rust URL preview parser
// Run from project root: dart run test_url_preview_parser.dart

import 'dart:io';
import 'lib/api.dart';
import 'lib/frb_generated.dart';

Future<void> main() async {
  print('🔧 Initializing Rust library...');
  await RustLib.init();
  print('✅ Rust library initialized\n');

  final testPath =
      Platform.environment['HOME']! +
      '/Library/Messages/Attachments/65/05/244F25B3-A34F-4662-B50E-3F830D71EFDF/138C22EC-A807-4889-B966-D8FDBF8C3311.pluginPayloadAttachment';

  print('📄 Test file: $testPath');
  final file = File(testPath);

  if (!file.existsSync()) {
    print('❌ File does not exist!');
    exit(1);
  }

  print(
    '✅ File exists (${(file.lengthSync() / 1024).toStringAsFixed(1)} KB)\n',
  );

  print('🔍 Parsing URL preview metadata...');
  try {
    final metadata = parseUrlPreviewPlist(filePath: testPath);

    print('\n✅ Successfully parsed! Results:\n');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📌 URL:       ${metadata.url ?? "(null)"}');
    print('🏷️  Site Name: ${metadata.siteName ?? "(null)"}');
    print('📝 Title:     ${metadata.title ?? "(null)"}');
    print('📄 Summary:   ${metadata.summary ?? "(null)"}');
    print('🖼️  Image URL: ${metadata.imageUrl ?? "(null)"}');
    print('🎬 Video URL: ${metadata.videoUrl ?? "(null)"}');
    print('🔖 Icon URL:  ${metadata.iconUrl ?? "(null)"}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    // Check if we got the expected post text
    if (metadata.summary != null &&
        metadata.summary!.contains('morganevelyncook')) {
      print('\n🎉 SUCCESS! Found expected post text about @morganevelyncook!');
    } else if (metadata.title != null || metadata.summary != null) {
      print('\n✅ Metadata extracted, but different than expected test case');
    } else {
      print('\n⚠️  No summary or title found in metadata');
    }
  } catch (e, stackTrace) {
    print('❌ Failed to parse: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}
