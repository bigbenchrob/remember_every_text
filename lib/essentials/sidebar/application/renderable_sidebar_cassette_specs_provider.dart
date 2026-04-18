import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

  return List<RenderableSidebarCassetteSpec>.unmodifiable([
    ..._renderableSidebarSpecs(rack: stableRack, cassetteIndexOffset: 0),
    ..._renderableSidebarSpecs(
      rack: ephemeralRack,
      cassetteIndexOffset: stableRack.cassettes.length,
    ),
  ]);
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
