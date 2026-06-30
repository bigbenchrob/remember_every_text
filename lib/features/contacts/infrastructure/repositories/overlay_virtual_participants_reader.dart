import '../../../../essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import '../../application/read_models/virtual_participants_reader.dart';
import '../../domain/overlay_virtual_contact.dart';
import 'overlay_participants_repository.dart';

class OverlayVirtualParticipantsReader implements VirtualParticipantsReader {
  const OverlayVirtualParticipantsReader({required OverlayDatabase overlayDb})
    : _overlayDb = overlayDb;

  final OverlayDatabase _overlayDb;

  @override
  Future<List<OverlayVirtualContact>> readVirtualParticipants() async {
    final rows = await _overlayDb.getVirtualParticipants();
    return const OverlayParticipantsRepository().mapVirtualParticipants(rows);
  }
}
