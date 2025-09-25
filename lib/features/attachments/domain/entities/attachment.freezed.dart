// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attachment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Attachment {

@AttachmentIdConverter() AttachmentId get id;@MessageIdConverter() MessageId get messageId; String? get filename; String? get mimeType; int? get sizeBytes; int? get width; int? get height; int? get durationMs; String? get uri; AttachmentStatus get status; DateTime? get createdAt; String? get checksum;
/// Create a copy of Attachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttachmentCopyWith<Attachment> get copyWith => _$AttachmentCopyWithImpl<Attachment>(this as Attachment, _$identity);

  /// Serializes this Attachment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Attachment&&(identical(other.id, id) || other.id == id)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.checksum, checksum) || other.checksum == checksum));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,messageId,filename,mimeType,sizeBytes,width,height,durationMs,uri,status,createdAt,checksum);

@override
String toString() {
  return 'Attachment(id: $id, messageId: $messageId, filename: $filename, mimeType: $mimeType, sizeBytes: $sizeBytes, width: $width, height: $height, durationMs: $durationMs, uri: $uri, status: $status, createdAt: $createdAt, checksum: $checksum)';
}


}

/// @nodoc
abstract mixin class $AttachmentCopyWith<$Res>  {
  factory $AttachmentCopyWith(Attachment value, $Res Function(Attachment) _then) = _$AttachmentCopyWithImpl;
@useResult
$Res call({
@AttachmentIdConverter() AttachmentId id,@MessageIdConverter() MessageId messageId, String? filename, String? mimeType, int? sizeBytes, int? width, int? height, int? durationMs, String? uri, AttachmentStatus status, DateTime? createdAt, String? checksum
});


$AttachmentIdCopyWith<$Res> get id;$MessageIdCopyWith<$Res> get messageId;

}
/// @nodoc
class _$AttachmentCopyWithImpl<$Res>
    implements $AttachmentCopyWith<$Res> {
  _$AttachmentCopyWithImpl(this._self, this._then);

  final Attachment _self;
  final $Res Function(Attachment) _then;

/// Create a copy of Attachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? messageId = null,Object? filename = freezed,Object? mimeType = freezed,Object? sizeBytes = freezed,Object? width = freezed,Object? height = freezed,Object? durationMs = freezed,Object? uri = freezed,Object? status = null,Object? createdAt = freezed,Object? checksum = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as AttachmentId,messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as MessageId,filename: freezed == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,uri: freezed == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttachmentStatus,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,checksum: freezed == checksum ? _self.checksum : checksum // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Attachment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttachmentIdCopyWith<$Res> get id {
  
  return $AttachmentIdCopyWith<$Res>(_self.id, (value) {
    return _then(_self.copyWith(id: value));
  });
}/// Create a copy of Attachment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageIdCopyWith<$Res> get messageId {
  
  return $MessageIdCopyWith<$Res>(_self.messageId, (value) {
    return _then(_self.copyWith(messageId: value));
  });
}
}


