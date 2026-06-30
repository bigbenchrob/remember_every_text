import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../infrastructure/repositories/url_launcher_archived_attachment_file_opener.dart';
import 'archived_attachment_file_opener.dart';

part 'archived_attachment_file_opener_provider.g.dart';

@riverpod
ArchivedAttachmentFileOpener archivedAttachmentFileOpener(Ref ref) {
  return const UrlLauncherArchivedAttachmentFileOpener();
}
