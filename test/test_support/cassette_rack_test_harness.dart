import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:remember_this_text/essentials/navigation/domain/sidebar_mode.dart';
import 'package:remember_this_text/essentials/sidebar/application/cassette_rack_state_provider.dart';
import 'package:remember_this_text/essentials/sidebar/domain/entities/cassette_spec.dart';

List<Override> cassetteRackTestHarnessOverrides({
  Iterable<SidebarMode> modes = SidebarMode.values,
}) {
  return [
    for (final mode in modes)
      cassetteRackStateProvider(
        mode,
      ).overrideWith(_CassetteRackStateTestHarness.new),
  ];
}

extension CassetteRackStateTestHarnessExtension on CassetteRackState {
  void setRackForTesting(List<CassetteSpec> cassettes) {
    seedRackForTest(cassettes);
  }

  void seedRackForTest(List<CassetteSpec> cassettes) {
    final self = this;
    if (self is! _CassetteRackStateTestHarness) {
      throw StateError(
        'Cassette rack test harness override is required before seeding an '
        'exact rack shape.',
      );
    }

    self.seedExactRack(cassettes);
  }
}

class _CassetteRackStateTestHarness extends CassetteRackState {
  void seedExactRack(List<CassetteSpec> cassettes) {
    state = CassetteRack(cassettes: List<CassetteSpec>.unmodifiable(cassettes));
  }
}
