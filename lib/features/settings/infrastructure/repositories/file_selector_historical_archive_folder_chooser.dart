import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

import '../../application/historical_archive_folder_chooser.dart';

class FileSelectorHistoricalArchiveFolderChooser
    implements HistoricalArchiveFolderChooser {
  const FileSelectorHistoricalArchiveFolderChooser();

  @override
  Future<String?> chooseMessagesFolder() {
    return FileSelectorPlatform.instance.getDirectoryPathWithOptions(
      const FileDialogOptions(confirmButtonText: 'Use This Folder'),
    );
  }
}
