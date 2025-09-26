// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contact_prefs.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ContactPrefs {

 ContactId get contactId; String? get displayNameOverride; bool get isFavorite; int? get pinnedRank;// lower comes first (e.g., 0,1,2…)
 DateTime? get updatedAt;
/// Create a copy of ContactPrefs
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactPrefsCopyWith<ContactPrefs> get copyWith => _$ContactPrefsCopyWithImpl<ContactPrefs>(this as ContactPrefs, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactPrefs&&(identical(other.contactId, contactId) || other.contactId == contactId)&&(identical(other.displayNameOverride, displayNameOverride) || other.displayNameOverride == displayNameOverride)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.pinnedRank, pinnedRank) || other.pinnedRank == pinnedRank)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,contactId,displayNameOverride,isFavorite,pinnedRank,updatedAt);

@override
String toString() {
  return 'ContactPrefs(contactId: $contactId, displayNameOverride: $displayNameOverride, isFavorite: $isFavorite, pinnedRank: $pinnedRank, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ContactPrefsCopyWith<$Res>  {
  factory $ContactPrefsCopyWith(ContactPrefs value, $Res Function(ContactPrefs) _then) = _$ContactPrefsCopyWithImpl;
@useResult
$Res call({
 ContactId contactId, String? displayNameOverride, bool isFavorite, int? pinnedRank, DateTime? updatedAt
});


$ContactIdCopyWith<$Res> get contactId;

}
/// @nodoc
class _$ContactPrefsCopyWithImpl<$Res>
    implements $ContactPrefsCopyWith<$Res> {
  _$ContactPrefsCopyWithImpl(this._self, this._then);

  final ContactPrefs _self;
  final $Res Function(ContactPrefs) _then;

/// Create a copy of ContactPrefs
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? contactId = null,Object? displayNameOverride = freezed,Object? isFavorite = null,Object? pinnedRank = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
contactId: null == contactId ? _self.contactId : contactId // ignore: cast_nullable_to_non_nullable
as ContactId,displayNameOverride: freezed == displayNameOverride ? _self.displayNameOverride : displayNameOverride // ignore: cast_nullable_to_non_nullable
as String?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,pinnedRank: freezed == pinnedRank ? _self.pinnedRank : pinnedRank // ignore: cast_nullable_to_non_nullable
as int?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of ContactPrefs
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactIdCopyWith<$Res> get contactId {
  
  return $ContactIdCopyWith<$Res>(_self.contactId, (value) {
    return _then(_self.copyWith(contactId: value));
  });
}
}


/// Adds pattern-matching-related methods to [ContactPrefs].
extension ContactPrefsPatterns on ContactPrefs {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContactPrefs value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactPrefs() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContactPrefs value)  $default,){
final _that = this;
switch (_that) {
case _ContactPrefs():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContactPrefs value)?  $default,){
final _that = this;
switch (_that) {
case _ContactPrefs() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ContactId contactId,  String? displayNameOverride,  bool isFavorite,  int? pinnedRank,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactPrefs() when $default != null:
return $default(_that.contactId,_that.displayNameOverride,_that.isFavorite,_that.pinnedRank,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ContactId contactId,  String? displayNameOverride,  bool isFavorite,  int? pinnedRank,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ContactPrefs():
return $default(_that.contactId,_that.displayNameOverride,_that.isFavorite,_that.pinnedRank,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ContactId contactId,  String? displayNameOverride,  bool isFavorite,  int? pinnedRank,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ContactPrefs() when $default != null:
return $default(_that.contactId,_that.displayNameOverride,_that.isFavorite,_that.pinnedRank,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _ContactPrefs extends ContactPrefs {
  const _ContactPrefs({required this.contactId, this.displayNameOverride, this.isFavorite = false, this.pinnedRank, this.updatedAt}): super._();
  

@override final  ContactId contactId;
@override final  String? displayNameOverride;
@override@JsonKey() final  bool isFavorite;
@override final  int? pinnedRank;
// lower comes first (e.g., 0,1,2…)
@override final  DateTime? updatedAt;

/// Create a copy of ContactPrefs
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactPrefsCopyWith<_ContactPrefs> get copyWith => __$ContactPrefsCopyWithImpl<_ContactPrefs>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactPrefs&&(identical(other.contactId, contactId) || other.contactId == contactId)&&(identical(other.displayNameOverride, displayNameOverride) || other.displayNameOverride == displayNameOverride)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.pinnedRank, pinnedRank) || other.pinnedRank == pinnedRank)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,contactId,displayNameOverride,isFavorite,pinnedRank,updatedAt);

@override
String toString() {
  return 'ContactPrefs(contactId: $contactId, displayNameOverride: $displayNameOverride, isFavorite: $isFavorite, pinnedRank: $pinnedRank, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ContactPrefsCopyWith<$Res> implements $ContactPrefsCopyWith<$Res> {
  factory _$ContactPrefsCopyWith(_ContactPrefs value, $Res Function(_ContactPrefs) _then) = __$ContactPrefsCopyWithImpl;
@override @useResult
$Res call({
 ContactId contactId, String? displayNameOverride, bool isFavorite, int? pinnedRank, DateTime? updatedAt
});


@override $ContactIdCopyWith<$Res> get contactId;

}
/// @nodoc
class __$ContactPrefsCopyWithImpl<$Res>
    implements _$ContactPrefsCopyWith<$Res> {
  __$ContactPrefsCopyWithImpl(this._self, this._then);

  final _ContactPrefs _self;
  final $Res Function(_ContactPrefs) _then;

/// Create a copy of ContactPrefs
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? contactId = null,Object? displayNameOverride = freezed,Object? isFavorite = null,Object? pinnedRank = freezed,Object? updatedAt = freezed,}) {
  return _then(_ContactPrefs(
contactId: null == contactId ? _self.contactId : contactId // ignore: cast_nullable_to_non_nullable
as ContactId,displayNameOverride: freezed == displayNameOverride ? _self.displayNameOverride : displayNameOverride // ignore: cast_nullable_to_non_nullable
as String?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,pinnedRank: freezed == pinnedRank ? _self.pinnedRank : pinnedRank // ignore: cast_nullable_to_non_nullable
as int?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of ContactPrefs
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactIdCopyWith<$Res> get contactId {
  
  return $ContactIdCopyWith<$Res>(_self.contactId, (value) {
    return _then(_self.copyWith(contactId: value));
  });
}
}

// dart format on
