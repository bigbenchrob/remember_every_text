import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';

void main() {
  test('archive marker JSON round-trips', () {
    final marker = ArchiveMarker(
      formatVersion: ArchiveMarker.currentFormatVersion,
      environment: ArchiveEnvironment.development,
      archiveInstanceId: ArchiveInstanceId(
        '123e4567-e89b-42d3-a456-426614174000',
      ),
      createdAtUtc: DateTime.utc(2026, 7, 27, 10, 30),
    );

    final decoded = jsonDecode(jsonEncode(marker.toJson()));
    final restored = ArchiveMarker.fromJson(decoded as Map<String, Object?>);

    expect(restored.formatVersion, marker.formatVersion);
    expect(restored.environment, marker.environment);
    expect(restored.archiveInstanceId, marker.archiveInstanceId);
    expect(restored.createdAtUtc, marker.createdAtUtc);
  });

  test('archive marker rejects malformed UTC timestamps', () {
    expect(
      () => ArchiveMarker.fromJson(<String, Object?>{
        'formatVersion': 1,
        'environment': 'development',
        'archiveInstanceId': '123e4567-e89b-42d3-a456-426614174000',
        'createdAtUtc': '2026-07-27T10:30:00',
      }),
      throwsFormatException,
    );
  });
}
