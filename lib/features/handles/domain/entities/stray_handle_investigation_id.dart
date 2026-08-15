import 'package:flutter/foundation.dart';

import '../../../../essentials/navigation/domain/entities/investigation_identity.dart';

/// Identifies one episode of the user's unfamiliar-source investigation.
///
/// Equal filters do not imply the same investigation. Navigation compares this
/// opaque provenance for equality without interpreting the selected controls.
@immutable
final class StrayHandleInvestigationId implements InvestigationIdentity {
  const StrayHandleInvestigationId(this.generation);

  static const initial = StrayHandleInvestigationId(0);

  final int generation;

  StrayHandleInvestigationId next() {
    return StrayHandleInvestigationId(generation + 1);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is StrayHandleInvestigationId && other.generation == generation;
  }

  @override
  int get hashCode => generation.hashCode;

  @override
  String toString() {
    return 'StrayHandleInvestigationId($generation)';
  }
}
