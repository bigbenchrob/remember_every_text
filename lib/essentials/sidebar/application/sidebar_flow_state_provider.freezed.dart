// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sidebar_flow_state_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SidebarFlowState implements DiagnosticableTreeMixin {

 TopChatMenuChoice get topMenuChoice; int? get chosenContactId; int? get selectedHandleId; SettingsMenuActionId? get persistentSettingsContext; DateTime? get scrollToDate; SidebarFlowMessageScope get messageScope; SidebarFlowContactProjection get contactProjection;
/// Create a copy of SidebarFlowState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SidebarFlowStateCopyWith<SidebarFlowState> get copyWith => _$SidebarFlowStateCopyWithImpl<SidebarFlowState>(this as SidebarFlowState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'SidebarFlowState'))
    ..add(DiagnosticsProperty('topMenuChoice', topMenuChoice))..add(DiagnosticsProperty('chosenContactId', chosenContactId))..add(DiagnosticsProperty('selectedHandleId', selectedHandleId))..add(DiagnosticsProperty('persistentSettingsContext', persistentSettingsContext))..add(DiagnosticsProperty('scrollToDate', scrollToDate))..add(DiagnosticsProperty('messageScope', messageScope))..add(DiagnosticsProperty('contactProjection', contactProjection));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SidebarFlowState&&(identical(other.topMenuChoice, topMenuChoice) || other.topMenuChoice == topMenuChoice)&&(identical(other.chosenContactId, chosenContactId) || other.chosenContactId == chosenContactId)&&(identical(other.selectedHandleId, selectedHandleId) || other.selectedHandleId == selectedHandleId)&&(identical(other.persistentSettingsContext, persistentSettingsContext) || other.persistentSettingsContext == persistentSettingsContext)&&(identical(other.scrollToDate, scrollToDate) || other.scrollToDate == scrollToDate)&&(identical(other.messageScope, messageScope) || other.messageScope == messageScope)&&(identical(other.contactProjection, contactProjection) || other.contactProjection == contactProjection));
}


@override
int get hashCode => Object.hash(runtimeType,topMenuChoice,chosenContactId,selectedHandleId,persistentSettingsContext,scrollToDate,messageScope,contactProjection);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'SidebarFlowState(topMenuChoice: $topMenuChoice, chosenContactId: $chosenContactId, selectedHandleId: $selectedHandleId, persistentSettingsContext: $persistentSettingsContext, scrollToDate: $scrollToDate, messageScope: $messageScope, contactProjection: $contactProjection)';
}


}

/// @nodoc
abstract mixin class $SidebarFlowStateCopyWith<$Res>  {
  factory $SidebarFlowStateCopyWith(SidebarFlowState value, $Res Function(SidebarFlowState) _then) = _$SidebarFlowStateCopyWithImpl;
@useResult
$Res call({
 TopChatMenuChoice topMenuChoice, int? chosenContactId, int? selectedHandleId, SettingsMenuActionId? persistentSettingsContext, DateTime? scrollToDate, SidebarFlowMessageScope messageScope, SidebarFlowContactProjection contactProjection
});




}
/// @nodoc
class _$SidebarFlowStateCopyWithImpl<$Res>
    implements $SidebarFlowStateCopyWith<$Res> {
  _$SidebarFlowStateCopyWithImpl(this._self, this._then);

  final SidebarFlowState _self;
  final $Res Function(SidebarFlowState) _then;

/// Create a copy of SidebarFlowState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? topMenuChoice = null,Object? chosenContactId = freezed,Object? selectedHandleId = freezed,Object? persistentSettingsContext = freezed,Object? scrollToDate = freezed,Object? messageScope = null,Object? contactProjection = null,}) {
  return _then(_self.copyWith(
topMenuChoice: null == topMenuChoice ? _self.topMenuChoice : topMenuChoice // ignore: cast_nullable_to_non_nullable
as TopChatMenuChoice,chosenContactId: freezed == chosenContactId ? _self.chosenContactId : chosenContactId // ignore: cast_nullable_to_non_nullable
as int?,selectedHandleId: freezed == selectedHandleId ? _self.selectedHandleId : selectedHandleId // ignore: cast_nullable_to_non_nullable
as int?,persistentSettingsContext: freezed == persistentSettingsContext ? _self.persistentSettingsContext : persistentSettingsContext // ignore: cast_nullable_to_non_nullable
as SettingsMenuActionId?,scrollToDate: freezed == scrollToDate ? _self.scrollToDate : scrollToDate // ignore: cast_nullable_to_non_nullable
as DateTime?,messageScope: null == messageScope ? _self.messageScope : messageScope // ignore: cast_nullable_to_non_nullable
as SidebarFlowMessageScope,contactProjection: null == contactProjection ? _self.contactProjection : contactProjection // ignore: cast_nullable_to_non_nullable
as SidebarFlowContactProjection,
  ));
}

}


