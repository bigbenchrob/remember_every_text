import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/config/theme/spacing/app_spacing.dart';
import 'package:remember_this_text/constants/domain/contact_constants.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers/working_db_populated_provider.dart';
import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/sidebar/application/cassette_rack_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/application/cassette_widget_coordinator_provider.dart';
import 'package:remember_this_text/essentials/sidebar/domain/entities/cassette_spec.dart';
import 'package:remember_this_text/essentials/sidebar/domain/sidebar_body_model.dart';
import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/payloads/attachment_archive_settings_cassette_payload.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/payloads/contact_chooser_cassette_payload.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/payloads/contact_hero_summary_cassette_payload.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/payloads/contact_message_scope_toggle_cassette_payload.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/payloads/contact_selection_control_cassette_payload.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/payloads/handle_filter_cassette_payload.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/payloads/reimport_data_info_cassette_payload.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/payloads/send_logs_info_cassette_payload.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolver_tools/contact_chooser_snapshot_provider.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolver_tools/filtered_picker_sections_provider.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolver_tools/picker_filter_mode_provider.dart';
import 'package:remember_this_text/features/contacts/application/sidebar_cassette_spec/resolver_tools/unified_picker_sections_provider.dart';
import 'package:remember_this_text/features/contacts/domain/participant_origin.dart';
import 'package:remember_this_text/features/contacts/infrastructure/repositories/contacts_list_repository.dart';
import 'package:remember_this_text/features/contacts/domain/spec_classes/contacts_cassette_spec.dart';
import 'package:remember_this_text/features/contacts/domain/spec_classes/contacts_settings_spec.dart';
import 'package:remember_this_text/features/handles/application/sidebar_cassette_spec/payloads/stray_emails_cassette_payload.dart';
import 'package:remember_this_text/features/handles/application/sidebar_cassette_spec/payloads/stray_handles_mode_switcher_cassette_payload.dart';
import 'package:remember_this_text/features/handles/application/sidebar_cassette_spec/payloads/stray_handles_review_cassette_payload.dart';
import 'package:remember_this_text/features/handles/application/sidebar_cassette_spec/payloads/stray_phone_numbers_cassette_payload.dart';
import 'package:remember_this_text/features/handles/application/sidebar_cassette_spec/payloads/unmatched_handles_cassette_payload.dart';
import 'package:remember_this_text/features/handles/application/state/stray_handle_mode_provider.dart';
import 'package:remember_this_text/features/handles/domain/spec_classes/handles_cassette_spec.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/payloads/recovered_no_handle_from_me_navigator_cassette_payload.dart';
import 'package:remember_this_text/features/messages/application/sidebar_cassette_spec/payloads/recovered_unlinked_navigator_cassette_payload.dart';
import 'package:remember_this_text/features/messages/domain/spec_classes/messages_info_cassette_spec.dart';
import 'package:remember_this_text/features/sidebar_utilities/application/sidebar_cassette_spec/payloads/top_chat_menu_cassette_payload.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/sidebar_utilities_constants.dart';
import 'package:remember_this_text/features/sidebar_utilities/domain/spec_classes/sidebar_utility_cassette_spec.dart';

