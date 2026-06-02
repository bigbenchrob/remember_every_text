import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../db/feature_level_providers.dart';
import '../../../onboarding/application/fda_checker.dart';
import 'import_status_checker.dart';

part 'live_import_status_service_provider.g.dart';

abstract interface class LiveImportStatusService {
  Future<ImportStatus> checkLiveImportStatus();
}

final class LiveImportStatusServiceImpl implements LiveImportStatusService {
  const LiveImportStatusServiceImpl({
    required Ref ref,
    ImportStatusChecker checker = const ImportStatusChecker(),
  }) : _ref = ref,
       _checker = checker;

  final Ref _ref;
  final ImportStatusChecker _checker;

  @override
  Future<ImportStatus> checkLiveImportStatus() async {
    final importDb = await _ref.read(sqfliteImportDatabaseProvider.future);

    return _checker.checkStatus(
      macOsChatDbPath: FdaChecker.chatDbPath,
      importDb: importDb,
    );
  }
}

@riverpod
LiveImportStatusService liveImportStatusService(Ref ref) {
  return LiveImportStatusServiceImpl(ref: ref);
}
