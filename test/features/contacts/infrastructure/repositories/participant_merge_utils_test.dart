import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/features/contacts/infrastructure/repositories/participant_merge_utils.dart';

void main() {
  test('preferred participant name follows single override precedence', () {
    const participant = WorkingParticipant(
      id: 17,
      originalName: 'Claire Merriman Campbell',
      displayName: 'Claire Merriman Campbell',
      shortName: 'Claire Merriman',
      isOrganization: false,
    );

    expect(
      preferredParticipantDisplayName(
        participant: participant,
        override: const ParticipantOverride(
          participantId: 17,
          displayNameOverride: 'Claire',
          createdAtUtc: '2026-01-01T00:00:00.000Z',
          updatedAtUtc: '2026-01-01T00:00:00.000Z',
        ),
      ),
      'Claire',
    );

    expect(
      preferredParticipantDisplayName(participant: participant, override: null),
      'Claire Merriman Campbell',
    );
  });
}
