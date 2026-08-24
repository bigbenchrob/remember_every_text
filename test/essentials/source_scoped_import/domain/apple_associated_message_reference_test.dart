import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/source_scoped_import/domain/apple_associated_message_reference.dart';

void main() {
  test('preserves an ordinary source message GUID', () {
    expect(appleAssociatedMessageTargetGuid('ordinary-guid'), 'ordinary-guid');
  });

  test('extracts the GUID from Apple part references', () {
    expect(appleAssociatedMessageTargetGuid('p:0/target-guid'), 'target-guid');
    expect(appleAssociatedMessageTargetGuid('p:a/target-guid'), 'target-guid');
  });

  test('extracts the GUID from Apple balloon references', () {
    expect(appleAssociatedMessageTargetGuid('bp:target-guid'), 'target-guid');
  });

  test('preserves malformed envelopes rather than inventing identity', () {
    expect(appleAssociatedMessageTargetGuid('p:0/'), 'p:0/');
    expect(appleAssociatedMessageTargetGuid('bp:'), 'bp:');
  });
}
