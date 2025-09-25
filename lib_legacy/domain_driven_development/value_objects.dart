// import 'package:dartz/dartz.dart';
// import 'package:meta/meta.dart';
// import 'package:uuid/uuid.dart';

// import './errors.dart';
// import './failures.dart';
// import 'i_validatable.dart';

// @immutable
// abstract class ValueObject<T> implements IValidatable {
//   const ValueObject();

//   Either<ValueFailure<T>, T> get value;

//   /// Throws [UnexpectedValueError] containing the [ValueFailure]
//   /// Use this when you are sure that, in context, the value must
//   /// logically be valid. If not, the only choice is to crash the app.\
//   ///
//   /// Allows the value to be treated as a T rather than an Either.
//   T getOrCrash() {
//     return value.fold((f) => throw UnexpectedValueError(f), id);
//   }

//   /// Returns the value if it's valid, otherwise returns the default.
//   /// This is a safer way to get the value than [getOrCrash], because
//   /// it doesn't crash the app.
//   T getOrElse(T dflt) {
//     return value.getOrElse(() => dflt);
//   }

//   /// For something like an update, where we want to be alerted to
//   /// a failure but otherwise don't care about the value.
//   /// (Unit is similar to void, but is an actual object so it works
//   /// with the Dart type system.)
//   Either<ValueFailure<dynamic>, Unit> get failureOrUnit {
//     return value.fold(
//       (l) => left(l),
//       (r) => right(unit),
//     );
//   }

//   /// Returns true if the value is valid.
//   /// This is the same as calling [fold] on the [Either] and
//   /// always choosing the right side.
//   /// This is useful when you want to do a simple check on the value
//   /// and don't care about the failure.
//   @override
//   bool isValid() {
//     return value.isRight();
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) {
//       return true;
//     }
//     return other is ValueObject<T> && other.value == value;
//   }

//   @override
//   int get hashCode => value.hashCode;
// }

// class UniqueIntId extends ValueObject<int> {
//   @override
//   final Either<ValueFailure<int>, int> value;

//   /// Used with int ids we trust are unique, such as database IDs.
//   factory UniqueIntId(int id) {
//     return UniqueIntId._(
//       right(id),
//     );
//   }

//   const UniqueIntId._(this.value);
// }

// ///
// class UniversalUniqueId extends ValueObject<String> {
//   @override
//   final Either<ValueFailure<String>, String> value;

//   // We cannot let a simple String be passed in. This would allow for possible non-unique IDs.
//   factory UniversalUniqueId() {
//     return UniversalUniqueId._(
//       right(const Uuid().v1()),
//     );
//   }

//   /// Used with strings we trust are unique, such as database IDs.
//   factory UniversalUniqueId.fromUniqueString(String uniqueIdStr) {
//     return UniversalUniqueId._(
//       right(uniqueIdStr),
//     );
//   }

//   const UniversalUniqueId._(this.value);
// }

// class DateTimeValueObject extends ValueObject<DateTime> {
//   @override
//   final Either<ValueFailure<DateTime>, DateTime> value;

//   factory DateTimeValueObject(DateTime input) {
//     return DateTimeValueObject._(
//       right(input),
//     );
//   }

//   String dateToString() {
//     return value.fold(
//       (l) => throw UnexpectedValueError(l),
//       (r) => r.toIso8601String(),
//     );
//   }

//   const DateTimeValueObject._(this.value);
// }
