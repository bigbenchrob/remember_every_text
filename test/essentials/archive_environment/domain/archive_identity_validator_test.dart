import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/archive_environment/domain.dart';

void main() {
  const productionRoot = '/archives/production';
  const developmentRoot = '/archives/development';
  const testRoot = '/tmp/message_lens_test';

  const validator = ArchiveIdentityValidator(
    rootPolicy: _TestRootPolicy(
      roots: <ArchiveEnvironment, String>{
        ArchiveEnvironment.production: productionRoot,
        ArchiveEnvironment.development: developmentRoot,
        ArchiveEnvironment.test: testRoot,
      },
    ),
  );

  group('ArchiveIdentityValidator', () {
    test('admits compatible development identity and marker', () {
      final resolved = validator.validate(
        claim: _claim(
          environment: ArchiveEnvironment.development,
          buildIdentity: ArchiveBuildIdentity.developmentDebug,
          rootPath: developmentRoot,
        ),
        marker: _marker(ArchiveEnvironment.development),
      );

      expect(resolved.environment, ArchiveEnvironment.development);
      expect(resolved.canonicalRootPath, developmentRoot);
      expect(
        resolved.archiveInstanceId.value,
        '123e4567-e89b-42d3-a456-426614174000',
      );
    });

    test('admits the exact FDA experiment identity as development', () {
      final resolved = validator.validate(
        claim: _claim(
          environment: ArchiveEnvironment.development,
          buildIdentity: ArchiveBuildIdentity.fdaExperiment,
          rootPath: developmentRoot,
        ),
        marker: _marker(ArchiveEnvironment.development),
      );

      expect(resolved.environment, ArchiveEnvironment.development);
      expect(
        resolved.bundleIdentifier,
        ArchiveIdentityValidator.fdaExperimentBundleIdentifier,
      );
      expect(
        resolved.productName,
        ArchiveIdentityValidator.fdaExperimentProductName,
      );
    });

    test('normal development identity cannot claim the FDA experiment app', () {
      expect(
        () => validator.validate(
          claim: const NativeArchiveClaim(
            environment: ArchiveEnvironment.development,
            buildIdentity: ArchiveBuildIdentity.developmentDebug,
            bundleIdentifier:
                ArchiveIdentityValidator.fdaExperimentBundleIdentifier,
            productName: ArchiveIdentityValidator.fdaExperimentProductName,
            canonicalRootPath: developmentRoot,
            productionSignatureIsValid: true,
          ),
          marker: _marker(ArchiveEnvironment.development),
        ),
        throwsA(
          isA<ArchiveAdmissionException>().having(
            (error) => error.failure,
            'failure',
            ArchiveAdmissionFailure.bundleIdentifierMismatch,
          ),
        ),
      );
    });

    test('admits production only with valid signature evidence', () {
      expect(
        () => validator.validate(
          claim: _claim(
            environment: ArchiveEnvironment.production,
            buildIdentity: ArchiveBuildIdentity.productionRelease,
            rootPath: productionRoot,
            productionSignatureIsValid: false,
          ),
          marker: _marker(ArchiveEnvironment.production),
        ),
        throwsA(
          isA<ArchiveAdmissionException>().having(
            (error) => error.failure,
            'failure',
            ArchiveAdmissionFailure.invalidProductionSignature,
          ),
        ),
      );
    });

    test('rejects development claim for a production marker', () {
      expect(
        () => validator.validate(
          claim: _claim(
            environment: ArchiveEnvironment.development,
            buildIdentity: ArchiveBuildIdentity.developmentDebug,
            rootPath: developmentRoot,
          ),
          marker: _marker(ArchiveEnvironment.production),
        ),
        throwsA(
          isA<ArchiveAdmissionException>().having(
            (error) => error.failure,
            'failure',
            ArchiveAdmissionFailure.markerEnvironmentMismatch,
          ),
        ),
      );
    });

    test('rejects build and environment mismatch', () {
      expect(
        () => validator.validate(
          claim: _claim(
            environment: ArchiveEnvironment.development,
            buildIdentity: ArchiveBuildIdentity.productionRelease,
            rootPath: developmentRoot,
          ),
          marker: _marker(ArchiveEnvironment.development),
        ),
        throwsA(
          isA<ArchiveAdmissionException>().having(
            (error) => error.failure,
            'failure',
            ArchiveAdmissionFailure.buildEnvironmentMismatch,
          ),
        ),
      );
    });

    test('rejects a noncanonical root', () {
      expect(
        () => validator.validate(
          claim: _claim(
            environment: ArchiveEnvironment.development,
            buildIdentity: ArchiveBuildIdentity.developmentDebug,
            rootPath: productionRoot,
          ),
          marker: _marker(ArchiveEnvironment.development),
        ),
        throwsA(
          isA<ArchiveAdmissionException>().having(
            (error) => error.failure,
            'failure',
            ArchiveAdmissionFailure.nonCanonicalRoot,
          ),
        ),
      );
    });

    test('rejects an Application Support root for tests', () {
      const applicationSupportRoot =
          '/Users/test/Library/Application Support/test.archive';
      const testValidator = ArchiveIdentityValidator(
        rootPolicy: _TestRootPolicy(
          roots: <ArchiveEnvironment, String>{
            ArchiveEnvironment.production: productionRoot,
            ArchiveEnvironment.development: developmentRoot,
            ArchiveEnvironment.test: applicationSupportRoot,
          },
        ),
      );

      expect(
        () => testValidator.validate(
          claim: _claim(
            environment: ArchiveEnvironment.test,
            buildIdentity: ArchiveBuildIdentity.testHarness,
            rootPath: applicationSupportRoot,
          ),
          marker: _marker(ArchiveEnvironment.test),
        ),
        throwsA(
          isA<ArchiveAdmissionException>().having(
            (error) => error.failure,
            'failure',
            ArchiveAdmissionFailure.testApplicationSupportRoot,
          ),
        ),
      );
    });
  });
}

