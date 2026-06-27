import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../infrastructure/repositories/file_selector_historical_archive_folder_chooser.dart';
import 'historical_archive_folder_chooser.dart';

part 'historical_archive_folder_chooser_provider.g.dart';

@riverpod
HistoricalArchiveFolderChooser historicalArchiveFolderChooser(Ref ref) {
  return const FileSelectorHistoricalArchiveFolderChooser();
}
