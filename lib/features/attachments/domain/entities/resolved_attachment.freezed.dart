// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'resolved_attachment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ResolvedAttachment {

 AttachmentInfo get attachmentInfo; AttachmentStatus get status; AttachmentProvenance? get provenance; File? get resolvedFile;
/// Create a copy of ResolvedAttachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResolvedAttachmentCopyWith<ResolvedAttachment> get copyWith => _$ResolvedAttachmentCopyWithImpl<ResolvedAttachment>(this as ResolvedAttachment, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResolvedAttachment&&(identical(other.attachmentInfo, attachmentInfo) || other.attachmentInfo == attachmentInfo)&&(identical(other.status, status) || other.status == status)&&(identical(other.provenance, provenance) || other.provenance == provenance)&&(identical(other.resolvedFile, resolvedFile) || other.resolvedFile == resolvedFile));
}


@override
int get hashCode => Object.hash(runtimeType,attachmentInfo,status,provenance,resolvedFile);

@override
String toString() {
  return 'ResolvedAttachment(attachmentInfo: $attachmentInfo, status: $status, provenance: $provenance, resolvedFile: $resolvedFile)';
}


}

/// @nodoc
abstract mixin class $ResolvedAttachmentCopyWith<$Res>  {
  factory $ResolvedAttachmentCopyWith(ResolvedAttachment value, $Res Function(ResolvedAttachment) _then) = _$ResolvedAttachmentCopyWithImpl;
@useResult
$Res call({
 AttachmentInfo attachmentInfo, AttachmentStatus status, AttachmentProvenance? provenance, File? resolvedFile
});




}
/// @nodoc
class _$ResolvedAttachmentCopyWithImpl<$Res>
    implements $ResolvedAttachmentCopyWith<$Res> {
  _$ResolvedAttachmentCopyWithImpl(this._self, this._then);

  final ResolvedAttachment _self;
  final $Res Function(ResolvedAttachment) _then;

/// Create a copy of ResolvedAttachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? attachmentInfo = null,Object? status = null,Object? provenance = freezed,Object? resolvedFile = freezed,}) {
  return _then(_self.copyWith(
attachmentInfo: null == attachmentInfo ? _self.attachmentInfo : attachmentInfo // ignore: cast_nullable_to_non_nullable
as AttachmentInfo,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttachmentStatus,provenance: freezed == provenance ? _self.provenance : provenance // ignore: cast_nullable_to_non_nullable
as AttachmentProvenance?,resolvedFile: freezed == resolvedFile ? _self.resolvedFile : resolvedFile // ignore: cast_nullable_to_non_nullable
as File?,
  ));
}

}


/// Adds pattern-matching-related methods to [ResolvedAttachment].
extension ResolvedAttachmentPatterns on ResolvedAttachment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResolvedAttachment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResolvedAttachment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResolvedAttachment value)  $default,){
final _that = this;
switch (_that) {
case _ResolvedAttachment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResolvedAttachment value)?  $default,){
final _that = this;
switch (_that) {
case _ResolvedAttachment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( AttachmentInfo attachmentInfo,  AttachmentStatus status,  AttachmentProvenance? provenance,  File? resolvedFile)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResolvedAttachment() when $default != null:
return $default(_that.attachmentInfo,_that.status,_that.provenance,_that.resolvedFile);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( AttachmentInfo attachmentInfo,  AttachmentStatus status,  AttachmentProvenance? provenance,  File? resolvedFile)  $default,) {final _that = this;
switch (_that) {
case _ResolvedAttachment():
return $default(_that.attachmentInfo,_that.status,_that.provenance,_that.resolvedFile);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( AttachmentInfo attachmentInfo,  AttachmentStatus status,  AttachmentProvenance? provenance,  File? resolvedFile)?  $default,) {final _that = this;
switch (_that) {
case _ResolvedAttachment() when $default != null:
return $default(_that.attachmentInfo,_that.status,_that.provenance,_that.resolvedFile);case _:
  return null;

}
}

}

/// @nodoc


class _ResolvedAttachment extends ResolvedAttachment {
  const _ResolvedAttachment({required this.attachmentInfo, required this.status, this.provenance, this.resolvedFile}): super._();
  

@override final  AttachmentInfo attachmentInfo;
@override final  AttachmentStatus status;
@override final  AttachmentProvenance? provenance;
@override final  File? resolvedFile;

/// Create a copy of ResolvedAttachment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResolvedAttachmentCopyWith<_ResolvedAttachment> get copyWith => __$ResolvedAttachmentCopyWithImpl<_ResolvedAttachment>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResolvedAttachment&&(identical(other.attachmentInfo, attachmentInfo) || other.attachmentInfo == attachmentInfo)&&(identical(other.status, status) || other.status == status)&&(identical(other.provenance, provenance) || other.provenance == provenance)&&(identical(other.resolvedFile, resolvedFile) || other.resolvedFile == resolvedFile));
}


@override
int get hashCode => Object.hash(runtimeType,attachmentInfo,status,provenance,resolvedFile);

@override
String toString() {
  return 'ResolvedAttachment(attachmentInfo: $attachmentInfo, status: $status, provenance: $provenance, resolvedFile: $resolvedFile)';
}


}

/// @nodoc
abstract mixin class _$ResolvedAttachmentCopyWith<$Res> implements $ResolvedAttachmentCopyWith<$Res> {
  factory _$ResolvedAttachmentCopyWith(_ResolvedAttachment value, $Res Function(_ResolvedAttachment) _then) = __$ResolvedAttachmentCopyWithImpl;
@override @useResult
$Res call({
 AttachmentInfo attachmentInfo, AttachmentStatus status, AttachmentProvenance? provenance, File? resolvedFile
});




}
/// @nodoc
class __$ResolvedAttachmentCopyWithImpl<$Res>
    implements _$ResolvedAttachmentCopyWith<$Res> {
  __$ResolvedAttachmentCopyWithImpl(this._self, this._then);

  final _ResolvedAttachment _self;
  final $Res Function(_ResolvedAttachment) _then;

/// Create a copy of ResolvedAttachment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? attachmentInfo = null,Object? status = null,Object? provenance = freezed,Object? resolvedFile = freezed,}) {
  return _then(_ResolvedAttachment(
attachmentInfo: null == attachmentInfo ? _self.attachmentInfo : attachmentInfo // ignore: cast_nullable_to_non_nullable
as AttachmentInfo,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as AttachmentStatus,provenance: freezed == provenance ? _self.provenance : provenance // ignore: cast_nullable_to_non_nullable
as AttachmentProvenance?,resolvedFile: freezed == resolvedFile ? _self.resolvedFile : resolvedFile // ignore: cast_nullable_to_non_nullable
as File?,
  ));
}


}

// dart format on
