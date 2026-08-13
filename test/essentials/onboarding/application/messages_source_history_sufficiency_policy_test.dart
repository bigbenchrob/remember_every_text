import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/onboarding/application/messages_source_history_sufficiency_policy.dart';

void main() {
  test('preserves the production sparse-history 10/11 boundary', () {
    expect(maximumSparseMessagesSourceHistoryRowCount, 10);
    expect(isMessagesSourceHistorySufficient(10), isFalse);
    expect(isMessagesSourceHistorySufficient(11), isTrue);
  });
}
