import 'dart:typed_data';

abstract class MessageExtractorPort {
  Future<Map<int, String>> extractAllMessageTexts({int? limit, String? dbPath});

  Future<Map<int, String>> extractMessageTextsFromBlobs(
    Map<int, Uint8List> attributedBodyBlobsByRowId,
  );

  Future<bool> isAvailable();

  Future<bool> isBlobExtractionAvailable();
}
