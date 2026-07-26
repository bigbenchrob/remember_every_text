import '../utilities/handle_normalizer.dart';

enum StrayHandleEndpointKind {
  phoneNumber,
  emailAddress,
  businessUrn,
  shortCode,
  other,
}

StrayHandleEndpointKind classifyStrayHandleEndpoint(String handleValue) {
  final trimmed = handleValue.trim();
  final lowercase = trimmed.toLowerCase();

  if (lowercase.startsWith('urn:')) {
    return StrayHandleEndpointKind.businessUrn;
  }
  if (trimmed.contains('@')) {
    return StrayHandleEndpointKind.emailAddress;
  }
  if (isShortCode(trimmed)) {
    return StrayHandleEndpointKind.shortCode;
  }

  final normalized = normalizeHandleIdentifier(trimmed);
  if (RegExp(r'^\+?\d{9,15}$').hasMatch(normalized)) {
    return StrayHandleEndpointKind.phoneNumber;
  }

  return StrayHandleEndpointKind.other;
}
