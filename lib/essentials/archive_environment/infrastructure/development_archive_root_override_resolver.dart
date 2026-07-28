import 'dart:io';

import 'package:path/path.dart' as path;

import '../domain/archive_admission_exception.dart';
import '../domain/archive_environment.dart';

/// Resolves the machine-local development archive-root override.
///
/// Native bootstrap and Dart admission each consume the same process
/// environment value independently. The native claim is admitted only when
/// both sides resolve the same canonical root.
final class DevelopmentArchiveRootOverrideResolver {
  const DevelopmentArchiveRootOverrideResolver({
    this.environmentVariableName =
        defaultDevelopmentArchiveRootEnvironmentVariable,
  });

  static const String defaultDevelopmentArchiveRootEnvironmentVariable =
      'MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT';

  final String environmentVariableName;

  String resolveExpectedRoot({
    required ArchiveEnvironment environment,
    required String defaultRootPath,
    Map<String, String>? processEnvironment,
  }) {
    final environmentValues = processEnvironment ?? Platform.environment;
    final configuredValue = environmentValues[environmentVariableName]?.trim();
    if (configuredValue == null || configuredValue.isEmpty) {
      return path.normalize(defaultRootPath);
    }

    if (environment != ArchiveEnvironment.development) {
      throw ArchiveAdmissionException(
        ArchiveAdmissionFailure.developmentRootOverrideNotPermitted,
        '$environmentVariableName is valid only for a development archive.',
      );
    }

    if (!path.isAbsolute(configuredValue)) {
      throw ArchiveAdmissionException(
        ArchiveAdmissionFailure.invalidDevelopmentRootOverride,
        '$environmentVariableName must contain an absolute path.',
      );
    }

    final configuredDirectory = Directory(path.normalize(configuredValue));
    if (!configuredDirectory.existsSync()) {
      throw ArchiveAdmissionException(
        ArchiveAdmissionFailure.unavailableDevelopmentRootOverride,
        'The configured development archive root is unavailable: '
        '${configuredDirectory.path}',
      );
    }

    try {
      return path.normalize(configuredDirectory.resolveSymbolicLinksSync());
    } on FileSystemException catch (error) {
      throw ArchiveAdmissionException(
        ArchiveAdmissionFailure.unavailableDevelopmentRootOverride,
        'The configured development archive root could not be resolved: '
        '${configuredDirectory.path}. ${error.message}',
      );
    }
  }
}
