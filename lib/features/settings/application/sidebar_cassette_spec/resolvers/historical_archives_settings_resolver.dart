import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../payloads/historical_archives_settings_cassette_payload.dart';

part 'historical_archives_settings_resolver.g.dart';

@riverpod
class HistoricalArchivesSettingsResolver
    extends _$HistoricalArchivesSettingsResolver {
  @override
  void build() {
    // Stateless resolver; called by the settings cassette workflow.
  }

  HistoricalArchivesSettingsCassettePayload resolve({
    required int cassetteIndex,
    List<HistoricalArchiveSidebarSourceSummary> knownSources = const [],
  }) {
    return HistoricalArchivesSettingsCassettePayload(
      knownSources: knownSources,
    );
  }
}
