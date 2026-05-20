/// Packs a numeric source id and a source-local rowid into one SQLite INTEGER.
///
/// This is a deterministic, collision-free row key within the documented
/// bounds. It is not a hash: the source id and source rowid can be recovered
/// exactly from the packed value.
///
/// Bounds:
/// - sourceId: 1..1,048,575 (20 bits)
/// - sourceRowId: 1..8,796,093,022,207 (43 bits)
///
/// The packed value stays within SQLite's signed positive INTEGER range by
/// using 63 bits total.
class SourceScopedRowKey {
  SourceScopedRowKey._();

  static const int sourceRowIdBits = 43;
  static const int maxSourceId = (1 << 20) - 1;
  static const int maxSourceRowId = (1 << sourceRowIdBits) - 1;

  static int pack({required int sourceId, required int sourceRowId}) {
    if (sourceId < 1 || sourceId > maxSourceId) {
      throw RangeError.range(sourceId, 1, maxSourceId, 'sourceId');
    }
    if (sourceRowId < 1 || sourceRowId > maxSourceRowId) {
      throw RangeError.range(sourceRowId, 1, maxSourceRowId, 'sourceRowId');
    }

    return (sourceId << sourceRowIdBits) | sourceRowId;
  }

  static int unpackSourceId(int packed) {
    _validatePacked(packed);
    return packed >> sourceRowIdBits;
  }

  static int unpackSourceRowId(int packed) {
    _validatePacked(packed);
    return packed & maxSourceRowId;
  }

  static void _validatePacked(int packed) {
    if (packed < 1) {
      throw RangeError.value(packed, 'packed', 'must be positive');
    }
  }
}
