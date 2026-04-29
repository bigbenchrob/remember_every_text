import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../features/settings/domain/spec_classes/settings_cassette_spec.dart';
import '../../navigation/domain/sidebar_mode.dart';
import '../domain/entities/cassette_spec.dart';
import 'cassette_rack_state_provider.dart';

part 'ephemeral_cassette_projection_provider.g.dart';

@riverpod
class EphemeralCassetteProjection extends _$EphemeralCassetteProjection {
  @override
  CassetteRack build(SidebarMode mode) {
    return const CassetteRack();
  }

  void replaceProjection(CassetteSpec root) {
    state = CassetteRack(cassettes: _deriveEphemeralProjection(root));
  }

  void clear() {
    if (state.cassettes.isEmpty) {
      return;
    }

    state = const CassetteRack();
  }
}

List<CassetteSpec> _deriveEphemeralProjection(CassetteSpec root) {
  final chain = <CassetteSpec>[root];
  var next = _resolveEphemeralChild(root);

  while (next != null) {
    chain.add(next);
    next = _resolveEphemeralChild(next);
  }

  return List<CassetteSpec>.unmodifiable(chain);
}

CassetteSpec? _resolveEphemeralChild(CassetteSpec spec) {
  return spec.maybeWhen(
    settings: (settingsSpec) {
      return settingsSpec.maybeWhen(
        importHistoricalArchivePanel: () {
          return null;
        },
        importHistoricalArchivePreflight: (_) {
          return null;
        },
        importHistoricalArchiveInProgress: (_) {
          return null;
        },
        importHistoricalArchiveResult: (_) {
          return null;
        },
        sendLogsPanel: () {
          return null;
        },
        resetMessageDataPanel: () {
          return null;
        },
        orElse: () {
          throw StateError(
            'Unsupported ephemeral settings cassette spec: $settingsSpec',
          );
        },
      );
    },
    orElse: () {
      throw StateError('Unsupported ephemeral cassette root: $spec');
    },
  );
}