void main() {
  group('cassetteWidgetCoordinatorProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          workingDbPopulatedProvider.overrideWith(
            _AlwaysPopulatedWorkingDb.new,
          ),
        ],
      );

      container
          .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
          .setRack([
            const CassetteSpec.handles(
              HandlesCassetteSpec.strayHandlesReview(
                filter: StrayHandleFilter.phones,
              ),
            ),
          ]);
    });

    tearDown(() {
      container.dispose();
    });

    test('rebuilds stray handle review cassette when mode changes', () async {
      final provider = cassetteWidgetCoordinatorProvider(SidebarMode.messages);

      final initialWidgets = await container.read(provider.future);
      expect(
        _strayHandlesReviewPayload(initialWidgets).mode,
        StrayHandleMode.allStrays,
      );

      container
          .read(strayHandleModeSettingProvider.notifier)
          .setMode(StrayHandleMode.spamCandidates);

      final updatedWidgets = await container.read(provider.future);
      expect(
        _strayHandlesReviewPayload(updatedWidgets).mode,
        StrayHandleMode.spamCandidates,
      );
    });

    test(
      'rebuilds stray handle mode switcher payload when mode changes',
      () async {
        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRack([
              const CassetteSpec.handles(
                HandlesCassetteSpec.strayHandlesModeSwitcher(
                  filter: StrayHandleFilter.phones,
                ),
              ),
            ]);

        final provider = cassetteWidgetCoordinatorProvider(
          SidebarMode.messages,
        );

        final initialWidgets = await container.read(provider.future);
        expect(
          _strayHandlesModeSwitcherPayload(initialWidgets).mode,
          StrayHandleMode.allStrays,
        );

        container
            .read(strayHandleModeSettingProvider.notifier)
            .setMode(StrayHandleMode.dismissed);

        final updatedWidgets = await container.read(provider.future);
        expect(
          _strayHandlesModeSwitcherPayload(updatedWidgets).mode,
          StrayHandleMode.dismissed,
        );
      },
    );

    test(
      'renders settings menu cassettes through body model content',
      () async {
        container
            .read(cassetteRackStateProvider(SidebarMode.settings).notifier)
            .setRack([
              const CassetteSpec.sidebarUtility(
                SidebarUtilityCassetteSpec.settingsMenu(),
              ),
            ]);

        final widgets = await container.read(
          cassetteWidgetCoordinatorProvider(SidebarMode.settings).future,
        );

        expect(
          _sharedBodyModelPayload(widgets).renderKind,
          SidebarCassetteRenderKind.sharedBodyModel,
        );
        expect(
          _sharedBodyModelPayload(widgets).bodyModel,
          isA<SidebarDropdownBodyModel>(),
        );
      },
    );

    test(
      'resolves send logs settings spec to inert feature-info payload',
      () async {
        container
            .read(cassetteRackStateProvider(SidebarMode.settings).notifier)
            .setRack([
              const CassetteSpec.contactsSettings(
                ContactsSettingsSpec.sendLogsInfo(),
              ),
            ]);

        final payload = _sendLogsInfoPayload(
          await container.read(
            cassetteWidgetCoordinatorProvider(SidebarMode.settings).future,
          ),
        );

        expect(payload.renderKind, SidebarCassetteRenderKind.featureInfo);
        expect(payload.role, SidebarCassetteRole.action);
      },
    );

    test(
      'resolves reimport data settings spec to inert feature-info payload',
      () async {
        container
            .read(cassetteRackStateProvider(SidebarMode.settings).notifier)
            .setRack([
              const CassetteSpec.contactsSettings(
                ContactsSettingsSpec.reimportDataInfo(),
              ),
            ]);

        final payload = _reimportDataInfoPayload(
          await container.read(
            cassetteWidgetCoordinatorProvider(SidebarMode.settings).future,
          ),
        );

        expect(payload.renderKind, SidebarCassetteRenderKind.featureInfo);
        expect(payload.role, SidebarCassetteRole.action);
      },
    );

    test(
      'resolves attachment archive settings spec to inert feature-info payload',
      () async {
        container
            .read(cassetteRackStateProvider(SidebarMode.settings).notifier)
            .setRack([
              const CassetteSpec.contactsSettings(
                ContactsSettingsSpec.attachmentArchive(),
              ),
            ]);

        final payload = _attachmentArchiveSettingsPayload(
          await container.read(
            cassetteWidgetCoordinatorProvider(SidebarMode.settings).future,
          ),
        );

        expect(payload.renderKind, SidebarCassetteRenderKind.featureInfo);
        expect(payload.role, SidebarCassetteRole.action);
      },
    );

    test(
      'resolves display name settings spec to static feature-info payload',
      () async {
        container
            .read(cassetteRackStateProvider(SidebarMode.settings).notifier)
            .setRack([
              const CassetteSpec.contactsSettings(
                ContactsSettingsSpec.displayNameInfo(),
              ),
            ]);

        final payload = _staticFeatureInfoPayload(
          await container.read(
            cassetteWidgetCoordinatorProvider(SidebarMode.settings).future,
          ),
        );

        expect(payload.title, 'Contact Names');
        expect(payload.renderKind, SidebarCassetteRenderKind.featureInfo);
        expect(payload.role, SidebarCassetteRole.contextSecondary);
      },
    );

    test('resolves unmatched handles spec to inert payload', () async {
      container
          .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
          .setRack([
            const CassetteSpec.handles(
              HandlesCassetteSpec.unmatchedHandlesList(),
            ),
          ]);

      final payload = _unmatchedHandlesPayload(
        await container.read(
          cassetteWidgetCoordinatorProvider(SidebarMode.messages).future,
        ),
      );

      expect(
        payload.renderKind,
        SidebarCassetteRenderKind.placementGovernedFeature,
      );
      expect(payload.role, SidebarCassetteRole.contextPrimary);
      expect(payload.shouldExpand, isTrue);
    });

    test('resolves stray phones spec to inert payload', () async {
      container
          .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
          .setRack([
            const CassetteSpec.handles(HandlesCassetteSpec.strayPhoneNumbers()),
          ]);

      final payload = _strayPhoneNumbersPayload(
        await container.read(
          cassetteWidgetCoordinatorProvider(SidebarMode.messages).future,
        ),
      );

      expect(
        payload.renderKind,
        SidebarCassetteRenderKind.placementGovernedFeature,
      );
      expect(payload.role, SidebarCassetteRole.contextPrimary);
      expect(payload.shouldExpand, isTrue);
    });

    test('resolves stray emails spec to inert payload', () async {
      container
          .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
          .setRack([
            const CassetteSpec.handles(HandlesCassetteSpec.strayEmails()),
          ]);

      final payload = _strayEmailsPayload(
        await container.read(
          cassetteWidgetCoordinatorProvider(SidebarMode.messages).future,
        ),
      );

      expect(
        payload.renderKind,
        SidebarCassetteRenderKind.placementGovernedFeature,
      );
      expect(payload.role, SidebarCassetteRole.contextPrimary);
      expect(payload.shouldExpand, isTrue);
    });

    test(
      'resolves recovered deleted messages info spec to inert payload',
      () async {
        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRack([
              const CassetteSpec.messagesInfo(
                MessagesInfoCassetteSpec.infoCard(
                  key: MessagesInfoKey.recoveredDeletedMessages,
                ),
              ),
            ]);

        final payload = _recoveredUnlinkedNavigatorPayload(
          await container.read(
            cassetteWidgetCoordinatorProvider(SidebarMode.messages).future,
          ),
        );

        expect(payload.cassetteIndex, 0);
        expect(payload.topSpacing, AppSpacing.lg);
        expect(
          payload.renderKind,
          SidebarCassetteRenderKind.placementGovernedFeature,
        );
      },
    );

    test(
      'resolves search-all-messages info spec to static feature-info payload',
      () async {
        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRack([
              const CassetteSpec.messagesInfo(
                MessagesInfoCassetteSpec.infoCard(
                  key: MessagesInfoKey.searchAllMessages,
                ),
              ),
            ]);

        final payload = _staticFeatureInfoPayload(
          await container.read(
            cassetteWidgetCoordinatorProvider(SidebarMode.messages).future,
          ),
        );

        expect(
          payload.bodyText,
          contains('heatmap below represents all the messages'),
        );
        expect(payload.renderKind, SidebarCassetteRenderKind.featureInfo);
      },
    );

    test(
      'resolves recovered no-handle messages info spec to inert payload',
      () async {
        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRack([
              const CassetteSpec.messagesInfo(
                MessagesInfoCassetteSpec.infoCard(
                  key: MessagesInfoKey.recoveredNoHandleMessages,
                ),
              ),
            ]);

        final payload = _recoveredNoHandleNavigatorPayload(
          await container.read(
            cassetteWidgetCoordinatorProvider(SidebarMode.messages).future,
          ),
        );

        expect(payload.cassetteIndex, 0);
        expect(payload.topSpacing, 0);
        expect(
          payload.renderKind,
          SidebarCassetteRenderKind.placementGovernedFeature,
        );
      },
    );

    test('resolves top chat menu spec to inert payload', () async {
      container
          .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
          .setRack([
            const CassetteSpec.sidebarUtility(
              SidebarUtilityCassetteSpec.topChatMenu(
                selectedChoice: TopChatMenuChoice.contacts,
              ),
            ),
          ]);

      final payload = _topChatMenuPayload(
        await container.read(
          cassetteWidgetCoordinatorProvider(SidebarMode.messages).future,
        ),
      );

      expect(payload.currentChoice, TopChatMenuChoice.contacts);
      expect(payload.cassetteIndex, 0);
      expect(payload.sidebarMode, SidebarMode.messages);
      expect(payload.isNaked, isTrue);
    });

    test(
      'resolves contact chooser payload without waiting for picker data',
      () async {
        final delayedContacts = Completer<List<ContactSummary>>();
        final delayedSections = Completer<UnifiedPickerSections>();

        container.dispose();
        container = ProviderContainer(
          overrides: [
            workingDbPopulatedProvider.overrideWith(
              _AlwaysPopulatedWorkingDb.new,
            ),
            contactsListRepositoryProvider.overrideWith(
              (ref) => delayedContacts.future,
            ),
            filteredPickerSectionsProvider.overrideWith(
              (ref) => delayedSections.future,
            ),
            pickerFilterProvider.overrideWith(_TestPickerFilter.new),
          ],
        );

        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRack([
              const CassetteSpec.contacts(
                ContactsCassetteSpec.contactChooser(),
              ),
            ]);

        final payload = _contactChooserPayload(
          await container.read(
            cassetteWidgetCoordinatorProvider(SidebarMode.messages).future,
          ),
        );

        expect(payload.cassetteIndex, 0);
        expect(payload.chosenContactId, isNull);
        expect(payload.loadState, ContactChooserLoadState.loading);
        expect(payload.pickerMode, isNull);
        expect(payload.pickerFilterMode, isNull);
        expect(payload.filteredSections, isNull);
      },
    );

    test(
      'chooser readiness does not invalidate the shared cassette coordinator',
      () async {
        const chosenContactId = 42;
        const readySections = UnifiedPickerSections(
          sections: <PickerSection>[],
          alphabeticalLetters: <String>[],
          alphabeticalStartIndex: 0,
          allFavoriteIds: <int>{},
        );

        container.dispose();
        container = ProviderContainer(
          overrides: [
            workingDbPopulatedProvider.overrideWith(
              _AlwaysPopulatedWorkingDb.new,
            ),
            contactsListRepositoryProvider.overrideWith(
              (ref) async => const <ContactSummary>[
                ContactSummary(
                  participantId: 42,
                  displayName: 'Ada Lovelace',
                  autoGeneratedName: 'Ada Lovelace',
                  shortName: 'Ada',
                  totalChats: 1,
                  totalMessages: 2,
                  origin: ParticipantOrigin.working,
                  handleCount: 1,
                ),
              ],
            ),
            filteredPickerSectionsProvider.overrideWith(
              (ref) async => readySections,
            ),
            pickerFilterProvider.overrideWith(_TestPickerFilter.new),
          ],
        );

        container
            .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
            .setRack([
              const CassetteSpec.contacts(
                ContactsCassetteSpec.contactChooser(
                  chosenContactId: chosenContactId,
                ),
              ),
            ]);

        final initialPayload = _contactChooserPayload(
          await container.read(
            cassetteWidgetCoordinatorProvider(SidebarMode.messages).future,
          ),
        );

        expect(initialPayload.chosenContactId, chosenContactId);
        expect(initialPayload.loadState, ContactChooserLoadState.loading);

        await container.read(contactsListRepositoryProvider.future);
        await container.read(filteredPickerSectionsProvider.future);

        final stablePayload = _contactChooserPayload(
          await container.read(
            cassetteWidgetCoordinatorProvider(SidebarMode.messages).future,
          ),
        );

        expect(stablePayload.chosenContactId, chosenContactId);
        expect(stablePayload.loadState, ContactChooserLoadState.loading);
        expect(stablePayload.pickerMode, isNull);
        expect(stablePayload.pickerFilterMode, isNull);
        expect(stablePayload.filteredSections, isNull);
      },
    );

    test('contact chooser snapshot upgrades from loading to ready', () async {
      const readySections = UnifiedPickerSections(
        sections: <PickerSection>[],
        alphabeticalLetters: <String>[],
        alphabeticalStartIndex: 0,
        allFavoriteIds: <int>{},
      );

      container.dispose();
      container = ProviderContainer(
        overrides: [
          workingDbPopulatedProvider.overrideWith(
            _AlwaysPopulatedWorkingDb.new,
          ),
          contactsListRepositoryProvider.overrideWith(
            (ref) async => const <ContactSummary>[
              ContactSummary(
                participantId: 42,
                displayName: 'Ada Lovelace',
                autoGeneratedName: 'Ada Lovelace',
                shortName: 'Ada',
                totalChats: 1,
                totalMessages: 2,
                origin: ParticipantOrigin.working,
                handleCount: 1,
              ),
            ],
          ),
          filteredPickerSectionsProvider.overrideWith(
            (ref) async => readySections,
          ),
          pickerFilterProvider.overrideWith(_TestPickerFilter.new),
        ],
      );

      final initialSnapshot = container.read(contactChooserSnapshotProvider);
      expect(initialSnapshot.loadState, ContactChooserLoadState.loading);

      await container.read(contactsListRepositoryProvider.future);
      await container.read(filteredPickerSectionsProvider.future);

      final readySnapshot = container.read(contactChooserSnapshotProvider);
      expect(readySnapshot.loadState, ContactChooserLoadState.ready);
      expect(readySnapshot.pickerMode, ContactPickerMode.flat);
      expect(readySnapshot.pickerFilterMode, PickerFilterMode.all);
      expect(readySnapshot.filteredSections, same(readySections));
    });

    test('resolves message scope toggle spec to inert payload', () async {
      container
          .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
          .setRack([
            const CassetteSpec.contacts(
              ContactsCassetteSpec.messageScopeToggle(contactId: 42),
            ),
          ]);

      final payload = _contactMessageScopeTogglePayload(
        await container.read(
          cassetteWidgetCoordinatorProvider(SidebarMode.messages).future,
        ),
      );

      expect(payload.contactId, 42);
      expect(payload.isNaked, isTrue);
    });

    test('resolves contact hero summary spec to inert payload', () async {
      container
          .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
          .setRack([
            const CassetteSpec.contacts(
              ContactsCassetteSpec.contactHeroSummary(chosenContactId: 42),
            ),
          ]);

      final payload = _contactHeroSummaryPayload(
        await container.read(
          cassetteWidgetCoordinatorProvider(SidebarMode.messages).future,
        ),
      );

      expect(payload.contactId, 42);
      expect(payload.cassetteIndex, 0);
      expect(payload.isNaked, isTrue);
      expect(payload.shouldExpand, isFalse);
    });

    test('resolves contact selection control spec to inert payload', () async {
      container
          .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
          .setRack([
            const CassetteSpec.contacts(
              ContactsCassetteSpec.contactSelectionControl(chosenContactId: 42),
            ),
          ]);

      final payload = _contactSelectionControlPayload(
        await container.read(
          cassetteWidgetCoordinatorProvider(SidebarMode.messages).future,
        ),
      );

      expect(payload.contactId, 42);
      expect(payload.cassetteIndex, 0);
      expect(payload.isNaked, isTrue);
    });

    test('resolves handle filter spec to inert payload', () async {
      container
          .read(cassetteRackStateProvider(SidebarMode.messages).notifier)
          .setRack([
            const CassetteSpec.contacts(
              ContactsCassetteSpec.handleFilter(
                contactId: 42,
                selectedHandleId: 7,
              ),
            ),
          ]);

      final payload = _handleFilterPayload(
        await container.read(
          cassetteWidgetCoordinatorProvider(SidebarMode.messages).future,
        ),
      );

      expect(payload.contactId, 42);
      expect(payload.selectedHandleId, 7);
      expect(payload.cassetteIndex, 0);
      expect(payload.isNaked, isTrue);
    });
  });
}

