import 'package:freezed_annotation/freezed_annotation.dart';

part 'contact_aggregate.freezed.dart';
part 'contact_aggregate.g.dart';

/// Contact Aggregate Root
///
/// Represents a person or entity that can send/receive messages.
/// Manages identity, handles, and contact metadata independent of chat context.
@freezed
abstract class Contact with _$Contact {
  const factory Contact({
    required ContactId id,
    required ContactDisplayName displayName,
    required List<ContactHandle> handles,
    ContactDetails? details,
    ContactPreferences? preferences,
    @Default([]) List<String> tags,
    ImportMetadata? importMetadata,
  }) = _Contact;

  const Contact._();

  factory Contact.fromJson(Map<String, dynamic> json) =>
      _$ContactFromJson(json);

  // Domain behavior methods

  /// Add a handle to the contact
  Contact addHandle(ContactHandle handle) {
    if (handles.any(
      (h) => h.address == handle.address && h.service == handle.service,
    )) {
      throw ContactInvariantViolation('Handle already exists for this contact');
    }

    return copyWith(handles: [...handles, handle]);
  }

  /// Remove a handle from the contact
  Contact removeHandle(HandleId handleId) {
    final newHandles = handles.where((h) => h.id != handleId).toList();

    if (newHandles.isEmpty && displayName.source == DisplayNameSource.handle) {
      throw ContactInvariantViolation(
        'Cannot remove last handle when display name is derived from handle',
      );
    }

    return copyWith(handles: newHandles);
  }

  /// Update display name
  Contact updateDisplayName(ContactDisplayName newDisplayName) {
    return copyWith(displayName: newDisplayName);
  }

  /// Merge with another contact
  Contact mergeWith(Contact other) {
    // Merge handles, avoiding duplicates
    final mergedHandles = [...handles];
    for (final otherHandle in other.handles) {
      if (!handles.any(
        (h) =>
            h.address == otherHandle.address &&
            h.service == otherHandle.service,
      )) {
        mergedHandles.add(otherHandle);
      }
    }

    // Choose best display name
    final bestDisplayName = _chooseBestDisplayName(
      displayName,
      other.displayName,
    );

    // Merge details
    final mergedDetails = details?.mergeWith(other.details) ?? other.details;

    return copyWith(
      displayName: bestDisplayName,
      handles: mergedHandles,
      details: mergedDetails,
    );
  }

  /// Get primary handle (first handle or preferred)
  ContactHandle? get primaryHandle {
    if (handles.isEmpty) {
      return null;
    }

    // Look for preferred handle
    final preferred = handles.where((h) => h.isPreferred).firstOrNull;
    if (preferred != null) {
      return preferred;
    }

    // Return first handle
    return handles.first;
  }

  /// Get handles for specific service
  List<ContactHandle> handlesForService(String service) {
    return handles.where((h) => h.service == service).toList();
  }

  /// Check if contact has any handles
  bool get hasHandles => handles.isNotEmpty;

  /// Get all unique services this contact uses
  Set<String> get services => handles.map((h) => h.service).toSet();

  ContactDisplayName _chooseBestDisplayName(
    ContactDisplayName a,
    ContactDisplayName b,
  ) {
    // Prefer explicit names over derived ones
    if (a.source == DisplayNameSource.explicit &&
        b.source != DisplayNameSource.explicit) {
      return a;
    }
    if (b.source == DisplayNameSource.explicit &&
        a.source != DisplayNameSource.explicit) {
      return b;
    }

    // Prefer contact-derived names over handle-derived ones
    if (a.source == DisplayNameSource.contact &&
        b.source == DisplayNameSource.handle) {
      return a;
    }
    if (b.source == DisplayNameSource.contact &&
        a.source == DisplayNameSource.handle) {
      return b;
    }

    // Prefer longer names (more information)
    return a.value.length >= b.value.length ? a : b;
  }
}

