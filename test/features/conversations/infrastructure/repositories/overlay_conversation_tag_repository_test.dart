import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart';
import 'package:remember_this_text/features/conversations/domain/conversation_tags/conversation_tag_display.dart';
import 'package:remember_this_text/features/conversations/infrastructure/repositories/overlay_conversation_tag_repository.dart';

void main() {
  late OverlayDatabase database;
  late OverlayConversationTagRepository repository;

  setUp(() {
    database = OverlayDatabase(NativeDatabase.memory());
    repository = OverlayConversationTagRepository(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'creates tags with collapsed display and normalized duplicate key',
    () async {
      final created = await repository.createTag('  Family   Trip  ');
      final duplicate = await repository.createTag('family trip');
      final allTags = await repository.readAllTags();

      expect(created.displayName, 'Family Trip');
      expect(created.normalizedName, 'family trip');
      expect(duplicate.id, created.id);
      expect(duplicate.displayName, 'Family Trip');
      expect(allTags, hasLength(1));
    },
  );

  test('rejects empty tag names', () async {
    expect(() => repository.createTag('   '), throwsA(isA<FormatException>()));
  });

  test('persists assignment and prevents duplicate assignment rows', () async {
    final tag = await repository.createAndAssignTag(
      conversationId: 42,
      rawName: 'Family',
    );
    await repository.assignTag(conversationId: 42, tagId: tag.id);

    final tagsByConversation = await repository.readTagsByConversationIds([42]);
    final assignmentRows = await database
        .select(database.conversationTagAssignments)
        .get();

    expect(tagsByConversation[42]!.map((tag) => tag.displayName), ['Family']);
    expect(assignmentRows, hasLength(1));
  });

  test('removing assignment does not delete tag definition', () async {
    final tag = await repository.createAndAssignTag(
      conversationId: 42,
      rawName: 'Family',
    );

    await repository.removeTag(conversationId: 42, tagId: tag.id);

    final tagsByConversation = await repository.readTagsByConversationIds([42]);
    final allTags = await repository.readAllTags();

    expect(tagsByConversation[42], isEmpty);
    expect(allTags.map((tag) => tag.displayName), ['Family']);
  });

  test('persists tag visibility policy on the tag definition', () async {
    final tag = await repository.createTag('2FA');

    await repository.setTagVisibilityPolicy(
      tagId: tag.id,
      visibilityPolicy: ConversationTagVisibilityPolicy.suppressFromBrowse,
    );

    final allTags = await repository.readAllTags();

    expect(allTags.single.displayName, '2FA');
    expect(
      allTags.single.visibilityPolicy,
      ConversationTagVisibilityPolicy.suppressFromBrowse,
    );
  });
}
