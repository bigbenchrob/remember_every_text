import 'dart:convert';
import 'dart:io';

import '../application/archive_marker_store.dart';
import '../domain/archive_admission_exception.dart';
import '../domain/archive_marker.dart';

/// Filesystem marker store rooted at one native-declared archive.
final class FileSystemArchiveMarkerStore implements ArchiveMarkerStore {
  FileSystemArchiveMarkerStore({required String rootPath})
    : _rootDirectory = Directory(rootPath);

  static const String markerFileName = '.messagelens-archive.json';
  static const Set<String> bootstrapFileNames = <String>{
    'MessageLens.instance.lock',
  };

  final Directory _rootDirectory;

  File get _markerFile => File('${_rootDirectory.path}/$markerFileName');

  @override
  Future<ArchiveMarker?> read() async {
    if (!_markerFile.existsSync()) {
      return null;
    }

    try {
      final decoded = jsonDecode(await _markerFile.readAsString());
      if (decoded is! Map) {
        throw const FormatException('Archive marker must be a JSON object.');
      }
      return ArchiveMarker.fromJson(Map<String, Object?>.from(decoded));
    } on ArchiveAdmissionException {
      rethrow;
    } catch (error) {
      throw ArchiveAdmissionException(
        ArchiveAdmissionFailure.malformedMarker,
        'Archive marker could not be decoded: $error',
      );
    }
  }

  @override
  Future<bool> canCreateInitialMarker() async {
    if (!_rootDirectory.existsSync()) {
      return true;
    }

    await for (final entity in _rootDirectory.list(followLinks: false)) {
      final name = entity.uri.pathSegments
          .where((segment) => segment.isNotEmpty)
          .last;
      if (!bootstrapFileNames.contains(name) || entity is! File) {
        return false;
      }
    }
    return true;
  }

  @override
  Future<void> createInitialMarker(ArchiveMarker marker) async {
    try {
      await _rootDirectory.create(recursive: true);
      if (_markerFile.existsSync()) {
        throw const ArchiveAdmissionException(
          ArchiveAdmissionFailure.markerCreationFailed,
          'Archive marker already exists.',
        );
      }

      final temporaryFile = File(
        '${_markerFile.path}.tmp-${marker.archiveInstanceId.value}',
      );
      await temporaryFile.create(exclusive: true);
      try {
        await temporaryFile.writeAsString(
          '${jsonEncode(marker.toJson())}\n',
          flush: true,
        );
        if (_markerFile.existsSync()) {
          throw const ArchiveAdmissionException(
            ArchiveAdmissionFailure.markerCreationFailed,
            'Archive marker appeared during initial creation.',
          );
        }
        await temporaryFile.rename(_markerFile.path);
      } finally {
        if (temporaryFile.existsSync()) {
          await temporaryFile.delete();
        }
      }
    } on ArchiveAdmissionException {
      rethrow;
    } catch (error) {
      throw ArchiveAdmissionException(
        ArchiveAdmissionFailure.markerCreationFailed,
        'Archive marker creation failed: $error',
      );
    }
  }
}
