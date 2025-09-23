// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contacts_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ContactsSpec {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ContactsSpec);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ContactsSpec()';
}


}

/// @nodoc
class $ContactsSpecCopyWith<$Res>  {
$ContactsSpecCopyWith(ContactsSpec _, $Res Function(ContactsSpec) __);
}


/// Adds pattern-matching-related methods to [ContactsSpec].
extension ContactsSpecPatterns on ContactsSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ContactsList value)?  list,TResult Function( _ContactDetail value)?  detail,TResult Function( _ContactsSearch value)?  search,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ContactsList() when list != null:
return list(_that);case _ContactDetail() when detail != null:
return detail(_that);case _ContactsSearch() when search != null:
return search(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ContactsList value)  list,required TResult Function( _ContactDetail value)  detail,required TResult Function( _ContactsSearch value)  search,}){
final _that = this;
switch (_that) {
case _ContactsList():
return list(_that);case _ContactDetail():
return detail(_that);case _ContactsSearch():
return search(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ContactsList value)?  list,TResult? Function( _ContactDetail value)?  detail,TResult? Function( _ContactsSearch value)?  search,}){
final _that = this;
switch (_that) {
case _ContactsList() when list != null:
return list(_that);case _ContactDetail() when detail != null:
return detail(_that);case _ContactsSearch() when search != null:
return search(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  list,TResult Function( String contactId)?  detail,TResult Function( String query)?  search,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ContactsList() when list != null:
return list();case _ContactDetail() when detail != null:
return detail(_that.contactId);case _ContactsSearch() when search != null:
return search(_that.query);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  list,required TResult Function( String contactId)  detail,required TResult Function( String query)  search,}) {final _that = this;
switch (_that) {
case _ContactsList():
return list();case _ContactDetail():
return detail(_that.contactId);case _ContactsSearch():
return search(_that.query);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  list,TResult? Function( String contactId)?  detail,TResult? Function( String query)?  search,}) {final _that = this;
switch (_that) {
case _ContactsList() when list != null:
return list();case _ContactDetail() when detail != null:
return detail(_that.contactId);case _ContactsSearch() when search != null:
return search(_that.query);case _:
  return null;

}
}

}

/// @nodoc


class _ContactsList implements ContactsSpec {
  const _ContactsList();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactsList);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ContactsSpec.list()';
}


}




/// @nodoc


class _ContactDetail implements ContactsSpec {
  const _ContactDetail({required this.contactId});
  

 final  String contactId;

/// Create a copy of ContactsSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactDetailCopyWith<_ContactDetail> get copyWith => __$ContactDetailCopyWithImpl<_ContactDetail>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactDetail&&(identical(other.contactId, contactId) || other.contactId == contactId));
}


@override
int get hashCode => Object.hash(runtimeType,contactId);

@override
String toString() {
  return 'ContactsSpec.detail(contactId: $contactId)';
}


}

/// @nodoc
abstract mixin class _$ContactDetailCopyWith<$Res> implements $ContactsSpecCopyWith<$Res> {
  factory _$ContactDetailCopyWith(_ContactDetail value, $Res Function(_ContactDetail) _then) = __$ContactDetailCopyWithImpl;
@useResult
$Res call({
 String contactId
});




}
/// @nodoc
class __$ContactDetailCopyWithImpl<$Res>
    implements _$ContactDetailCopyWith<$Res> {
  __$ContactDetailCopyWithImpl(this._self, this._then);

  final _ContactDetail _self;
  final $Res Function(_ContactDetail) _then;

/// Create a copy of ContactsSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? contactId = null,}) {
  return _then(_ContactDetail(
contactId: null == contactId ? _self.contactId : contactId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _ContactsSearch implements ContactsSpec {
  const _ContactsSearch({required this.query});
  

 final  String query;

/// Create a copy of ContactsSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContactsSearchCopyWith<_ContactsSearch> get copyWith => __$ContactsSearchCopyWithImpl<_ContactsSearch>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ContactsSearch&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,query);

@override
String toString() {
  return 'ContactsSpec.search(query: $query)';
}


}

/// @nodoc
abstract mixin class _$ContactsSearchCopyWith<$Res> implements $ContactsSpecCopyWith<$Res> {
  factory _$ContactsSearchCopyWith(_ContactsSearch value, $Res Function(_ContactsSearch) _then) = __$ContactsSearchCopyWithImpl;
@useResult
$Res call({
 String query
});




}
/// @nodoc
class __$ContactsSearchCopyWithImpl<$Res>
    implements _$ContactsSearchCopyWith<$Res> {
  __$ContactsSearchCopyWithImpl(this._self, this._then);

  final _ContactsSearch _self;
  final $Res Function(_ContactsSearch) _then;

/// Create a copy of ContactsSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? query = null,}) {
  return _then(_ContactsSearch(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
