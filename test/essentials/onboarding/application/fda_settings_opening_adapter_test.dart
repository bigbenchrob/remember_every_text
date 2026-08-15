import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/onboarding/application/fda_settings_opening_adapter.dart';
import 'package:remember_this_text/essentials/onboarding/application/full_disk_access.dart';

void main() {
  test('delegates Settings opening and preserves failure', () async {
    final fullDiskAccess = _FakeFullDiskAccess();
    final adapter = FdaSettingsOpeningAdapter(fullDiskAccess: fullDiskAccess);

    await adapter.openSettings();
    expect(fullDiskAccess.settingsInvocationCount, 1);

    fullDiskAccess.failSettingsOpen = true;
    await expectLater(adapter.openSettings(), throwsA(isA<StateError>()));
    expect(fullDiskAccess.settingsInvocationCount, 2);
  });
}

final class _FakeFullDiskAccess implements FullDiskAccess {
  bool failSettingsOpen = false;
  int settingsInvocationCount = 0;

  @override
  String get messagesDatabasePath => '/test/Library/Messages/chat.db';

  @override
  bool canReadMessagesDatabase() => false;

  @override
  MessagesSourceAccessResult inspectMessagesSourceAccess() =>
      MessagesSourceAccessResult.accessDenied;

  @override
  Future<void> openSettings() async {
    settingsInvocationCount += 1;
    if (failSettingsOpen) {
      throw StateError('System Settings could not be opened.');
    }
  }
}
