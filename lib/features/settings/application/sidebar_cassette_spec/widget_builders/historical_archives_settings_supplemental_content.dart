import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../historical_archives_workflow_panel_model_provider.dart';
import '../payloads/historical_archives_settings_cassette_payload.dart';

class HistoricalArchivesSettingsSupplementalContent extends ConsumerWidget {
  const HistoricalArchivesSettingsSupplementalContent({
    super.key,
    required this.payload,
  });

  final HistoricalArchivesSettingsCassettePayload payload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        Text(
          'Known Archive Sources',
          style: typography.controlValue.copyWith(
            color: colors.content.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        if (payload.knownSources.isEmpty)
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaces.control,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.lines.borderSubtle, width: 0.8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'No archive folders have been added yet. When this workflow is fully wired, known sources will appear here with date range, message count, last import result, last-run counts, and last imported time.',
                style: typography.body.copyWith(
                  color: colors.content.textSecondary,
                ),
              ),
            ),
          )
        else
          for (final source in payload.knownSources) ...[
            _HistoricalArchiveSourceTile(source: source),
            const SizedBox(height: 10),
          ],
        const SizedBox(height: 14),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaces.control,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.lines.borderSubtle, width: 0.8),
          ),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                await ref
                    .read(historicalArchivesWorkflowProvider.notifier)
                    .chooseMessagesFolder();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Text(
                  'Add an Archive Folder',
                  style: typography.controlValue.copyWith(
                    color: colors.accents.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoricalArchiveSourceTile extends ConsumerWidget {
  const _HistoricalArchiveSourceTile({required this.source});

  final HistoricalArchiveSidebarSourceSummary source;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaces.control,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.lines.borderSubtle, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              source.label,
              style: typography.controlValue.copyWith(
                color: colors.content.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              source.dateRangeLabel,
              style: typography.caption1.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
            Text(
              source.messageCountLabel,
              style: typography.caption1.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
            Text(
              source.statusLabel,
              style: typography.caption1.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
            Text(
              source.lastRunSummaryLabel,
              style: typography.caption1.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
            Text(
              source.lastImportedLabel,
              style: typography.caption1.copyWith(
                color: colors.content.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
