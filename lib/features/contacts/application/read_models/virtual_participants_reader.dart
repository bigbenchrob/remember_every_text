import '../../domain/overlay_virtual_contact.dart';

abstract interface class VirtualParticipantsReader {
  Future<List<OverlayVirtualContact>> readVirtualParticipants();
}
