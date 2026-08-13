import 'dart:collection';

import '../entities/test_agent_id.dart';
import 'test_agent.dart';

final class TestAgentBinding {
  const TestAgentBinding({required this.id, required this.agent});

  final TestAgentId id;
  final TestAgent agent;
}

abstract interface class TestAgentResolver {
  TestAgent resolve(TestAgentId id);
}

/// An immutable resolver assembled explicitly at application composition.
final class ImmutableTestAgentResolver implements TestAgentResolver {
  ImmutableTestAgentResolver(Iterable<TestAgentBinding> bindings)
    : _agentsById = _buildBindings(bindings);

  final Map<TestAgentId, TestAgent> _agentsById;

  static Map<TestAgentId, TestAgent> _buildBindings(
    Iterable<TestAgentBinding> bindings,
  ) {
    final agentsById = <TestAgentId, TestAgent>{};
    for (final binding in bindings) {
      if (agentsById.containsKey(binding.id)) {
        throw DuplicateTestAgentBindingException(binding.id);
      }
      agentsById[binding.id] = binding.agent;
    }
    return UnmodifiableMapView<TestAgentId, TestAgent>(agentsById);
  }

  @override
  TestAgent resolve(TestAgentId id) {
    final agent = _agentsById[id];
    if (agent == null) {
      throw MissingTestAgentBindingException(id);
    }
    return agent;
  }
}

final class DuplicateTestAgentBindingException implements Exception {
  const DuplicateTestAgentBindingException(this.id);

  final TestAgentId id;

  @override
  String toString() => 'Duplicate Test Agent binding for $id.';
}

final class MissingTestAgentBindingException implements Exception {
  const MissingTestAgentBindingException(this.id);

  final TestAgentId id;

  @override
  String toString() => 'No Test Agent binding exists for $id.';
}