SharedBodyModelSidebarCassettePayload _sharedBodyModelPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<SharedBodyModelSidebarCassettePayload>());
  return payload as SharedBodyModelSidebarCassettePayload;
}

StrayHandlesReviewCassettePayload _strayHandlesReviewPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<StrayHandlesReviewCassettePayload>());
  return payload as StrayHandlesReviewCassettePayload;
}

StrayHandlesModeSwitcherCassettePayload _strayHandlesModeSwitcherPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<StrayHandlesModeSwitcherCassettePayload>());
  return payload as StrayHandlesModeSwitcherCassettePayload;
}

UnmatchedHandlesCassettePayload _unmatchedHandlesPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<UnmatchedHandlesCassettePayload>());
  return payload as UnmatchedHandlesCassettePayload;
}

StrayPhoneNumbersCassettePayload _strayPhoneNumbersPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<StrayPhoneNumbersCassettePayload>());
  return payload as StrayPhoneNumbersCassettePayload;
}

StrayEmailsCassettePayload _strayEmailsPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<StrayEmailsCassettePayload>());
  return payload as StrayEmailsCassettePayload;
}

SendLogsInfoCassettePayload _sendLogsInfoPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<SendLogsInfoCassettePayload>());
  return payload as SendLogsInfoCassettePayload;
}