/// Adds pattern-matching-related methods to [Attachment].
extension AttachmentPatterns on Attachment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Attachment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Attachment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Attachment value)  $default,){
final _that = this;
switch (_that) {
case _Attachment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Attachment value)?  $default,){
final _that = this;
switch (_that) {
case _Attachment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@AttachmentIdConverter()  AttachmentId id, @MessageIdConverter()  MessageId messageId,  String? filename,  String? mimeType,  int? sizeBytes,  int? width,  int? height,  int? durationMs,  String? uri,  AttachmentStatus status,  DateTime? createdAt,  String? checksum)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Attachment() when $default != null:
return $default(_that.id,_that.messageId,_that.filename,_that.mimeType,_that.sizeBytes,_that.width,_that.height,_that.durationMs,_that.uri,_that.status,_that.createdAt,_that.checksum);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@AttachmentIdConverter()  AttachmentId id, @MessageIdConverter()  MessageId messageId,  String? filename,  String? mimeType,  int? sizeBytes,  int? width,  int? height,  int? durationMs,  String? uri,  AttachmentStatus status,  DateTime? createdAt,  String? checksum)  $default,) {final _that = this;
switch (_that) {
case _Attachment():
return $default(_that.id,_that.messageId,_that.filename,_that.mimeType,_that.sizeBytes,_that.width,_that.height,_that.durationMs,_that.uri,_that.status,_that.createdAt,_that.checksum);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@AttachmentIdConverter()  AttachmentId id, @MessageIdConverter()  MessageId messageId,  String? filename,  String? mimeType,  int? sizeBytes,  int? width,  int? height,  int? durationMs,  String? uri,  AttachmentStatus status,  DateTime? createdAt,  String? checksum)?  $default,) {final _that = this;
switch (_that) {
case _Attachment() when $default != null:
return $default(_that.id,_that.messageId,_that.filename,_that.mimeType,_that.sizeBytes,_that.width,_that.height,_that.durationMs,_that.uri,_that.status,_that.createdAt,_that.checksum);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Attachment extends Attachment {
  const _Attachment({@AttachmentIdConverter() required this.id, @MessageIdConverter() required this.messageId, this.filename, this.mimeType, this.sizeBytes, this.width, this.height, this.durationMs, this.uri, this.status = AttachmentStatus.available, this.createdAt, this.checksum}): super._();
  factory _Attachment.fromJson(Map<String, dynamic> json) => _$AttachmentFromJson(json);

@override@AttachmentIdConverter() final  AttachmentId id;
@override@MessageIdConverter() final  MessageId messageId;
@override final  String? filename;
@override final  String? mimeType;
@override final  int? sizeBytes;
@override final  int? width;
@override final  int? height;
@override final  int? durationMs;
@override final  String? uri;
@override@JsonKey() final  AttachmentStatus status;
@override final  DateTime? createdAt;
@override final  String? checksum;

/// Create a copy of Attachment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttachmentCopyWith<_Attachment> get copyWith => __$AttachmentCopyWithImpl<_Attachment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AttachmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Attachment&&(identical(other.id, id) || other.id == id)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.uri, uri) || other.uri == uri)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.checksum, checksum) || other.checksum == checksum));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,messageId,filename,mimeType,sizeBytes,width,height,durationMs,uri,status,createdAt,checksum);

@override
String toString() {
  return 'Attachment(id: $id, messageId: $messageId, filename: $filename, mimeType: $mimeType, sizeBytes: $sizeBytes, width: $width, height: $height, durationMs: $durationMs, uri: $uri, status: $status, createdAt: $createdAt, checksum: $checksum)';
}


}

/// @nodoc
abstract mixin class _$AttachmentCopyWith<$Res> implements $AttachmentCopyWith<$Res> {
  factory _$AttachmentCopyWith(_Attachment value, $Res Function(_Attachment) _then) = __$AttachmentCopyWithImpl;
@override @useResult
$Res call({
@AttachmentIdConverter() AttachmentId id,@MessageIdConverter() MessageId messageId, String? filename, String? mimeType, int? sizeBytes, int? width, int? height, int? durationMs, String? uri, AttachmentStatus status, DateTime? createdAt, String? checksum
});


@override $AttachmentIdCopyWith<$Res> get id;@override $MessageIdCopyWith<$Res> get messageId;

}
/// @nodoc
class __$AttachmentCopyWithImpl<$Res>
    implements _$AttachmentCopyWith<$Res> {
  __$AttachmentCopyWithImpl(this._self, this._then);

  final _Attachment _self;
  final $Res Function(_Attachment) _then;

/// Create a copy of Attachment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? messageId = null,Object? filename = freezed,Object? mimeType = freezed,Object? sizeBytes = freezed,Object? width = freezed,Object? height = freezed,Object? durationMs = freezed,Object? uri = freezed,Object? status = null,Object? createdAt = freezed,Object? checksum = freezed,}) {
  return _then(_Attachment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as AttachmentId,messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as MessageId,filename: freezed == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,sizeBytes: freezed == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,durationMs: freezed == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int?,uri: freezed == uri ? _self.uri : uri // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttachmentStatus,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,checksum: freezed == checksum ? _self.checksum : checksum // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Attachment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttachmentIdCopyWith<$Res> get id {
  
  return $AttachmentIdCopyWith<$Res>(_self.id, (value) {
    return _then(_self.copyWith(id: value));
  });
}/// Create a copy of Attachment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageIdCopyWith<$Res> get messageId {
  
  return $MessageIdCopyWith<$Res>(_self.messageId, (value) {
    return _then(_self.copyWith(messageId: value));
  });
}
}

// dart format on