/// Adds pattern-matching-related methods to [SidebarFlowState].
extension SidebarFlowStatePatterns on SidebarFlowState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SidebarFlowState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SidebarFlowState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SidebarFlowState value)  $default,){
final _that = this;
switch (_that) {
case _SidebarFlowState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SidebarFlowState value)?  $default,){
final _that = this;
switch (_that) {
case _SidebarFlowState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TopChatMenuChoice topMenuChoice,  int? chosenContactId,  int? selectedHandleId,  SettingsMenuActionId? persistentSettingsContext,  DateTime? scrollToDate,  SidebarFlowMessageScope messageScope,  SidebarFlowContactProjection contactProjection)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SidebarFlowState() when $default != null:
return $default(_that.topMenuChoice,_that.chosenContactId,_that.selectedHandleId,_that.persistentSettingsContext,_that.scrollToDate,_that.messageScope,_that.contactProjection);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TopChatMenuChoice topMenuChoice,  int? chosenContactId,  int? selectedHandleId,  SettingsMenuActionId? persistentSettingsContext,  DateTime? scrollToDate,  SidebarFlowMessageScope messageScope,  SidebarFlowContactProjection contactProjection)  $default,) {final _that = this;
switch (_that) {
case _SidebarFlowState():
return $default(_that.topMenuChoice,_that.chosenContactId,_that.selectedHandleId,_that.persistentSettingsContext,_that.scrollToDate,_that.messageScope,_that.contactProjection);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TopChatMenuChoice topMenuChoice,  int? chosenContactId,  int? selectedHandleId,  SettingsMenuActionId? persistentSettingsContext,  DateTime? scrollToDate,  SidebarFlowMessageScope messageScope,  SidebarFlowContactProjection contactProjection)?  $default,) {final _that = this;
switch (_that) {
case _SidebarFlowState() when $default != null:
return $default(_that.topMenuChoice,_that.chosenContactId,_that.selectedHandleId,_that.persistentSettingsContext,_that.scrollToDate,_that.messageScope,_that.contactProjection);case _:
  return null;

}
}

}

/// @nodoc


class _SidebarFlowState extends SidebarFlowState with DiagnosticableTreeMixin {
  const _SidebarFlowState({this.topMenuChoice = TopChatMenuChoice.contacts, this.chosenContactId, this.selectedHandleId, this.persistentSettingsContext, this.scrollToDate, this.messageScope = SidebarFlowMessageScope.regular, this.contactProjection = SidebarFlowContactProjection.allMessages}): super._();
  

@override@JsonKey() final  TopChatMenuChoice topMenuChoice;
@override final  int? chosenContactId;
@override final  int? selectedHandleId;
@override final  SettingsMenuActionId? persistentSettingsContext;
@override final  DateTime? scrollToDate;
@override@JsonKey() final  SidebarFlowMessageScope messageScope;
@override@JsonKey() final  SidebarFlowContactProjection contactProjection;

/// Create a copy of SidebarFlowState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SidebarFlowStateCopyWith<_SidebarFlowState> get copyWith => __$SidebarFlowStateCopyWithImpl<_SidebarFlowState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'SidebarFlowState'))
    ..add(DiagnosticsProperty('topMenuChoice', topMenuChoice))..add(DiagnosticsProperty('chosenContactId', chosenContactId))..add(DiagnosticsProperty('selectedHandleId', selectedHandleId))..add(DiagnosticsProperty('persistentSettingsContext', persistentSettingsContext))..add(DiagnosticsProperty('scrollToDate', scrollToDate))..add(DiagnosticsProperty('messageScope', messageScope))..add(DiagnosticsProperty('contactProjection', contactProjection));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SidebarFlowState&&(identical(other.topMenuChoice, topMenuChoice) || other.topMenuChoice == topMenuChoice)&&(identical(other.chosenContactId, chosenContactId) || other.chosenContactId == chosenContactId)&&(identical(other.selectedHandleId, selectedHandleId) || other.selectedHandleId == selectedHandleId)&&(identical(other.persistentSettingsContext, persistentSettingsContext) || other.persistentSettingsContext == persistentSettingsContext)&&(identical(other.scrollToDate, scrollToDate) || other.scrollToDate == scrollToDate)&&(identical(other.messageScope, messageScope) || other.messageScope == messageScope)&&(identical(other.contactProjection, contactProjection) || other.contactProjection == contactProjection));
}


