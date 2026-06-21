import '../../services/native_link_preview_service.dart';
import '../application/link_preview_metadata_reader.dart';

class NativeLinkPreviewMetadataReader implements LinkPreviewMetadataReader {
  NativeLinkPreviewMetadataReader({NativeLinkPreviewService? service})
    : _service = service ?? NativeLinkPreviewService();

  final NativeLinkPreviewService _service;

  @override
  Future<NativeLinkMetadata?> fetchMetadata(String url) {
    return _service.fetchMetadata(url);
  }
}
