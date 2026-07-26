// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'messages_view_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MessagesSpec {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessagesSpec);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessagesSpec()';
}


}

/// @nodoc
class $MessagesSpecCopyWith<$Res>  {
$MessagesSpecCopyWith(MessagesSpec _, $Res Function(MessagesSpec) __);
}


/// Adds pattern-matching-related methods to [MessagesSpec].
extension MessagesSpecPatterns on MessagesSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _MessagesForContact value)?  forContact,TResult Function( _MessagesGlobalTimeline value)?  globalTimeline,TResult Function( _MessagesForHandle value)?  forHandle,TResult Function( _RecoveredUnlinkedMessages value)?  recoveredUnlinkedMessages,TResult Function( _RecoveredNoHandleFromMeMessages value)?  recoveredNoHandleFromMeMessages,TResult Function( _RecoveredAttachmentViewer value)?  recoveredAttachmentViewer,TResult Function( _MessagesHandleInvestigation value)?  handleInvestigation,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessagesForContact() when forContact != null:
return forContact(_that);case _MessagesGlobalTimeline() when globalTimeline != null:
return globalTimeline(_that);case _MessagesForHandle() when forHandle != null:
return forHandle(_that);case _RecoveredUnlinkedMessages() when recoveredUnlinkedMessages != null:
return recoveredUnlinkedMessages(_that);case _RecoveredNoHandleFromMeMessages() when recoveredNoHandleFromMeMessages != null:
return recoveredNoHandleFromMeMessages(_that);case _RecoveredAttachmentViewer() when recoveredAttachmentViewer != null:
return recoveredAttachmentViewer(_that);case _MessagesHandleInvestigation() when handleInvestigation != null:
return handleInvestigation(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _MessagesForContact value)  forContact,required TResult Function( _MessagesGlobalTimeline value)  globalTimeline,required TResult Function( _MessagesForHandle value)  forHandle,required TResult Function( _RecoveredUnlinkedMessages value)  recoveredUnlinkedMessages,required TResult Function( _RecoveredNoHandleFromMeMessages value)  recoveredNoHandleFromMeMessages,required TResult Function( _RecoveredAttachmentViewer value)  recoveredAttachmentViewer,required TResult Function( _MessagesHandleInvestigation value)  handleInvestigation,}){
final _that = this;
switch (_that) {
case _MessagesForContact():
return forContact(_that);case _MessagesGlobalTimeline():
return globalTimeline(_that);case _MessagesForHandle():
return forHandle(_that);case _RecoveredUnlinkedMessages():
return recoveredUnlinkedMessages(_that);case _RecoveredNoHandleFromMeMessages():
return recoveredNoHandleFromMeMessages(_that);case _RecoveredAttachmentViewer():
return recoveredAttachmentViewer(_that);case _MessagesHandleInvestigation():
return handleInvestigation(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _MessagesForContact value)?  forContact,TResult? Function( _MessagesGlobalTimeline value)?  globalTimeline,TResult? Function( _MessagesForHandle value)?  forHandle,TResult? Function( _RecoveredUnlinkedMessages value)?  recoveredUnlinkedMessages,TResult? Function( _RecoveredNoHandleFromMeMessages value)?  recoveredNoHandleFromMeMessages,TResult? Function( _RecoveredAttachmentViewer value)?  recoveredAttachmentViewer,TResult? Function( _MessagesHandleInvestigation value)?  handleInvestigation,}){
final _that = this;
switch (_that) {
case _MessagesForContact() when forContact != null:
return forContact(_that);case _MessagesGlobalTimeline() when globalTimeline != null:
return globalTimeline(_that);case _MessagesForHandle() when forHandle != null:
return forHandle(_that);case _RecoveredUnlinkedMessages() when recoveredUnlinkedMessages != null:
return recoveredUnlinkedMessages(_that);case _RecoveredNoHandleFromMeMessages() when recoveredNoHandleFromMeMessages != null:
return recoveredNoHandleFromMeMessages(_that);case _RecoveredAttachmentViewer() when recoveredAttachmentViewer != null:
return recoveredAttachmentViewer(_that);case _MessagesHandleInvestigation() when handleInvestigation != null:
return handleInvestigation(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int contactId,  DateTime? scrollToDate,  int? filterHandleId)?  forContact,TResult Function( DateTime? scrollToDate)?  globalTimeline,TResult Function( int handleId)?  forHandle,TResult Function( int? contactId,  DateTime? scrollToDate)?  recoveredUnlinkedMessages,TResult Function( DateTime? scrollToDate)?  recoveredNoHandleFromMeMessages,TResult Function( int messageId,  AttachmentInfo attachment)?  recoveredAttachmentViewer,TResult Function( StrayHandleInvestigationId investigationId,  StrayHandleInvestigation investigation,  HandleInvestigationTarget target)?  handleInvestigation,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessagesForContact() when forContact != null:
return forContact(_that.contactId,_that.scrollToDate,_that.filterHandleId);case _MessagesGlobalTimeline() when globalTimeline != null:
return globalTimeline(_that.scrollToDate);case _MessagesForHandle() when forHandle != null:
return forHandle(_that.handleId);case _RecoveredUnlinkedMessages() when recoveredUnlinkedMessages != null:
return recoveredUnlinkedMessages(_that.contactId,_that.scrollToDate);case _RecoveredNoHandleFromMeMessages() when recoveredNoHandleFromMeMessages != null:
return recoveredNoHandleFromMeMessages(_that.scrollToDate);case _RecoveredAttachmentViewer() when recoveredAttachmentViewer != null:
return recoveredAttachmentViewer(_that.messageId,_that.attachment);case _MessagesHandleInvestigation() when handleInvestigation != null:
return handleInvestigation(_that.investigationId,_that.investigation,_that.target);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int contactId,  DateTime? scrollToDate,  int? filterHandleId)  forContact,required TResult Function( DateTime? scrollToDate)  globalTimeline,required TResult Function( int handleId)  forHandle,required TResult Function( int? contactId,  DateTime? scrollToDate)  recoveredUnlinkedMessages,required TResult Function( DateTime? scrollToDate)  recoveredNoHandleFromMeMessages,required TResult Function( int messageId,  AttachmentInfo attachment)  recoveredAttachmentViewer,required TResult Function( StrayHandleInvestigationId investigationId,  StrayHandleInvestigation investigation,  HandleInvestigationTarget target)  handleInvestigation,}) {final _that = this;
switch (_that) {
case _MessagesForContact():
return forContact(_that.contactId,_that.scrollToDate,_that.filterHandleId);case _MessagesGlobalTimeline():
return globalTimeline(_that.scrollToDate);case _MessagesForHandle():
return forHandle(_that.handleId);case _RecoveredUnlinkedMessages():
return recoveredUnlinkedMessages(_that.contactId,_that.scrollToDate);case _RecoveredNoHandleFromMeMessages():
return recoveredNoHandleFromMeMessages(_that.scrollToDate);case _RecoveredAttachmentViewer():
return recoveredAttachmentViewer(_that.messageId,_that.attachment);case _MessagesHandleInvestigation():
return handleInvestigation(_that.investigationId,_that.investigation,_that.target);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int contactId,  DateTime? scrollToDate,  int? filterHandleId)?  forContact,TResult? Function( DateTime? scrollToDate)?  globalTimeline,TResult? Function( int handleId)?  forHandle,TResult? Function( int? contactId,  DateTime? scrollToDate)?  recoveredUnlinkedMessages,TResult? Function( DateTime? scrollToDate)?  recoveredNoHandleFromMeMessages,TResult? Function( int messageId,  AttachmentInfo attachment)?  recoveredAttachmentViewer,TResult? Function( StrayHandleInvestigationId investigationId,  StrayHandleInvestigation investigation,  HandleInvestigationTarget target)?  handleInvestigation,}) {final _that = this;
switch (_that) {
case _MessagesForContact() when forContact != null:
return forContact(_that.contactId,_that.scrollToDate,_that.filterHandleId);case _MessagesGlobalTimeline() when globalTimeline != null:
return globalTimeline(_that.scrollToDate);case _MessagesForHandle() when forHandle != null:
return forHandle(_that.handleId);case _RecoveredUnlinkedMessages() when recoveredUnlinkedMessages != null:
return recoveredUnlinkedMessages(_that.contactId,_that.scrollToDate);case _RecoveredNoHandleFromMeMessages() when recoveredNoHandleFromMeMessages != null:
return recoveredNoHandleFromMeMessages(_that.scrollToDate);case _RecoveredAttachmentViewer() when recoveredAttachmentViewer != null:
return recoveredAttachmentViewer(_that.messageId,_that.attachment);case _MessagesHandleInvestigation() when handleInvestigation != null:
return handleInvestigation(_that.investigationId,_that.investigation,_that.target);case _:
  return null;

}
}

}