@override
int get hashCode => Object.hash(runtimeType,topMenuChoice,chosenContactId,selectedHandleId,persistentSettingsContext,scrollToDate,messageScope,contactProjection);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'SidebarFlowState(topMenuChoice: $topMenuChoice, chosenContactId: $chosenContactId, selectedHandleId: $selectedHandleId, persistentSettingsContext: $persistentSettingsContext, scrollToDate: $scrollToDate, messageScope: $messageScope, contactProjection: $contactProjection)';
}


}

/// @nodoc
abstract mixin class _$SidebarFlowStateCopyWith<$Res> implements $SidebarFlowStateCopyWith<$Res> {
  factory _$SidebarFlowStateCopyWith(_SidebarFlowState value, $Res Function(_SidebarFlowState) _then) = __$SidebarFlowStateCopyWithImpl;
@override @useResult
$Res call({
 TopChatMenuChoice topMenuChoice, int? chosenContactId, int? selectedHandleId, SettingsMenuActionId? persistentSettingsContext, DateTime? scrollToDate, SidebarFlowMessageScope messageScope, SidebarFlowContactProjection contactProjection
});




}
/// @nodoc
class __$SidebarFlowStateCopyWithImpl<$Res>
    implements _$SidebarFlowStateCopyWith<$Res> {
  __$SidebarFlowStateCopyWithImpl(this._self, this._then);

  final _SidebarFlowState _self;
  final $Res Function(_SidebarFlowState) _then;

/// Create a copy of SidebarFlowState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? topMenuChoice = null,Object? chosenContactId = freezed,Object? selectedHandleId = freezed,Object? persistentSettingsContext = freezed,Object? scrollToDate = freezed,Object? messageScope = null,Object? contactProjection = null,}) {
  return _then(_SidebarFlowState(
topMenuChoice: null == topMenuChoice ? _self.topMenuChoice : topMenuChoice // ignore: cast_nullable_to_non_nullable
as TopChatMenuChoice,chosenContactId: freezed == chosenContactId ? _self.chosenContactId : chosenContactId // ignore: cast_nullable_to_non_nullable
as int?,selectedHandleId: freezed == selectedHandleId ? _self.selectedHandleId : selectedHandleId // ignore: cast_nullable_to_non_nullable
as int?,persistentSettingsContext: freezed == persistentSettingsContext ? _self.persistentSettingsContext : persistentSettingsContext // ignore: cast_nullable_to_non_nullable
as SettingsMenuActionId?,scrollToDate: freezed == scrollToDate ? _self.scrollToDate : scrollToDate // ignore: cast_nullable_to_non_nullable
as DateTime?,messageScope: null == messageScope ? _self.messageScope : messageScope // ignore: cast_nullable_to_non_nullable
as SidebarFlowMessageScope,contactProjection: null == contactProjection ? _self.contactProjection : contactProjection // ignore: cast_nullable_to_non_nullable
as SidebarFlowContactProjection,
  ));
}


}

// dart format on
