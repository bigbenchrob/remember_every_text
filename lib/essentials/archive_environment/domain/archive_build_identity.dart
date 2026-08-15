import 'archive_environment.dart';

/// Immutable build intent supplied by native bootstrap.
enum ArchiveBuildIdentity {
  developmentDebug(ArchiveEnvironment.development),
  developmentProfile(ArchiveEnvironment.development),
  developmentRelease(ArchiveEnvironment.development),
  fdaExperiment(ArchiveEnvironment.development),
  productionRelease(ArchiveEnvironment.production),
  testHarness(ArchiveEnvironment.test);

  const ArchiveBuildIdentity(this.environment);

  final ArchiveEnvironment environment;

  String get serializedName => name;

  static ArchiveBuildIdentity parse(String value) {
    return ArchiveBuildIdentity.values.firstWhere(
      (identity) => identity.serializedName == value,
      orElse: () {
        throw FormatException('Unknown archive build identity: $value');
      },
    );
  }
}
