import 'dart:typed_data';

typedef MessageExtractionProgressObserver =
    void Function({
      required int completedWorkCount,
      required int totalWorkCount,
      required int lastCompletedSourceRowId,
    });

abstract class MessageExtractorPort {
  Future<Map<int, String>> extractAllMessageTexts({int? limit, String? dbPath});

  Future<Map<int, String>> extractMessageTextsFromBlobs(
    Map<int, Uint8List> attributedBodyBlobsByRowId, {
    MessageExtractionProgressObserver? onProgress,
  });

  Future<bool> isAvailable();

  Future<bool> isBlobExtractionAvailable();
}
