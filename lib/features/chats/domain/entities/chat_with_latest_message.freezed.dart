// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_with_latest_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatWithLatestMessage {

 int get chatId; String get chatGuid; String? get chatDisplayName; int? get contactId; String? get contactDisplayName; int get messageCount;// Latest message info
 int? get latestMessageId; String? get latestMessageContent; int get latestMessageTimestamp; bool? get latestMessageIsFromMe; bool? get latestMessageHasAttachments;// Participant info for group chats
 List<String> get participantNames; bool get isGroupChat;
/// Create a copy of ChatWithLatestMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatWithLatestMessageCopyWith<ChatWithLatestMessage> get copyWith => _$ChatWithLatestMessageCopyWithImpl<ChatWithLatestMessage>(this as ChatWithLatestMessage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatWithLatestMessage&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.chatGuid, chatGuid) || other.chatGuid == chatGuid)&&(identical(other.chatDisplayName, chatDisplayName) || other.chatDisplayName == chatDisplayName)&&(identical(other.contactId, contactId) || other.contactId == contactId)&&(identical(other.contactDisplayName, contactDisplayName) || other.contactDisplayName == contactDisplayName)&&(identical(other.messageCount, messageCount) || other.messageCount == messageCount)&&(identical(other.latestMessageId, latestMessageId) || other.latestMessageId == latestMessageId)&&(identical(other.latestMessageContent, latestMessageContent) || other.latestMessageContent == latestMessageContent)&&(identical(other.latestMessageTimestamp, latestMessageTimestamp) || other.latestMessageTimestamp == latestMessageTimestamp)&&(identical(other.latestMessageIsFromMe, latestMessageIsFromMe) || other.latestMessageIsFromMe == latestMessageIsFromMe)&&(identical(other.latestMessageHasAttachments, latestMessageHasAttachments) || other.latestMessageHasAttachments == latestMessageHasAttachments)&&const DeepCollectionEquality().equals(other.participantNames, participantNames)&&(identical(other.isGroupChat, isGroupChat) || other.isGroupChat == isGroupChat));
}


@override
int get hashCode => Object.hash(runtimeType,chatId,chatGuid,chatDisplayName,contactId,contactDisplayName,messageCount,latestMessageId,latestMessageContent,latestMessageTimestamp,latestMessageIsFromMe,latestMessageHasAttachments,const DeepCollectionEquality().hash(participantNames),isGroupChat);

@override
String toString() {
  return 'ChatWithLatestMessage(chatId: $chatId, chatGuid: $chatGuid, chatDisplayName: $chatDisplayName, contactId: $contactId, contactDisplayName: $contactDisplayName, messageCount: $messageCount, latestMessageId: $latestMessageId, latestMessageContent: $latestMessageContent, latestMessageTimestamp: $latestMessageTimestamp, latestMessageIsFromMe: $latestMessageIsFromMe, latestMessageHasAttachments: $latestMessageHasAttachments, participantNames: $participantNames, isGroupChat: $isGroupChat)';
}


}

