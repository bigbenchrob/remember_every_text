import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/conversation_graph/application/projection_work_progress.dart';

void main() {
  test(
    'publishes only bounded real-work boundaries and terminal completion',
    () {
      final publishedCounts = [
        for (var completed = 1; completed <= 621; completed++)
          if (shouldPublishGraphProjectionProgress(
            completedWorkCount: completed,
            totalWorkCount: 621,
          ))
            completed,
      ];

      expect(publishedCounts, [250, 500, 621]);
    },
  );

  test(
    'progress rejects impossible numerator and denominator combinations',
    () {
      expect(
        () => GraphProjectionWorkProgress(
          completedWorkCount: 2,
          totalWorkCount: 1,
        ),
        throwsA(isA<AssertionError>()),
      );
    },
  );
}
