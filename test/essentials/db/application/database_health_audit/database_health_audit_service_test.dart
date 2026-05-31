import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/db/application/database_health_audit/database_health_audit_service.dart';

void main() {
  group('DatabaseHealthAuditService', () {
    test(
      'uses injected full disk access state in environment report',
      () async {
        final service = DatabaseHealthAuditService(
          hasFullDiskAccess: false,
          queryLayers: const [],
        );

        final report = await service.buildPhase1Report();

        expect(report.environment.hasFullDiskAccess, isFalse);
      },
    );
  });
}