/// @nodoc
abstract mixin class $ChatWithLatestMessageCopyWith<$Res>  {
  factory $ChatWithLatestMessageCopyWith(ChatWithLatestMessage value, $Res Function(ChatWithLatestMessage) _then) = _$ChatWithLatestMessageCopyWithImpl;
@useResult
$Res call({
 int chatId, String chatGuid, String? chatDisplayName, int? contactId, String? contactDisplayName, int messageCount, int? latestMessageId, String? latestMessageContent, int latestMessageTimestamp, bool? latestMessageIsFromMe, bool? latestMessageHasAttachments, List<String> participantNames, bool isGroupChat
});




}
/// @nodoc
class _$ChatWithLatestMessageCopyWithImpl<$Res>
    implements $ChatWithLatestMessageCopyWith<$Res> {
  _$ChatWithLatestMessageCopyWithImpl(this._self, this._then);

  final ChatWithLatestMessage _self;
  final $Res Function(ChatWithLatestMessage) _then;

/// Create a copy of ChatWithLatestMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chatId = null,Object? chatGuid = null,Object? chatDisplayName = freezed,Object? contactId = freezed,Object? contactDisplayName = freezed,Object? messageCount = null,Object? latestMessageId = freezed,Object? latestMessageContent = freezed,Object? latestMessageTimestamp = null,Object? latestMessageIsFromMe = freezed,Object? latestMessageHasAttachments = freezed,Object? participantNames = null,Object? isGroupChat = null,}) {
  return _then(_self.copyWith(
chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as int,chatGuid: null == chatGuid ? _self.chatGuid : chatGuid // ignore: cast_nullable_to_non_nullable
as String,chatDisplayName: freezed == chatDisplayName ? _self.chatDisplayName : chatDisplayName // ignore: cast_nullable_to_non_nullable
as String?,contactId: freezed == contactId ? _self.contactId : contactId // ignore: cast_nullable_to_non_nullable
as int?,contactDisplayName: freezed == contactDisplayName ? _self.contactDisplayName : contactDisplayName // ignore: cast_nullable_to_non_nullable
as String?,messageCount: null == messageCount ? _self.messageCount : messageCount // ignore: cast_nullable_to_non_nullable
as int,latestMessageId: freezed == latestMessageId ? _self.latestMessageId : latestMessageId // ignore: cast_nullable_to_non_nullable
as int?,latestMessageContent: freezed == latestMessageContent ? _self.latestMessageContent : latestMessageContent // ignore: cast_nullable_to_non_nullable
as String?,latestMessageTimestamp: null == latestMessageTimestamp ? _self.latestMessageTimestamp : latestMessageTimestamp // ignore: cast_nullable_to_non_nullable
as int,latestMessageIsFromMe: freezed == latestMessageIsFromMe ? _self.latestMessageIsFromMe : latestMessageIsFromMe // ignore: cast_nullable_to_non_nullable
as bool?,latestMessageHasAttachments: freezed == latestMessageHasAttachments ? _self.latestMessageHasAttachments : latestMessageHasAttachments // ignore: cast_nullable_to_non_nullable
as bool?,participantNames: null == participantNames ? _self.participantNames : participantNames // ignore: cast_nullable_to_non_nullable
as List<String>,isGroupChat: null == isGroupChat ? _self.isGroupChat : isGroupChat // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatWithLatestMessage].
extension ChatWithLatestMessagePatterns on ChatWithLatestMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatWithLatestMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatWithLatestMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatWithLatestMessage value)  $default,){
final _that = this;
switch (_that) {
case _ChatWithLatestMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatWithLatestMessage value)?  $default,){
final _that = this;
switch (_that) {
case _ChatWithLatestMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int chatId,  String chatGuid,  String? chatDisplayName,  int? contactId,  String? contactDisplayName,  int messageCount,  int? latestMessageId,  String? latestMessageContent,  int latestMessageTimestamp,  bool? latestMessageIsFromMe,  bool? latestMessageHasAttachments,  List<String> participantNames,  bool isGroupChat)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatWithLatestMessage() when $default != null:
return $default(_that.chatId,_that.chatGuid,_that.chatDisplayName,_that.contactId,_that.contactDisplayName,_that.messageCount,_that.latestMessageId,_that.latestMessageContent,_that.latestMessageTimestamp,_that.latestMessageIsFromMe,_that.latestMessageHasAttachments,_that.participantNames,_that.isGroupChat);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int chatId,  String chatGuid,  String? chatDisplayName,  int? contactId,  String? contactDisplayName,  int messageCount,  int? latestMessageId,  String? latestMessageContent,  int latestMessageTimestamp,  bool? latestMessageIsFromMe,  bool? latestMessageHasAttachments,  List<String> participantNames,  bool isGroupChat)  $default,) {final _that = this;
switch (_that) {
case _ChatWithLatestMessage():
return $default(_that.chatId,_that.chatGuid,_that.chatDisplayName,_that.contactId,_that.contactDisplayName,_that.messageCount,_that.latestMessageId,_that.latestMessageContent,_that.latestMessageTimestamp,_that.latestMessageIsFromMe,_that.latestMessageHasAttachments,_that.participantNames,_that.isGroupChat);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int chatId,  String chatGuid,  String? chatDisplayName,  int? contactId,  String? contactDisplayName,  int messageCount,  int? latestMessageId,  String? latestMessageContent,  int latestMessageTimestamp,  bool? latestMessageIsFromMe,  bool? latestMessageHasAttachments,  List<String> participantNames,  bool isGroupChat)?  $default,) {final _that = this;
switch (_that) {
case _ChatWithLatestMessage() when $default != null:
return $default(_that.chatId,_that.chatGuid,_that.chatDisplayName,_that.contactId,_that.contactDisplayName,_that.messageCount,_that.latestMessageId,_that.latestMessageContent,_that.latestMessageTimestamp,_that.latestMessageIsFromMe,_that.latestMessageHasAttachments,_that.participantNames,_that.isGroupChat);case _:
  return null;

}
}

}

