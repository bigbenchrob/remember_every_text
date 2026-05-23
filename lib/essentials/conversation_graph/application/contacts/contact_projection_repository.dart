class ContactProjectionResult {
  const ContactProjectionResult({
    required this.examinedContactCount,
    required this.insertedContactCount,
    required this.insertedContactHandleEdgeCount,
  });

  final int examinedContactCount;
  final int insertedContactCount;
  final int insertedContactHandleEdgeCount;
}

abstract interface class ContactProjectionRepository {
  Future<ContactProjectionResult> projectContacts();
}

List<String> contactHandleKeys(String handle) {
  final normalized = handle.trim().toLowerCase();
  if (normalized.isEmpty) {
    return const <String>[];
  }

  final keys = <String>{normalized};
  final digits = normalized.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isNotEmpty) {
    keys.add(digits);
    if (digits.length == 10) {
      keys.add('1$digits');
    } else if (digits.length == 11 && digits.startsWith('1')) {
      keys.add(digits.substring(1));
    }
  }

  return keys.toList(growable: false);
}