/// @nodoc


class _MessagesForContact implements MessagesSpec {
  const _MessagesForContact({required this.contactId, this.scrollToDate, this.filterHandleId});
  

 final  int contactId;
 final  DateTime? scrollToDate;
 final  int? filterHandleId;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessagesForContactCopyWith<_MessagesForContact> get copyWith => __$MessagesForContactCopyWithImpl<_MessagesForContact>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessagesForContact&&(identical(other.contactId, contactId) || other.contactId == contactId)&&(identical(other.scrollToDate, scrollToDate) || other.scrollToDate == scrollToDate)&&(identical(other.filterHandleId, filterHandleId) || other.filterHandleId == filterHandleId));
}


@override
int get hashCode => Object.hash(runtimeType,contactId,scrollToDate,filterHandleId);

@override
String toString() {
  return 'MessagesSpec.forContact(contactId: $contactId, scrollToDate: $scrollToDate, filterHandleId: $filterHandleId)';
}


}

/// @nodoc
abstract mixin class _$MessagesForContactCopyWith<$Res> implements $MessagesSpecCopyWith<$Res> {
  factory _$MessagesForContactCopyWith(_MessagesForContact value, $Res Function(_MessagesForContact) _then) = __$MessagesForContactCopyWithImpl;
@useResult
$Res call({
 int contactId, DateTime? scrollToDate, int? filterHandleId
});




}
/// @nodoc
class __$MessagesForContactCopyWithImpl<$Res>
    implements _$MessagesForContactCopyWith<$Res> {
  __$MessagesForContactCopyWithImpl(this._self, this._then);

  final _MessagesForContact _self;
  final $Res Function(_MessagesForContact) _then;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? contactId = null,Object? scrollToDate = freezed,Object? filterHandleId = freezed,}) {
  return _then(_MessagesForContact(
contactId: null == contactId ? _self.contactId : contactId // ignore: cast_nullable_to_non_nullable
as int,scrollToDate: freezed == scrollToDate ? _self.scrollToDate : scrollToDate // ignore: cast_nullable_to_non_nullable
as DateTime?,filterHandleId: freezed == filterHandleId ? _self.filterHandleId : filterHandleId // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class _MessagesGlobalTimeline implements MessagesSpec {
  const _MessagesGlobalTimeline({this.scrollToDate});
  

 final  DateTime? scrollToDate;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessagesGlobalTimelineCopyWith<_MessagesGlobalTimeline> get copyWith => __$MessagesGlobalTimelineCopyWithImpl<_MessagesGlobalTimeline>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessagesGlobalTimeline&&(identical(other.scrollToDate, scrollToDate) || other.scrollToDate == scrollToDate));
}


@override
int get hashCode => Object.hash(runtimeType,scrollToDate);

@override
String toString() {
  return 'MessagesSpec.globalTimeline(scrollToDate: $scrollToDate)';
}


}