ReimportDataInfoCassettePayload _reimportDataInfoPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<ReimportDataInfoCassettePayload>());
  return payload as ReimportDataInfoCassettePayload;
}

AttachmentArchiveSettingsCassettePayload _attachmentArchiveSettingsPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<AttachmentArchiveSettingsCassettePayload>());
  return payload as AttachmentArchiveSettingsCassettePayload;
}

StaticFeatureInfoSidebarCassettePayload _staticFeatureInfoPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<StaticFeatureInfoSidebarCassettePayload>());
  return payload as StaticFeatureInfoSidebarCassettePayload;
}

RecoveredUnlinkedNavigatorCassettePayload _recoveredUnlinkedNavigatorPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<RecoveredUnlinkedNavigatorCassettePayload>());
  return payload as RecoveredUnlinkedNavigatorCassettePayload;
}

RecoveredNoHandleFromMeNavigatorCassettePayload
_recoveredNoHandleNavigatorPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<RecoveredNoHandleFromMeNavigatorCassettePayload>());
  return payload as RecoveredNoHandleFromMeNavigatorCassettePayload;
}

ContactChooserCassettePayload _contactChooserPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<ContactChooserCassettePayload>());
  return payload as ContactChooserCassettePayload;
}

ContactHeroSummaryCassettePayload _contactHeroSummaryPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<ContactHeroSummaryCassettePayload>());
  return payload as ContactHeroSummaryCassettePayload;
}

ContactMessageScopeToggleCassettePayload _contactMessageScopeTogglePayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<ContactMessageScopeToggleCassettePayload>());
  return payload as ContactMessageScopeToggleCassettePayload;
}

ContactSelectionControlCassettePayload _contactSelectionControlPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<ContactSelectionControlCassettePayload>());
  return payload as ContactSelectionControlCassettePayload;
}

HandleFilterCassettePayload _handleFilterPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<HandleFilterCassettePayload>());
  return payload as HandleFilterCassettePayload;
}

TopChatMenuCassettePayload _topChatMenuPayload(
  List<ResolvedSidebarCassette> resolvedCassettes,
) {
  expect(resolvedCassettes, hasLength(1));
  final payload = resolvedCassettes.single.payload;
  expect(payload, isA<TopChatMenuCassettePayload>());
  return payload as TopChatMenuCassettePayload;
}

class _AlwaysPopulatedWorkingDb extends WorkingDbPopulated {
  @override
  bool build() {
    return true;
  }
}

class _TestPickerFilter extends PickerFilter {
  @override
  PickerFilterMode build() {
    return PickerFilterMode.all;
  }
}
