import '../../services/native_link_preview_service.dart';

abstract interface class LinkPreviewMetadataReader {
  Future<NativeLinkMetadata?> fetchMetadata(String url);
}
