// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'import_subtask_timing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ImportSubtaskTiming {

 String get stageName; String get subtaskName; DateTime get startedAt; DateTime? get endedAt; int? get itemCount;
/// Create a copy of ImportSubtaskTiming
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportSubtaskTimingCopyWith<ImportSubtaskTiming> get copyWith => _$ImportSubtaskTimingCopyWithImpl<ImportSubtaskTiming>(this as ImportSubtaskTiming, _$identity);

  /// Serializes this ImportSubtaskTiming to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportSubtaskTiming&&(identical(other.stageName, stageName) || other.stageName == stageName)&&(identical(other.subtaskName, subtaskName) || other.subtaskName == subtaskName)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.itemCount, itemCount) || other.itemCount == itemCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,stageName,subtaskName,startedAt,endedAt,itemCount);

@override
String toString() {
  return 'ImportSubtaskTiming(stageName: $stageName, subtaskName: $subtaskName, startedAt: $startedAt, endedAt: $endedAt, itemCount: $itemCount)';
}


}

/// @nodoc
abstract mixin class $ImportSubtaskTimingCopyWith<$Res>  {
  factory $ImportSubtaskTimingCopyWith(ImportSubtaskTiming value, $Res Function(ImportSubtaskTiming) _then) = _$ImportSubtaskTimingCopyWithImpl;
@useResult
$Res call({
 String stageName, String subtaskName, DateTime startedAt, DateTime? endedAt, int? itemCount
});




}
/// @nodoc
class _$ImportSubtaskTimingCopyWithImpl<$Res>
    implements $ImportSubtaskTimingCopyWith<$Res> {
  _$ImportSubtaskTimingCopyWithImpl(this._self, this._then);

  final ImportSubtaskTiming _self;
  final $Res Function(ImportSubtaskTiming) _then;

/// Create a copy of ImportSubtaskTiming
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stageName = null,Object? subtaskName = null,Object? startedAt = null,Object? endedAt = freezed,Object? itemCount = freezed,}) {
  return _then(_self.copyWith(
stageName: null == stageName ? _self.stageName : stageName // ignore: cast_nullable_to_non_nullable
as String,subtaskName: null == subtaskName ? _self.subtaskName : subtaskName // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,itemCount: freezed == itemCount ? _self.itemCount : itemCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ImportSubtaskTiming].
extension ImportSubtaskTimingPatterns on ImportSubtaskTiming {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImportSubtaskTiming value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImportSubtaskTiming() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImportSubtaskTiming value)  $default,){
final _that = this;
switch (_that) {
case _ImportSubtaskTiming():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImportSubtaskTiming value)?  $default,){
final _that = this;
switch (_that) {
case _ImportSubtaskTiming() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String stageName,  String subtaskName,  DateTime startedAt,  DateTime? endedAt,  int? itemCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImportSubtaskTiming() when $default != null:
return $default(_that.stageName,_that.subtaskName,_that.startedAt,_that.endedAt,_that.itemCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String stageName,  String subtaskName,  DateTime startedAt,  DateTime? endedAt,  int? itemCount)  $default,) {final _that = this;
switch (_that) {
case _ImportSubtaskTiming():
return $default(_that.stageName,_that.subtaskName,_that.startedAt,_that.endedAt,_that.itemCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String stageName,  String subtaskName,  DateTime startedAt,  DateTime? endedAt,  int? itemCount)?  $default,) {final _that = this;
switch (_that) {
case _ImportSubtaskTiming() when $default != null:
return $default(_that.stageName,_that.subtaskName,_that.startedAt,_that.endedAt,_that.itemCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImportSubtaskTiming implements ImportSubtaskTiming {
  const _ImportSubtaskTiming({required this.stageName, required this.subtaskName, required this.startedAt, this.endedAt, this.itemCount});
  factory _ImportSubtaskTiming.fromJson(Map<String, dynamic> json) => _$ImportSubtaskTimingFromJson(json);

@override final  String stageName;
@override final  String subtaskName;
@override final  DateTime startedAt;
@override final  DateTime? endedAt;
@override final  int? itemCount;

/// Create a copy of ImportSubtaskTiming
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImportSubtaskTimingCopyWith<_ImportSubtaskTiming> get copyWith => __$ImportSubtaskTimingCopyWithImpl<_ImportSubtaskTiming>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImportSubtaskTimingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImportSubtaskTiming&&(identical(other.stageName, stageName) || other.stageName == stageName)&&(identical(other.subtaskName, subtaskName) || other.subtaskName == subtaskName)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.itemCount, itemCount) || other.itemCount == itemCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,stageName,subtaskName,startedAt,endedAt,itemCount);

@override
String toString() {
  return 'ImportSubtaskTiming(stageName: $stageName, subtaskName: $subtaskName, startedAt: $startedAt, endedAt: $endedAt, itemCount: $itemCount)';
}


}

/// @nodoc
abstract mixin class _$ImportSubtaskTimingCopyWith<$Res> implements $ImportSubtaskTimingCopyWith<$Res> {
  factory _$ImportSubtaskTimingCopyWith(_ImportSubtaskTiming value, $Res Function(_ImportSubtaskTiming) _then) = __$ImportSubtaskTimingCopyWithImpl;
@override @useResult
$Res call({
 String stageName, String subtaskName, DateTime startedAt, DateTime? endedAt, int? itemCount
});




}
/// @nodoc
class __$ImportSubtaskTimingCopyWithImpl<$Res>
    implements _$ImportSubtaskTimingCopyWith<$Res> {
  __$ImportSubtaskTimingCopyWithImpl(this._self, this._then);

  final _ImportSubtaskTiming _self;
  final $Res Function(_ImportSubtaskTiming) _then;

/// Create a copy of ImportSubtaskTiming
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stageName = null,Object? subtaskName = null,Object? startedAt = null,Object? endedAt = freezed,Object? itemCount = freezed,}) {
  return _then(_ImportSubtaskTiming(
stageName: null == stageName ? _self.stageName : stageName // ignore: cast_nullable_to_non_nullable
as String,subtaskName: null == subtaskName ? _self.subtaskName : subtaskName // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,itemCount: freezed == itemCount ? _self.itemCount : itemCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
