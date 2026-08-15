/// The trust boundary assigned to one MessageLens archive.
enum ArchiveEnvironment {
  production,
  development,
  test;

  String get serializedName => name;

  static ArchiveEnvironment parse(String value) {
    return ArchiveEnvironment.values.firstWhere(
      (environment) => environment.serializedName == value,
      orElse: () {
        throw FormatException('Unknown archive environment: $value');
      },
    );
  }
}
