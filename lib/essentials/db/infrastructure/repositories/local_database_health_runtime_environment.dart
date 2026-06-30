import 'dart:io';

import '../../application/database_health_audit/database_health_runtime_environment.dart';

class LocalDatabaseHealthRuntimeEnvironment
    implements DatabaseHealthRuntimeEnvironment {
  const LocalDatabaseHealthRuntimeEnvironment();

  @override
  DatabaseHealthRuntimeEnvironmentSnapshot read() {
    return DatabaseHealthRuntimeEnvironmentSnapshot(
      platform: Platform.operatingSystem,
      platformVersion: Platform.operatingSystemVersion,
      timezone: Platform.environment['TZ'] ?? DateTime.now().timeZoneName,
    );
  }
}