/// Contact unique identifier
@freezed
abstract class ContactId with _$ContactId {
  const factory ContactId(String value) = _ContactId;
  factory ContactId.fromJson(Map<String, dynamic> json) =>
      _$ContactIdFromJson(json);

  factory ContactId.generate() => ContactId(_generateUuid());
}

/// Contact display name with source tracking
@freezed
abstract class ContactDisplayName with _$ContactDisplayName {
  const factory ContactDisplayName({
    required String value,
    required DisplayNameSource source,
    String? firstName,
    String? lastName,
    String? nickname,
    String? company,
  }) = _ContactDisplayName;

  const ContactDisplayName._();

  factory ContactDisplayName.fromJson(Map<String, dynamic> json) =>
      _$ContactDisplayNameFromJson(json);

  factory ContactDisplayName.explicit(String name) {
    if (name.trim().isEmpty) {
      throw ContactValidationError('Display name cannot be empty');
    }

    return ContactDisplayName(
      value: name.trim(),
      source: DisplayNameSource.explicit,
    );
  }

  factory ContactDisplayName.fromParts({
    String? firstName,
    String? lastName,
    String? nickname,
    String? company,
  }) {
    String displayName;

    if (firstName != null || lastName != null) {
      displayName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    } else if (company != null && company.isNotEmpty) {
      displayName = company;
    } else if (nickname != null && nickname.isNotEmpty) {
      displayName = nickname;
    } else {
      throw ContactValidationError(
        'At least one name component must be provided',
      );
    }

    return ContactDisplayName(
      value: displayName,
      source: DisplayNameSource.contact,
      firstName: firstName,
      lastName: lastName,
      nickname: nickname,
      company: company,
    );
  }

  factory ContactDisplayName.fromHandle(String handleAddress) {
    return ContactDisplayName(
      value: handleAddress,
      source: DisplayNameSource.handle,
    );
  }
}

/// Source of display name
enum DisplayNameSource {
  explicit, // User-set name
  contact, // Derived from contact database (first, last, company)
  handle, // Derived from handle/phone/email
  fallback, // System-generated fallback
}

/// Contact handle (phone, email, etc.)
@freezed
abstract class ContactHandle with _$ContactHandle {
  const factory ContactHandle({
    required HandleId id,
    required String address,
    required String service,
    @Default(false) bool isPreferred,
    @Default(false) bool isVerified,
    HandleMetadata? metadata,
  }) = _ContactHandle;

  const ContactHandle._();

  factory ContactHandle.fromJson(Map<String, dynamic> json) =>
      _$ContactHandleFromJson(json);

  factory ContactHandle.phone(String phoneNumber, {bool isPreferred = false}) {
    return ContactHandle(
      id: HandleId.fromServiceAndAddress('phone', phoneNumber),
      address: phoneNumber,
      service: 'phone',
      isPreferred: isPreferred,
    );
  }

  factory ContactHandle.email(String emailAddress, {bool isPreferred = false}) {
    return ContactHandle(
      id: HandleId.fromServiceAndAddress('email', emailAddress),
      address: emailAddress,
      service: 'email',
      isPreferred: isPreferred,
    );
  }

  factory ContactHandle.imessage(String address, {bool isPreferred = false}) {
    return ContactHandle(
      id: HandleId.fromServiceAndAddress('iMessage', address),
      address: address,
      service: 'iMessage',
      isPreferred: isPreferred,
    );
  }

  /// Get formatted display version of address
  String get displayAddress {
    switch (service.toLowerCase()) {
      case 'phone':
        return _formatPhoneNumber(address);
      case 'email':
        return address.toLowerCase();
      default:
        return address;
    }
  }

  /// Check if this is a phone number handle
  bool get isPhone => service.toLowerCase() == 'phone';

  /// Check if this is an email handle
  bool get isEmail => service.toLowerCase() == 'email';

  String _formatPhoneNumber(String phone) {
    // Basic phone number formatting - could be enhanced
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    return phone;
  }
}

