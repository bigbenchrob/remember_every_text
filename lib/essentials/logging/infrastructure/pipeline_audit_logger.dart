import 'dart:io';

import 'package:path/path.dart' as path;

/// Writes structured, human-readable audit logs for active graph lifecycle and
/// diagnostic pipelines.
///
/// Each run appends a new timestamped section to the log file. Files are
/// stored in the app's database directory so they sit alongside the databases
/// they describe.
class PipelineAuditLogger {
  PipelineAuditLogger._(this._sink, this._filePath);

  final IOSink _sink;
  final String _filePath;

  /// The path of the log file being written to.
  String get filePath => _filePath;

  /// Open (or create) a log file inside an admitted archive directory.
  static Future<PipelineAuditLogger> open(
    String fileName, {
    required String directoryPath,
  }) async {
    if (fileName.isEmpty ||
        path.isAbsolute(fileName) ||
        path.basename(fileName) != fileName) {
      throw StateError('Pipeline audit log file name must be a base name.');
    }

    if (_isSymlink(directoryPath)) {
      throw StateError('Pipeline audit log directory must not be a symlink.');
    }

    final logPath = path.join(directoryPath, fileName);
    final file = File(logPath);
    if (_isSymlink(file.path) || _isDirectory(file.path)) {
      throw StateError('Pipeline audit log target must be a regular file.');
    }
    final sink = file.openWrite(mode: FileMode.append);
    return PipelineAuditLogger._(sink, logPath);
  }

  // ---------------------------------------------------------------------------
  // Structured writing helpers
  // ---------------------------------------------------------------------------

  static final String _separator = '=' * 72;

  /// Write a prominent section header.
  void header(String title) {
    _sink.writeln('');
    _sink.writeln(_separator);
    _sink.writeln(title);
    _sink.writeln(_separator);
  }

  /// Write a sub-section header.
  void subHeader(String title) {
    _sink.writeln('');
    _sink.writeln('--- $title ---');
  }

  /// Write an informational line.
  void info(String message) {
    _sink.writeln(message);
  }

  /// Write a blank line.
  void blank() {
    _sink.writeln('');
  }

  /// Write a key-value line with right-aligned count.
  void stat(String label, Object value) {
    final paddedLabel = label.padRight(50);
    _sink.writeln('  $paddedLabel $value');
  }

  /// Write a comparison line: source count vs destination count with delta.
  void compare(String label, int source, int destination) {
    final delta = destination - source;
    final sign = delta >= 0 ? '+' : '';
    final paddedLabel = label.padRight(40);
    _sink.writeln(
      '  $paddedLabel src=$source  dst=$destination  delta=$sign$delta',
    );
  }

  /// Write a warning line.
  void warn(String message) {
    _sink.writeln('  ⚠ WARNING: $message');
  }

  /// Write an error line.
  void error(String message) {
    _sink.writeln('  ✗ ERROR: $message');
  }

  /// Write a success line.
  void ok(String message) {
    _sink.writeln('  ✓ $message');
  }

  /// Write a table of key-value pairs with aligned columns.
  void table(Map<String, Object> rows) {
    if (rows.isEmpty) {
      return;
    }
    final maxKeyLen = rows.keys.fold<int>(
      0,
      (prev, k) => k.length > prev ? k.length : prev,
    );
    for (final entry in rows.entries) {
      final paddedKey = entry.key.padRight(maxKeyLen + 2);
      _sink.writeln('  $paddedKey ${entry.value}');
    }
  }

  /// Write a list of skip reasons with counts.
  void skipReasons(Map<String, int> reasons) {
    if (reasons.isEmpty) {
      ok('No rows skipped');
      return;
    }
    for (final entry in reasons.entries) {
      _sink.writeln('    - ${entry.key}: ${entry.value} rows');
    }
  }

  /// Flush and close the log file.
  Future<void> close() async {
    await _sink.flush();
    await _sink.close();
  }
}

bool _isDirectory(String filePath) {
  return FileSystemEntity.typeSync(filePath, followLinks: false) ==
      FileSystemEntityType.directory;
}

bool _isSymlink(String filePath) {
  return FileSystemEntity.typeSync(filePath, followLinks: false) ==
      FileSystemEntityType.link;
}
