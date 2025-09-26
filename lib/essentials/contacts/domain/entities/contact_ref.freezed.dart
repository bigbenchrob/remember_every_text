// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contact_ref.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ContactRef {

 ContactId get id; String? get displayNameFromSource; List<String> get handles;// normalized (e164/email)
 String? get sourceVersion;
/// Create a copy of ContactRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactRefCopyWith<ContactRef> get copyWith => _$ContactRefCopyWithImpl<ContactRef>(this as ContactRef, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactRef&&(identical(other.id, id) || other.id == id)&&(identical(other.displayNameFromSource, displayNameFromSource) || other.displayNameFromSource == displayNameFromSource)&&const DeepCollectionEquality().equals(other.handles, handles)&&(identical(other.sourceVersion, sourceVersion) || other.sourceVersion == sourceVersion));
}


@override
int get hashCode => Object.hash(runtimeType,id,displayNameFromSource,const DeepCollectionEquality().hash(handles),sourceVersion);

@override
String toString() {
  return 'ContactRef(id: $id, displayNameFromSource: $displayNameFromSource, handles: $handles, sourceVersion: $sourceVersion)';
}


}

/// @nodoc
abstract mixin class $ContactRefCopyWith<$Res>  {
  factory $ContactRefCopyWith(ContactRef value, $Res Function(ContactRef) _then) = _$ContactRefCopyWithImpl;
@useResult
$Res call({
 ContactId id, String? displayNameFromSource, List<String> handles, String? sourceVersion
});


$ContactIdCopyWith<$Res> get id;

}
/// @nodoc
class _$ContactRefCopyWithImpl<$Res>
    implements $ContactRefCopyWith<$Res> {
  _$ContactRefCopyWithImpl(this._self, this._then);

  final ContactRef _self;
  final $Res Function(ContactRef) _then;

/// Create a copy of ContactRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? displayNameFromSource = freezed,Object? handles = null,Object? sourceVersion = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ContactId,displayNameFromSource: freezed == displayNameFromSource ? _self.displayNameFromSource : displayNameFromSource // ignore: cast_nullable_to_non_nullable
as String?,handles: null == handles ? _self.handles : handles // ignore: cast_nullable_to_non_nullable
as List<String>,sourceVersion: freezed == sourceVersion ? _self.sourceVersion : sourceVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of ContactRef
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactIdCopyWith<$Res> get id {
  
  return $ContactIdCopyWith<$Res>(_self.id, (value) {
    return _then(_self.copyWith(id: value));
  });
}
}


/// Adds pattern-matching-related methods to [ContactRef].
extension ContactRefPatterns on ContactRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContactRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContactRef value)  $default,){
final _that = this;
switch (_that) {
case _ContactRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContactRef value)?  $default,){
final _that = this;
switch (_that) {
case _ContactRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ContactId id,  String? displayNameFromSource,  List<String> handles,  String? sourceVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactRef() when $default != null:
return $default(_that.id,_that.displayNameFromSource,_that.handles,_that.sourceVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ContactId id,  String? displayNameFromSource,  List<String> handles,  String? sourceVersion)  $default,) {final _that = this;
switch (_that) {
case _ContactRef():
return $default(_that.id,_that.displayNameFromSource,_that.handles,_that.sourceVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ContactId id,  String? displayNameFromSource,  List<String> handles,  String? sourceVersion)?  $default,) {final _that = this;
switch (_that) {
case _ContactRef() when $default != null:
return $default(_that.id,_that.displayNameFromSource,_that.handles,_that.sourceVersion);case _:
  return null;

}
}

}

/// @nodoc


class _ContactRef extends ContactRef {
  const _ContactRef({required this.id, this.displayNameFromSource, final  List<String> handles = const <String>[], this.sourceVersion}): _handles = handles,super._();
  

@override final  ContactId id;
@override final  String? displayNameFromSource;
 final  List<String> _handles;
@override@JsonKey() List<String> get handles {
  if (_handles is EqualUnmodifiableListView) return _handles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_handles);
}

// normalized (e164/email)
@override final  String? sourceVersion;

/// Create a copy of ContactRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactRefCopyWith<_ContactRef> get copyWith => __$ContactRefCopyWithImpl<_ContactRef>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactRef&&(identical(other.id, id) || other.id == id)&&(identical(other.displayNameFromSource, displayNameFromSource) || other.displayNameFromSource == displayNameFromSource)&&const DeepCollectionEquality().equals(other._handles, _handles)&&(identical(other.sourceVersion, sourceVersion) || other.sourceVersion == sourceVersion));
}


@override
int get hashCode => Object.hash(runtimeType,id,displayNameFromSource,const DeepCollectionEquality().hash(_handles),sourceVersion);

@override
String toString() {
  return 'ContactRef(id: $id, displayNameFromSource: $displayNameFromSource, handles: $handles, sourceVersion: $sourceVersion)';
}


}

/// @nodoc
abstract mixin class _$ContactRefCopyWith<$Res> implements $ContactRefCopyWith<$Res> {
  factory _$ContactRefCopyWith(_ContactRef value, $Res Function(_ContactRef) _then) = __$ContactRefCopyWithImpl;
@override @useResult
$Res call({
 ContactId id, String? displayNameFromSource, List<String> handles, String? sourceVersion
});


@override $ContactIdCopyWith<$Res> get id;

}
/// @nodoc
class __$ContactRefCopyWithImpl<$Res>
    implements _$ContactRefCopyWith<$Res> {
  __$ContactRefCopyWithImpl(this._self, this._then);

  final _ContactRef _self;
  final $Res Function(_ContactRef) _then;

/// Create a copy of ContactRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? displayNameFromSource = freezed,Object? handles = null,Object? sourceVersion = freezed,}) {
  return _then(_ContactRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ContactId,displayNameFromSource: freezed == displayNameFromSource ? _self.displayNameFromSource : displayNameFromSource // ignore: cast_nullable_to_non_nullable
as String?,handles: null == handles ? _self._handles : handles // ignore: cast_nullable_to_non_nullable
as List<String>,sourceVersion: freezed == sourceVersion ? _self.sourceVersion : sourceVersion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of ContactRef
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
