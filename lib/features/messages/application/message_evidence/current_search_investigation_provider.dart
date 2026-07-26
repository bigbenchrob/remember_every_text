import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/search_investigation_id.dart';

part 'current_search_investigation_provider.g.dart';

/// Owns the identity of the current primary Search investigation.
///
/// A Search-created subordinate presentation is effective only while its
/// originating identity remains current. Navigation away does not advance the
/// identity; replacing the investigation does.
@Riverpod(keepAlive: true)
class CurrentSearchInvestigation extends _$CurrentSearchInvestigation {
  @override
  SearchInvestigationId build() => const SearchInvestigationId(0);

  SearchInvestigationId advance() {
    state = state.next();
    return state;
  }
}