/// @nodoc
abstract mixin class _$MessagesGlobalTimelineCopyWith<$Res> implements $MessagesSpecCopyWith<$Res> {
  factory _$MessagesGlobalTimelineCopyWith(_MessagesGlobalTimeline value, $Res Function(_MessagesGlobalTimeline) _then) = __$MessagesGlobalTimelineCopyWithImpl;
@useResult
$Res call({
 DateTime? scrollToDate
});




}
/// @nodoc
class __$MessagesGlobalTimelineCopyWithImpl<$Res>
    implements _$MessagesGlobalTimelineCopyWith<$Res> {
  __$MessagesGlobalTimelineCopyWithImpl(this._self, this._then);

  final _MessagesGlobalTimeline _self;
  final $Res Function(_MessagesGlobalTimeline) _then;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? scrollToDate = freezed,}) {
  return _then(_MessagesGlobalTimeline(
scrollToDate: freezed == scrollToDate ? _self.scrollToDate : scrollToDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc


class _MessagesForHandle implements MessagesSpec {
  const _MessagesForHandle({required this.handleId});
  

 final  int handleId;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessagesForHandleCopyWith<_MessagesForHandle> get copyWith => __$MessagesForHandleCopyWithImpl<_MessagesForHandle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessagesForHandle&&(identical(other.handleId, handleId) || other.handleId == handleId));
}


@override
int get hashCode => Object.hash(runtimeType,handleId);

@override
String toString() {
  return 'MessagesSpec.forHandle(handleId: $handleId)';
}


}

/// @nodoc
abstract mixin class _$MessagesForHandleCopyWith<$Res> implements $MessagesSpecCopyWith<$Res> {
  factory _$MessagesForHandleCopyWith(_MessagesForHandle value, $Res Function(_MessagesForHandle) _then) = __$MessagesForHandleCopyWithImpl;
@useResult
$Res call({
 int handleId
});




}
/// @nodoc
class __$MessagesForHandleCopyWithImpl<$Res>
    implements _$MessagesForHandleCopyWith<$Res> {
  __$MessagesForHandleCopyWithImpl(this._self, this._then);

  final _MessagesForHandle _self;
  final $Res Function(_MessagesForHandle) _then;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? handleId = null,}) {
  return _then(_MessagesForHandle(
handleId: null == handleId ? _self.handleId : handleId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _RecoveredUnlinkedMessages implements MessagesSpec {
  const _RecoveredUnlinkedMessages({this.contactId, this.scrollToDate});
  

 final  int? contactId;
 final  DateTime? scrollToDate;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecoveredUnlinkedMessagesCopyWith<_RecoveredUnlinkedMessages> get copyWith => __$RecoveredUnlinkedMessagesCopyWithImpl<_RecoveredUnlinkedMessages>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecoveredUnlinkedMessages&&(identical(other.contactId, contactId) || other.contactId == contactId)&&(identical(other.scrollToDate, scrollToDate) || other.scrollToDate == scrollToDate));
}


@override
int get hashCode => Object.hash(runtimeType,contactId,scrollToDate);

@override
String toString() {
  return 'MessagesSpec.recoveredUnlinkedMessages(contactId: $contactId, scrollToDate: $scrollToDate)';
}


}

/// @nodoc
abstract mixin class _$RecoveredUnlinkedMessagesCopyWith<$Res> implements $MessagesSpecCopyWith<$Res> {
  factory _$RecoveredUnlinkedMessagesCopyWith(_RecoveredUnlinkedMessages value, $Res Function(_RecoveredUnlinkedMessages) _then) = __$RecoveredUnlinkedMessagesCopyWithImpl;
@useResult
$Res call({
 int? contactId, DateTime? scrollToDate
});




}
/// @nodoc
class __$RecoveredUnlinkedMessagesCopyWithImpl<$Res>
    implements _$RecoveredUnlinkedMessagesCopyWith<$Res> {
  __$RecoveredUnlinkedMessagesCopyWithImpl(this._self, this._then);

  final _RecoveredUnlinkedMessages _self;
  final $Res Function(_RecoveredUnlinkedMessages) _then;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? contactId = freezed,Object? scrollToDate = freezed,}) {
  return _then(_RecoveredUnlinkedMessages(
contactId: freezed == contactId ? _self.contactId : contactId // ignore: cast_nullable_to_non_nullable
as int?,scrollToDate: freezed == scrollToDate ? _self.scrollToDate : scrollToDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc


class _RecoveredNoHandleFromMeMessages implements MessagesSpec {
  const _RecoveredNoHandleFromMeMessages({this.scrollToDate});
  

 final  DateTime? scrollToDate;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecoveredNoHandleFromMeMessagesCopyWith<_RecoveredNoHandleFromMeMessages> get copyWith => __$RecoveredNoHandleFromMeMessagesCopyWithImpl<_RecoveredNoHandleFromMeMessages>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecoveredNoHandleFromMeMessages&&(identical(other.scrollToDate, scrollToDate) || other.scrollToDate == scrollToDate));
}


@override
int get hashCode => Object.hash(runtimeType,scrollToDate);

@override
String toString() {
  return 'MessagesSpec.recoveredNoHandleFromMeMessages(scrollToDate: $scrollToDate)';
}


}

/// @nodoc
abstract mixin class _$RecoveredNoHandleFromMeMessagesCopyWith<$Res> implements $MessagesSpecCopyWith<$Res> {
  factory _$RecoveredNoHandleFromMeMessagesCopyWith(_RecoveredNoHandleFromMeMessages value, $Res Function(_RecoveredNoHandleFromMeMessages) _then) = __$RecoveredNoHandleFromMeMessagesCopyWithImpl;
@useResult
$Res call({
 DateTime? scrollToDate
});




}
/// @nodoc
class __$RecoveredNoHandleFromMeMessagesCopyWithImpl<$Res>
    implements _$RecoveredNoHandleFromMeMessagesCopyWith<$Res> {
  __$RecoveredNoHandleFromMeMessagesCopyWithImpl(this._self, this._then);

  final _RecoveredNoHandleFromMeMessages _self;
  final $Res Function(_RecoveredNoHandleFromMeMessages) _then;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? scrollToDate = freezed,}) {
  return _then(_RecoveredNoHandleFromMeMessages(
scrollToDate: freezed == scrollToDate ? _self.scrollToDate : scrollToDate // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc


class _RecoveredAttachmentViewer implements MessagesSpec {
  const _RecoveredAttachmentViewer({required this.messageId, required this.attachment});
  

 final  int messageId;
 final  AttachmentInfo attachment;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecoveredAttachmentViewerCopyWith<_RecoveredAttachmentViewer> get copyWith => __$RecoveredAttachmentViewerCopyWithImpl<_RecoveredAttachmentViewer>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecoveredAttachmentViewer&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.attachment, attachment) || other.attachment == attachment));
}