/// @nodoc


class _ChatWithLatestMessage extends ChatWithLatestMessage {
  const _ChatWithLatestMessage({required this.chatId, required this.chatGuid, this.chatDisplayName, this.contactId, this.contactDisplayName, required this.messageCount, this.latestMessageId, this.latestMessageContent, required this.latestMessageTimestamp, this.latestMessageIsFromMe, this.latestMessageHasAttachments, required final  List<String> participantNames, required this.isGroupChat}): _participantNames = participantNames,super._();
  

@override final  int chatId;
@override final  String chatGuid;
@override final  String? chatDisplayName;
@override final  int? contactId;
@override final  String? contactDisplayName;
@override final  int messageCount;
// Latest message info
@override final  int? latestMessageId;
@override final  String? latestMessageContent;
@override final  int latestMessageTimestamp;
@override final  bool? latestMessageIsFromMe;
@override final  bool? latestMessageHasAttachments;
// Participant info for group chats
 final  List<String> _participantNames;
// Participant info for group chats
@override List<String> get participantNames {
  if (_participantNames is EqualUnmodifiableListView) return _participantNames;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participantNames);
}

@override final  bool isGroupChat;

/// Create a copy of ChatWithLatestMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatWithLatestMessageCopyWith<_ChatWithLatestMessage> get copyWith => __$ChatWithLatestMessageCopyWithImpl<_ChatWithLatestMessage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatWithLatestMessage&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.chatGuid, chatGuid) || other.chatGuid == chatGuid)&&(identical(other.chatDisplayName, chatDisplayName) || other.chatDisplayName == chatDisplayName)&&(identical(other.contactId, contactId) || other.contactId == contactId)&&(identical(other.contactDisplayName, contactDisplayName) || other.contactDisplayName == contactDisplayName)&&(identical(other.messageCount, messageCount) || other.messageCount == messageCount)&&(identical(other.latestMessageId, latestMessageId) || other.latestMessageId == latestMessageId)&&(identical(other.latestMessageContent, latestMessageContent) || other.latestMessageContent == latestMessageContent)&&(identical(other.latestMessageTimestamp, latestMessageTimestamp) || other.latestMessageTimestamp == latestMessageTimestamp)&&(identical(other.latestMessageIsFromMe, latestMessageIsFromMe) || other.latestMessageIsFromMe == latestMessageIsFromMe)&&(identical(other.latestMessageHasAttachments, latestMessageHasAttachments) || other.latestMessageHasAttachments == latestMessageHasAttachments)&&const DeepCollectionEquality().equals(other._participantNames, _participantNames)&&(identical(other.isGroupChat, isGroupChat) || other.isGroupChat == isGroupChat));
}


@override
int get hashCode => Object.hash(runtimeType,chatId,chatGuid,chatDisplayName,contactId,contactDisplayName,messageCount,latestMessageId,latestMessageContent,latestMessageTimestamp,latestMessageIsFromMe,latestMessageHasAttachments,const DeepCollectionEquality().hash(_participantNames),isGroupChat);