/// Handle unique identifier
@freezed
abstract class HandleId with _$HandleId {
  const factory HandleId(String value) = _HandleId;
  factory HandleId.fromJson(Map<String, dynamic> json) =>
      _$HandleIdFromJson(json);

  factory HandleId.fromServiceAndAddress(String service, String address) {
    return HandleId('${service.toLowerCase()}:${address.toLowerCase()}');
  }

  factory HandleId.generate() => HandleId(_generateUuid());
}

/// Handle metadata
@freezed
abstract class HandleMetadata with _$HandleMetadata {
  const factory HandleMetadata({
    String? label, // "Home", "Work", "Mobile", etc.
    DateTime? lastUsed,
    DateTime? verified,
    String? countryCode, // For phone numbers
    String? region, // Geographic region
  }) = _HandleMetadata;

  factory HandleMetadata.fromJson(Map<String, dynamic> json) =>
      _$HandleMetadataFromJson(json);
}

/// Contact details (additional information)
@freezed
abstract class ContactDetails with _$ContactDetails {
  const factory ContactDetails({
    String? organization,
    String? jobTitle,
    String? department,
    ContactAddress? address,
    DateTime? birthday,
    String? notes,
    @Default([]) List<String> categories,
  }) = _ContactDetails;

  factory ContactDetails.fromJson(Map<String, dynamic> json) =>
      _$ContactDetailsFromJson(json);

  /// Merge with other contact details
  ContactDetails mergeWith(ContactDetails? other) {
    if (other == null) {
      return this;
    }

    return copyWith(
      organization: organization ?? other.organization,
      jobTitle: jobTitle ?? other.jobTitle,
      department: department ?? other.department,
      address: address ?? other.address,
      birthday: birthday ?? other.birthday,
      notes: notes ?? other.notes,
      categories: {...categories, ...other.categories}.toList(),
    );
  }
}

/// Contact address
@freezed
abstract class ContactAddress with _$ContactAddress {
  const factory ContactAddress({
    String? street,
    String? city,
    String? state,
    String? postalCode,
    String? country,
  }) = _ContactAddress;

  const ContactAddress._();

  factory ContactAddress.fromJson(Map<String, dynamic> json) =>
      _$ContactAddressFromJson(json);

  /// Get formatted address string
  String get formatted {
    final parts = [
      street,
      city,
      state,
      postalCode,
      country,
    ].where((part) => part != null && part.isNotEmpty).toList();
    return parts.join(', ');
  }
}

/// Contact preferences
@freezed
abstract class ContactPreferences with _$ContactPreferences {
  const factory ContactPreferences({
    @Default(false) bool isFavorite,
    @Default(false) bool isBlocked,
    @Default(true) bool allowNotifications,
    String? customRingtone,
    String? customTextTone,
  }) = _ContactPreferences;

  factory ContactPreferences.fromJson(Map<String, dynamic> json) =>
      _$ContactPreferencesFromJson(json);
}

/// Import metadata for ETL tracking
@freezed
abstract class ImportMetadata with _$ImportMetadata {
  const factory ImportMetadata({
    required String sourceSystem,
    required int sourceId,
    required DateTime importedAt,
    String? sourceHash,
    int? sourceVersion,
  }) = _ImportMetadata;

  factory ImportMetadata.fromJson(Map<String, dynamic> json) =>
      _$ImportMetadataFromJson(json);
}

/// Domain exceptions
class ContactInvariantViolation extends Error {
  final String message;
  ContactInvariantViolation(this.message);

  @override
  String toString() => 'ContactInvariantViolation: $message';
}

class ContactValidationError extends Error {
  final String message;
  ContactValidationError(this.message);

  @override
  String toString() => 'ContactValidationError: $message';
}

// Extension for nullable first element
extension ListExtensions<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

// Utility function for UUID generation (placeholder)
String _generateUuid() {
  // Implementation would use uuid package
  return 'uuid-placeholder-${DateTime.now().millisecondsSinceEpoch}';
}
