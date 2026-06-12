import '../../source_scoped_import/domain/known_sources.dart';
import '../../source_scoped_import/domain/source_scoped_row_key.dart';

/// Temporary compatibility helpers for graph ids and retained overlay ids.
///
/// These helpers do not define identity semantics. They only enumerate the
/// equivalent storage keys needed while overlay rows still contain old ids.
int? graphContactIdForRetainedOverlayContactId(int contactId) {
  if (contactId <= 0 || contactId > SourceScopedRowKey.maxSourceRowId) {
    return null;
  }
  return SourceScopedRowKey.pack(
    sourceId: liveAddressBookSourceId,
    sourceRowId: contactId,
  );
}

int? retainedOverlayContactIdForGraphContactId(int contactId) {
  if (SourceScopedRowKey.unpackSourceId(contactId) != liveAddressBookSourceId) {
    return null;
  }
  return SourceScopedRowKey.unpackSourceRowId(contactId);
}

Set<int> contactOverlayKeyVariants(int contactId) {
  final ids = <int>{contactId};
  final graphContactId = graphContactIdForRetainedOverlayContactId(contactId);
  if (graphContactId != null) {
    ids.add(graphContactId);
  }
  final retainedOverlayContactId = retainedOverlayContactIdForGraphContactId(
    contactId,
  );
  if (retainedOverlayContactId != null) {
    ids.add(retainedOverlayContactId);
  }
  return ids;
}

bool contactIdsRepresentSamePerson(int first, int second) {
  return contactOverlayKeyVariants(first).contains(second) ||
      contactOverlayKeyVariants(second).contains(first);
}

T? overlayValueForContactId<T>(Map<int, T> valuesByContactId, int contactId) {
  for (final key in contactOverlayKeyVariants(contactId)) {
    final value = valuesByContactId[key];
    if (value != null) {
      return value;
    }
  }
  return null;
}

int? graphHandleIdForRetainedOverlayHandleId(int handleId) {
  if (handleId <= 0 || handleId > SourceScopedRowKey.maxSourceRowId) {
    return null;
  }
  return SourceScopedRowKey.pack(
    sourceId: liveChatDbSourceId,
    sourceRowId: handleId,
  );
}

Set<int> handleOverlayKeyVariants(int handleId) {
  final ids = <int>{handleId};
  final graphHandleId = graphHandleIdForRetainedOverlayHandleId(handleId);
  if (graphHandleId != null) {
    ids.add(graphHandleId);
  }
  return ids;
}

int? retainedOverlayMessageRowIdForGraphMessageId(int messageSsId) {
  if (SourceScopedRowKey.unpackSourceId(messageSsId) != liveChatDbSourceId) {
    return null;
  }
  return SourceScopedRowKey.unpackSourceRowId(messageSsId);
}

int? graphMessageIdForRetainedOverlayMessageRowId(int messageRowId) {
  if (messageRowId <= 0 || messageRowId > SourceScopedRowKey.maxSourceRowId) {
    return null;
  }
  return SourceScopedRowKey.pack(
    sourceId: liveChatDbSourceId,
    sourceRowId: messageRowId,
  );
}
