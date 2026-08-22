enum AtomicFileInstallResult { installed, destinationExists }

/// Atomically makes a verified temporary file visible at its final path.
///
/// Implementations must never replace an existing destination.
abstract interface class AtomicNoOverwriteFileInstaller {
  Future<AtomicFileInstallResult> install({
    required String temporaryPath,
    required String destinationPath,
  });
}