@override
String toString() {
  return 'ChatWithLatestMessage(chatId: $chatId, chatGuid: $chatGuid, chatDisplayName: $chatDisplayName, contactId: $contactId, contactDisplayName: $contactDisplayName, messageCount: $messageCount, latestMessageId: $latestMessageId, latestMessageContent: $latestMessageContent, latestMessageTimestamp: $latestMessageTimestamp, latestMessageIsFromMe: $latestMessageIsFromMe, latestMessageHasAttachments: $latestMessageHasAttachments, participantNames: $participantNames, isGroupChat: $isGroupChat)';
}


}

/// @nodoc
abstract mixin class _$ChatWithLatestMessageCopyWith<$Res> implements $ChatWithLatestMessageCopyWith<$Res> {
  factory _$ChatWithLatestMessageCopyWith(_ChatWithLatestMessage value, $Res Function(_ChatWithLatestMessage) _then) = __$ChatWithLatestMessageCopyWithImpl;
@override @useResult
$Res call({
 int chatId, String chatGuid, String? chatDisplayName, int? contactId, String? contactDisplayName, int messageCount, int? latestMessageId, String? latestMessageContent, int latestMessageTimestamp, bool? latestMessageIsFromMe, bool? latestMessageHasAttachments, List<String> participantNames, bool isGroupChat
});




}
/// @nodoc
class __$ChatWithLatestMessageCopyWithImpl<$Res>
    implements _$ChatWithLatestMessageCopyWith<$Res> {
  __$ChatWithLatestMessageCopyWithImpl(this._self, this._then);

  final _ChatWithLatestMessage _self;
  final $Res Function(_ChatWithLatestMessage) _then;

/// Create a copy of ChatWithLatestMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chatId = null,Object? chatGuid = null,Object? chatDisplayName = freezed,Object? contactId = freezed,Object? contactDisplayName = freezed,Object? messageCount = null,Object? latestMessageId = freezed,Object? latestMessageContent = freezed,Object? latestMessageTimestamp = null,Object? latestMessageIsFromMe = freezed,Object? latestMessageHasAttachments = freezed,Object? participantNames = null,Object? isGroupChat = null,}) {
  return _then(_ChatWithLatestMessage(
chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as int,chatGuid: null == chatGuid ? _self.chatGuid : chatGuid // ignore: cast_nullable_to_non_nullable
as String,chatDisplayName: freezed == chatDisplayName ? _self.chatDisplayName : chatDisplayName // ignore: cast_nullable_to_non_nullable
as String?,contactId: freezed == contactId ? _self.contactId : contactId // ignore: cast_nullable_to_non_nullable
as int?,contactDisplayName: freezed == contactDisplayName ? _self.contactDisplayName : contactDisplayName // ignore: cast_nullable_to_non_nullable
as String?,messageCount: null == messageCount ? _self.messageCount : messageCount // ignore: cast_nullable_to_non_nullable
as int,latestMessageId: freezed == latestMessageId ? _self.latestMessageId : latestMessageId // ignore: cast_nullable_to_non_nullable
as int?,latestMessageContent: freezed == latestMessageContent ? _self.latestMessageContent : latestMessageContent // ignore: cast_nullable_to_non_nullable
as String?,latestMessageTimestamp: null == latestMessageTimestamp ? _self.latestMessageTimestamp : latestMessageTimestamp // ignore: cast_nullable_to_non_nullable
as int,latestMessageIsFromMe: freezed == latestMessageIsFromMe ? _self.latestMessageIsFromMe : latestMessageIsFromMe // ignore: cast_nullable_to_non_nullable
as bool?,latestMessageHasAttachments: freezed == latestMessageHasAttachments ? _self.latestMessageHasAttachments : latestMessageHasAttachments // ignore: cast_nullable_to_non_nullable
as bool?,participantNames: null == participantNames ? _self._participantNames : participantNames // ignore: cast_nullable_to_non_nullable
as List<String>,isGroupChat: null == isGroupChat ? _self.isGroupChat : isGroupChat // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
