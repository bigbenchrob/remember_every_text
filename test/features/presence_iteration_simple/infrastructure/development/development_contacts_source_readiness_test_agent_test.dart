import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/presence/domain/services/test_agent.dart';
import 'package:remember_this_text/features/presence_iteration_simple/infrastructure/development/development_contacts_source_readiness_test_agent.dart';

void main() {
  test('selects the current source afresh for every evaluation', () async {
    var selected = _RecordingTestAgent(result: false);
    final unavailable = selected;
    final available = _RecordingTestAgent(result: true);
    final agent = DevelopmentContactsSourceReadinessTestAgent(
      testAgentForCurrentMode: () async => selected,
    );

    expect(await agent.evaluate(), isFalse);
    selected = available;
    expect(await agent.evaluate(), isTrue);

    expect(unavailable.invocationCount, 1);
    expect(available.invocationCount, 1);
  });
}

final class _RecordingTestAgent implements TestAgent {
  _RecordingTestAgent({required this.result});

  final bool result;
  int invocationCount = 0;

  @override
  Future<bool> evaluate() async {
    invocationCount += 1;
    return result;
  }
}
