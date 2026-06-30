class DatabaseHealthRuntimeEnvironmentSnapshot {
  const DatabaseHealthRuntimeEnvironmentSnapshot({
    required this.platform,
    required this.platformVersion,
    required this.timezone,
  });

  final String platform;
  final String platformVersion;
  final String timezone;
}

abstract interface class DatabaseHealthRuntimeEnvironment {
  DatabaseHealthRuntimeEnvironmentSnapshot read();
}
