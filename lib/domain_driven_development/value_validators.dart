import 'dart:io';

import 'package:dartz/dartz.dart';

import 'failures.dart';

Either<ValueFailure<int>, int> validateIntNonZero(int input) {
  if (input != 0) {
    return right(input);
  } else {
    return left(ValueFailure.empty(failedValue: input));
  }
}

Either<ValueFailure<String>, String> validateMaxStringLength(
  String input,
  int maxLength,
) {
  if (input.length <= maxLength) {
    return right(input);
  } else {
    return left(
      ValueFailure.exceedingLength(failedValue: input, max: maxLength),
    );
  }
}

Either<ValueFailure<String>, String> validateMinStringLength(
  String input,
  int minLength,
) {
  if (input.length >= minLength) {
    return right(input);
  } else {
    return left(
      ValueFailure.insufficientLength(failedValue: input, min: minLength),
    );
  }
}

Either<ValueFailure<String>, String> validateStringNotEmpty(String input) {
  if (input.isEmpty) {
    return left(ValueFailure.empty(failedValue: input));
  } else {
    return right(input);
  }
}

Either<ValueFailure<String>, String> validateSingleLine(String input) {
  if (input.contains('\n')) {
    return left(ValueFailure.multiline(failedValue: input));
  } else {
    return right(input);
  }
}

Either<ValueFailure<String>, String> validateEmailAddress(String input) {
  // Maybe not the most robust way of email validation but it's good enough
  const emailRegex =
      r"""^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+""";
  if (RegExp(emailRegex).hasMatch(input)) {
    return right(input);
  } else {
    return left(ValueFailure.invalidEmail(failedValue: input));
  }
}

Either<ValueFailure<String>, String> validatePassword(String input) {
  // You can also add some advanced password checks (uppercase/lowercase, at least 1 number, ...)
  if (input.length >= 6) {
    return right(input);
  } else {
    return left(ValueFailure.shortPassword(failedValue: input));
  }
}

Either<ValueFailure<String>, String> validateMacFolderPath(String input) {
  // You can also add some advanced password checks (uppercase/lowercase, at least 1 number, ...)
  if (input.length >= 6) {
    return right(input);
  } else {
    return left(ValueFailure.invalidFolderPath(failedValue: input));
  }
}

/// Same as validateFolderPath but with a different error message
Either<ValueFailure<String>, String> validateMacFilePath(String input) {
  if (FileSystemEntity.typeSync(input) != FileSystemEntityType.notFound) {
    return right(input);
  } else {
    return left(ValueFailure.invalidFilePath(failedValue: input));
  }
}

Either<ValueFailure<String>, String> validateSupabaseApiUrl(String input) {
  return validateStringNotEmpty(input).flatMap((value) {
    final uri = Uri.tryParse(value);
    if (uri == null) {
      return left(ValueFailure.invalidSupabaseUrl(failedValue: value));
    }
    if (!uri.hasScheme || !uri.hasAuthority) {
      return left(ValueFailure.invalidSupabaseUrl(failedValue: value));
    }
    if (uri.scheme != 'https') {
      return left(ValueFailure.invalidSupabaseUrl(failedValue: value));
    }
    return right(value);
  });
}

Either<ValueFailure<String>, String> validateSupabaseServiceRoleKey(
  String input,
) {
  return validateStringNotEmpty(input);
}
