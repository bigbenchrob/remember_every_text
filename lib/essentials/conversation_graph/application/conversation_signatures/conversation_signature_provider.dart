import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../conversations/conversation_reader_provider.dart';
import 'conversation_signature.dart';
import 'conversation_signature_reader.dart';

part 'conversation_signature_provider.g.dart';

@riverpod
Future<ConversationSignatureReader> conversationSignatureReader(Ref ref) async {
  final reader = await ref.watch(conversationReaderProvider.future);
  return ConversationSignatureReader(reader: reader);
}

@riverpod
Future<List<ConversationSignature>> conversationSignatures(
  Ref ref, {
  int limit = 100,
}) async {
  final reader = await ref.watch(conversationSignatureReaderProvider.future);
  return reader.readSignatures(limit: limit);
}
