import '../services/fda_settings_opening_authority.dart';
import '../services/test_agent.dart';
import 'test_agent_id.dart';
import 'trip_definition_id.dart';

sealed class Step {
  const Step({required this.id, required this.name});

  final int id;
  final String name;

  /// Completes this Step and returns its possible canonical Trip destination.
  ///
  /// Only a terminal Step's result crosses the Trip boundary.
  Future<TripDefinitionId?> complete();
}

final class TellStep extends Step {
  const TellStep({required super.id, required super.name, required this.text});

  final String text;

  @override
  Future<TripDefinitionId?> complete() => Future<TripDefinitionId?>.value();
}

final class FixedDestinationStep extends Step {
  const FixedDestinationStep({
    required super.id,
    required super.name,
    required this.destinationTripDefinitionId,
  });

  final TripDefinitionId destinationTripDefinitionId;

  @override
  Future<TripDefinitionId?> complete() =>
      Future<TripDefinitionId?>.value(destinationTripDefinitionId);
}

final class TestStep extends Step {
  const TestStep({
    required super.id,
    required super.name,
    required this.testAgentId,
    required TestAgent testAgent,
    required this.trueDestinationTripDefinitionId,
    required this.falseDestinationTripDefinitionId,
  }) : _testAgent = testAgent;

  final TestAgentId testAgentId;
  final TestAgent _testAgent;
  final TripDefinitionId? trueDestinationTripDefinitionId;
  final TripDefinitionId? falseDestinationTripDefinitionId;

  @override
  Future<TripDefinitionId?> complete() async {
    final result = await _testAgent.evaluate();
    return result
        ? trueDestinationTripDefinitionId
        : falseDestinationTripDefinitionId;
  }
}

final class OpenFdaSettingsStep extends Step {
  const OpenFdaSettingsStep({
    required super.id,
    required super.name,
    required FdaSettingsOpeningAuthority settingsOpeningAuthority,
  }) : _settingsOpeningAuthority = settingsOpeningAuthority;

  final FdaSettingsOpeningAuthority _settingsOpeningAuthority;

  @override
  Future<TripDefinitionId?> complete() async {
    await _settingsOpeningAuthority.openSettings();
    return null;
  }
}
