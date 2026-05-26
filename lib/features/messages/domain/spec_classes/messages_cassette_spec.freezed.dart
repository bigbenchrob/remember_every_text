// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'messages_cassette_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MessagesCassetteSpec {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessagesCassetteSpec);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessagesCassetteSpec()';
}


}

/// @nodoc
class $MessagesCassetteSpecCopyWith<$Res>  {
$MessagesCassetteSpecCopyWith(MessagesCassetteSpec _, $Res Function(MessagesCassetteSpec) __);
}


/// Adds pattern-matching-related methods to [MessagesCassetteSpec].
extension MessagesCassetteSpecPatterns on MessagesCassetteSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _MessagesConversationSignaturesSpec value)?  conversationSignatures,TResult Function( _MessagesHeatMapSpec value)?  heatMap,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessagesConversationSignaturesSpec() when conversationSignatures != null:
return conversationSignatures(_that);case _MessagesHeatMapSpec() when heatMap != null:
return heatMap(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _MessagesConversationSignaturesSpec value)  conversationSignatures,required TResult Function( _MessagesHeatMapSpec value)  heatMap,}){
final _that = this;
switch (_that) {
case _MessagesConversationSignaturesSpec():
return conversationSignatures(_that);case _MessagesHeatMapSpec():
return heatMap(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _MessagesConversationSignaturesSpec value)?  conversationSignatures,TResult? Function( _MessagesHeatMapSpec value)?  heatMap,}){
final _that = this;
switch (_that) {
case _MessagesConversationSignaturesSpec() when conversationSignatures != null:
return conversationSignatures(_that);case _MessagesHeatMapSpec() when heatMap != null:
return heatMap(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  conversationSignatures,TResult Function( int? contactId)?  heatMap,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessagesConversationSignaturesSpec() when conversationSignatures != null:
return conversationSignatures();case _MessagesHeatMapSpec() when heatMap != null:
return heatMap(_that.contactId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  conversationSignatures,required TResult Function( int? contactId)  heatMap,}) {final _that = this;
switch (_that) {
case _MessagesConversationSignaturesSpec():
return conversationSignatures();case _MessagesHeatMapSpec():
return heatMap(_that.contactId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  conversationSignatures,TResult? Function( int? contactId)?  heatMap,}) {final _that = this;
switch (_that) {
case _MessagesConversationSignaturesSpec() when conversationSignatures != null:
return conversationSignatures();case _MessagesHeatMapSpec() when heatMap != null:
return heatMap(_that.contactId);case _:
  return null;

}
}

}

/// @nodoc


class _MessagesConversationSignaturesSpec implements MessagesCassetteSpec {
  const _MessagesConversationSignaturesSpec();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessagesConversationSignaturesSpec);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessagesCassetteSpec.conversationSignatures()';
}


}




/// @nodoc


class _MessagesHeatMapSpec implements MessagesCassetteSpec {
  const _MessagesHeatMapSpec({this.contactId});
  

 final  int? contactId;

/// Create a copy of MessagesCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessagesHeatMapSpecCopyWith<_MessagesHeatMapSpec> get copyWith => __$MessagesHeatMapSpecCopyWithImpl<_MessagesHeatMapSpec>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessagesHeatMapSpec&&(identical(other.contactId, contactId) || other.contactId == contactId));
}


@override
int get hashCode => Object.hash(runtimeType,contactId);

@override
String toString() {
  return 'MessagesCassetteSpec.heatMap(contactId: $contactId)';
}


}

/// @nodoc
abstract mixin class _$MessagesHeatMapSpecCopyWith<$Res> implements $MessagesCassetteSpecCopyWith<$Res> {
  factory _$MessagesHeatMapSpecCopyWith(_MessagesHeatMapSpec value, $Res Function(_MessagesHeatMapSpec) _then) = __$MessagesHeatMapSpecCopyWithImpl;
@useResult
$Res call({
 int? contactId
});




}
/// @nodoc
class __$MessagesHeatMapSpecCopyWithImpl<$Res>
    implements _$MessagesHeatMapSpecCopyWith<$Res> {
  __$MessagesHeatMapSpecCopyWithImpl(this._self, this._then);

  final _MessagesHeatMapSpec _self;
  final $Res Function(_MessagesHeatMapSpec) _then;

/// Create a copy of MessagesCassetteSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? contactId = freezed,}) {
  return _then(_MessagesHeatMapSpec(
contactId: freezed == contactId ? _self.contactId : contactId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
