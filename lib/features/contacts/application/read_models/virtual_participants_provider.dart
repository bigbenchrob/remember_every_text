import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart'
    show overlayDatabaseProvider;
import '../../domain/overlay_virtual_contact.dart';
import '../../infrastructure/repositories/overlay_virtual_participants_reader.dart';
import 'virtual_participants_reader.dart';

part 'virtual_participants_provider.g.dart';

@riverpod
Future<VirtualParticipantsReader> virtualParticipantsReader(Ref ref) async {
  final overlayDb = await ref.watch(overlayDatabaseProvider.future);
  return OverlayVirtualParticipantsReader(overlayDb: overlayDb);
}

@riverpod
Future<List<OverlayVirtualContact>> virtualParticipants(Ref ref) async {
  final reader = await ref.watch(virtualParticipantsReaderProvider.future);
  return reader.readVirtualParticipants();
}