@override
int get hashCode => Object.hash(runtimeType,messageId,attachment);

@override
String toString() {
  return 'MessagesSpec.recoveredAttachmentViewer(messageId: $messageId, attachment: $attachment)';
}


}

/// @nodoc
abstract mixin class _$RecoveredAttachmentViewerCopyWith<$Res> implements $MessagesSpecCopyWith<$Res> {
  factory _$RecoveredAttachmentViewerCopyWith(_RecoveredAttachmentViewer value, $Res Function(_RecoveredAttachmentViewer) _then) = __$RecoveredAttachmentViewerCopyWithImpl;
@useResult
$Res call({
 int messageId, AttachmentInfo attachment
});




}
/// @nodoc
class __$RecoveredAttachmentViewerCopyWithImpl<$Res>
    implements _$RecoveredAttachmentViewerCopyWith<$Res> {
  __$RecoveredAttachmentViewerCopyWithImpl(this._self, this._then);

  final _RecoveredAttachmentViewer _self;
  final $Res Function(_RecoveredAttachmentViewer) _then;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? messageId = null,Object? attachment = null,}) {
  return _then(_RecoveredAttachmentViewer(
messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as int,attachment: null == attachment ? _self.attachment : attachment // ignore: cast_nullable_to_non_nullable
as AttachmentInfo,
  ));
}


}

