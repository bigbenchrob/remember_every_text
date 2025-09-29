import 'dart:typed_data';

abstract class ImportDatabasePort {
  Future<void> clearAllData();

  Future<int> insertHandle({
    required int id,
    String? contactId,
    String? service,
  });
  Future<int> insertChat({
    required int id,
    String? guid,
    String? chatIdentifier,
    String? serviceName,
    String? displayName,
  });
  Future<int> insertChatHandleJoin({
    required int chatId,
    required int handleId,
  });
  Future<int> insertMessage({
    required int id,
    int? handleId,
    String? text,
    int? date,
    int? isFromMe,
    String? service,
    String? subject,
    String? cacheRoomnames,
    int? error,
    int? dateRead,
    int? dateDelivered,
  });
  Future<void> updateMessageText(int messageId, String text);
  Future<int> insertAttachment({
    required int id,
    String? guid,
    String? filename,
    String? mimeType,
    int? totalBytes,
    int? isSticker,
    int? transferState,
  });
  Future<int> insertChatMessageJoin({
    required int chatId,
    required int messageId,
  });
  Future<int> insertMessageAttachmentJoin({
    required int messageId,
    required int attachmentId,
  });
  Future<int> insertContact({
    required int id,
    String? first,
    String? last,
    String? company,
    String? nickname,
  });
  Future<int> insertContactEmail({
    required int id,
    required int contactId,
    required String email,
    String? label,
  });
  Future<int> insertContactPhone({
    required int id,
    required int contactId,
    required String phone,
    String? label,
  });
  Future<int> insertContactImage({
    required int contactId,
    required Uint8List imageData,
  });
  Future<int> insertContactHandle({
    required int handleId,
    required int contactId,
    required String contactMethod,
  });

  Future<int> setMetadata({required String key, required String value});
  Future<String?> getMetadata(String key);
  Future<Map<String, int>> getDatabaseStats();

  Future<List<Map<String, dynamic>>> getAllHandles();

  Future<int?> findContactIdByEmail(String email);
  Future<int?> findContactIdByNormalizedPhone(String normalized10);
}
