// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_migration_delta.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MessageMigrationDelta {

 int get messageIdDelta; int get messageCountDelta;
/// Create a copy of MessageMigrationDelta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageMigrationDeltaCopyWith<MessageMigrationDelta> get copyWith => _$MessageMigrationDeltaCopyWithImpl<MessageMigrationDelta>(this as MessageMigrationDelta, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageMigrationDelta&&(identical(other.messageIdDelta, messageIdDelta) || other.messageIdDelta == messageIdDelta)&&(identical(other.messageCountDelta, messageCountDelta) || other.messageCountDelta == messageCountDelta));
}


@override
int get hashCode => Object.hash(runtimeType,messageIdDelta,messageCountDelta);

@override
String toString() {
  return 'MessageMigrationDelta(messageIdDelta: $messageIdDelta, messageCountDelta: $messageCountDelta)';
}


}

/// @nodoc
abstract mixin class $MessageMigrationDeltaCopyWith<$Res>  {
  factory $MessageMigrationDeltaCopyWith(MessageMigrationDelta value, $Res Function(MessageMigrationDelta) _then) = _$MessageMigrationDeltaCopyWithImpl;
@useResult
$Res call({
 int messageIdDelta, int messageCountDelta
});




}
/// @nodoc
class _$MessageMigrationDeltaCopyWithImpl<$Res>
    implements $MessageMigrationDeltaCopyWith<$Res> {
  _$MessageMigrationDeltaCopyWithImpl(this._self, this._then);

  final MessageMigrationDelta _self;
  final $Res Function(MessageMigrationDelta) _then;

/// Create a copy of MessageMigrationDelta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? messageIdDelta = null,Object? messageCountDelta = null,}) {
  return _then(_self.copyWith(
messageIdDelta: null == messageIdDelta ? _self.messageIdDelta : messageIdDelta // ignore: cast_nullable_to_non_nullable
as int,messageCountDelta: null == messageCountDelta ? _self.messageCountDelta : messageCountDelta // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageMigrationDelta].
extension MessageMigrationDeltaPatterns on MessageMigrationDelta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageMigrationDelta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageMigrationDelta() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageMigrationDelta value)  $default,){
final _that = this;
switch (_that) {
case _MessageMigrationDelta():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageMigrationDelta value)?  $default,){
final _that = this;
switch (_that) {
case _MessageMigrationDelta() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int messageIdDelta,  int messageCountDelta)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageMigrationDelta() when $default != null:
return $default(_that.messageIdDelta,_that.messageCountDelta);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int messageIdDelta,  int messageCountDelta)  $default,) {final _that = this;
switch (_that) {
case _MessageMigrationDelta():
return $default(_that.messageIdDelta,_that.messageCountDelta);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int messageIdDelta,  int messageCountDelta)?  $default,) {final _that = this;
switch (_that) {
case _MessageMigrationDelta() when $default != null:
return $default(_that.messageIdDelta,_that.messageCountDelta);case _:
  return null;

}
}

}

/// @nodoc


class _MessageMigrationDelta extends MessageMigrationDelta {
  const _MessageMigrationDelta({required this.messageIdDelta, required this.messageCountDelta}): super._();
  

@override final  int messageIdDelta;
@override final  int messageCountDelta;

/// Create a copy of MessageMigrationDelta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageMigrationDeltaCopyWith<_MessageMigrationDelta> get copyWith => __$MessageMigrationDeltaCopyWithImpl<_MessageMigrationDelta>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageMigrationDelta&&(identical(other.messageIdDelta, messageIdDelta) || other.messageIdDelta == messageIdDelta)&&(identical(other.messageCountDelta, messageCountDelta) || other.messageCountDelta == messageCountDelta));
}


@override
int get hashCode => Object.hash(runtimeType,messageIdDelta,messageCountDelta);

@override
String toString() {
  return 'MessageMigrationDelta(messageIdDelta: $messageIdDelta, messageCountDelta: $messageCountDelta)';
}


}

/// @nodoc
abstract mixin class _$MessageMigrationDeltaCopyWith<$Res> implements $MessageMigrationDeltaCopyWith<$Res> {
  factory _$MessageMigrationDeltaCopyWith(_MessageMigrationDelta value, $Res Function(_MessageMigrationDelta) _then) = __$MessageMigrationDeltaCopyWithImpl;
@override @useResult
$Res call({
 int messageIdDelta, int messageCountDelta
});




}
/// @nodoc
class __$MessageMigrationDeltaCopyWithImpl<$Res>
    implements _$MessageMigrationDeltaCopyWith<$Res> {
  __$MessageMigrationDeltaCopyWithImpl(this._self, this._then);

  final _MessageMigrationDelta _self;
  final $Res Function(_MessageMigrationDelta) _then;

/// Create a copy of MessageMigrationDelta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? messageIdDelta = null,Object? messageCountDelta = null,}) {
  return _then(_MessageMigrationDelta(
messageIdDelta: null == messageIdDelta ? _self.messageIdDelta : messageIdDelta // ignore: cast_nullable_to_non_nullable
as int,messageCountDelta: null == messageCountDelta ? _self.messageCountDelta : messageCountDelta // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
