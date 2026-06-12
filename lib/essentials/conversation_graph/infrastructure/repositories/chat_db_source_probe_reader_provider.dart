import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/monitor/chat_db_source_probe_reader.dart';
import 'sqlite_chat_db_source_probe_reader.dart';

part 'chat_db_source_probe_reader_provider.g.dart';

@riverpod
ChatDbSourceProbeReader chatDbSourceProbeReader(
  ChatDbSourceProbeReaderRef ref,
) {
  return const SqliteChatDbSourceProbeReader();
}
