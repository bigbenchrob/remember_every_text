import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db/feature_level_providers.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/working/working_database.dart';
import 'package:remember_this_text/essentials/search/feature_level_providers.dart';
import 'package:remember_this_text/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late WorkingDatabase db;
  late OverlayDatabase overlayDb;
  late SharedPreferences prefs;
  late ProviderContainer container;

  ProviderContainer createContainer({bool enableFts = false}) {
    final overrides = <Override>[
      driftWorkingDatabaseProvider.overrideWith((ref) async => db),
      overlayDatabaseProvider.overrideWith((ref) async => overlayDb),
      sharedPreferencesProvider.overrideWith((ref) async => prefs),
    ];
    if (enableFts) {
      overrides.add(useFtsSearchByDefaultProvider.overrideWith((ref) => true));
    }
    return ProviderContainer(overrides: overrides);
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = WorkingDatabase(NativeDatabase.memory());
    overlayDb = OverlayDatabase(NativeDatabase.memory());
    prefs = await SharedPreferences.getInstance();
    container = createContainer();
  });

  tearDown(() async {
    await db.close();
    await overlayDb.close();
    container.dispose();
  });

  test('searchChatMessageIds returns matching message IDs', () async {
    final chatId = await db
        .into(db.workingChats)
        .insert(const WorkingChatsCompanion(guid: Value('chat-1')));

    final msgId1 = await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'msg-1',
            chatId: chatId,
            textContent: const Value('Hello Modular Search'),
            sentAtUtc: const Value('2024-01-01T00:00:00Z'),
          ),
        );
    await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'msg-2',
            chatId: chatId,
            textContent: const Value('Other content'),
            sentAtUtc: const Value('2024-01-01T00:10:00Z'),
          ),
        );

    final service = container.read(searchServiceProvider);
    final resultIds = await service.searchChatMessageIds(
      chatId: chatId,
      query: 'modular',
    );

    expect(resultIds, hasLength(1));
    expect(resultIds.first, equals(msgId1));
  });

  test('searchContactMessageIds returns results via contact index', () async {
    const contactId = 1;
    await db
        .into(db.workingParticipants)
        .insert(
          const WorkingParticipantsCompanion(
            id: Value(contactId),
            originalName: Value('Test User'),
            displayName: Value('Test User'),
            shortName: Value('Test'),
          ),
        );
    final chatId = await db
        .into(db.workingChats)
        .insert(const WorkingChatsCompanion(guid: Value('chat-2')));
    final messageId = await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'msg-contact',
            chatId: chatId,
            textContent: const Value('Contact specific search'),
            sentAtUtc: const Value('2024-01-02T00:00:00Z'),
          ),
        );
    await db
        .into(db.contactMessageIndex)
        .insert(
          ContactMessageIndexCompanion.insert(
            contactId: contactId,
            ordinal: 0,
            messageId: messageId,
            monthKey: '2024-01',
            sentAtUtc: const Value('2024-01-02T00:00:00Z'),
          ),
        );

    final service = container.read(searchServiceProvider);
    final resultIds = await service.searchContactMessageIds(
      contactId: contactId,
      query: 'specific',
    );

    expect(resultIds, hasLength(1));
    expect(resultIds.first, equals(messageId));
  });

  test('fts multi-term search returns matching IDs', () async {
    final chatId = await db
        .into(db.workingChats)
        .insert(const WorkingChatsCompanion(guid: Value('chat-fts')));
    final msgId1 = await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'fts-1',
            chatId: chatId,
            textContent: const Value('hello world modular indexing'),
            sentAtUtc: const Value('2024-01-03T00:00:00Z'),
          ),
        );
    await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'fts-2',
            chatId: chatId,
            textContent: const Value('hello'),
            sentAtUtc: const Value('2024-01-02T00:00:00Z'),
          ),
        );

    final ftsContainer = createContainer(enableFts: true);
    final service = ftsContainer.read(searchServiceProvider);

    final resultIds = await service.searchChatMessageIds(
      chatId: chatId,
      query: 'hello world',
    );

    expect(resultIds, hasLength(1));
    expect(resultIds.first, equals(msgId1));
    ftsContainer.dispose();
  });

  test('fts search respects contact filter', () async {
    const contactId = 99;
    await db
        .into(db.workingParticipants)
        .insert(
          const WorkingParticipantsCompanion(
            id: Value(contactId),
            originalName: Value('Contact FTS'),
            displayName: Value('Contact FTS'),
            shortName: Value('Contact'),
          ),
        );
    final chatId = await db
        .into(db.workingChats)
        .insert(const WorkingChatsCompanion(guid: Value('chat-contact')));
    final firstId = await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'contact-fts',
            chatId: chatId,
            textContent: const Value('searchable term contact'),
            sentAtUtc: const Value('2024-01-04T00:00:00Z'),
          ),
        );
    await db
        .into(db.contactMessageIndex)
        .insert(
          ContactMessageIndexCompanion.insert(
            contactId: contactId,
            ordinal: 0,
            messageId: firstId,
            monthKey: '2024-01',
            sentAtUtc: const Value('2024-01-04T00:00:00Z'),
          ),
        );

    final ftsContainer = createContainer(enableFts: true);
    final service = ftsContainer.read(searchServiceProvider);
    final resultIds = await service.searchContactMessageIds(
      contactId: contactId,
      query: 'searchable term',
    );
    expect(resultIds, hasLength(1));
    expect(resultIds.first, equals(firstId));
    ftsContainer.dispose();
  });

  test('fts contact search returns newest-first ids', () async {
    const contactId = 101;
    await db
        .into(db.workingParticipants)
        .insert(
          const WorkingParticipantsCompanion(
            id: Value(contactId),
            originalName: Value('Ordered Contact'),
            displayName: Value('Ordered Contact'),
            shortName: Value('Ordered'),
          ),
        );

    final chatId = await db
        .into(db.workingChats)
        .insert(const WorkingChatsCompanion(guid: Value('chat-contact-order')));

    final olderMessageId = await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'contact-order-old',
            chatId: chatId,
            textContent: const Value('target'),
            sentAtUtc: const Value('2024-01-01T00:00:00Z'),
          ),
        );
    final newerMessageId = await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'contact-order-new',
            chatId: chatId,
            textContent: const Value(
              'target with filler words that reduce ranking density for this document',
            ),
            sentAtUtc: const Value('2024-01-02T00:00:00Z'),
          ),
        );

    await db
        .into(db.contactMessageIndex)
        .insert(
          ContactMessageIndexCompanion.insert(
            contactId: contactId,
            ordinal: 0,
            messageId: olderMessageId,
            monthKey: '2024-01',
            sentAtUtc: const Value('2024-01-01T00:00:00Z'),
          ),
        );
    await db
        .into(db.contactMessageIndex)
        .insert(
          ContactMessageIndexCompanion.insert(
            contactId: contactId,
            ordinal: 1,
            messageId: newerMessageId,
            monthKey: '2024-01',
            sentAtUtc: const Value('2024-01-02T00:00:00Z'),
          ),
        );

    final ftsContainer = createContainer(enableFts: true);
    final service = ftsContainer.read(searchServiceProvider);

    final resultIds = await service.searchContactMessageIds(
      contactId: contactId,
      query: 'target',
    );

    expect(
      resultIds.take(2).toList(),
      equals([newerMessageId, olderMessageId]),
    );
    ftsContainer.dispose();
  });

  test('global search retrieves and prioritizes direct tag matches', () async {
    final chatId = await db
        .into(db.workingChats)
        .insert(const WorkingChatsCompanion(guid: Value('chat-tag-global')));

    final incidentalBodyMatchId = await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'tag-global-body',
            chatId: chatId,
            textContent: const Value(
              'This body happens to mention milosz once.',
            ),
            sentAtUtc: const Value('2024-01-01T00:00:00Z'),
          ),
        );
    final directTagMatchId = await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'tag-global-overlay',
            chatId: chatId,
            textContent: const Value('Completely unrelated body text.'),
            sentAtUtc: const Value('2024-01-03T00:00:00Z'),
          ),
        );

    await overlayDb.addMessageUserTags(
      messageGuid: 'tag-global-overlay',
      tags: const <String>['Miłosz'],
    );

    final ftsContainer = createContainer(enableFts: true);
    final service = ftsContainer.read(searchServiceProvider);
    final resultIds = await service.searchGlobalMessageIds(query: 'milosz');

    expect(
      resultIds.take(2).toList(),
      equals([directTagMatchId, incidentalBodyMatchId]),
    );
    ftsContainer.dispose();
  });

  test(
    'contact search retrieves tag-only matches within the scoped contact',
    () async {
      const contactId = 121;
      await db
          .into(db.workingParticipants)
          .insert(
            const WorkingParticipantsCompanion(
              id: Value(contactId),
              originalName: Value('Tagged Contact'),
              displayName: Value('Tagged Contact'),
              shortName: Value('Tagged'),
            ),
          );
      final chatId = await db
          .into(db.workingChats)
          .insert(const WorkingChatsCompanion(guid: Value('chat-tag-contact')));
      final messageId = await db
          .into(db.workingMessages)
          .insert(
            WorkingMessagesCompanion.insert(
              guid: 'tag-contact-message',
              chatId: chatId,
              textContent: const Value(
                'Body text without the retrieval handle.',
              ),
              sentAtUtc: const Value('2024-02-01T00:00:00Z'),
            ),
          );
      await db
          .into(db.contactMessageIndex)
          .insert(
            ContactMessageIndexCompanion.insert(
              contactId: contactId,
              ordinal: 0,
              messageId: messageId,
              monthKey: '2024-02',
              sentAtUtc: const Value('2024-02-01T00:00:00Z'),
            ),
          );
      await overlayDb.addMessageUserTags(
        messageGuid: 'tag-contact-message',
        tags: const <String>['preparation'],
      );

      final ftsContainer = createContainer(enableFts: true);
      final service = ftsContainer.read(searchServiceProvider);
      final resultIds = await service.searchContactMessageIds(
        contactId: contactId,
        query: 'prepar',
      );

      expect(resultIds, contains(messageId));
      expect(resultIds.first, equals(messageId));
      ftsContainer.dispose();
    },
  );

  test('global search returns saved-only messages for is:saved', () async {
    final chatId = await db
        .into(db.workingChats)
        .insert(const WorkingChatsCompanion(guid: Value('chat-saved-global')));

    final unsavedMessageId = await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'saved-global-unsaved',
            chatId: chatId,
            textContent: const Value('Older unsaved message'),
            sentAtUtc: const Value('2024-03-01T00:00:00Z'),
          ),
        );
    final savedMessageId = await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'saved-global-only',
            chatId: chatId,
            textContent: const Value('Newest saved message'),
            sentAtUtc: const Value('2024-03-02T00:00:00Z'),
          ),
        );
    await overlayDb.setMessageSaved(
      messageGuid: 'saved-global-only',
      isSaved: true,
    );

    final service = container.read(searchServiceProvider);
    final resultIds = await service.searchGlobalMessageIds(query: 'is:saved');

    expect(resultIds, equals([savedMessageId]));
    expect(resultIds, isNot(contains(unsavedMessageId)));
  });

  test('chat search filters matching results by is:saved', () async {
    final chatId = await db
        .into(db.workingChats)
        .insert(const WorkingChatsCompanion(guid: Value('chat-saved-filter')));

    final savedMessageId = await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'saved-filter-kept',
            chatId: chatId,
            textContent: const Value('archive plan for testing'),
            sentAtUtc: const Value('2024-04-02T00:00:00Z'),
          ),
        );
    final unsavedMessageId = await db
        .into(db.workingMessages)
        .insert(
          WorkingMessagesCompanion.insert(
            guid: 'saved-filter-dropped',
            chatId: chatId,
            textContent: const Value('archive plan for testing'),
            sentAtUtc: const Value('2024-04-01T00:00:00Z'),
          ),
        );
    await overlayDb.setMessageSaved(
      messageGuid: 'saved-filter-kept',
      isSaved: true,
    );

    final service = container.read(searchServiceProvider);
    final resultIds = await service.searchChatMessageIds(
      chatId: chatId,
      query: 'is:saved archive',
    );

    expect(resultIds, equals([savedMessageId]));
    expect(resultIds, isNot(contains(unsavedMessageId)));
  });

  test(
    'contact search returns only saved messages in scope for is:saved',
    () async {
      const contactId = 131;
      await db
          .into(db.workingParticipants)
          .insert(
            const WorkingParticipantsCompanion(
              id: Value(contactId),
              originalName: Value('Saved Contact'),
              displayName: Value('Saved Contact'),
              shortName: Value('Saved'),
            ),
          );
      final chatId = await db
          .into(db.workingChats)
          .insert(
            const WorkingChatsCompanion(guid: Value('chat-saved-contact')),
          );
      final savedMessageId = await db
          .into(db.workingMessages)
          .insert(
            WorkingMessagesCompanion.insert(
              guid: 'saved-contact-kept',
              chatId: chatId,
              textContent: const Value('saved contact message'),
              sentAtUtc: const Value('2024-05-02T00:00:00Z'),
            ),
          );
      final unsavedMessageId = await db
          .into(db.workingMessages)
          .insert(
            WorkingMessagesCompanion.insert(
              guid: 'saved-contact-dropped',
              chatId: chatId,
              textContent: const Value('unsaved contact message'),
              sentAtUtc: const Value('2024-05-01T00:00:00Z'),
            ),
          );
      await db
          .into(db.contactMessageIndex)
          .insert(
            ContactMessageIndexCompanion.insert(
              contactId: contactId,
              ordinal: 0,
              messageId: savedMessageId,
              monthKey: '2024-05',
              sentAtUtc: const Value('2024-05-02T00:00:00Z'),
            ),
          );
      await db
          .into(db.contactMessageIndex)
          .insert(
            ContactMessageIndexCompanion.insert(
              contactId: contactId,
              ordinal: 1,
              messageId: unsavedMessageId,
              monthKey: '2024-05',
              sentAtUtc: const Value('2024-05-01T00:00:00Z'),
            ),
          );
      await overlayDb.setMessageSaved(
        messageGuid: 'saved-contact-kept',
        isSaved: true,
      );

      final service = container.read(searchServiceProvider);
      final resultIds = await service.searchContactMessageIds(
        contactId: contactId,
        query: 'is:saved',
      );

      expect(resultIds, equals([savedMessageId]));
      expect(resultIds, isNot(contains(unsavedMessageId)));
    },
  );
}
