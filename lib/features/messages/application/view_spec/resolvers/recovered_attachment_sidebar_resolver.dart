import 'package:flutter/widgets.dart';

import '../../../domain/entities/attachment_info.dart';
import '../widget_builders/recovered_attachment_sidebar_builder.dart';

/// Resolves the [MessagesSpec.recoveredAttachmentViewer] variant.
class RecoveredAttachmentSidebarResolver {
  RecoveredAttachmentSidebarResolver();

  static const _builder = RecoveredAttachmentSidebarBuilder();

  // Returns the end-sidebar widget for a single recovered attachment.
  Widget resolve({required int messageId, required AttachmentInfo attachment}) {
    return _builder.build(messageId: messageId, attachment: attachment);
  }
}
