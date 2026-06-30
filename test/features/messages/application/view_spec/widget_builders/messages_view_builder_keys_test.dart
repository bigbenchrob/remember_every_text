import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/features/messages/application/view_spec/widget_builders/global_timeline_builder.dart';
import 'package:remember_this_text/features/messages/application/view_spec/widget_builders/handle_lens_builder.dart';
import 'package:remember_this_text/features/messages/application/view_spec/widget_builders/messages_for_contact_builder.dart';
import 'package:remember_this_text/features/messages/application/view_spec/widget_builders/messages_for_handle_builder.dart';
import 'package:remember_this_text/features/messages/application/view_spec/widget_builders/recovered_unlinked_messages_builder.dart';
import 'package:remember_this_text/features/messages/application/view_spec/widget_builders/search_result_context_sidebar_builder.dart';
import 'package:remember_this_text/features/messages/presentation/view/contact_messages_evidence_view.dart';
import 'package:remember_this_text/features/messages/presentation/view/global_messages_evidence_view.dart';
import 'package:remember_this_text/features/messages/presentation/view/handle_lens_view.dart';
import 'package:remember_this_text/features/messages/presentation/view/handle_messages_evidence_view.dart';
import 'package:remember_this_text/features/messages/presentation/view/recovered_messages_evidence_view.dart';
import 'package:remember_this_text/features/messages/presentation/view/search_result_context_sidebar_view.dart';

void main() {
  group('message center-surface builder keys', () {
    test('contact timeline builder keys vary by contact and filter', () {
      final contact42 = buildMessagesForContactView(contactId: 42);
      final contact84 = buildMessagesForContactView(contactId: 84);
      final filtered42 = buildMessagesForContactView(
        contactId: 42,
        filterHandleId: 7,
      );

      expect(contact42.key, isA<ValueKey<String>>());
      expect(contact42.key, isNot(contact84.key));
      expect(contact42.key, isNot(filtered42.key));
    });

    test('global timeline builder keys vary by month anchor', () {
      final unanchored = buildGlobalTimelineView();
      final anchored = buildGlobalTimelineView(
        scrollToDate: DateTime.utc(2024, 1, 1),
      );

      expect(unanchored.key, isA<ValueKey<String>>());
      expect(unanchored.key, isNot(anchored.key));
    });

    test('handle timeline builder keys vary by handle', () {
      final handle12 = buildMessagesForHandleView(handleId: 12);
      final handle13 = buildMessagesForHandleView(handleId: 13);

      expect(handle12.key, isA<ValueKey<String>>());
      expect(handle12.key, isNot(handle13.key));
    });

    test('recovered timeline builder keys vary by scope meaning', () {
      final recoveredForContact = buildRecoveredUnlinkedMessagesView(
        contactId: 42,
      );
      final recoveredGlobal = buildRecoveredUnlinkedMessagesView();
      final noHandleFromMe = buildRecoveredUnlinkedMessagesView(
        onlyNoHandleFromMe: true,
      );

      expect(recoveredForContact.key, isA<ValueKey<String>>());
      expect(recoveredForContact.key, isNot(recoveredGlobal.key));
      expect(recoveredGlobal.key, isNot(noHandleFromMe.key));
    });
  });

  group('message center-surface builder targets', () {
    test('active message builders return evidence-spine views', () {
      expect(
        buildMessagesForContactView(contactId: 42),
        isA<ContactMessagesEvidenceView>(),
      );
      expect(buildGlobalTimelineView(), isA<GlobalMessagesEvidenceView>());
      expect(
        buildMessagesForHandleView(handleId: 12),
        isA<HandleMessagesEvidenceView>(),
      );
      expect(
        buildRecoveredUnlinkedMessagesView(contactId: 42),
        isA<RecoveredMessagesEvidenceView>(),
      );
      expect(buildHandleLensView(handleId: 12), isA<HandleLensView>());
      expect(
        const SearchResultContextSidebarBuilder().build(
          messageId: 100,
          chatId: 200,
          beforeCount: 5,
          afterCount: 10,
        ),
        isA<SearchResultContextSidebarView>(),
      );
    });
  });
}
