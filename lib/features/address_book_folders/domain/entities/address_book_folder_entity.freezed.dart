// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'address_book_folder_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AddressBookFolderEntity {

 FolderPathValueObject get path; AddressBookFolderShortPath get shortPath; FolderCreationDate get lastCreationDate; FolderModificationDate get lastModificationDate; NonZeroInt get recordCount;
/// Create a copy of AddressBookFolderEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddressBookFolderEntityCopyWith<AddressBookFolderEntity> get copyWith => _$AddressBookFolderEntityCopyWithImpl<AddressBookFolderEntity>(this as AddressBookFolderEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddressBookFolderEntity&&(identical(other.path, path) || other.path == path)&&(identical(other.shortPath, shortPath) || other.shortPath == shortPath)&&(identical(other.lastCreationDate, lastCreationDate) || other.lastCreationDate == lastCreationDate)&&(identical(other.lastModificationDate, lastModificationDate) || other.lastModificationDate == lastModificationDate)&&(identical(other.recordCount, recordCount) || other.recordCount == recordCount));
}


@override
int get hashCode => Object.hash(runtimeType,path,shortPath,lastCreationDate,lastModificationDate,recordCount);

@override
String toString() {
  return 'AddressBookFolderEntity(path: $path, shortPath: $shortPath, lastCreationDate: $lastCreationDate, lastModificationDate: $lastModificationDate, recordCount: $recordCount)';
}


}

/// @nodoc
abstract mixin class $AddressBookFolderEntityCopyWith<$Res>  {
  factory $AddressBookFolderEntityCopyWith(AddressBookFolderEntity value, $Res Function(AddressBookFolderEntity) _then) = _$AddressBookFolderEntityCopyWithImpl;
@useResult
$Res call({
 FolderPathValueObject path, AddressBookFolderShortPath shortPath, FolderCreationDate lastCreationDate, FolderModificationDate lastModificationDate, NonZeroInt recordCount
});




}
/// @nodoc
class _$AddressBookFolderEntityCopyWithImpl<$Res>
    implements $AddressBookFolderEntityCopyWith<$Res> {
  _$AddressBookFolderEntityCopyWithImpl(this._self, this._then);

  final AddressBookFolderEntity _self;
  final $Res Function(AddressBookFolderEntity) _then;

/// Create a copy of AddressBookFolderEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? shortPath = null,Object? lastCreationDate = null,Object? lastModificationDate = null,Object? recordCount = null,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as FolderPathValueObject,shortPath: null == shortPath ? _self.shortPath : shortPath // ignore: cast_nullable_to_non_nullable
as AddressBookFolderShortPath,lastCreationDate: null == lastCreationDate ? _self.lastCreationDate : lastCreationDate // ignore: cast_nullable_to_non_nullable
as FolderCreationDate,lastModificationDate: null == lastModificationDate ? _self.lastModificationDate : lastModificationDate // ignore: cast_nullable_to_non_nullable
as FolderModificationDate,recordCount: null == recordCount ? _self.recordCount : recordCount // ignore: cast_nullable_to_non_nullable
as NonZeroInt,
  ));
}

}


