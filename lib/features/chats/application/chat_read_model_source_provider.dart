import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_read_model_source_provider.g.dart';

enum ChatReadModelSourceMode { legacy, conversationGraph }

@Riverpod(keepAlive: true)
class ChatReadModelSource extends _$ChatReadModelSource {
  @override
  ChatReadModelSourceMode build() {
    return ChatReadModelSourceMode.conversationGraph;
  }

  void setMode(ChatReadModelSourceMode mode) {
    state = mode;
  }
}
