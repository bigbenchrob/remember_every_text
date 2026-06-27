import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../infrastructure/repositories/sqlite_chat_db_source_probe_reader.dart';
import 'chat_db_source_probe_reader.dart';

part 'chat_db_source_probe_reader_provider.g.dart';

@riverpod
ChatDbSourceProbeReader chatDbSourceProbeReader(Ref ref) {
  return const SqliteChatDbSourceProbeReader();
}
