// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contact_aggregate.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Contact {

 ContactId get id; ContactDisplayName get displayName; List<ContactHandle> get handles; ContactDetails? get details; ContactPreferences? get preferences; List<String> get tags; ImportMetadata? get importMetadata;
/// Create a copy of Contact
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactCopyWith<Contact> get copyWith => _$ContactCopyWithImpl<Contact>(this as Contact, _$identity);

  /// Serializes this Contact to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Contact&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&const DeepCollectionEquality().equals(other.handles, handles)&&(identical(other.details, details) || other.details == details)&&(identical(other.preferences, preferences) || other.preferences == preferences)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.importMetadata, importMetadata) || other.importMetadata == importMetadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,displayName,const DeepCollectionEquality().hash(handles),details,preferences,const DeepCollectionEquality().hash(tags),importMetadata);

@override
String toString() {
  return 'Contact(id: $id, displayName: $displayName, handles: $handles, details: $details, preferences: $preferences, tags: $tags, importMetadata: $importMetadata)';
}


}

/// @nodoc
abstract mixin class $ContactCopyWith<$Res>  {
  factory $ContactCopyWith(Contact value, $Res Function(Contact) _then) = _$ContactCopyWithImpl;
@useResult
$Res call({
 ContactId id, ContactDisplayName displayName, List<ContactHandle> handles, ContactDetails? details, ContactPreferences? preferences, List<String> tags, ImportMetadata? importMetadata
});


$ContactIdCopyWith<$Res> get id;$ContactDisplayNameCopyWith<$Res> get displayName;$ContactDetailsCopyWith<$Res>? get details;$ContactPreferencesCopyWith<$Res>? get preferences;$ImportMetadataCopyWith<$Res>? get importMetadata;

}
/// @nodoc
class _$ContactCopyWithImpl<$Res>
    implements $ContactCopyWith<$Res> {
  _$ContactCopyWithImpl(this._self, this._then);

  final Contact _self;
  final $Res Function(Contact) _then;

/// Create a copy of Contact
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? displayName = null,Object? handles = null,Object? details = freezed,Object? preferences = freezed,Object? tags = null,Object? importMetadata = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ContactId,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as ContactDisplayName,handles: null == handles ? _self.handles : handles // ignore: cast_nullable_to_non_nullable
as List<ContactHandle>,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as ContactDetails?,preferences: freezed == preferences ? _self.preferences : preferences // ignore: cast_nullable_to_non_nullable
as ContactPreferences?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,importMetadata: freezed == importMetadata ? _self.importMetadata : importMetadata // ignore: cast_nullable_to_non_nullable
as ImportMetadata?,
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
}/// Create a copy of Contact
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactDisplayNameCopyWith<$Res> get displayName {
  
  return $ContactDisplayNameCopyWith<$Res>(_self.displayName, (value) {
    return _then(_self.copyWith(displayName: value));
  });
}/// Create a copy of Contact
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactDetailsCopyWith<$Res>? get details {
    if (_self.details == null) {
    return null;
  }

  return $ContactDetailsCopyWith<$Res>(_self.details!, (value) {
    return _then(_self.copyWith(details: value));
  });
}/// Create a copy of Contact
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactPreferencesCopyWith<$Res>? get preferences {
    if (_self.preferences == null) {
    return null;
  }

  return $ContactPreferencesCopyWith<$Res>(_self.preferences!, (value) {
    return _then(_self.copyWith(preferences: value));
  });
}/// Create a copy of Contact
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImportMetadataCopyWith<$Res>? get importMetadata {
    if (_self.importMetadata == null) {
    return null;
  }

  return $ImportMetadataCopyWith<$Res>(_self.importMetadata!, (value) {
    return _then(_self.copyWith(importMetadata: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ContactId id,  ContactDisplayName displayName,  List<ContactHandle> handles,  ContactDetails? details,  ContactPreferences? preferences,  List<String> tags,  ImportMetadata? importMetadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Contact() when $default != null:
return $default(_that.id,_that.displayName,_that.handles,_that.details,_that.preferences,_that.tags,_that.importMetadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ContactId id,  ContactDisplayName displayName,  List<ContactHandle> handles,  ContactDetails? details,  ContactPreferences? preferences,  List<String> tags,  ImportMetadata? importMetadata)  $default,) {final _that = this;
switch (_that) {
case _Contact():
return $default(_that.id,_that.displayName,_that.handles,_that.details,_that.preferences,_that.tags,_that.importMetadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ContactId id,  ContactDisplayName displayName,  List<ContactHandle> handles,  ContactDetails? details,  ContactPreferences? preferences,  List<String> tags,  ImportMetadata? importMetadata)?  $default,) {final _that = this;
switch (_that) {
case _Contact() when $default != null:
return $default(_that.id,_that.displayName,_that.handles,_that.details,_that.preferences,_that.tags,_that.importMetadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Contact extends Contact {
  const _Contact({required this.id, required this.displayName, required final  List<ContactHandle> handles, this.details, this.preferences, final  List<String> tags = const [], this.importMetadata}): _handles = handles,_tags = tags,super._();
  factory _Contact.fromJson(Map<String, dynamic> json) => _$ContactFromJson(json);

@override final  ContactId id;
@override final  ContactDisplayName displayName;
 final  List<ContactHandle> _handles;
@override List<ContactHandle> get handles {
  if (_handles is EqualUnmodifiableListView) return _handles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_handles);
}

@override final  ContactDetails? details;
@override final  ContactPreferences? preferences;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override final  ImportMetadata? importMetadata;

/// Create a copy of Contact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactCopyWith<_Contact> get copyWith => __$ContactCopyWithImpl<_Contact>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContactToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Contact&&(identical(other.id, id) || other.id == id)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&const DeepCollectionEquality().equals(other._handles, _handles)&&(identical(other.details, details) || other.details == details)&&(identical(other.preferences, preferences) || other.preferences == preferences)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.importMetadata, importMetadata) || other.importMetadata == importMetadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,displayName,const DeepCollectionEquality().hash(_handles),details,preferences,const DeepCollectionEquality().hash(_tags),importMetadata);

@override
String toString() {
  return 'Contact(id: $id, displayName: $displayName, handles: $handles, details: $details, preferences: $preferences, tags: $tags, importMetadata: $importMetadata)';
}


}

/// @nodoc
abstract mixin class _$ContactCopyWith<$Res> implements $ContactCopyWith<$Res> {
  factory _$ContactCopyWith(_Contact value, $Res Function(_Contact) _then) = __$ContactCopyWithImpl;
@override @useResult
$Res call({
 ContactId id, ContactDisplayName displayName, List<ContactHandle> handles, ContactDetails? details, ContactPreferences? preferences, List<String> tags, ImportMetadata? importMetadata
});


@override $ContactIdCopyWith<$Res> get id;@override $ContactDisplayNameCopyWith<$Res> get displayName;@override $ContactDetailsCopyWith<$Res>? get details;@override $ContactPreferencesCopyWith<$Res>? get preferences;@override $ImportMetadataCopyWith<$Res>? get importMetadata;

}
/// @nodoc
class __$ContactCopyWithImpl<$Res>
    implements _$ContactCopyWith<$Res> {
  __$ContactCopyWithImpl(this._self, this._then);

  final _Contact _self;
  final $Res Function(_Contact) _then;

/// Create a copy of Contact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? displayName = null,Object? handles = null,Object? details = freezed,Object? preferences = freezed,Object? tags = null,Object? importMetadata = freezed,}) {
  return _then(_Contact(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ContactId,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as ContactDisplayName,handles: null == handles ? _self._handles : handles // ignore: cast_nullable_to_non_nullable
as List<ContactHandle>,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as ContactDetails?,preferences: freezed == preferences ? _self.preferences : preferences // ignore: cast_nullable_to_non_nullable
as ContactPreferences?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,importMetadata: freezed == importMetadata ? _self.importMetadata : importMetadata // ignore: cast_nullable_to_non_nullable
as ImportMetadata?,
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
}/// Create a copy of Contact
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactDisplayNameCopyWith<$Res> get displayName {
  
  return $ContactDisplayNameCopyWith<$Res>(_self.displayName, (value) {
    return _then(_self.copyWith(displayName: value));
  });
}/// Create a copy of Contact
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactDetailsCopyWith<$Res>? get details {
    if (_self.details == null) {
    return null;
  }

  return $ContactDetailsCopyWith<$Res>(_self.details!, (value) {
    return _then(_self.copyWith(details: value));
  });
}/// Create a copy of Contact
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactPreferencesCopyWith<$Res>? get preferences {
    if (_self.preferences == null) {
    return null;
  }

  return $ContactPreferencesCopyWith<$Res>(_self.preferences!, (value) {
    return _then(_self.copyWith(preferences: value));
  });
}/// Create a copy of Contact
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImportMetadataCopyWith<$Res>? get importMetadata {
    if (_self.importMetadata == null) {
    return null;
  }

  return $ImportMetadataCopyWith<$Res>(_self.importMetadata!, (value) {
    return _then(_self.copyWith(importMetadata: value));
  });
}
}


/// @nodoc
mixin _$ContactId {

 String get value;
/// Create a copy of ContactId
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactIdCopyWith<ContactId> get copyWith => _$ContactIdCopyWithImpl<ContactId>(this as ContactId, _$identity);

  /// Serializes this ContactId to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactId&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'ContactId(value: $value)';
}


}

/// @nodoc
abstract mixin class $ContactIdCopyWith<$Res>  {
  factory $ContactIdCopyWith(ContactId value, $Res Function(ContactId) _then) = _$ContactIdCopyWithImpl;
@useResult
$Res call({
 String value
});




}
/// @nodoc
class _$ContactIdCopyWithImpl<$Res>
    implements $ContactIdCopyWith<$Res> {
  _$ContactIdCopyWithImpl(this._self, this._then);

  final ContactId _self;
  final $Res Function(ContactId) _then;

/// Create a copy of ContactId
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ContactId].
extension ContactIdPatterns on ContactId {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContactId value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactId() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContactId value)  $default,){
final _that = this;
switch (_that) {
case _ContactId():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContactId value)?  $default,){
final _that = this;
switch (_that) {
case _ContactId() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactId() when $default != null:
return $default(_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value)  $default,) {final _that = this;
switch (_that) {
case _ContactId():
return $default(_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value)?  $default,) {final _that = this;
switch (_that) {
case _ContactId() when $default != null:
return $default(_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContactId implements ContactId {
  const _ContactId(this.value);
  factory _ContactId.fromJson(Map<String, dynamic> json) => _$ContactIdFromJson(json);

@override final  String value;

/// Create a copy of ContactId
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactIdCopyWith<_ContactId> get copyWith => __$ContactIdCopyWithImpl<_ContactId>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContactIdToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactId&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'ContactId(value: $value)';
}


}

/// @nodoc
abstract mixin class _$ContactIdCopyWith<$Res> implements $ContactIdCopyWith<$Res> {
  factory _$ContactIdCopyWith(_ContactId value, $Res Function(_ContactId) _then) = __$ContactIdCopyWithImpl;
@override @useResult
$Res call({
 String value
});




}
/// @nodoc
class __$ContactIdCopyWithImpl<$Res>
    implements _$ContactIdCopyWith<$Res> {
  __$ContactIdCopyWithImpl(this._self, this._then);

  final _ContactId _self;
  final $Res Function(_ContactId) _then;

/// Create a copy of ContactId
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(_ContactId(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ContactDisplayName {

 String get value; DisplayNameSource get source; String? get firstName; String? get lastName; String? get nickname; String? get company;
/// Create a copy of ContactDisplayName
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactDisplayNameCopyWith<ContactDisplayName> get copyWith => _$ContactDisplayNameCopyWithImpl<ContactDisplayName>(this as ContactDisplayName, _$identity);

  /// Serializes this ContactDisplayName to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactDisplayName&&(identical(other.value, value) || other.value == value)&&(identical(other.source, source) || other.source == source)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.company, company) || other.company == company));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,source,firstName,lastName,nickname,company);

@override
String toString() {
  return 'ContactDisplayName(value: $value, source: $source, firstName: $firstName, lastName: $lastName, nickname: $nickname, company: $company)';
}


}

/// @nodoc
abstract mixin class $ContactDisplayNameCopyWith<$Res>  {
  factory $ContactDisplayNameCopyWith(ContactDisplayName value, $Res Function(ContactDisplayName) _then) = _$ContactDisplayNameCopyWithImpl;
@useResult
$Res call({
 String value, DisplayNameSource source, String? firstName, String? lastName, String? nickname, String? company
});




}
/// @nodoc
class _$ContactDisplayNameCopyWithImpl<$Res>
    implements $ContactDisplayNameCopyWith<$Res> {
  _$ContactDisplayNameCopyWithImpl(this._self, this._then);

  final ContactDisplayName _self;
  final $Res Function(ContactDisplayName) _then;

/// Create a copy of ContactDisplayName
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? source = null,Object? firstName = freezed,Object? lastName = freezed,Object? nickname = freezed,Object? company = freezed,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as DisplayNameSource,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ContactDisplayName].
extension ContactDisplayNamePatterns on ContactDisplayName {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContactDisplayName value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactDisplayName() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContactDisplayName value)  $default,){
final _that = this;
switch (_that) {
case _ContactDisplayName():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContactDisplayName value)?  $default,){
final _that = this;
switch (_that) {
case _ContactDisplayName() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value,  DisplayNameSource source,  String? firstName,  String? lastName,  String? nickname,  String? company)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactDisplayName() when $default != null:
return $default(_that.value,_that.source,_that.firstName,_that.lastName,_that.nickname,_that.company);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value,  DisplayNameSource source,  String? firstName,  String? lastName,  String? nickname,  String? company)  $default,) {final _that = this;
switch (_that) {
case _ContactDisplayName():
return $default(_that.value,_that.source,_that.firstName,_that.lastName,_that.nickname,_that.company);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value,  DisplayNameSource source,  String? firstName,  String? lastName,  String? nickname,  String? company)?  $default,) {final _that = this;
switch (_that) {
case _ContactDisplayName() when $default != null:
return $default(_that.value,_that.source,_that.firstName,_that.lastName,_that.nickname,_that.company);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContactDisplayName extends ContactDisplayName {
  const _ContactDisplayName({required this.value, required this.source, this.firstName, this.lastName, this.nickname, this.company}): super._();
  factory _ContactDisplayName.fromJson(Map<String, dynamic> json) => _$ContactDisplayNameFromJson(json);

@override final  String value;
@override final  DisplayNameSource source;
@override final  String? firstName;
@override final  String? lastName;
@override final  String? nickname;
@override final  String? company;

/// Create a copy of ContactDisplayName
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactDisplayNameCopyWith<_ContactDisplayName> get copyWith => __$ContactDisplayNameCopyWithImpl<_ContactDisplayName>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContactDisplayNameToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactDisplayName&&(identical(other.value, value) || other.value == value)&&(identical(other.source, source) || other.source == source)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.nickname, nickname) || other.nickname == nickname)&&(identical(other.company, company) || other.company == company));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,source,firstName,lastName,nickname,company);

@override
String toString() {
  return 'ContactDisplayName(value: $value, source: $source, firstName: $firstName, lastName: $lastName, nickname: $nickname, company: $company)';
}


}

/// @nodoc
abstract mixin class _$ContactDisplayNameCopyWith<$Res> implements $ContactDisplayNameCopyWith<$Res> {
  factory _$ContactDisplayNameCopyWith(_ContactDisplayName value, $Res Function(_ContactDisplayName) _then) = __$ContactDisplayNameCopyWithImpl;
@override @useResult
$Res call({
 String value, DisplayNameSource source, String? firstName, String? lastName, String? nickname, String? company
});




}
/// @nodoc
class __$ContactDisplayNameCopyWithImpl<$Res>
    implements _$ContactDisplayNameCopyWith<$Res> {
  __$ContactDisplayNameCopyWithImpl(this._self, this._then);

  final _ContactDisplayName _self;
  final $Res Function(_ContactDisplayName) _then;

/// Create a copy of ContactDisplayName
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? source = null,Object? firstName = freezed,Object? lastName = freezed,Object? nickname = freezed,Object? company = freezed,}) {
  return _then(_ContactDisplayName(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as DisplayNameSource,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,nickname: freezed == nickname ? _self.nickname : nickname // ignore: cast_nullable_to_non_nullable
as String?,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ContactHandle {

 HandleId get id; String get address; String get service; bool get isPreferred; bool get isVerified; HandleMetadata? get metadata;
/// Create a copy of ContactHandle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactHandleCopyWith<ContactHandle> get copyWith => _$ContactHandleCopyWithImpl<ContactHandle>(this as ContactHandle, _$identity);

  /// Serializes this ContactHandle to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactHandle&&(identical(other.id, id) || other.id == id)&&(identical(other.address, address) || other.address == address)&&(identical(other.service, service) || other.service == service)&&(identical(other.isPreferred, isPreferred) || other.isPreferred == isPreferred)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.metadata, metadata) || other.metadata == metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,address,service,isPreferred,isVerified,metadata);

@override
String toString() {
  return 'ContactHandle(id: $id, address: $address, service: $service, isPreferred: $isPreferred, isVerified: $isVerified, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $ContactHandleCopyWith<$Res>  {
  factory $ContactHandleCopyWith(ContactHandle value, $Res Function(ContactHandle) _then) = _$ContactHandleCopyWithImpl;
@useResult
$Res call({
 HandleId id, String address, String service, bool isPreferred, bool isVerified, HandleMetadata? metadata
});


$HandleIdCopyWith<$Res> get id;$HandleMetadataCopyWith<$Res>? get metadata;

}
/// @nodoc
class _$ContactHandleCopyWithImpl<$Res>
    implements $ContactHandleCopyWith<$Res> {
  _$ContactHandleCopyWithImpl(this._self, this._then);

  final ContactHandle _self;
  final $Res Function(ContactHandle) _then;

/// Create a copy of ContactHandle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? address = null,Object? service = null,Object? isPreferred = null,Object? isVerified = null,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as HandleId,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,service: null == service ? _self.service : service // ignore: cast_nullable_to_non_nullable
as String,isPreferred: null == isPreferred ? _self.isPreferred : isPreferred // ignore: cast_nullable_to_non_nullable
as bool,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as HandleMetadata?,
  ));
}
/// Create a copy of ContactHandle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HandleIdCopyWith<$Res> get id {
  
  return $HandleIdCopyWith<$Res>(_self.id, (value) {
    return _then(_self.copyWith(id: value));
  });
}/// Create a copy of ContactHandle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HandleMetadataCopyWith<$Res>? get metadata {
    if (_self.metadata == null) {
    return null;
  }

  return $HandleMetadataCopyWith<$Res>(_self.metadata!, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}


/// Adds pattern-matching-related methods to [ContactHandle].
extension ContactHandlePatterns on ContactHandle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContactHandle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactHandle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContactHandle value)  $default,){
final _that = this;
switch (_that) {
case _ContactHandle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContactHandle value)?  $default,){
final _that = this;
switch (_that) {
case _ContactHandle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HandleId id,  String address,  String service,  bool isPreferred,  bool isVerified,  HandleMetadata? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactHandle() when $default != null:
return $default(_that.id,_that.address,_that.service,_that.isPreferred,_that.isVerified,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HandleId id,  String address,  String service,  bool isPreferred,  bool isVerified,  HandleMetadata? metadata)  $default,) {final _that = this;
switch (_that) {
case _ContactHandle():
return $default(_that.id,_that.address,_that.service,_that.isPreferred,_that.isVerified,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HandleId id,  String address,  String service,  bool isPreferred,  bool isVerified,  HandleMetadata? metadata)?  $default,) {final _that = this;
switch (_that) {
case _ContactHandle() when $default != null:
return $default(_that.id,_that.address,_that.service,_that.isPreferred,_that.isVerified,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContactHandle extends ContactHandle {
  const _ContactHandle({required this.id, required this.address, required this.service, this.isPreferred = false, this.isVerified = false, this.metadata}): super._();
  factory _ContactHandle.fromJson(Map<String, dynamic> json) => _$ContactHandleFromJson(json);

@override final  HandleId id;
@override final  String address;
@override final  String service;
@override@JsonKey() final  bool isPreferred;
@override@JsonKey() final  bool isVerified;
@override final  HandleMetadata? metadata;

/// Create a copy of ContactHandle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactHandleCopyWith<_ContactHandle> get copyWith => __$ContactHandleCopyWithImpl<_ContactHandle>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContactHandleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactHandle&&(identical(other.id, id) || other.id == id)&&(identical(other.address, address) || other.address == address)&&(identical(other.service, service) || other.service == service)&&(identical(other.isPreferred, isPreferred) || other.isPreferred == isPreferred)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.metadata, metadata) || other.metadata == metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,address,service,isPreferred,isVerified,metadata);

@override
String toString() {
  return 'ContactHandle(id: $id, address: $address, service: $service, isPreferred: $isPreferred, isVerified: $isVerified, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$ContactHandleCopyWith<$Res> implements $ContactHandleCopyWith<$Res> {
  factory _$ContactHandleCopyWith(_ContactHandle value, $Res Function(_ContactHandle) _then) = __$ContactHandleCopyWithImpl;
@override @useResult
$Res call({
 HandleId id, String address, String service, bool isPreferred, bool isVerified, HandleMetadata? metadata
});


@override $HandleIdCopyWith<$Res> get id;@override $HandleMetadataCopyWith<$Res>? get metadata;

}
/// @nodoc
class __$ContactHandleCopyWithImpl<$Res>
    implements _$ContactHandleCopyWith<$Res> {
  __$ContactHandleCopyWithImpl(this._self, this._then);

  final _ContactHandle _self;
  final $Res Function(_ContactHandle) _then;

/// Create a copy of ContactHandle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? address = null,Object? service = null,Object? isPreferred = null,Object? isVerified = null,Object? metadata = freezed,}) {
  return _then(_ContactHandle(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as HandleId,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,service: null == service ? _self.service : service // ignore: cast_nullable_to_non_nullable
as String,isPreferred: null == isPreferred ? _self.isPreferred : isPreferred // ignore: cast_nullable_to_non_nullable
as bool,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as HandleMetadata?,
  ));
}

/// Create a copy of ContactHandle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HandleIdCopyWith<$Res> get id {
  
  return $HandleIdCopyWith<$Res>(_self.id, (value) {
    return _then(_self.copyWith(id: value));
  });
}/// Create a copy of ContactHandle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HandleMetadataCopyWith<$Res>? get metadata {
    if (_self.metadata == null) {
    return null;
  }

  return $HandleMetadataCopyWith<$Res>(_self.metadata!, (value) {
    return _then(_self.copyWith(metadata: value));
  });
}
}


/// @nodoc
mixin _$HandleId {

 String get value;
/// Create a copy of HandleId
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HandleIdCopyWith<HandleId> get copyWith => _$HandleIdCopyWithImpl<HandleId>(this as HandleId, _$identity);

  /// Serializes this HandleId to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HandleId&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'HandleId(value: $value)';
}


}

/// @nodoc
abstract mixin class $HandleIdCopyWith<$Res>  {
  factory $HandleIdCopyWith(HandleId value, $Res Function(HandleId) _then) = _$HandleIdCopyWithImpl;
@useResult
$Res call({
 String value
});




}
/// @nodoc
class _$HandleIdCopyWithImpl<$Res>
    implements $HandleIdCopyWith<$Res> {
  _$HandleIdCopyWithImpl(this._self, this._then);

  final HandleId _self;
  final $Res Function(HandleId) _then;

/// Create a copy of HandleId
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [HandleId].
extension HandleIdPatterns on HandleId {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HandleId value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HandleId() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HandleId value)  $default,){
final _that = this;
switch (_that) {
case _HandleId():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HandleId value)?  $default,){
final _that = this;
switch (_that) {
case _HandleId() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HandleId() when $default != null:
return $default(_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value)  $default,) {final _that = this;
switch (_that) {
case _HandleId():
return $default(_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value)?  $default,) {final _that = this;
switch (_that) {
case _HandleId() when $default != null:
return $default(_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HandleId implements HandleId {
  const _HandleId(this.value);
  factory _HandleId.fromJson(Map<String, dynamic> json) => _$HandleIdFromJson(json);

@override final  String value;

/// Create a copy of HandleId
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HandleIdCopyWith<_HandleId> get copyWith => __$HandleIdCopyWithImpl<_HandleId>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HandleIdToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HandleId&&(identical(other.value, value) || other.value == value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value);

@override
String toString() {
  return 'HandleId(value: $value)';
}


}

/// @nodoc
abstract mixin class _$HandleIdCopyWith<$Res> implements $HandleIdCopyWith<$Res> {
  factory _$HandleIdCopyWith(_HandleId value, $Res Function(_HandleId) _then) = __$HandleIdCopyWithImpl;
@override @useResult
$Res call({
 String value
});




}
/// @nodoc
class __$HandleIdCopyWithImpl<$Res>
    implements _$HandleIdCopyWith<$Res> {
  __$HandleIdCopyWithImpl(this._self, this._then);

  final _HandleId _self;
  final $Res Function(_HandleId) _then;

/// Create a copy of HandleId
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,}) {
  return _then(_HandleId(
null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$HandleMetadata {

 String? get label;// "Home", "Work", "Mobile", etc.
 DateTime? get lastUsed; DateTime? get verified; String? get countryCode;// For phone numbers
 String? get region;
/// Create a copy of HandleMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HandleMetadataCopyWith<HandleMetadata> get copyWith => _$HandleMetadataCopyWithImpl<HandleMetadata>(this as HandleMetadata, _$identity);

  /// Serializes this HandleMetadata to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HandleMetadata&&(identical(other.label, label) || other.label == label)&&(identical(other.lastUsed, lastUsed) || other.lastUsed == lastUsed)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.region, region) || other.region == region));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,lastUsed,verified,countryCode,region);

@override
String toString() {
  return 'HandleMetadata(label: $label, lastUsed: $lastUsed, verified: $verified, countryCode: $countryCode, region: $region)';
}


}

/// @nodoc
abstract mixin class $HandleMetadataCopyWith<$Res>  {
  factory $HandleMetadataCopyWith(HandleMetadata value, $Res Function(HandleMetadata) _then) = _$HandleMetadataCopyWithImpl;
@useResult
$Res call({
 String? label, DateTime? lastUsed, DateTime? verified, String? countryCode, String? region
});




}
/// @nodoc
class _$HandleMetadataCopyWithImpl<$Res>
    implements $HandleMetadataCopyWith<$Res> {
  _$HandleMetadataCopyWithImpl(this._self, this._then);

  final HandleMetadata _self;
  final $Res Function(HandleMetadata) _then;

/// Create a copy of HandleMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = freezed,Object? lastUsed = freezed,Object? verified = freezed,Object? countryCode = freezed,Object? region = freezed,}) {
  return _then(_self.copyWith(
label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,lastUsed: freezed == lastUsed ? _self.lastUsed : lastUsed // ignore: cast_nullable_to_non_nullable
as DateTime?,verified: freezed == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as DateTime?,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HandleMetadata].
extension HandleMetadataPatterns on HandleMetadata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HandleMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HandleMetadata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HandleMetadata value)  $default,){
final _that = this;
switch (_that) {
case _HandleMetadata():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HandleMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _HandleMetadata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? label,  DateTime? lastUsed,  DateTime? verified,  String? countryCode,  String? region)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HandleMetadata() when $default != null:
return $default(_that.label,_that.lastUsed,_that.verified,_that.countryCode,_that.region);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? label,  DateTime? lastUsed,  DateTime? verified,  String? countryCode,  String? region)  $default,) {final _that = this;
switch (_that) {
case _HandleMetadata():
return $default(_that.label,_that.lastUsed,_that.verified,_that.countryCode,_that.region);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? label,  DateTime? lastUsed,  DateTime? verified,  String? countryCode,  String? region)?  $default,) {final _that = this;
switch (_that) {
case _HandleMetadata() when $default != null:
return $default(_that.label,_that.lastUsed,_that.verified,_that.countryCode,_that.region);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HandleMetadata implements HandleMetadata {
  const _HandleMetadata({this.label, this.lastUsed, this.verified, this.countryCode, this.region});
  factory _HandleMetadata.fromJson(Map<String, dynamic> json) => _$HandleMetadataFromJson(json);

@override final  String? label;
// "Home", "Work", "Mobile", etc.
@override final  DateTime? lastUsed;
@override final  DateTime? verified;
@override final  String? countryCode;
// For phone numbers
@override final  String? region;

/// Create a copy of HandleMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HandleMetadataCopyWith<_HandleMetadata> get copyWith => __$HandleMetadataCopyWithImpl<_HandleMetadata>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HandleMetadataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HandleMetadata&&(identical(other.label, label) || other.label == label)&&(identical(other.lastUsed, lastUsed) || other.lastUsed == lastUsed)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.region, region) || other.region == region));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,lastUsed,verified,countryCode,region);

@override
String toString() {
  return 'HandleMetadata(label: $label, lastUsed: $lastUsed, verified: $verified, countryCode: $countryCode, region: $region)';
}


}

/// @nodoc
abstract mixin class _$HandleMetadataCopyWith<$Res> implements $HandleMetadataCopyWith<$Res> {
  factory _$HandleMetadataCopyWith(_HandleMetadata value, $Res Function(_HandleMetadata) _then) = __$HandleMetadataCopyWithImpl;
@override @useResult
$Res call({
 String? label, DateTime? lastUsed, DateTime? verified, String? countryCode, String? region
});




}
/// @nodoc
class __$HandleMetadataCopyWithImpl<$Res>
    implements _$HandleMetadataCopyWith<$Res> {
  __$HandleMetadataCopyWithImpl(this._self, this._then);

  final _HandleMetadata _self;
  final $Res Function(_HandleMetadata) _then;

/// Create a copy of HandleMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = freezed,Object? lastUsed = freezed,Object? verified = freezed,Object? countryCode = freezed,Object? region = freezed,}) {
  return _then(_HandleMetadata(
label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,lastUsed: freezed == lastUsed ? _self.lastUsed : lastUsed // ignore: cast_nullable_to_non_nullable
as DateTime?,verified: freezed == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as DateTime?,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ContactDetails {

 String? get organization; String? get jobTitle; String? get department; ContactAddress? get address; DateTime? get birthday; String? get notes; List<String> get categories;
/// Create a copy of ContactDetails
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactDetailsCopyWith<ContactDetails> get copyWith => _$ContactDetailsCopyWithImpl<ContactDetails>(this as ContactDetails, _$identity);

  /// Serializes this ContactDetails to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactDetails&&(identical(other.organization, organization) || other.organization == organization)&&(identical(other.jobTitle, jobTitle) || other.jobTitle == jobTitle)&&(identical(other.department, department) || other.department == department)&&(identical(other.address, address) || other.address == address)&&(identical(other.birthday, birthday) || other.birthday == birthday)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.categories, categories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,organization,jobTitle,department,address,birthday,notes,const DeepCollectionEquality().hash(categories));

@override
String toString() {
  return 'ContactDetails(organization: $organization, jobTitle: $jobTitle, department: $department, address: $address, birthday: $birthday, notes: $notes, categories: $categories)';
}


}

/// @nodoc
abstract mixin class $ContactDetailsCopyWith<$Res>  {
  factory $ContactDetailsCopyWith(ContactDetails value, $Res Function(ContactDetails) _then) = _$ContactDetailsCopyWithImpl;
@useResult
$Res call({
 String? organization, String? jobTitle, String? department, ContactAddress? address, DateTime? birthday, String? notes, List<String> categories
});


$ContactAddressCopyWith<$Res>? get address;

}
/// @nodoc
class _$ContactDetailsCopyWithImpl<$Res>
    implements $ContactDetailsCopyWith<$Res> {
  _$ContactDetailsCopyWithImpl(this._self, this._then);

  final ContactDetails _self;
  final $Res Function(ContactDetails) _then;

/// Create a copy of ContactDetails
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? organization = freezed,Object? jobTitle = freezed,Object? department = freezed,Object? address = freezed,Object? birthday = freezed,Object? notes = freezed,Object? categories = null,}) {
  return _then(_self.copyWith(
organization: freezed == organization ? _self.organization : organization // ignore: cast_nullable_to_non_nullable
as String?,jobTitle: freezed == jobTitle ? _self.jobTitle : jobTitle // ignore: cast_nullable_to_non_nullable
as String?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as ContactAddress?,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of ContactDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactAddressCopyWith<$Res>? get address {
    if (_self.address == null) {
    return null;
  }

  return $ContactAddressCopyWith<$Res>(_self.address!, (value) {
    return _then(_self.copyWith(address: value));
  });
}
}


/// Adds pattern-matching-related methods to [ContactDetails].
extension ContactDetailsPatterns on ContactDetails {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContactDetails value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactDetails() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContactDetails value)  $default,){
final _that = this;
switch (_that) {
case _ContactDetails():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContactDetails value)?  $default,){
final _that = this;
switch (_that) {
case _ContactDetails() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? organization,  String? jobTitle,  String? department,  ContactAddress? address,  DateTime? birthday,  String? notes,  List<String> categories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactDetails() when $default != null:
return $default(_that.organization,_that.jobTitle,_that.department,_that.address,_that.birthday,_that.notes,_that.categories);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? organization,  String? jobTitle,  String? department,  ContactAddress? address,  DateTime? birthday,  String? notes,  List<String> categories)  $default,) {final _that = this;
switch (_that) {
case _ContactDetails():
return $default(_that.organization,_that.jobTitle,_that.department,_that.address,_that.birthday,_that.notes,_that.categories);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? organization,  String? jobTitle,  String? department,  ContactAddress? address,  DateTime? birthday,  String? notes,  List<String> categories)?  $default,) {final _that = this;
switch (_that) {
case _ContactDetails() when $default != null:
return $default(_that.organization,_that.jobTitle,_that.department,_that.address,_that.birthday,_that.notes,_that.categories);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContactDetails implements ContactDetails {
  const _ContactDetails({this.organization, this.jobTitle, this.department, this.address, this.birthday, this.notes, final  List<String> categories = const []}): _categories = categories;
  factory _ContactDetails.fromJson(Map<String, dynamic> json) => _$ContactDetailsFromJson(json);

@override final  String? organization;
@override final  String? jobTitle;
@override final  String? department;
@override final  ContactAddress? address;
@override final  DateTime? birthday;
@override final  String? notes;
 final  List<String> _categories;
@override@JsonKey() List<String> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}


/// Create a copy of ContactDetails
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactDetailsCopyWith<_ContactDetails> get copyWith => __$ContactDetailsCopyWithImpl<_ContactDetails>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContactDetailsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactDetails&&(identical(other.organization, organization) || other.organization == organization)&&(identical(other.jobTitle, jobTitle) || other.jobTitle == jobTitle)&&(identical(other.department, department) || other.department == department)&&(identical(other.address, address) || other.address == address)&&(identical(other.birthday, birthday) || other.birthday == birthday)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other._categories, _categories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,organization,jobTitle,department,address,birthday,notes,const DeepCollectionEquality().hash(_categories));

@override
String toString() {
  return 'ContactDetails(organization: $organization, jobTitle: $jobTitle, department: $department, address: $address, birthday: $birthday, notes: $notes, categories: $categories)';
}


}

/// @nodoc
abstract mixin class _$ContactDetailsCopyWith<$Res> implements $ContactDetailsCopyWith<$Res> {
  factory _$ContactDetailsCopyWith(_ContactDetails value, $Res Function(_ContactDetails) _then) = __$ContactDetailsCopyWithImpl;
@override @useResult
$Res call({
 String? organization, String? jobTitle, String? department, ContactAddress? address, DateTime? birthday, String? notes, List<String> categories
});


@override $ContactAddressCopyWith<$Res>? get address;

}
/// @nodoc
class __$ContactDetailsCopyWithImpl<$Res>
    implements _$ContactDetailsCopyWith<$Res> {
  __$ContactDetailsCopyWithImpl(this._self, this._then);

  final _ContactDetails _self;
  final $Res Function(_ContactDetails) _then;

/// Create a copy of ContactDetails
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? organization = freezed,Object? jobTitle = freezed,Object? department = freezed,Object? address = freezed,Object? birthday = freezed,Object? notes = freezed,Object? categories = null,}) {
  return _then(_ContactDetails(
organization: freezed == organization ? _self.organization : organization // ignore: cast_nullable_to_non_nullable
as String?,jobTitle: freezed == jobTitle ? _self.jobTitle : jobTitle // ignore: cast_nullable_to_non_nullable
as String?,department: freezed == department ? _self.department : department // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as ContactAddress?,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as DateTime?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of ContactDetails
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactAddressCopyWith<$Res>? get address {
    if (_self.address == null) {
    return null;
  }

  return $ContactAddressCopyWith<$Res>(_self.address!, (value) {
    return _then(_self.copyWith(address: value));
  });
}
}


/// @nodoc
mixin _$ContactAddress {

 String? get street; String? get city; String? get state; String? get postalCode; String? get country;
/// Create a copy of ContactAddress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactAddressCopyWith<ContactAddress> get copyWith => _$ContactAddressCopyWithImpl<ContactAddress>(this as ContactAddress, _$identity);

  /// Serializes this ContactAddress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactAddress&&(identical(other.street, street) || other.street == street)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.country, country) || other.country == country));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,street,city,state,postalCode,country);

@override
String toString() {
  return 'ContactAddress(street: $street, city: $city, state: $state, postalCode: $postalCode, country: $country)';
}


}

/// @nodoc
abstract mixin class $ContactAddressCopyWith<$Res>  {
  factory $ContactAddressCopyWith(ContactAddress value, $Res Function(ContactAddress) _then) = _$ContactAddressCopyWithImpl;
@useResult
$Res call({
 String? street, String? city, String? state, String? postalCode, String? country
});




}
/// @nodoc
class _$ContactAddressCopyWithImpl<$Res>
    implements $ContactAddressCopyWith<$Res> {
  _$ContactAddressCopyWithImpl(this._self, this._then);

  final ContactAddress _self;
  final $Res Function(ContactAddress) _then;

/// Create a copy of ContactAddress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? street = freezed,Object? city = freezed,Object? state = freezed,Object? postalCode = freezed,Object? country = freezed,}) {
  return _then(_self.copyWith(
street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ContactAddress].
extension ContactAddressPatterns on ContactAddress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContactAddress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactAddress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContactAddress value)  $default,){
final _that = this;
switch (_that) {
case _ContactAddress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContactAddress value)?  $default,){
final _that = this;
switch (_that) {
case _ContactAddress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? street,  String? city,  String? state,  String? postalCode,  String? country)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactAddress() when $default != null:
return $default(_that.street,_that.city,_that.state,_that.postalCode,_that.country);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? street,  String? city,  String? state,  String? postalCode,  String? country)  $default,) {final _that = this;
switch (_that) {
case _ContactAddress():
return $default(_that.street,_that.city,_that.state,_that.postalCode,_that.country);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? street,  String? city,  String? state,  String? postalCode,  String? country)?  $default,) {final _that = this;
switch (_that) {
case _ContactAddress() when $default != null:
return $default(_that.street,_that.city,_that.state,_that.postalCode,_that.country);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContactAddress extends ContactAddress {
  const _ContactAddress({this.street, this.city, this.state, this.postalCode, this.country}): super._();
  factory _ContactAddress.fromJson(Map<String, dynamic> json) => _$ContactAddressFromJson(json);

@override final  String? street;
@override final  String? city;
@override final  String? state;
@override final  String? postalCode;
@override final  String? country;

/// Create a copy of ContactAddress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactAddressCopyWith<_ContactAddress> get copyWith => __$ContactAddressCopyWithImpl<_ContactAddress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContactAddressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactAddress&&(identical(other.street, street) || other.street == street)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.country, country) || other.country == country));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,street,city,state,postalCode,country);

@override
String toString() {
  return 'ContactAddress(street: $street, city: $city, state: $state, postalCode: $postalCode, country: $country)';
}


}

/// @nodoc
abstract mixin class _$ContactAddressCopyWith<$Res> implements $ContactAddressCopyWith<$Res> {
  factory _$ContactAddressCopyWith(_ContactAddress value, $Res Function(_ContactAddress) _then) = __$ContactAddressCopyWithImpl;
@override @useResult
$Res call({
 String? street, String? city, String? state, String? postalCode, String? country
});




}
/// @nodoc
class __$ContactAddressCopyWithImpl<$Res>
    implements _$ContactAddressCopyWith<$Res> {
  __$ContactAddressCopyWithImpl(this._self, this._then);

  final _ContactAddress _self;
  final $Res Function(_ContactAddress) _then;

/// Create a copy of ContactAddress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? street = freezed,Object? city = freezed,Object? state = freezed,Object? postalCode = freezed,Object? country = freezed,}) {
  return _then(_ContactAddress(
street: freezed == street ? _self.street : street // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ContactPreferences {

 bool get isFavorite; bool get isBlocked; bool get allowNotifications; String? get customRingtone; String? get customTextTone;
/// Create a copy of ContactPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContactPreferencesCopyWith<ContactPreferences> get copyWith => _$ContactPreferencesCopyWithImpl<ContactPreferences>(this as ContactPreferences, _$identity);

  /// Serializes this ContactPreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactPreferences&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.isBlocked, isBlocked) || other.isBlocked == isBlocked)&&(identical(other.allowNotifications, allowNotifications) || other.allowNotifications == allowNotifications)&&(identical(other.customRingtone, customRingtone) || other.customRingtone == customRingtone)&&(identical(other.customTextTone, customTextTone) || other.customTextTone == customTextTone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isFavorite,isBlocked,allowNotifications,customRingtone,customTextTone);

@override
String toString() {
  return 'ContactPreferences(isFavorite: $isFavorite, isBlocked: $isBlocked, allowNotifications: $allowNotifications, customRingtone: $customRingtone, customTextTone: $customTextTone)';
}


}

/// @nodoc
abstract mixin class $ContactPreferencesCopyWith<$Res>  {
  factory $ContactPreferencesCopyWith(ContactPreferences value, $Res Function(ContactPreferences) _then) = _$ContactPreferencesCopyWithImpl;
@useResult
$Res call({
 bool isFavorite, bool isBlocked, bool allowNotifications, String? customRingtone, String? customTextTone
});




}
/// @nodoc
class _$ContactPreferencesCopyWithImpl<$Res>
    implements $ContactPreferencesCopyWith<$Res> {
  _$ContactPreferencesCopyWithImpl(this._self, this._then);

  final ContactPreferences _self;
  final $Res Function(ContactPreferences) _then;

/// Create a copy of ContactPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isFavorite = null,Object? isBlocked = null,Object? allowNotifications = null,Object? customRingtone = freezed,Object? customTextTone = freezed,}) {
  return _then(_self.copyWith(
isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,isBlocked: null == isBlocked ? _self.isBlocked : isBlocked // ignore: cast_nullable_to_non_nullable
as bool,allowNotifications: null == allowNotifications ? _self.allowNotifications : allowNotifications // ignore: cast_nullable_to_non_nullable
as bool,customRingtone: freezed == customRingtone ? _self.customRingtone : customRingtone // ignore: cast_nullable_to_non_nullable
as String?,customTextTone: freezed == customTextTone ? _self.customTextTone : customTextTone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ContactPreferences].
extension ContactPreferencesPatterns on ContactPreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ContactPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactPreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ContactPreferences value)  $default,){
final _that = this;
switch (_that) {
case _ContactPreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ContactPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _ContactPreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isFavorite,  bool isBlocked,  bool allowNotifications,  String? customRingtone,  String? customTextTone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactPreferences() when $default != null:
return $default(_that.isFavorite,_that.isBlocked,_that.allowNotifications,_that.customRingtone,_that.customTextTone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isFavorite,  bool isBlocked,  bool allowNotifications,  String? customRingtone,  String? customTextTone)  $default,) {final _that = this;
switch (_that) {
case _ContactPreferences():
return $default(_that.isFavorite,_that.isBlocked,_that.allowNotifications,_that.customRingtone,_that.customTextTone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isFavorite,  bool isBlocked,  bool allowNotifications,  String? customRingtone,  String? customTextTone)?  $default,) {final _that = this;
switch (_that) {
case _ContactPreferences() when $default != null:
return $default(_that.isFavorite,_that.isBlocked,_that.allowNotifications,_that.customRingtone,_that.customTextTone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ContactPreferences implements ContactPreferences {
  const _ContactPreferences({this.isFavorite = false, this.isBlocked = false, this.allowNotifications = true, this.customRingtone, this.customTextTone});
  factory _ContactPreferences.fromJson(Map<String, dynamic> json) => _$ContactPreferencesFromJson(json);

@override@JsonKey() final  bool isFavorite;
@override@JsonKey() final  bool isBlocked;
@override@JsonKey() final  bool allowNotifications;
@override final  String? customRingtone;
@override final  String? customTextTone;

/// Create a copy of ContactPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactPreferencesCopyWith<_ContactPreferences> get copyWith => __$ContactPreferencesCopyWithImpl<_ContactPreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContactPreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactPreferences&&(identical(other.isFavorite, isFavorite) || other.isFavorite == isFavorite)&&(identical(other.isBlocked, isBlocked) || other.isBlocked == isBlocked)&&(identical(other.allowNotifications, allowNotifications) || other.allowNotifications == allowNotifications)&&(identical(other.customRingtone, customRingtone) || other.customRingtone == customRingtone)&&(identical(other.customTextTone, customTextTone) || other.customTextTone == customTextTone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isFavorite,isBlocked,allowNotifications,customRingtone,customTextTone);

@override
String toString() {
  return 'ContactPreferences(isFavorite: $isFavorite, isBlocked: $isBlocked, allowNotifications: $allowNotifications, customRingtone: $customRingtone, customTextTone: $customTextTone)';
}


}

/// @nodoc
abstract mixin class _$ContactPreferencesCopyWith<$Res> implements $ContactPreferencesCopyWith<$Res> {
  factory _$ContactPreferencesCopyWith(_ContactPreferences value, $Res Function(_ContactPreferences) _then) = __$ContactPreferencesCopyWithImpl;
@override @useResult
$Res call({
 bool isFavorite, bool isBlocked, bool allowNotifications, String? customRingtone, String? customTextTone
});




}
/// @nodoc
class __$ContactPreferencesCopyWithImpl<$Res>
    implements _$ContactPreferencesCopyWith<$Res> {
  __$ContactPreferencesCopyWithImpl(this._self, this._then);

  final _ContactPreferences _self;
  final $Res Function(_ContactPreferences) _then;

/// Create a copy of ContactPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isFavorite = null,Object? isBlocked = null,Object? allowNotifications = null,Object? customRingtone = freezed,Object? customTextTone = freezed,}) {
  return _then(_ContactPreferences(
isFavorite: null == isFavorite ? _self.isFavorite : isFavorite // ignore: cast_nullable_to_non_nullable
as bool,isBlocked: null == isBlocked ? _self.isBlocked : isBlocked // ignore: cast_nullable_to_non_nullable
as bool,allowNotifications: null == allowNotifications ? _self.allowNotifications : allowNotifications // ignore: cast_nullable_to_non_nullable
as bool,customRingtone: freezed == customRingtone ? _self.customRingtone : customRingtone // ignore: cast_nullable_to_non_nullable
as String?,customTextTone: freezed == customTextTone ? _self.customTextTone : customTextTone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ImportMetadata {

 String get sourceSystem; int get sourceId; DateTime get importedAt; String? get sourceHash; int? get sourceVersion;
/// Create a copy of ImportMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportMetadataCopyWith<ImportMetadata> get copyWith => _$ImportMetadataCopyWithImpl<ImportMetadata>(this as ImportMetadata, _$identity);

  /// Serializes this ImportMetadata to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportMetadata&&(identical(other.sourceSystem, sourceSystem) || other.sourceSystem == sourceSystem)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.importedAt, importedAt) || other.importedAt == importedAt)&&(identical(other.sourceHash, sourceHash) || other.sourceHash == sourceHash)&&(identical(other.sourceVersion, sourceVersion) || other.sourceVersion == sourceVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sourceSystem,sourceId,importedAt,sourceHash,sourceVersion);

@override
String toString() {
  return 'ImportMetadata(sourceSystem: $sourceSystem, sourceId: $sourceId, importedAt: $importedAt, sourceHash: $sourceHash, sourceVersion: $sourceVersion)';
}


}

/// @nodoc
abstract mixin class $ImportMetadataCopyWith<$Res>  {
  factory $ImportMetadataCopyWith(ImportMetadata value, $Res Function(ImportMetadata) _then) = _$ImportMetadataCopyWithImpl;
@useResult
$Res call({
 String sourceSystem, int sourceId, DateTime importedAt, String? sourceHash, int? sourceVersion
});




}
/// @nodoc
class _$ImportMetadataCopyWithImpl<$Res>
    implements $ImportMetadataCopyWith<$Res> {
  _$ImportMetadataCopyWithImpl(this._self, this._then);

  final ImportMetadata _self;
  final $Res Function(ImportMetadata) _then;

/// Create a copy of ImportMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sourceSystem = null,Object? sourceId = null,Object? importedAt = null,Object? sourceHash = freezed,Object? sourceVersion = freezed,}) {
  return _then(_self.copyWith(
sourceSystem: null == sourceSystem ? _self.sourceSystem : sourceSystem // ignore: cast_nullable_to_non_nullable
as String,sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as int,importedAt: null == importedAt ? _self.importedAt : importedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sourceHash: freezed == sourceHash ? _self.sourceHash : sourceHash // ignore: cast_nullable_to_non_nullable
as String?,sourceVersion: freezed == sourceVersion ? _self.sourceVersion : sourceVersion // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ImportMetadata].
extension ImportMetadataPatterns on ImportMetadata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImportMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImportMetadata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImportMetadata value)  $default,){
final _that = this;
switch (_that) {
case _ImportMetadata():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImportMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _ImportMetadata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sourceSystem,  int sourceId,  DateTime importedAt,  String? sourceHash,  int? sourceVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImportMetadata() when $default != null:
return $default(_that.sourceSystem,_that.sourceId,_that.importedAt,_that.sourceHash,_that.sourceVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sourceSystem,  int sourceId,  DateTime importedAt,  String? sourceHash,  int? sourceVersion)  $default,) {final _that = this;
switch (_that) {
case _ImportMetadata():
return $default(_that.sourceSystem,_that.sourceId,_that.importedAt,_that.sourceHash,_that.sourceVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sourceSystem,  int sourceId,  DateTime importedAt,  String? sourceHash,  int? sourceVersion)?  $default,) {final _that = this;
switch (_that) {
case _ImportMetadata() when $default != null:
return $default(_that.sourceSystem,_that.sourceId,_that.importedAt,_that.sourceHash,_that.sourceVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImportMetadata implements ImportMetadata {
  const _ImportMetadata({required this.sourceSystem, required this.sourceId, required this.importedAt, this.sourceHash, this.sourceVersion});
  factory _ImportMetadata.fromJson(Map<String, dynamic> json) => _$ImportMetadataFromJson(json);

@override final  String sourceSystem;
@override final  int sourceId;
@override final  DateTime importedAt;
@override final  String? sourceHash;
@override final  int? sourceVersion;

/// Create a copy of ImportMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImportMetadataCopyWith<_ImportMetadata> get copyWith => __$ImportMetadataCopyWithImpl<_ImportMetadata>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImportMetadataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImportMetadata&&(identical(other.sourceSystem, sourceSystem) || other.sourceSystem == sourceSystem)&&(identical(other.sourceId, sourceId) || other.sourceId == sourceId)&&(identical(other.importedAt, importedAt) || other.importedAt == importedAt)&&(identical(other.sourceHash, sourceHash) || other.sourceHash == sourceHash)&&(identical(other.sourceVersion, sourceVersion) || other.sourceVersion == sourceVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sourceSystem,sourceId,importedAt,sourceHash,sourceVersion);

@override
String toString() {
  return 'ImportMetadata(sourceSystem: $sourceSystem, sourceId: $sourceId, importedAt: $importedAt, sourceHash: $sourceHash, sourceVersion: $sourceVersion)';
}


}

/// @nodoc
abstract mixin class _$ImportMetadataCopyWith<$Res> implements $ImportMetadataCopyWith<$Res> {
  factory _$ImportMetadataCopyWith(_ImportMetadata value, $Res Function(_ImportMetadata) _then) = __$ImportMetadataCopyWithImpl;
@override @useResult
$Res call({
 String sourceSystem, int sourceId, DateTime importedAt, String? sourceHash, int? sourceVersion
});




}
/// @nodoc
class __$ImportMetadataCopyWithImpl<$Res>
    implements _$ImportMetadataCopyWith<$Res> {
  __$ImportMetadataCopyWithImpl(this._self, this._then);

  final _ImportMetadata _self;
  final $Res Function(_ImportMetadata) _then;

/// Create a copy of ImportMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sourceSystem = null,Object? sourceId = null,Object? importedAt = null,Object? sourceHash = freezed,Object? sourceVersion = freezed,}) {
  return _then(_ImportMetadata(
sourceSystem: null == sourceSystem ? _self.sourceSystem : sourceSystem // ignore: cast_nullable_to_non_nullable
as String,sourceId: null == sourceId ? _self.sourceId : sourceId // ignore: cast_nullable_to_non_nullable
as int,importedAt: null == importedAt ? _self.importedAt : importedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sourceHash: freezed == sourceHash ? _self.sourceHash : sourceHash // ignore: cast_nullable_to_non_nullable
as String?,sourceVersion: freezed == sourceVersion ? _self.sourceVersion : sourceVersion // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
