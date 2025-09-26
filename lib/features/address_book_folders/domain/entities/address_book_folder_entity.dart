import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart' as p;

import '../../../../core/util/date_converter.dart';

import '../../../../domain_driven_development/value_objects.dart';
import '../value_objects/value_objects.dart';

part 'address_book_folder_entity.freezed.dart';

@freezed
abstract class AddressBookFolderEntity with _$AddressBookFolderEntity {
  const factory AddressBookFolderEntity({
    required FolderPathValueObject path,
    required AddressBookFolderShortPath shortPath,
    required FolderCreationDate lastCreationDate,
    required FolderModificationDate lastModificationDate,
    required NonZeroInt recordCount,
  }) = _AddressBookFolderEntity;

  const AddressBookFolderEntity._();

  factory AddressBookFolderEntity.fromJson(Map<String, dynamic> json) {
    final path = json['path'].toString();
    final splitPath = p.split(path);
    final shortPath = splitPath[7];

    // dumbass varying apple date formats:
    //  Apple: nanoseconds since 2001-01-01
    //  Unix: seconds since 1970-01-01
    //  Apple Core Time Stamp: seconds since 2001=01-01 == this db
    //  Dart: milliseconds since 1970-01-01

    final creationDateMaxCTS =
        json['creationDateMax'] as double? ??
        0.0; // Default timestamp if missing
    final creationDateMaxApple = DateConverter.coreTS2Apple(creationDateMaxCTS);
    final creationDateDart = DateConverter.apple2Dart(creationDateMaxApple);

    final modDateMaxCTS =
        json['modificationDateMax'] as double? ??
        0.0; // Default timestamp if missing
    final modDateMaxApple = DateConverter.coreTS2Apple(modDateMaxCTS);
    final modDateDart = DateConverter.apple2Dart(modDateMaxApple);

    final recordCount = json['count'] as int;

    return AddressBookFolderEntity(
      path: FolderPathValueObject(path),
      shortPath: AddressBookFolderShortPath(shortPath),
      lastCreationDate: FolderCreationDate(
        DateConverter.dartTimeStamp2DateTime(creationDateDart),
      ),
      lastModificationDate: FolderModificationDate(
        DateConverter.dartTimeStamp2DateTime(modDateDart),
      ),
      recordCount: NonZeroInt(recordCount),
    );
  }
}
