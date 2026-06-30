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
