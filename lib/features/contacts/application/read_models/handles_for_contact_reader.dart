import 'linked_handle.dart';

abstract interface class HandlesForContactReader {
  Future<List<LinkedHandle>> readHandlesForContact({required int contactId});
}