/// @nodoc


class _MessagesHandleInvestigation implements MessagesSpec {
  const _MessagesHandleInvestigation({required this.investigationId, required this.investigation, required this.target});
  

 final  StrayHandleInvestigationId investigationId;
 final  StrayHandleInvestigation investigation;
 final  HandleInvestigationTarget target;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessagesHandleInvestigationCopyWith<_MessagesHandleInvestigation> get copyWith => __$MessagesHandleInvestigationCopyWithImpl<_MessagesHandleInvestigation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessagesHandleInvestigation&&(identical(other.investigationId, investigationId) || other.investigationId == investigationId)&&(identical(other.investigation, investigation) || other.investigation == investigation)&&(identical(other.target, target) || other.target == target));
}


@override
int get hashCode => Object.hash(runtimeType,investigationId,investigation,target);

@override
String toString() {
  return 'MessagesSpec.handleInvestigation(investigationId: $investigationId, investigation: $investigation, target: $target)';
}


}

/// @nodoc
abstract mixin class _$MessagesHandleInvestigationCopyWith<$Res> implements $MessagesSpecCopyWith<$Res> {
  factory _$MessagesHandleInvestigationCopyWith(_MessagesHandleInvestigation value, $Res Function(_MessagesHandleInvestigation) _then) = __$MessagesHandleInvestigationCopyWithImpl;
@useResult
$Res call({
 StrayHandleInvestigationId investigationId, StrayHandleInvestigation investigation, HandleInvestigationTarget target
});


$HandleInvestigationTargetCopyWith<$Res> get target;

}
/// @nodoc
class __$MessagesHandleInvestigationCopyWithImpl<$Res>
    implements _$MessagesHandleInvestigationCopyWith<$Res> {
  __$MessagesHandleInvestigationCopyWithImpl(this._self, this._then);

  final _MessagesHandleInvestigation _self;
  final $Res Function(_MessagesHandleInvestigation) _then;

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? investigationId = null,Object? investigation = null,Object? target = null,}) {
  return _then(_MessagesHandleInvestigation(
investigationId: null == investigationId ? _self.investigationId : investigationId // ignore: cast_nullable_to_non_nullable
as StrayHandleInvestigationId,investigation: null == investigation ? _self.investigation : investigation // ignore: cast_nullable_to_non_nullable
as StrayHandleInvestigation,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as HandleInvestigationTarget,
  ));
}

