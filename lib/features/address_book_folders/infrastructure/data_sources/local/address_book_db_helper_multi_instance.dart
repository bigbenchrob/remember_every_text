import 'package:sqflite/sqflite.dart';

/// Opens one AddressBook SQLite candidate path for viability checks.
///
/// AddressBook folder discovery probes multiple candidate database paths, so
/// this helper intentionally avoids singleton database ownership.
class AddressBookDbHelperMultiInstance {
  final String _path;
  Database? _db;
  AddressBookDbHelperMultiInstance(this._path);

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    Database db;
    try {
      db = await openReadOnlyDatabase(_path);
    } catch (error) {
      throw StateError(
        "AddressBook database couldn't be opened at path '$_path': $error",
      );
    }
    return db;
  }
}