/// Adds pattern-matching-related methods to [AddressBookFolderEntity].
extension AddressBookFolderEntityPatterns on AddressBookFolderEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddressBookFolderEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddressBookFolderEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddressBookFolderEntity value)  $default,){
final _that = this;
switch (_that) {
case _AddressBookFolderEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddressBookFolderEntity value)?  $default,){
final _that = this;
switch (_that) {
case _AddressBookFolderEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FolderPathValueObject path,  AddressBookFolderShortPath shortPath,  FolderCreationDate lastCreationDate,  FolderModificationDate lastModificationDate,  NonZeroInt recordCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddressBookFolderEntity() when $default != null:
return $default(_that.path,_that.shortPath,_that.lastCreationDate,_that.lastModificationDate,_that.recordCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FolderPathValueObject path,  AddressBookFolderShortPath shortPath,  FolderCreationDate lastCreationDate,  FolderModificationDate lastModificationDate,  NonZeroInt recordCount)  $default,) {final _that = this;
switch (_that) {
case _AddressBookFolderEntity():
return $default(_that.path,_that.shortPath,_that.lastCreationDate,_that.lastModificationDate,_that.recordCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FolderPathValueObject path,  AddressBookFolderShortPath shortPath,  FolderCreationDate lastCreationDate,  FolderModificationDate lastModificationDate,  NonZeroInt recordCount)?  $default,) {final _that = this;
switch (_that) {
case _AddressBookFolderEntity() when $default != null:
return $default(_that.path,_that.shortPath,_that.lastCreationDate,_that.lastModificationDate,_that.recordCount);case _:
  return null;

}
}

}

/// @nodoc


class _AddressBookFolderEntity extends AddressBookFolderEntity {
  const _AddressBookFolderEntity({required this.path, required this.shortPath, required this.lastCreationDate, required this.lastModificationDate, required this.recordCount}): super._();
  

@override final  FolderPathValueObject path;
@override final  AddressBookFolderShortPath shortPath;
@override final  FolderCreationDate lastCreationDate;
@override final  FolderModificationDate lastModificationDate;
@override final  NonZeroInt recordCount;

/// Create a copy of AddressBookFolderEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddressBookFolderEntityCopyWith<_AddressBookFolderEntity> get copyWith => __$AddressBookFolderEntityCopyWithImpl<_AddressBookFolderEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddressBookFolderEntity&&(identical(other.path, path) || other.path == path)&&(identical(other.shortPath, shortPath) || other.shortPath == shortPath)&&(identical(other.lastCreationDate, lastCreationDate) || other.lastCreationDate == lastCreationDate)&&(identical(other.lastModificationDate, lastModificationDate) || other.lastModificationDate == lastModificationDate)&&(identical(other.recordCount, recordCount) || other.recordCount == recordCount));
}


@override
int get hashCode => Object.hash(runtimeType,path,shortPath,lastCreationDate,lastModificationDate,recordCount);

@override
String toString() {
  return 'AddressBookFolderEntity(path: $path, shortPath: $shortPath, lastCreationDate: $lastCreationDate, lastModificationDate: $lastModificationDate, recordCount: $recordCount)';
}


}

/// @nodoc
abstract mixin class _$AddressBookFolderEntityCopyWith<$Res> implements $AddressBookFolderEntityCopyWith<$Res> {
  factory _$AddressBookFolderEntityCopyWith(_AddressBookFolderEntity value, $Res Function(_AddressBookFolderEntity) _then) = __$AddressBookFolderEntityCopyWithImpl;
@override @useResult
$Res call({
 FolderPathValueObject path, AddressBookFolderShortPath shortPath, FolderCreationDate lastCreationDate, FolderModificationDate lastModificationDate, NonZeroInt recordCount
});




}
/// @nodoc
class __$AddressBookFolderEntityCopyWithImpl<$Res>
    implements _$AddressBookFolderEntityCopyWith<$Res> {
  __$AddressBookFolderEntityCopyWithImpl(this._self, this._then);

  final _AddressBookFolderEntity _self;
  final $Res Function(_AddressBookFolderEntity) _then;

/// Create a copy of AddressBookFolderEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? shortPath = null,Object? lastCreationDate = null,Object? lastModificationDate = null,Object? recordCount = null,}) {
  return _then(_AddressBookFolderEntity(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as FolderPathValueObject,shortPath: null == shortPath ? _self.shortPath : shortPath // ignore: cast_nullable_to_non_nullable
as AddressBookFolderShortPath,lastCreationDate: null == lastCreationDate ? _self.lastCreationDate : lastCreationDate // ignore: cast_nullable_to_non_nullable
as FolderCreationDate,lastModificationDate: null == lastModificationDate ? _self.lastModificationDate : lastModificationDate // ignore: cast_nullable_to_non_nullable
as FolderModificationDate,recordCount: null == recordCount ? _self.recordCount : recordCount // ignore: cast_nullable_to_non_nullable
as NonZeroInt,
  ));
}


}

// dart format on
