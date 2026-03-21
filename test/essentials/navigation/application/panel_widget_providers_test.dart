import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:remember_this_text/essentials/navigation/application/panel_widget_providers.dart';
import 'package:remember_this_text/essentials/sidebar/presentation/view/sidebar_cassette_card.dart';
import 'package:remember_this_text/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart';

void main() {
  group('isPinnedAppControlCassette', () {
    test('returns true only for app control cassette cards', () {
      final appControlCard = SidebarCassetteCard(
        title: '',
        role: SidebarCassetteRole.appControl,
        isNaked: true,
        child: const SizedBox.shrink(),
      );
      final contextCard = SidebarCassetteCard(
        title: '',
        role: SidebarCassetteRole.contextPrimary,
        isNaked: true,
        child: const SizedBox.shrink(),
      );

      expect(isPinnedAppControlCassette(appControlCard), isTrue);
      expect(isPinnedAppControlCassette(contextCard), isFalse);
      expect(isPinnedAppControlCassette(const SizedBox.shrink()), isFalse);
    });

    test('unwraps padded cassette cards before checking pinned role', () {
      final wrappedAppControlCard = Padding(
        padding: const EdgeInsets.only(top: 8),
        child: SidebarCassetteCard(
          title: '',
          role: SidebarCassetteRole.appControl,
          isNaked: true,
          child: const SizedBox.shrink(),
        ),
      );

      expect(isPinnedAppControlCassette(wrappedAppControlCard), isTrue);
    });
  });

  group('shouldExpandSidebarCassette', () {
    test('unwraps padded cassette cards before checking expansion', () {
      final wrappedExpandingCard = Padding(
        padding: const EdgeInsets.only(top: 8),
        child: SidebarCassetteCard(
          title: '',
          shouldExpand: true,
          child: const SizedBox.shrink(),
        ),
      );
      final wrappedIntrinsicCard = Padding(
        padding: const EdgeInsets.only(top: 8),
        child: SidebarCassetteCard(title: '', child: const SizedBox.shrink()),
      );

      expect(shouldExpandSidebarCassette(wrappedExpandingCard), isTrue);
      expect(shouldExpandSidebarCassette(wrappedIntrinsicCard), isFalse);
      expect(shouldExpandSidebarCassette(const SizedBox.shrink()), isFalse);
    });
  });
}
