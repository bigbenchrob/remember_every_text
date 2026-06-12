import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../application/historical_archive_folder_chooser.dart';
import 'file_selector_historical_archive_folder_chooser.dart';

part 'historical_archive_folder_chooser_provider.g.dart';

@riverpod
HistoricalArchiveFolderChooser historicalArchiveFolderChooser(
  HistoricalArchiveFolderChooserRef ref,
) {
  return const FileSelectorHistoricalArchiveFolderChooser();
}
