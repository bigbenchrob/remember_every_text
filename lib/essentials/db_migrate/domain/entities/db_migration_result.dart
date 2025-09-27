/// Final outcome of projecting a ledger import batch into the working
/// Drift database.
class DbMigrationResult {
  const DbMigrationResult({
    required this.batchId,
    required this.success,
    this.error,
    this.identitiesProjected = 0,
    this.identityHandleLinksProjected = 0,
    this.chatsProjected = 0,
    this.participantsProjected = 0,
    this.messagesProjected = 0,
    this.attachmentsProjected = 0,
    this.reactionsProjected = 0,
    this.warnings = const <String>[],
  });

  /// Identifier of the `import_batches` row that was projected.
  final int batchId;

  /// Overall success flag.
  final bool success;

  /// Optional fatal error string.
  final String? error;

  final int identitiesProjected;
  final int identityHandleLinksProjected;
  final int chatsProjected;
  final int participantsProjected;
  final int messagesProjected;
  final int attachmentsProjected;
  final int reactionsProjected;

  final List<String> warnings;

  DbMigrationResult copyWith({
    bool? success,
    String? error,
    int? identitiesProjected,
    int? identityHandleLinksProjected,
    int? chatsProjected,
    int? participantsProjected,
    int? messagesProjected,
    int? attachmentsProjected,
    int? reactionsProjected,
    List<String>? warnings,
  }) {
    return DbMigrationResult(
      batchId: batchId,
      success: success ?? this.success,
      error: error ?? this.error,
      identitiesProjected: identitiesProjected ?? this.identitiesProjected,
      identityHandleLinksProjected:
          identityHandleLinksProjected ?? this.identityHandleLinksProjected,
      chatsProjected: chatsProjected ?? this.chatsProjected,
      participantsProjected:
          participantsProjected ?? this.participantsProjected,
      messagesProjected: messagesProjected ?? this.messagesProjected,
      attachmentsProjected: attachmentsProjected ?? this.attachmentsProjected,
      reactionsProjected: reactionsProjected ?? this.reactionsProjected,
      warnings: warnings ?? this.warnings,
    );
  }

  Map<String, Object?> toSummaryMap() {
    return <String, Object?>{
      'batch_id': batchId,
      'success': success,
      'error': error,
      'identities_projected': identitiesProjected,
      'identity_handle_links_projected': identityHandleLinksProjected,
      'chats_projected': chatsProjected,
      'participants_projected': participantsProjected,
      'messages_projected': messagesProjected,
      'attachments_projected': attachmentsProjected,
      'reactions_projected': reactionsProjected,
      'warnings': warnings,
    };
  }
}