NativeArchiveClaim _claim({
  required ArchiveEnvironment environment,
  required ArchiveBuildIdentity buildIdentity,
  required String rootPath,
  bool productionSignatureIsValid = true,
}) {
  final applicationIdentity = switch (environment) {
    ArchiveEnvironment.production => (
      bundleIdentifier:
          ArchiveIdentityValidator.defaultProductionBundleIdentifier,
      productName: ArchiveIdentityValidator.defaultProductionProductName,
    ),
    ArchiveEnvironment.development => (
      bundleIdentifier:
          ArchiveIdentityValidator.defaultDevelopmentBundleIdentifier,
      productName: ArchiveIdentityValidator.defaultDevelopmentProductName,
    ),
    ArchiveEnvironment.test => (
      bundleIdentifier: 'com.bigbenchsoftware.MessageLens.tests',
      productName: 'MessageLens Tests',
    ),
  };

  final resolvedApplicationIdentity =
      buildIdentity == ArchiveBuildIdentity.fdaExperiment
      ? (
          bundleIdentifier:
              ArchiveIdentityValidator.fdaExperimentBundleIdentifier,
          productName: ArchiveIdentityValidator.fdaExperimentProductName,
        )
      : applicationIdentity;

  return NativeArchiveClaim(
    environment: environment,
    buildIdentity: buildIdentity,
    bundleIdentifier: resolvedApplicationIdentity.bundleIdentifier,
    productName: resolvedApplicationIdentity.productName,
    canonicalRootPath: rootPath,
    productionSignatureIsValid: productionSignatureIsValid,
  );
}

ArchiveMarker _marker(ArchiveEnvironment environment) {
  return ArchiveMarker(
    formatVersion: ArchiveMarker.currentFormatVersion,
    environment: environment,
    archiveInstanceId: ArchiveInstanceId(
      '123e4567-e89b-42d3-a456-426614174000',
    ),
    createdAtUtc: DateTime.utc(2026, 7, 27),
  );
}

final class _TestRootPolicy implements CanonicalArchiveRootPolicy {
  const _TestRootPolicy({required this.roots});

  final Map<ArchiveEnvironment, String> roots;

  @override
  bool isCanonicalRoot({
    required ArchiveEnvironment environment,
    required String rootPath,
  }) {
    return roots[environment] == rootPath;
  }

  @override
  bool isPlatformApplicationSupportPath(String rootPath) {
    return rootPath.contains('/Library/Application Support/');
  }
}
