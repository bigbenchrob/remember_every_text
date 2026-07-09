// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversations_view_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConversationsSpec {

 int get conversationId; int? get anchorMessageId;
/// Create a copy of ConversationsSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationsSpecCopyWith<ConversationsSpec> get copyWith => _$ConversationsSpecCopyWithImpl<ConversationsSpec>(this as ConversationsSpec, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationsSpec&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.anchorMessageId, anchorMessageId) || other.anchorMessageId == anchorMessageId));
}


@override
int get hashCode => Object.hash(runtimeType,conversationId,anchorMessageId);

@override
String toString() {
  return 'ConversationsSpec(conversationId: $conversationId, anchorMessageId: $anchorMessageId)';
}


}

/// @nodoc
abstract mixin class $ConversationsSpecCopyWith<$Res>  {
  factory $ConversationsSpecCopyWith(ConversationsSpec value, $Res Function(ConversationsSpec) _then) = _$ConversationsSpecCopyWithImpl;
@useResult
$Res call({
 int conversationId, int anchorMessageId
});




}
/// @nodoc
class _$ConversationsSpecCopyWithImpl<$Res>
    implements $ConversationsSpecCopyWith<$Res> {
  _$ConversationsSpecCopyWithImpl(this._self, this._then);

  final ConversationsSpec _self;
  final $Res Function(ConversationsSpec) _then;

/// Create a copy of ConversationsSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? conversationId = null,Object? anchorMessageId = null,}) {
  return _then(_self.copyWith(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as int,anchorMessageId: null == anchorMessageId ? _self.anchorMessageId! : anchorMessageId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ConversationsSpec].
extension ConversationsSpecPatterns on ConversationsSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _ConversationsConversationMessages value)?  conversationMessages,TResult Function( _ConversationsConversationExcerpt value)?  conversationExcerpt,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConversationsConversationMessages() when conversationMessages != null:
return conversationMessages(_that);case _ConversationsConversationExcerpt() when conversationExcerpt != null:
return conversationExcerpt(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _ConversationsConversationMessages value)  conversationMessages,required TResult Function( _ConversationsConversationExcerpt value)  conversationExcerpt,}){
final _that = this;
switch (_that) {
case _ConversationsConversationMessages():
return conversationMessages(_that);case _ConversationsConversationExcerpt():
return conversationExcerpt(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _ConversationsConversationMessages value)?  conversationMessages,TResult? Function( _ConversationsConversationExcerpt value)?  conversationExcerpt,}){
final _that = this;
switch (_that) {
case _ConversationsConversationMessages() when conversationMessages != null:
return conversationMessages(_that);case _ConversationsConversationExcerpt() when conversationExcerpt != null:
return conversationExcerpt(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int conversationId,  int? anchorMessageId,  String? searchQuery)?  conversationMessages,TResult Function( int conversationId,  int anchorMessageId,  int beforeCount,  int afterCount)?  conversationExcerpt,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConversationsConversationMessages() when conversationMessages != null:
return conversationMessages(_that.conversationId,_that.anchorMessageId,_that.searchQuery);case _ConversationsConversationExcerpt() when conversationExcerpt != null:
return conversationExcerpt(_that.conversationId,_that.anchorMessageId,_that.beforeCount,_that.afterCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int conversationId,  int? anchorMessageId,  String? searchQuery)  conversationMessages,required TResult Function( int conversationId,  int anchorMessageId,  int beforeCount,  int afterCount)  conversationExcerpt,}) {final _that = this;
switch (_that) {
case _ConversationsConversationMessages():
return conversationMessages(_that.conversationId,_that.anchorMessageId,_that.searchQuery);case _ConversationsConversationExcerpt():
return conversationExcerpt(_that.conversationId,_that.anchorMessageId,_that.beforeCount,_that.afterCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int conversationId,  int? anchorMessageId,  String? searchQuery)?  conversationMessages,TResult? Function( int conversationId,  int anchorMessageId,  int beforeCount,  int afterCount)?  conversationExcerpt,}) {final _that = this;
switch (_that) {
case _ConversationsConversationMessages() when conversationMessages != null:
return conversationMessages(_that.conversationId,_that.anchorMessageId,_that.searchQuery);case _ConversationsConversationExcerpt() when conversationExcerpt != null:
return conversationExcerpt(_that.conversationId,_that.anchorMessageId,_that.beforeCount,_that.afterCount);case _:
  return null;

}
}

}

/// @nodoc


