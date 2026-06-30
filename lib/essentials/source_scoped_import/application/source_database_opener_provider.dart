import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/ports/source_database_port.dart';
import '../infrastructure/source_database/sqflite_source_database.dart';

part 'source_database_opener_provider.g.dart';

@riverpod
SourceDatabaseOpener sourceDatabaseOpener(Ref ref) {
  return const SqfliteSourceDatabaseOpener();
}
