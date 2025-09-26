import 'package:dartz/dartz.dart';

import '../../../../domain_driven_development/failures.dart';
import '../../../../domain_driven_development/value_objects.dart';
import '../../../../domain_driven_development/value_validators.dart';

/// A value object used by other entities to validate the chat id.
/// At this point, it is just a wrapper around an integer that also
/// validates that the integer is non-zero.

class AddressBookFolderShortPath extends ValueObject<String> {
  @override
  final Either<ValueFailure<String>, String> value;

  factory AddressBookFolderShortPath(String input) {
    return AddressBookFolderShortPath._(validateStringNotEmpty(input));
  }

  const AddressBookFolderShortPath._(this.value);
}

class FolderCreationDate extends ValueObject<DateTime> {
  @override
  final Either<ValueFailure<DateTime>, DateTime> value;

  factory FolderCreationDate(DateTime input) {
    return FolderCreationDate._(right(input));
  }

  const FolderCreationDate._(this.value);
}

class FolderModificationDate extends ValueObject<DateTime> {
  @override
  final Either<ValueFailure<DateTime>, DateTime> value;

  factory FolderModificationDate(DateTime input) {
    return FolderModificationDate._(right(input));
  }

  const FolderModificationDate._(this.value);
}
