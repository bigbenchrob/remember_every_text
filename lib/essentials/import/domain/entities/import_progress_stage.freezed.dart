// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'import_progress_stage.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ImportProgressStage {

 String get name; String get displayName; bool get isActive; bool get isComplete; double? get progress; int? get current; int? get total;
/// Create a copy of ImportProgressStage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportProgressStageCopyWith<ImportProgressStage> get copyWith => _$ImportProgressStageCopyWithImpl<ImportProgressStage>(this as ImportProgressStage, _$identity);

  /// Serializes this ImportProgressStage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportProgressStage&&(identical(other.name, name) || other.name == name)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isComplete, isComplete) || other.isComplete == isComplete)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.current, current) || other.current == current)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,displayName,isActive,isComplete,progress,current,total);

@override
String toString() {
  return 'ImportProgressStage(name: $name, displayName: $displayName, isActive: $isActive, isComplete: $isComplete, progress: $progress, current: $current, total: $total)';
}


}

/// @nodoc
abstract mixin class $ImportProgressStageCopyWith<$Res>  {
  factory $ImportProgressStageCopyWith(ImportProgressStage value, $Res Function(ImportProgressStage) _then) = _$ImportProgressStageCopyWithImpl;
@useResult
$Res call({
 String name, String displayName, bool isActive, bool isComplete, double? progress, int? current, int? total
});




}
/// @nodoc
class _$ImportProgressStageCopyWithImpl<$Res>
    implements $ImportProgressStageCopyWith<$Res> {
  _$ImportProgressStageCopyWithImpl(this._self, this._then);

  final ImportProgressStage _self;
  final $Res Function(ImportProgressStage) _then;

/// Create a copy of ImportProgressStage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? displayName = null,Object? isActive = null,Object? isComplete = null,Object? progress = freezed,Object? current = freezed,Object? total = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isComplete: null == isComplete ? _self.isComplete : isComplete // ignore: cast_nullable_to_non_nullable
as bool,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double?,current: freezed == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int?,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ImportProgressStage].
extension ImportProgressStagePatterns on ImportProgressStage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImportProgressStage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImportProgressStage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImportProgressStage value)  $default,){
final _that = this;
switch (_that) {
case _ImportProgressStage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImportProgressStage value)?  $default,){
final _that = this;
switch (_that) {
case _ImportProgressStage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String displayName,  bool isActive,  bool isComplete,  double? progress,  int? current,  int? total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImportProgressStage() when $default != null:
return $default(_that.name,_that.displayName,_that.isActive,_that.isComplete,_that.progress,_that.current,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String displayName,  bool isActive,  bool isComplete,  double? progress,  int? current,  int? total)  $default,) {final _that = this;
switch (_that) {
case _ImportProgressStage():
return $default(_that.name,_that.displayName,_that.isActive,_that.isComplete,_that.progress,_that.current,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String displayName,  bool isActive,  bool isComplete,  double? progress,  int? current,  int? total)?  $default,) {final _that = this;
switch (_that) {
case _ImportProgressStage() when $default != null:
return $default(_that.name,_that.displayName,_that.isActive,_that.isComplete,_that.progress,_that.current,_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImportProgressStage implements ImportProgressStage {
  const _ImportProgressStage({required this.name, required this.displayName, this.isActive = false, this.isComplete = false, this.progress, this.current, this.total});
  factory _ImportProgressStage.fromJson(Map<String, dynamic> json) => _$ImportProgressStageFromJson(json);

@override final  String name;
@override final  String displayName;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  bool isComplete;
@override final  double? progress;
@override final  int? current;
@override final  int? total;

/// Create a copy of ImportProgressStage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImportProgressStageCopyWith<_ImportProgressStage> get copyWith => __$ImportProgressStageCopyWithImpl<_ImportProgressStage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImportProgressStageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImportProgressStage&&(identical(other.name, name) || other.name == name)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isComplete, isComplete) || other.isComplete == isComplete)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.current, current) || other.current == current)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,displayName,isActive,isComplete,progress,current,total);

@override
String toString() {
  return 'ImportProgressStage(name: $name, displayName: $displayName, isActive: $isActive, isComplete: $isComplete, progress: $progress, current: $current, total: $total)';
}


}

/// @nodoc
abstract mixin class _$ImportProgressStageCopyWith<$Res> implements $ImportProgressStageCopyWith<$Res> {
  factory _$ImportProgressStageCopyWith(_ImportProgressStage value, $Res Function(_ImportProgressStage) _then) = __$ImportProgressStageCopyWithImpl;
@override @useResult
$Res call({
 String name, String displayName, bool isActive, bool isComplete, double? progress, int? current, int? total
});




}
/// @nodoc
class __$ImportProgressStageCopyWithImpl<$Res>
    implements _$ImportProgressStageCopyWith<$Res> {
  __$ImportProgressStageCopyWithImpl(this._self, this._then);

  final _ImportProgressStage _self;
  final $Res Function(_ImportProgressStage) _then;

/// Create a copy of ImportProgressStage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? displayName = null,Object? isActive = null,Object? isComplete = null,Object? progress = freezed,Object? current = freezed,Object? total = freezed,}) {
  return _then(_ImportProgressStage(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isComplete: null == isComplete ? _self.isComplete : isComplete // ignore: cast_nullable_to_non_nullable
as bool,progress: freezed == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double?,current: freezed == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int?,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
