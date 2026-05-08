abstract interface class Reader<TSnapshot> {
  Future<TSnapshot> read();
}

abstract interface class Integrator<TInput, TOutput> {
  TOutput integrate(TInput input);
}

abstract interface class Orchestrator<TResult> {
  Future<TResult> run();
}
