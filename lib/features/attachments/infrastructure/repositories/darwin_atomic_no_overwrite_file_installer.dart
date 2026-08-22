import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

import '../../application/atomic_no_overwrite_file_installer.dart';

typedef _LinkNative = Int32 Function(Pointer<Utf8>, Pointer<Utf8>);
typedef _LinkDart = int Function(Pointer<Utf8>, Pointer<Utf8>);

/// macOS atomic no-overwrite installation through POSIX `link(2)`.
///
/// The verified temporary file and destination are in the same directory.
/// `link(2)` atomically creates the destination directory entry and fails when
/// that entry already exists; it never replaces the existing payload.
class DarwinAtomicNoOverwriteFileInstaller
    implements AtomicNoOverwriteFileInstaller {
  const DarwinAtomicNoOverwriteFileInstaller();

  static final _link = DynamicLibrary.process()
      .lookupFunction<_LinkNative, _LinkDart>('link');

  @override
  Future<AtomicFileInstallResult> install({
    required String temporaryPath,
    required String destinationPath,
  }) async {
    if (!Platform.isMacOS) {
      throw UnsupportedError(
        'Atomic attachment installation currently supports macOS only.',
      );
    }

    final temporaryPointer = temporaryPath.toNativeUtf8();
    final destinationPointer = destinationPath.toNativeUtf8();
    try {
      final result = _link(temporaryPointer, destinationPointer);
      if (result == 0) {
        return AtomicFileInstallResult.installed;
      }

      if (FileSystemEntity.typeSync(destinationPath, followLinks: false) !=
          FileSystemEntityType.notFound) {
        return AtomicFileInstallResult.destinationExists;
      }

      throw FileSystemException(
        'Atomic no-overwrite attachment installation failed.',
        destinationPath,
      );
    } finally {
      calloc.free(temporaryPointer);
      calloc.free(destinationPointer);
    }
  }
}
