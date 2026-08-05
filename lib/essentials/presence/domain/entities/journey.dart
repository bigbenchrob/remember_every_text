import 'step.dart';

class Journey {
  const Journey({required this.id, required this.name, required this.steps});

  final int id;
  final String name;
  final List<Step> steps;
}
