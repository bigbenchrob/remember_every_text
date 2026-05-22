import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../source_scoped_import/infrastructure/import_database_provider.dart';
import '../../infrastructure/working_database_provider.dart';
import 'contact_projector.dart';

part 'contact_projector_provider.g.dart';

@riverpod
Future<ContactProjector> contactProjector(Ref ref) async {
  final importDatabase = await ref.watch(importDatabaseProvider.future);
  final workingDatabase = await ref.watch(workingDatabaseProvider.future);

  return ContactProjector(
    importDatabase: importDatabase,
    workingDatabase: workingDatabase,
  );
}
