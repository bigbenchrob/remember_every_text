// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'view_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ViewSpec {

 Object get spec;



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ViewSpec&&const DeepCollectionEquality().equals(other.spec, spec));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(spec));

@override
String toString() {
  return 'ViewSpec(spec: $spec)';
}


}

/// @nodoc
class $ViewSpecCopyWith<$Res>  {
$ViewSpecCopyWith(ViewSpec _, $Res Function(ViewSpec) __);
}


/// Adds pattern-matching-related methods to [ViewSpec].
extension ViewSpecPatterns on ViewSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ViewMessages value)?  messages,TResult Function( _ViewChats value)?  chats,TResult Function( _ViewContacts value)?  contacts,TResult Function( _ViewImport value)?  import,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ViewMessages() when messages != null:
return messages(_that);case _ViewChats() when chats != null:
return chats(_that);case _ViewContacts() when contacts != null:
return contacts(_that);case _ViewImport() when import != null:
return import(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ViewMessages value)  messages,required TResult Function( _ViewChats value)  chats,required TResult Function( _ViewContacts value)  contacts,required TResult Function( _ViewImport value)  import,}){
final _that = this;
switch (_that) {
case _ViewMessages():
return messages(_that);case _ViewChats():
return chats(_that);case _ViewContacts():
return contacts(_that);case _ViewImport():
return import(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ViewMessages value)?  messages,TResult? Function( _ViewChats value)?  chats,TResult? Function( _ViewContacts value)?  contacts,TResult? Function( _ViewImport value)?  import,}){
final _that = this;
switch (_that) {
case _ViewMessages() when messages != null:
return messages(_that);case _ViewChats() when chats != null:
return chats(_that);case _ViewContacts() when contacts != null:
return contacts(_that);case _ViewImport() when import != null:
return import(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( MessagesSpec spec)?  messages,TResult Function( ChatsSpec spec)?  chats,TResult Function( ContactsSpec spec)?  contacts,TResult Function( ImportSpec spec)?  import,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ViewMessages() when messages != null:
return messages(_that.spec);case _ViewChats() when chats != null:
return chats(_that.spec);case _ViewContacts() when contacts != null:
return contacts(_that.spec);case _ViewImport() when import != null:
return import(_that.spec);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( MessagesSpec spec)  messages,required TResult Function( ChatsSpec spec)  chats,required TResult Function( ContactsSpec spec)  contacts,required TResult Function( ImportSpec spec)  import,}) {final _that = this;
switch (_that) {
case _ViewMessages():
return messages(_that.spec);case _ViewChats():
return chats(_that.spec);case _ViewContacts():
return contacts(_that.spec);case _ViewImport():
return import(_that.spec);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( MessagesSpec spec)?  messages,TResult? Function( ChatsSpec spec)?  chats,TResult? Function( ContactsSpec spec)?  contacts,TResult? Function( ImportSpec spec)?  import,}) {final _that = this;
switch (_that) {
case _ViewMessages() when messages != null:
return messages(_that.spec);case _ViewChats() when chats != null:
return chats(_that.spec);case _ViewContacts() when contacts != null:
return contacts(_that.spec);case _ViewImport() when import != null:
return import(_that.spec);case _:
  return null;

}
}

}

/// @nodoc


class _ViewMessages implements ViewSpec {
  const _ViewMessages(this.spec);
  

@override final  MessagesSpec spec;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ViewMessagesCopyWith<_ViewMessages> get copyWith => __$ViewMessagesCopyWithImpl<_ViewMessages>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ViewMessages&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'ViewSpec.messages(spec: $spec)';
}


}

/// @nodoc
abstract mixin class _$ViewMessagesCopyWith<$Res> implements $ViewSpecCopyWith<$Res> {
  factory _$ViewMessagesCopyWith(_ViewMessages value, $Res Function(_ViewMessages) _then) = __$ViewMessagesCopyWithImpl;
@useResult
$Res call({
 MessagesSpec spec
});


$MessagesSpecCopyWith<$Res> get spec;

}
/// @nodoc
class __$ViewMessagesCopyWithImpl<$Res>
    implements _$ViewMessagesCopyWith<$Res> {
  __$ViewMessagesCopyWithImpl(this._self, this._then);

  final _ViewMessages _self;
  final $Res Function(_ViewMessages) _then;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? spec = null,}) {
  return _then(_ViewMessages(
null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as MessagesSpec,
  ));
}

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessagesSpecCopyWith<$Res> get spec {
  
  return $MessagesSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}