class _ConversationsConversationMessages implements ConversationsSpec {
  const _ConversationsConversationMessages({required this.conversationId, this.anchorMessageId, this.searchQuery});
  

@override final  int conversationId;
@override final  int? anchorMessageId;
 final  String? searchQuery;

/// Create a copy of ConversationsSpec
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConversationsConversationMessagesCopyWith<_ConversationsConversationMessages> get copyWith => __$ConversationsConversationMessagesCopyWithImpl<_ConversationsConversationMessages>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConversationsConversationMessages&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.anchorMessageId, anchorMessageId) || other.anchorMessageId == anchorMessageId)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery));
}


@override
int get hashCode => Object.hash(runtimeType,conversationId,anchorMessageId,searchQuery);

@override
String toString() {
  return 'ConversationsSpec.conversationMessages(conversationId: $conversationId, anchorMessageId: $anchorMessageId, searchQuery: $searchQuery)';
}


}

/// @nodoc
abstract mixin class _$ConversationsConversationMessagesCopyWith<$Res> implements $ConversationsSpecCopyWith<$Res> {
  factory _$ConversationsConversationMessagesCopyWith(_ConversationsConversationMessages value, $Res Function(_ConversationsConversationMessages) _then) = __$ConversationsConversationMessagesCopyWithImpl;
@override @useResult
$Res call({
 int conversationId, int? anchorMessageId, String? searchQuery
});




}
/// @nodoc
class __$ConversationsConversationMessagesCopyWithImpl<$Res>
    implements _$ConversationsConversationMessagesCopyWith<$Res> {
  __$ConversationsConversationMessagesCopyWithImpl(this._self, this._then);

  final _ConversationsConversationMessages _self;
  final $Res Function(_ConversationsConversationMessages) _then;

/// Create a copy of ConversationsSpec
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conversationId = null,Object? anchorMessageId = freezed,Object? searchQuery = freezed,}) {
  return _then(_ConversationsConversationMessages(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as int,anchorMessageId: freezed == anchorMessageId ? _self.anchorMessageId : anchorMessageId // ignore: cast_nullable_to_non_nullable
as int?,searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class _ConversationsConversationExcerpt implements ConversationsSpec {
  const _ConversationsConversationExcerpt({required this.conversationId, required this.anchorMessageId, this.beforeCount = 10, this.afterCount = 10});
  

@override final  int conversationId;
@override final  int anchorMessageId;
@JsonKey() final  int beforeCount;
@JsonKey() final  int afterCount;

/// Create a copy of ConversationsSpec
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConversationsConversationExcerptCopyWith<_ConversationsConversationExcerpt> get copyWith => __$ConversationsConversationExcerptCopyWithImpl<_ConversationsConversationExcerpt>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConversationsConversationExcerpt&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.anchorMessageId, anchorMessageId) || other.anchorMessageId == anchorMessageId)&&(identical(other.beforeCount, beforeCount) || other.beforeCount == beforeCount)&&(identical(other.afterCount, afterCount) || other.afterCount == afterCount));
}


@override
int get hashCode => Object.hash(runtimeType,conversationId,anchorMessageId,beforeCount,afterCount);

@override
String toString() {
  return 'ConversationsSpec.conversationExcerpt(conversationId: $conversationId, anchorMessageId: $anchorMessageId, beforeCount: $beforeCount, afterCount: $afterCount)';
}


}

/// @nodoc
abstract mixin class _$ConversationsConversationExcerptCopyWith<$Res> implements $ConversationsSpecCopyWith<$Res> {
  factory _$ConversationsConversationExcerptCopyWith(_ConversationsConversationExcerpt value, $Res Function(_ConversationsConversationExcerpt) _then) = __$ConversationsConversationExcerptCopyWithImpl;
@override @useResult
$Res call({
 int conversationId, int anchorMessageId, int beforeCount, int afterCount
});




}
/// @nodoc
class __$ConversationsConversationExcerptCopyWithImpl<$Res>
    implements _$ConversationsConversationExcerptCopyWith<$Res> {
  __$ConversationsConversationExcerptCopyWithImpl(this._self, this._then);

  final _ConversationsConversationExcerpt _self;
  final $Res Function(_ConversationsConversationExcerpt) _then;

/// Create a copy of ConversationsSpec
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? conversationId = null,Object? anchorMessageId = null,Object? beforeCount = null,Object? afterCount = null,}) {
  return _then(_ConversationsConversationExcerpt(
conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as int,anchorMessageId: null == anchorMessageId ? _self.anchorMessageId : anchorMessageId // ignore: cast_nullable_to_non_nullable
as int,beforeCount: null == beforeCount ? _self.beforeCount : beforeCount // ignore: cast_nullable_to_non_nullable
as int,afterCount: null == afterCount ? _self.afterCount : afterCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
