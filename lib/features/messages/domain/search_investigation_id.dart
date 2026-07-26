import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../essentials/navigation/domain/entities/investigation_identity.dart';

/// Identifies one episode of the user's Search investigation.
///
/// Equal Search parameters do not imply the same investigation, so identity is
/// generation-based rather than derived from query values.
@immutable
final class SearchInvestigationId implements InvestigationIdentity {
  const SearchInvestigationId(this.generation);

  final int generation;

  SearchInvestigationId next() => SearchInvestigationId(generation + 1);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SearchInvestigationId && other.generation == generation;
  }

  @override
  int get hashCode => generation.hashCode;

  @override
  String toString() => 'SearchInvestigationId($generation)';
}
