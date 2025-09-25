// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contact.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Contact {

 ContactId get id; List<String> get handles; String? get displayNameFromSource; String? get displayNameOverride; bool get isFavorite; int? get pinnedRank;
/// Create a copy of Contact
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactCopyWith<Contact> get copyWith => _$ContactCopyWithImpl<Contact>(this as Contact, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Contact&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other.handles, handles)&&(identical(other.displayNameFromSource, displayNameFromSource) || other.displayNameFromSource == displayNameFromSource)&&(identical(other.displayNameOverride, displayNameOverride) || other.displayNameOverride == displayNameOverride)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.pinnedRank, pinnedRank) || other.pinnedRank == pinnedRank));
}


@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(handles),displayNameFromSource,displayNameOverride,isFavorite,pinnedRank);

@override
String toString() {
  return 'Contact(id: $id, handles: $handles, displayNameFromSource: $displayNameFromSource, displayNameOverride: $displayNameOverride, isFavorite: $isFavorite, pinnedRank: $pinnedRank)';
}


}

/// @nodoc
abstract mixin class $ContactCopyWith<$Res>  {
  factory $ContactCopyWith(Contact value, $Res Function(Contact) _then) = _$ContactCopyWithImpl;
@useResult
$Res call({
 ContactId id, List<String> handles, String? displayNameFromSource, String? displayNameOverride, bool isFavorite, int? pinnedRank
});


$ContactIdCopyWith<$Res> get id;

}
/// @nodoc
class _$ContactCopyWithImpl<$Res>
    implements $ContactCopyWith<$Res> {
  _$ContactCopyWithImpl(this._self, this._then);

  final Contact _self;
  final $Res Function(Contact) _then;

/// Create a copy of Contact
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? handles = null,Object? displayNameFromSource = freezed,Object? displayNameOverride = freezed,Object? isFavorite = null,Object? pinnedRank = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ContactId,handles: null == handles ? _self.handles : handles // ignore: cast_nullable_to_non_nullable
as List<String>,displayNameFromSource: freezed == displayNameFromSource ? _self.displayNameFromSource : displayNameFromSource // ignore: cast_nullable_to_non_nullable
as String?,displayNameOverride: freezed == displayNameOverride ? _self.displayNameOverride : displayNameOverride // ignore: cast_nullable_to_non_nullable
as String?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,pinnedRank: freezed == pinnedRank ? _self.pinnedRank : pinnedRank // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of Contact
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactIdCopyWith<$Res> get id {
  
  return $ContactIdCopyWith<$Res>(_self.id, (value) {
    return _then(_self.copyWith(id: value));
  });
}
}


/// Adds pattern-matching-related methods to [Contact].
extension ContactPatterns on Contact {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Contact value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Contact() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Contact value)  $default,){
final _that = this;
switch (_that) {
case _Contact():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Contact value)?  $default,){
final _that = this;
switch (_that) {
case _Contact() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ContactId id,  List<String> handles,  String? displayNameFromSource,  String? displayNameOverride,  bool isFavorite,  int? pinnedRank)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Contact() when $default != null:
return $default(_that.id,_that.handles,_that.displayNameFromSource,_that.displayNameOverride,_that.isFavorite,_that.pinnedRank);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ContactId id,  List<String> handles,  String? displayNameFromSource,  String? displayNameOverride,  bool isFavorite,  int? pinnedRank)  $default,) {final _that = this;
switch (_that) {
case _Contact():
return $default(_that.id,_that.handles,_that.displayNameFromSource,_that.displayNameOverride,_that.isFavorite,_that.pinnedRank);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ContactId id,  List<String> handles,  String? displayNameFromSource,  String? displayNameOverride,  bool isFavorite,  int? pinnedRank)?  $default,) {final _that = this;
switch (_that) {
case _Contact() when $default != null:
return $default(_that.id,_that.handles,_that.displayNameFromSource,_that.displayNameOverride,_that.isFavorite,_that.pinnedRank);case _:
  return null;

}
}

}

/// @nodoc


class _Contact extends Contact {
  const _Contact({required this.id, required final  List<String> handles, required this.displayNameFromSource, required this.displayNameOverride, required this.isFavorite, required this.pinnedRank}): _handles = handles,super._();
  

@override final  ContactId id;
 final  List<String> _handles;
@override List<String> get handles {
  if (_handles is EqualUnmodifiableListView) return _handles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_handles);
}

@override final  String? displayNameFromSource;
@override final  String? displayNameOverride;
@override final  bool isFavorite;
@override final  int? pinnedRank;

/// Create a copy of Contact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactCopyWith<_Contact> get copyWith => __$ContactCopyWithImpl<_Contact>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Contact&&(identical(other.id, id) || other.id == id)&&const DeepCollectionEquality().equals(other._handles, _handles)&&(identical(other.displayNameFromSource, displayNameFromSource) || other.displayNameFromSource == displayNameFromSource)&&(identical(other.displayNameOverride, displayNameOverride) || other.displayNameOverride == displayNameOverride)&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.pinnedRank, pinnedRank) || other.pinnedRank == pinnedRank));
}


@override
int get hashCode => Object.hash(runtimeType,id,const DeepCollectionEquality().hash(_handles),displayNameFromSource,displayNameOverride,isFavorite,pinnedRank);

@override
String toString() {
  return 'Contact(id: $id, handles: $handles, displayNameFromSource: $displayNameFromSource, displayNameOverride: $displayNameOverride, isFavorite: $isFavorite, pinnedRank: $pinnedRank)';
}


}

/// @nodoc
abstract mixin class _$ContactCopyWith<$Res> implements $ContactCopyWith<$Res> {
  factory _$ContactCopyWith(_Contact value, $Res Function(_Contact) _then) = __$ContactCopyWithImpl;
@override @useResult
$Res call({
 ContactId id, List<String> handles, String? displayNameFromSource, String? displayNameOverride, bool isFavorite, int? pinnedRank
});


@override $ContactIdCopyWith<$Res> get id;

}
/// @nodoc
class __$ContactCopyWithImpl<$Res>
    implements _$ContactCopyWith<$Res> {
  __$ContactCopyWithImpl(this._self, this._then);

  final _Contact _self;
  final $Res Function(_Contact) _then;

/// Create a copy of Contact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? handles = null,Object? displayNameFromSource = freezed,Object? displayNameOverride = freezed,Object? isFavorite = null,Object? pinnedRank = freezed,}) {
  return _then(_Contact(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ContactId,handles: null == handles ? _self._handles : handles // ignore: cast_nullable_to_non_nullable
as List<String>,displayNameFromSource: freezed == displayNameFromSource ? _self.displayNameFromSource : displayNameFromSource // ignore: cast_nullable_to_non_nullable
as String?,displayNameOverride: freezed == displayNameOverride ? _self.displayNameOverride : displayNameOverride // ignore: cast_nullable_to_non_nullable
as String?,isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,pinnedRank: freezed == pinnedRank ? _self.pinnedRank : pinnedRank // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of Contact
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactIdCopyWith<$Res> get id {
  
  return $ContactIdCopyWith<$Res>(_self.id, (value) {
    return _then(_self.copyWith(id: value));
  });
}
}

// dart format on
