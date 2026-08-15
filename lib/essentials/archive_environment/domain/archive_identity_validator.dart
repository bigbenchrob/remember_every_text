import 'archive_admission_exception.dart';
import 'archive_build_identity.dart';
import 'archive_environment.dart';
import 'archive_marker.dart';
import 'canonical_archive_root_policy.dart';
import 'native_archive_claim.dart';
import 'resolved_archive_identity.dart';

/// Pure compatibility rules for native claims and archive markers.
final class ArchiveIdentityValidator {
  const ArchiveIdentityValidator({
    required this.rootPolicy,
    this.productionBundleIdentifier = defaultProductionBundleIdentifier,
    this.productionProductName = defaultProductionProductName,
    this.developmentBundleIdentifier = defaultDevelopmentBundleIdentifier,
    this.developmentProductName = defaultDevelopmentProductName,
  });

  static const String defaultProductionBundleIdentifier =
      'com.bigbenchsoftware.MessageLens';
  static const String defaultProductionProductName = 'MessageLens';
  static const String defaultDevelopmentBundleIdentifier =
      'com.bigbenchsoftware.MessageLens.development';
  static const String defaultDevelopmentProductName = 'MessageLens Development';
  static const String fdaExperimentBundleIdentifier =
      'com.bigbenchsoftware.MessageLens.fdaexperiment';
  static const String fdaExperimentProductName = 'MessageLens FDA Experiment';

  final CanonicalArchiveRootPolicy rootPolicy;
  final String productionBundleIdentifier;
  final String productionProductName;
  final String developmentBundleIdentifier;
  final String developmentProductName;

  ResolvedArchiveIdentity validate({
    required NativeArchiveClaim claim,
    required ArchiveMarker marker,
  }) {
    validateClaim(claim);
    _validateMarker(claim: claim, marker: marker);

    return ResolvedArchiveIdentity(
      environment: claim.environment,
      buildIdentity: claim.buildIdentity,
      archiveInstanceId: marker.archiveInstanceId,
      canonicalRootPath: claim.canonicalRootPath,
      bundleIdentifier: claim.bundleIdentifier,
      productName: claim.productName,
    );
  }

  void validateClaim(NativeArchiveClaim claim) {
    if (claim.buildIdentity.environment != claim.environment) {
      throw const ArchiveAdmissionException(
        ArchiveAdmissionFailure.buildEnvironmentMismatch,
        'Native build identity does not match the declared archive environment.',
      );
    }

    final expectedIdentity = _expectedApplicationIdentity(claim.buildIdentity);
    if (claim.bundleIdentifier != expectedIdentity.bundleIdentifier) {
      throw ArchiveAdmissionException(
        ArchiveAdmissionFailure.bundleIdentifierMismatch,
        'Bundle ${claim.bundleIdentifier} is incompatible with '
        '${claim.environment.serializedName}.',
      );
    }
    if (claim.productName != expectedIdentity.productName) {
      throw ArchiveAdmissionException(
        ArchiveAdmissionFailure.productNameMismatch,
        'Product ${claim.productName} is incompatible with '
        '${claim.environment.serializedName}.',
      );
    }
    if (claim.environment == ArchiveEnvironment.production &&
        !claim.productionSignatureIsValid) {
      throw const ArchiveAdmissionException(
        ArchiveAdmissionFailure.invalidProductionSignature,
        'Production archive authority requires the expected production signature.',
      );
    }
    if (!rootPolicy.isCanonicalRoot(
      environment: claim.environment,
      rootPath: claim.canonicalRootPath,
    )) {
      throw ArchiveAdmissionException(
        ArchiveAdmissionFailure.nonCanonicalRoot,
        'Archive root is not canonical for '
        '${claim.environment.serializedName}.',
      );
    }
    if (claim.environment == ArchiveEnvironment.test &&
        rootPolicy.isPlatformApplicationSupportPath(claim.canonicalRootPath)) {
      throw const ArchiveAdmissionException(
        ArchiveAdmissionFailure.testApplicationSupportRoot,
        'Tests may not use a platform Application Support root.',
      );
    }
  }

  void _validateMarker({
    required NativeArchiveClaim claim,
    required ArchiveMarker marker,
  }) {
    if (marker.formatVersion != ArchiveMarker.currentFormatVersion) {
      throw ArchiveAdmissionException(
        ArchiveAdmissionFailure.markerFormatMismatch,
        'Unsupported archive marker format ${marker.formatVersion}.',
      );
    }
    if (marker.environment != claim.environment) {
      throw ArchiveAdmissionException(
        ArchiveAdmissionFailure.markerEnvironmentMismatch,
        'A ${claim.environment.serializedName} process cannot admit a '
        '${marker.environment.serializedName} archive.',
      );
    }
  }

  ({String bundleIdentifier, String productName}) _expectedApplicationIdentity(
    ArchiveBuildIdentity buildIdentity,
  ) {
    return switch (buildIdentity) {
      ArchiveBuildIdentity.productionRelease => (
        bundleIdentifier: productionBundleIdentifier,
        productName: productionProductName,
      ),
      ArchiveBuildIdentity.developmentDebug ||
      ArchiveBuildIdentity.developmentProfile ||
      ArchiveBuildIdentity.developmentRelease => (
        bundleIdentifier: developmentBundleIdentifier,
        productName: developmentProductName,
      ),
      ArchiveBuildIdentity.fdaExperiment => (
        bundleIdentifier: fdaExperimentBundleIdentifier,
        productName: fdaExperimentProductName,
      ),
      ArchiveBuildIdentity.testHarness => (
        bundleIdentifier: 'com.bigbenchsoftware.MessageLens.tests',
        productName: 'MessageLens Tests',
      ),
    };
  }
}