/// Create a copy of MessagesSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HandleInvestigationTargetCopyWith<$Res> get target {
  
  return $HandleInvestigationTargetCopyWith<$Res>(_self.target, (value) {
    return _then(_self.copyWith(target: value));
  });
}
}

/// @nodoc
mixin _$HandleInvestigationTarget {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HandleInvestigationTarget);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HandleInvestigationTarget()';
}


}

/// @nodoc
class $HandleInvestigationTargetCopyWith<$Res>  {
$HandleInvestigationTargetCopyWith(HandleInvestigationTarget _, $Res Function(HandleInvestigationTarget) __);
}


/// Adds pattern-matching-related methods to [HandleInvestigationTarget].
extension HandleInvestigationTargetPatterns on HandleInvestigationTarget {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _HandleInvestigationTargetIdle value)?  idle,TResult Function( _HandleInvestigationTargetSelectedSource value)?  selectedSource,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HandleInvestigationTargetIdle() when idle != null:
return idle(_that);case _HandleInvestigationTargetSelectedSource() when selectedSource != null:
return selectedSource(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _HandleInvestigationTargetIdle value)  idle,required TResult Function( _HandleInvestigationTargetSelectedSource value)  selectedSource,}){
final _that = this;
switch (_that) {
case _HandleInvestigationTargetIdle():
return idle(_that);case _HandleInvestigationTargetSelectedSource():
return selectedSource(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _HandleInvestigationTargetIdle value)?  idle,TResult? Function( _HandleInvestigationTargetSelectedSource value)?  selectedSource,}){
final _that = this;
switch (_that) {
case _HandleInvestigationTargetIdle() when idle != null:
return idle(_that);case _HandleInvestigationTargetSelectedSource() when selectedSource != null:
return selectedSource(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function( int handleId)?  selectedSource,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HandleInvestigationTargetIdle() when idle != null:
return idle();case _HandleInvestigationTargetSelectedSource() when selectedSource != null:
return selectedSource(_that.handleId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function( int handleId)  selectedSource,}) {final _that = this;
switch (_that) {
case _HandleInvestigationTargetIdle():
return idle();case _HandleInvestigationTargetSelectedSource():
return selectedSource(_that.handleId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function( int handleId)?  selectedSource,}) {final _that = this;
switch (_that) {
case _HandleInvestigationTargetIdle() when idle != null:
return idle();case _HandleInvestigationTargetSelectedSource() when selectedSource != null:
return selectedSource(_that.handleId);case _:
  return null;

}
}

}

/// @nodoc


class _HandleInvestigationTargetIdle implements HandleInvestigationTarget {
  const _HandleInvestigationTargetIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HandleInvestigationTargetIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HandleInvestigationTarget.idle()';
}


}




/// @nodoc


class _HandleInvestigationTargetSelectedSource implements HandleInvestigationTarget {
  const _HandleInvestigationTargetSelectedSource({required this.handleId});
  

 final  int handleId;

/// Create a copy of HandleInvestigationTarget
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HandleInvestigationTargetSelectedSourceCopyWith<_HandleInvestigationTargetSelectedSource> get copyWith => __$HandleInvestigationTargetSelectedSourceCopyWithImpl<_HandleInvestigationTargetSelectedSource>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HandleInvestigationTargetSelectedSource&&(identical(other.handleId, handleId) || other.handleId == handleId));
}


