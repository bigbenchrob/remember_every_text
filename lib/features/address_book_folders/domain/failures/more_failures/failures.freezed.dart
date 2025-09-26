// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'failures.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Failure {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Failure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Failure()';
}


}

/// @nodoc
class $FailureCopyWith<$Res>  {
$FailureCopyWith(Failure _, $Res Function(Failure) __);
}


/// Adds pattern-matching-related methods to [Failure].
extension FailurePatterns on Failure {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _EmptyFailure value)?  empty,TResult Function( _UnprocessableEntityFailure value)?  unprocessableEntity,TResult Function( FolderRetrievalFailure value)?  folderRetrieval,TResult Function( _UnauthorizedFailure value)?  unauthorized,TResult Function( _BadRequestFailure value)?  badRequest,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmptyFailure() when empty != null:
return empty(_that);case _UnprocessableEntityFailure() when unprocessableEntity != null:
return unprocessableEntity(_that);case FolderRetrievalFailure() when folderRetrieval != null:
return folderRetrieval(_that);case _UnauthorizedFailure() when unauthorized != null:
return unauthorized(_that);case _BadRequestFailure() when badRequest != null:
return badRequest(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _EmptyFailure value)  empty,required TResult Function( _UnprocessableEntityFailure value)  unprocessableEntity,required TResult Function( FolderRetrievalFailure value)  folderRetrieval,required TResult Function( _UnauthorizedFailure value)  unauthorized,required TResult Function( _BadRequestFailure value)  badRequest,}){
final _that = this;
switch (_that) {
case _EmptyFailure():
return empty(_that);case _UnprocessableEntityFailure():
return unprocessableEntity(_that);case FolderRetrievalFailure():
return folderRetrieval(_that);case _UnauthorizedFailure():
return unauthorized(_that);case _BadRequestFailure():
return badRequest(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _EmptyFailure value)?  empty,TResult? Function( _UnprocessableEntityFailure value)?  unprocessableEntity,TResult? Function( FolderRetrievalFailure value)?  folderRetrieval,TResult? Function( _UnauthorizedFailure value)?  unauthorized,TResult? Function( _BadRequestFailure value)?  badRequest,}){
final _that = this;
switch (_that) {
case _EmptyFailure() when empty != null:
return empty(_that);case _UnprocessableEntityFailure() when unprocessableEntity != null:
return unprocessableEntity(_that);case FolderRetrievalFailure() when folderRetrieval != null:
return folderRetrieval(_that);case _UnauthorizedFailure() when unauthorized != null:
return unauthorized(_that);case _BadRequestFailure() when badRequest != null:
return badRequest(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  empty,TResult Function( String message)?  unprocessableEntity,TResult Function( String message)?  folderRetrieval,TResult Function()?  unauthorized,TResult Function()?  badRequest,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmptyFailure() when empty != null:
return empty();case _UnprocessableEntityFailure() when unprocessableEntity != null:
return unprocessableEntity(_that.message);case FolderRetrievalFailure() when folderRetrieval != null:
return folderRetrieval(_that.message);case _UnauthorizedFailure() when unauthorized != null:
return unauthorized();case _BadRequestFailure() when badRequest != null:
return badRequest();case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  empty,required TResult Function( String message)  unprocessableEntity,required TResult Function( String message)  folderRetrieval,required TResult Function()  unauthorized,required TResult Function()  badRequest,}) {final _that = this;
switch (_that) {
case _EmptyFailure():
return empty();case _UnprocessableEntityFailure():
return unprocessableEntity(_that.message);case FolderRetrievalFailure():
return folderRetrieval(_that.message);case _UnauthorizedFailure():
return unauthorized();case _BadRequestFailure():
return badRequest();case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  empty,TResult? Function( String message)?  unprocessableEntity,TResult? Function( String message)?  folderRetrieval,TResult? Function()?  unauthorized,TResult? Function()?  badRequest,}) {final _that = this;
switch (_that) {
case _EmptyFailure() when empty != null:
return empty();case _UnprocessableEntityFailure() when unprocessableEntity != null:
return unprocessableEntity(_that.message);case FolderRetrievalFailure() when folderRetrieval != null:
return folderRetrieval(_that.message);case _UnauthorizedFailure() when unauthorized != null:
return unauthorized();case _BadRequestFailure() when badRequest != null:
return badRequest();case _:
  return null;

}
}

}

/// @nodoc


class _EmptyFailure extends Failure {
  const _EmptyFailure(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmptyFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Failure.empty()';
}


}




/// @nodoc


class _UnprocessableEntityFailure extends Failure {
  const _UnprocessableEntityFailure({required this.message}): super._();
  

 final  String message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnprocessableEntityFailureCopyWith<_UnprocessableEntityFailure> get copyWith => __$UnprocessableEntityFailureCopyWithImpl<_UnprocessableEntityFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnprocessableEntityFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'Failure.unprocessableEntity(message: $message)';
}


}

/// @nodoc
abstract mixin class _$UnprocessableEntityFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory _$UnprocessableEntityFailureCopyWith(_UnprocessableEntityFailure value, $Res Function(_UnprocessableEntityFailure) _then) = __$UnprocessableEntityFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$UnprocessableEntityFailureCopyWithImpl<$Res>
    implements _$UnprocessableEntityFailureCopyWith<$Res> {
  __$UnprocessableEntityFailureCopyWithImpl(this._self, this._then);

  final _UnprocessableEntityFailure _self;
  final $Res Function(_UnprocessableEntityFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_UnprocessableEntityFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class FolderRetrievalFailure extends Failure {
  const FolderRetrievalFailure({required this.message}): super._();
  

 final  String message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FolderRetrievalFailureCopyWith<FolderRetrievalFailure> get copyWith => _$FolderRetrievalFailureCopyWithImpl<FolderRetrievalFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FolderRetrievalFailure&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'Failure.folderRetrieval(message: $message)';
}


}

/// @nodoc
abstract mixin class $FolderRetrievalFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $FolderRetrievalFailureCopyWith(FolderRetrievalFailure value, $Res Function(FolderRetrievalFailure) _then) = _$FolderRetrievalFailureCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$FolderRetrievalFailureCopyWithImpl<$Res>
    implements $FolderRetrievalFailureCopyWith<$Res> {
  _$FolderRetrievalFailureCopyWithImpl(this._self, this._then);

  final FolderRetrievalFailure _self;
  final $Res Function(FolderRetrievalFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(FolderRetrievalFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _UnauthorizedFailure extends Failure {
  const _UnauthorizedFailure(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnauthorizedFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Failure.unauthorized()';
}


}




/// @nodoc


class _BadRequestFailure extends Failure {
  const _BadRequestFailure(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BadRequestFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Failure.badRequest()';
}


}




// dart format on
