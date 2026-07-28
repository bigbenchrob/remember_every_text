import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_admission_exception.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_environment.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_instance_id.dart';
import 'package:remember_this_text/essentials/archive_environment/domain/archive_marker.dart';
import 'package:remember_this_text/essentials/archive_environment/infrastructure/file_system_archive_marker_store.dart';

void main() {
  late Directory root;

  setUp(() {
    root = Directory.systemTemp.createTempSync('messagelens-marker-');
  });

  tearDown(() {
    if (root.existsSync()) {
      root.deleteSync(recursive: true);
    }
  });

  test('atomically creates and reads a marker', () async {
    final store = FileSystemArchiveMarkerStore(rootPath: root.path);
    final marker = ArchiveMarker(
      formatVersion: ArchiveMarker.currentFormatVersion,
      environment: ArchiveEnvironment.test,
      archiveInstanceId: ArchiveInstanceId(
        '89ae4d7e-c98e-4af4-b1ba-2db5b7777ce9',
      ),
      createdAtUtc: DateTime.utc(2026, 7, 27),
    );

    await store.createInitialMarker(marker);

    final restored = await store.read();
    expect(restored?.toJson(), marker.toJson());
    expect(
      root.listSync().whereType<File>().map((file) => file.path),
      hasLength(1),
    );
  });

  test('reports malformed marker as admission failure', () async {
    await File(
      '${root.path}/${FileSystemArchiveMarkerStore.markerFileName}',
    ).writeAsString('{not-json');
    final store = FileSystemArchiveMarkerStore(rootPath: root.path);

    await expectLater(
      store.read(),
      throwsA(
        isA<ArchiveAdmissionException>().having(
          (error) => error.failure,
          'failure',
          ArchiveAdmissionFailure.malformedMarker,
        ),
      ),
    );
  });

  test('never overwrites an existing marker', () async {
    final markerFile = File(
      '${root.path}/${FileSystemArchiveMarkerStore.markerFileName}',
    );
    await markerFile.writeAsString('existing');
    final store = FileSystemArchiveMarkerStore(rootPath: root.path);

    await expectLater(
      store.createInitialMarker(
        ArchiveMarker(
          formatVersion: ArchiveMarker.currentFormatVersion,
          environment: ArchiveEnvironment.test,
          archiveInstanceId: ArchiveInstanceId(
            'ec595fd6-e1b9-42bb-9dac-cb4d7374ec04',
          ),
          createdAtUtc: DateTime.utc(2026, 7, 27),
        ),
      ),
      throwsA(
        isA<ArchiveAdmissionException>().having(
          (error) => error.failure,
          'failure',
          ArchiveAdmissionFailure.markerCreationFailed,
        ),
      ),
    );
    expect(await markerFile.readAsString(), 'existing');
  });
}
