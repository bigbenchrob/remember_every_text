import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/sidebar_utilities/domain/spec_classes/sidebar_utility_cassette_spec.dart';
import '../../navigation/domain/sidebar_mode.dart';
import '../domain/entities/cassette_spec.dart';
import 'cassette_rack_state_provider.dart';
import 'ephemeral_cassette_projection_provider.dart';

part 'renderable_sidebar_cassette_specs_provider.g.dart';

final class RenderableSidebarCassetteSpec {
  const RenderableSidebarCassetteSpec({
    required this.spec,
    required this.cassetteIndex,
  });

  final CassetteSpec spec;
  final int cassetteIndex;
}

@riverpod
List<RenderableSidebarCassetteSpec> renderableSidebarCassetteSpecs(
  Ref ref,
  SidebarMode mode,
) {
  final stableRack = ref.watch(cassetteRackStateProvider(mode));
  final ephemeralRack = ref.watch(ephemeralCassetteProjectionProvider(mode));

  if (_shouldOverlaySettingsEphemeralFlow(
    mode: mode,
    stableRack: stableRack,
    ephemeralRack: ephemeralRack,
  )) {
    return List<RenderableSidebarCassetteSpec>.unmodifiable([
      ..._renderableSidebarSpecs(
        rack: CassetteRack(cassettes: [stableRack.cassettes.first]),
        cassetteIndexOffset: 0,
      ),
      ..._renderableSidebarSpecs(rack: ephemeralRack, cassetteIndexOffset: 1),
    ]);
  }

  return List<RenderableSidebarCassetteSpec>.unmodifiable([
    ..._renderableSidebarSpecs(rack: stableRack, cassetteIndexOffset: 0),
    ..._renderableSidebarSpecs(
      rack: ephemeralRack,
      cassetteIndexOffset: stableRack.cassettes.length,
    ),
  ]);
}

bool _shouldOverlaySettingsEphemeralFlow({
  required SidebarMode mode,
  required CassetteRack stableRack,
  required CassetteRack ephemeralRack,
}) {
  if (mode != SidebarMode.settings) {
    return false;
  }

  if (ephemeralRack.cassettes.isEmpty || stableRack.cassettes.isEmpty) {
    return false;
  }

  return stableRack.cassettes.first.maybeWhen(
    sidebarUtility: (sidebarUtilitySpec) {
      return sidebarUtilitySpec ==
          const SidebarUtilityCassetteSpec.settingsMenu();
    },
    orElse: () {
      return false;
    },
  );
}

List<RenderableSidebarCassetteSpec> _renderableSidebarSpecs({
  required CassetteRack rack,
  required int cassetteIndexOffset,
}) {
  return List<RenderableSidebarCassetteSpec>.generate(rack.cassettes.length, (
    index,
  ) {
    return RenderableSidebarCassetteSpec(
      spec: rack.cassettes[index],
      cassetteIndex: cassetteIndexOffset + index,
    );
  }, growable: false);
}
