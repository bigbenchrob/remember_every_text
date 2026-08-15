/// Establishes one fully configured Boolean fact.
abstract interface class TestAgent {
  Future<bool> evaluate();
}