/// @nodoc


class _ViewChats implements ViewSpec {
  const _ViewChats(this.spec);
  

@override final  ChatsSpec spec;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ViewChatsCopyWith<_ViewChats> get copyWith => __$ViewChatsCopyWithImpl<_ViewChats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ViewChats&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'ViewSpec.chats(spec: $spec)';
}


}

/// @nodoc
abstract mixin class _$ViewChatsCopyWith<$Res> implements $ViewSpecCopyWith<$Res> {
  factory _$ViewChatsCopyWith(_ViewChats value, $Res Function(_ViewChats) _then) = __$ViewChatsCopyWithImpl;
@useResult
$Res call({
 ChatsSpec spec
});


$ChatsSpecCopyWith<$Res> get spec;

}
/// @nodoc
class __$ViewChatsCopyWithImpl<$Res>
    implements _$ViewChatsCopyWith<$Res> {
  __$ViewChatsCopyWithImpl(this._self, this._then);

  final _ViewChats _self;
  final $Res Function(_ViewChats) _then;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? spec = null,}) {
  return _then(_ViewChats(
null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as ChatsSpec,
  ));
}

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ChatsSpecCopyWith<$Res> get spec {
  
  return $ChatsSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}

/// @nodoc


class _ViewContacts implements ViewSpec {
  const _ViewContacts(this.spec);
  

@override final  ContactsSpec spec;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ViewContactsCopyWith<_ViewContacts> get copyWith => __$ViewContactsCopyWithImpl<_ViewContacts>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ViewContacts&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'ViewSpec.contacts(spec: $spec)';
}


}

/// @nodoc
abstract mixin class _$ViewContactsCopyWith<$Res> implements $ViewSpecCopyWith<$Res> {
  factory _$ViewContactsCopyWith(_ViewContacts value, $Res Function(_ViewContacts) _then) = __$ViewContactsCopyWithImpl;
@useResult
$Res call({
 ContactsSpec spec
});


$ContactsSpecCopyWith<$Res> get spec;

}
/// @nodoc
class __$ViewContactsCopyWithImpl<$Res>
    implements _$ViewContactsCopyWith<$Res> {
  __$ViewContactsCopyWithImpl(this._self, this._then);

  final _ViewContacts _self;
  final $Res Function(_ViewContacts) _then;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? spec = null,}) {
  return _then(_ViewContacts(
null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as ContactsSpec,
  ));
}

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ContactsSpecCopyWith<$Res> get spec {
  
  return $ContactsSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}

/// @nodoc


class _ViewImport implements ViewSpec {
  const _ViewImport(this.spec);
  

@override final  ImportSpec spec;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ViewImportCopyWith<_ViewImport> get copyWith => __$ViewImportCopyWithImpl<_ViewImport>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ViewImport&&(identical(other.spec, spec) || other.spec == spec));
}


@override
int get hashCode => Object.hash(runtimeType,spec);

@override
String toString() {
  return 'ViewSpec.import(spec: $spec)';
}


}

/// @nodoc
abstract mixin class _$ViewImportCopyWith<$Res> implements $ViewSpecCopyWith<$Res> {
  factory _$ViewImportCopyWith(_ViewImport value, $Res Function(_ViewImport) _then) = __$ViewImportCopyWithImpl;
@useResult
$Res call({
 ImportSpec spec
});


$ImportSpecCopyWith<$Res> get spec;

}
/// @nodoc
class __$ViewImportCopyWithImpl<$Res>
    implements _$ViewImportCopyWith<$Res> {
  __$ViewImportCopyWithImpl(this._self, this._then);

  final _ViewImport _self;
  final $Res Function(_ViewImport) _then;

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? spec = null,}) {
  return _then(_ViewImport(
null == spec ? _self.spec : spec // ignore: cast_nullable_to_non_nullable
as ImportSpec,
  ));
}

/// Create a copy of ViewSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImportSpecCopyWith<$Res> get spec {
  
  return $ImportSpecCopyWith<$Res>(_self.spec, (value) {
    return _then(_self.copyWith(spec: value));
  });
}
}

// dart format on
