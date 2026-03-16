import 'package:flutter/widgets.dart';

import '../../../domain/entities/attachment_info.dart';
import '../../../presentation/view/recovered_attachment_sidebar_view.dart';

class RecoveredAttachmentSidebarBuilder {
  const RecoveredAttachmentSidebarBuilder();

  Widget build({required int messageId, required AttachmentInfo attachment}) {
    return RecoveredAttachmentSidebarView(
      messageId: messageId,
      attachment: attachment,
    );
  }
}
