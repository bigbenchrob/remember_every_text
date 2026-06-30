import 'package:url_launcher/url_launcher.dart';

import '../../application/status/archived_attachment_file_opener.dart';

class UrlLauncherArchivedAttachmentFileOpener
    implements ArchivedAttachmentFileOpener {
  const UrlLauncherArchivedAttachmentFileOpener();

  @override
  Future<void> open(String archivedFilePath) async {
    final uri = Uri.file(archivedFilePath);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
