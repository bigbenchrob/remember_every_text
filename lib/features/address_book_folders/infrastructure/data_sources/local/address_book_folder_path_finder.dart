import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'package:path/path.dart';

import '../../../../../core/util/paths_helper.dart';

class AddressBookFolderPathsFinder {
  final PathsHelper pathsHelper;

  AddressBookFolderPathsFinder({required this.pathsHelper});

  Future<List<String>> getAddressBookPaths() async {
    final dirList = await getAddressBookDirectories();
    final pathsList = dirList
        .map((dir) => '${dir.path}/AddressBook-v22.abcddb')
        .toList();
    return pathsList;
  }

  Future<List<Directory>> getAddressBookDirectories() async {
    const dirStub = 'Library/Application Support/AddressBook/Sources/';
    final parentDirPath = pathsHelper.userGraft(dirStub);
    final dirObj = Directory(parentDirPath);
    final directories = await dirChatFolders(dirObj);

    return directories.toList();
  }

  Future<List<Directory>> dirChatFolders(Directory dir) {
    final directories = <Directory>[];
    final completer = Completer<List<Directory>>();
    final lister = dir.list(followLinks: false);

    lister.listen(
      (entity) {
        if (entity is! File) {
          if (directoryAtPathContainsAddressBookDB(entity.path))
            directories.add(Directory(entity.path));
        }
      },
      onDone: () => completer.complete(directories),
      onError: (Object e) => completer.completeError(e),
    );

    return completer.future;
  }

  bool directoryAtPathContainsAddressBookDB(String dirPath) {
    final dir = Directory(dirPath);
    var hasDB = false;
    try {
      if (dir.existsSync()) {
        for (final entity in dir.listSync(followLinks: false)) {
          final baseName = basename(entity.path);
          if (entity is File && baseName == 'AddressBook-v22.abcddb') {
            hasDB = true;
          }
        }
      }
    } catch (e) {
      // print(e);
    }

    return hasDB;
  }
}