@override
int get hashCode => Object.hash(runtimeType,handleId);

@override
String toString() {
  return 'HandleInvestigationTarget.selectedSource(handleId: $handleId)';
}


}

/// @nodoc
abstract mixin class _$HandleInvestigationTargetSelectedSourceCopyWith<$Res> implements $HandleInvestigationTargetCopyWith<$Res> {
  factory _$HandleInvestigationTargetSelectedSourceCopyWith(_HandleInvestigationTargetSelectedSource value, $Res Function(_HandleInvestigationTargetSelectedSource) _then) = __$HandleInvestigationTargetSelectedSourceCopyWithImpl;
@useResult
$Res call({
 int handleId
});




}
/// @nodoc
class __$HandleInvestigationTargetSelectedSourceCopyWithImpl<$Res>
    implements _$HandleInvestigationTargetSelectedSourceCopyWith<$Res> {
  __$HandleInvestigationTargetSelectedSourceCopyWithImpl(this._self, this._then);

  final _HandleInvestigationTargetSelectedSource _self;
  final $Res Function(_HandleInvestigationTargetSelectedSource) _then;

/// Create a copy of HandleInvestigationTarget
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? handleId = null,}) {
  return _then(_HandleInvestigationTargetSelectedSource(
handleId: null == handleId ? _self.handleId : handleId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
