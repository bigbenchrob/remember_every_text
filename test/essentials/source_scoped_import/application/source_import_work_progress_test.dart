import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/application/source_import_work_progress.dart';

void main() {
  test(
    'progress cadence publishes start, bounded batches, and exact final',
    () {
      final observations = <SourceImportWorkProgress>[];

      for (var completed = 0; completed <= 2501; completed += 1) {
        publishSourceImportProgress(
          observer: observations.add,
          unit: SourceImportWorkUnit.messages,
          completedWorkCount: completed,
          totalWorkCount: 2501,
          lastCompletedSourceRowId: completed == 0 ? null : completed + 100,
        );
      }

      expect(observations.map((item) => item.completedWorkCount), <int>[
        0,
        1000,
        2000,
        2501,
      ]);
      expect(observations.first.totalWorkCount, 2501);
      expect(observations.last.lastCompletedSourceRowId, 2601);
    },
  );

  test('empty enumerable work emits one truthful zero observation', () {
    final observations = <SourceImportWorkProgress>[];

    publishSourceImportProgress(
      observer: observations.add,
      unit: SourceImportWorkUnit.attachments,
      completedWorkCount: 0,
      totalWorkCount: 0,
    );

    expect(observations, hasLength(1));
    expect(observations.single.completedWorkCount, 0);
    expect(observations.single.totalWorkCount, 0);
  });

  test('record exception exposes bounded domain and row context only', () {
    const exception = SourceImportRecordException(
      unit: SourceImportWorkUnit.handles,
      sourceRowId: 42,
      reason: 'handle.id is required',
    );

    expect(
      exception.toString(),
      'Source import handles at source ROWID 42 failed: '
      'handle.id is required',
    );
  });
}
