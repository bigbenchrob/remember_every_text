import 'package:sqflite/sqflite.dart';

/// Necessary because AddressFolderRepository needs to
/// rapidly generate a sequence of database for different
/// paths. A singleton is exactly what we *don't* want here!

/// _db intialization is lazy loaded, so in order to test that
/// a folder path contains a functional sqlite database, need
/// to instantiate this helper and call .database on it.

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
    } catch (e) {
      throw "A dang database couldn't be found at the path: $_path";
    }
    return db;
  }
}
