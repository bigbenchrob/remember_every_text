import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/spacing/app_spacing.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../config/theme/widgets/theme_widgets.dart';
import '../../../../../essentials/conversation_graph/application/conversation_favourites/conversation_favourites_provider.dart';
import '../../../../../essentials/conversation_graph/presentation/widgets/conversation_favourite_button.dart';
import '../../../../../essentials/conversation_graph/presentation/widgets/conversation_signature_card.dart';
import '../../../../../essentials/sidebar/feature_level_providers.dart';
import '../../../../../essentials/sidebar/presentation/view/sidebar_grouped_control_section_surface.dart';
import '../../../domain/calendar_heatmap_timeline_data.dart';
import '../../../feature_level_providers.dart';
import '../../../presentation/widgets/calendar_heatmap_timeline_widget.dart';
import '../resolver_tools/conversation_signature_display_provider.dart';
import '../resolver_tools/conversation_signature_preferences_provider.dart';

class ConversationSignaturesWidget extends ConsumerStatefulWidget {
  const ConversationSignaturesWidget({super.key});

  @override
  ConsumerState<ConversationSignaturesWidget> createState() =>
      _ConversationSignaturesWidgetState();
}

class _ConversationSignaturesWidgetState
    extends ConsumerState<ConversationSignaturesWidget> {
  late final TextEditingController _searchController;
  var _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final cardStyle = _conversationSignatureCardStyle(colors, typography);
    final preferences = ref.watch(
      conversationSignaturePreferencesControllerProvider,
    );
    final favourites = ref.watch(conversationFavouritesControllerProvider);
    final favouriteConversationIds = favourites.coreConversationIds;
    final favouriteSignaturesAsync = ref.watch(
      favouriteConversationSignatureDisplayProvider(
        conversationIds: favouriteConversationIds,
      ),
    );
    final signaturesAsync = ref.watch(
      conversationSignatureDisplayProvider(
        searchQuery: _searchQuery,
        filter: preferences.filter,
        sort: preferences.sort,
        excludedFavouriteConversationIds: favouriteConversationIds,
      ),
    );
    final selectedConversationId = ref.watch(
      sidebarFlowProvider.select((state) => state.selectedConversationId),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        favouriteSignaturesAsync.when(
          data: (favouriteSignatures) {
            if (favouriteSignatures.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _conversationSignatureListInset,
              ),
              child: _FavouriteConversationSection(
                signatures: favouriteSignatures,
                selectedConversationId: selectedConversationId,
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
        _ConversationSignatureControls(
          searchController: _searchController,
          filter: preferences.filter,
          sort: preferences.sort,
          onSearchChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          onFilterChanged: (value) {
            unawaited(
              ref
                  .read(
                    conversationSignaturePreferencesControllerProvider.notifier,
                  )
                  .setFilter(value),
            );
          },
          onSortChanged: (value) {
            unawaited(
              ref
                  .read(
                    conversationSignaturePreferencesControllerProvider.notifier,
                  )
                  .setSort(value),
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _conversationSignatureListInset,
            ),
            child: signaturesAsync.when(
              data: (signatures) {
                if (signatures.isEmpty) {
                  return const Center(
                    child: Text('No matching conversations.'),
                  );
                }

                return ListView.separated(
                  itemCount: signatures.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 7),
                  itemBuilder: (context, index) {
                    final signature = signatures[index];
                    return ConversationSignatureCard(
                      signature: _toCardData(signature),
                      style: cardStyle,
                      monthColorForMessageCount:
                          _conversationMonthColorForMessageCount,
                      isSelected:
                          signature.conversationId == selectedConversationId,
                      trailing: ConversationFavouriteButton(
                        conversationId: signature.conversationId,
                      ),
                      onPressed: () {
                        ref
                            .read(
                              conversationNavigationActionsProvider.notifier,
                            )
                            .selectConversation(
                              conversationId: signature.conversationId,
                            );
                      },
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: Text('Loading conversations...')),
              error: (error, _) => Center(
                child: Text('Unable to load conversation signatures. $error'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

const double _conversationSignatureListInset = 12;
const double _conversationSignatureControlInset = 12;

class _FavouriteConversationSection extends ConsumerWidget {
  const _FavouriteConversationSection({
    required this.signatures,
    required this.selectedConversationId,
  });

  final List<ConversationSignatureDisplayModel> signatures;
  final int? selectedConversationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final cardStyle = _favouriteConversationSignatureCardStyle(
      colors,
      typography,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Favourites',
                    style: typography.caption.copyWith(
                      color: colors.content.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  'Core',
                  style: typography.caption.copyWith(
                    color: colors.content.textTertiary.withValues(alpha: 0.68),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          for (var index = 0; index < signatures.length; index++) ...[
            if (index > 0) const SizedBox(height: 5),
            ConversationSignatureCard(
              signature: _toCardData(signatures[index]),
              style: cardStyle,
              monthColorForMessageCount: _conversationMonthColorForMessageCount,
              isSelected:
                  signatures[index].conversationId == selectedConversationId,
              trailing: ConversationFavouriteButton(
                conversationId: signatures[index].conversationId,
              ),
              onPressed: () {
                ref
                    .read(conversationNavigationActionsProvider.notifier)
                    .selectConversation(
                      conversationId: signatures[index].conversationId,
                    );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _ConversationSignatureControls extends ConsumerWidget {
  const _ConversationSignatureControls({
    required this.searchController,
    required this.filter,
    required this.sort,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onSortChanged,
  });

  final TextEditingController searchController;
  final ConversationSignatureFilter filter;
  final ConversationSignatureSort sort;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ConversationSignatureFilter> onFilterChanged;
  final ValueChanged<ConversationSignatureSort> onSortChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);
    final labelStyle = typography.caption.copyWith(
      color: colors.content.textTertiary,
      fontWeight: FontWeight.w500,
    );
    final valueStyle = typography.caption.copyWith(
      color: colors.content.textPrimary,
      fontWeight: FontWeight.w500,
    );

    return SidebarGroupedControlSectionSurface(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _conversationSignatureControlInset,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surfaces.control,
                  border: Border.all(color: colors.lines.borderSubtle),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  child: CupertinoTextField.borderless(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    placeholder: 'Find conversations',
                    placeholderStyle: typography.caption.copyWith(
                      color: colors.content.textTertiary,
                    ),
                    style: typography.caption.copyWith(
                      color: colors.content.textPrimary,
                    ),
                    prefix: Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: Icon(
                        CupertinoIcons.search,
                        size: 13,
                        color: colors.content.textTertiary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppThemeWidgets.dropdownMenu<ConversationSignatureFilter>(
                options: ConversationSignatureFilter.values,
                selectedOption: filter,
                onSelected: onFilterChanged,
                optionLabelBuilder: conversationSignatureFilterLabel,
                leadingLabel: 'Show',
                triggerPadding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 7,
                ),
                itemPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                triggerBorderRadius: BorderRadius.circular(6),
                panelBorderRadius: BorderRadius.circular(8),
                trailingIconSize: 12,
                leadingLabelStyle: labelStyle,
                selectedValueStyle: valueStyle,
              ),
              const SizedBox(height: AppSpacing.xs),
              AppThemeWidgets.dropdownMenu<ConversationSignatureSort>(
                options: ConversationSignatureSort.values,
                selectedOption: sort,
                onSelected: onSortChanged,
                optionLabelBuilder: conversationSignatureSortLabel,
                leadingLabel: 'Sort',
                triggerPadding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 7,
                ),
                itemPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                triggerBorderRadius: BorderRadius.circular(6),
                panelBorderRadius: BorderRadius.circular(8),
                trailingIconSize: 12,
                leadingLabelStyle: labelStyle,
                selectedValueStyle: valueStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

ConversationSignatureCardData _toCardData(
  ConversationSignatureDisplayModel signature,
) {
  return ConversationSignatureCardData(
    conversationId: signature.conversationId,
    title: signature.title,
    participantCount: signature.participantCount,
    messageCount: signature.messageCount,
    firstMessageAtUtc: signature.firstMessageAtUtc,
    lastMessageAtUtc: signature.lastMessageAtUtc,
    activityMonths: signature.activityMonths,
  );
}

Color _conversationMonthColorForMessageCount(int messageCount) {
  return calendarHeatmapColorForIntensity(
    MonthIntensity.fromMessageCount(messageCount),
  );
}

ConversationSignatureCardStyle _conversationSignatureCardStyle(
  ThemeColors colors,
  ThemeTypography typography,
) {
  return ConversationSignatureCardStyle(
    backgroundColor: colors.surfaces.surface.withValues(alpha: 0.14),
    hoverBackgroundColor: colors.surfaces.hover,
    selectedBackgroundColor: colors.surfaces.selected,
    borderColor: colors.lines.borderSubtle.withValues(alpha: 0),
    hoverBorderColor: colors.lines.borderSubtle.withValues(alpha: 0.38),
    selectedBorderColor: colors.accents.selection.withValues(alpha: 0.58),
    titleStyle: typography.callout.copyWith(
      color: colors.content.textPrimary,
      fontWeight: FontWeight.w600,
    ),
    selectedTitleStyle: typography.callout.copyWith(
      color: colors.content.textPrimary,
      fontWeight: FontWeight.w600,
    ),
    participantSuffixStyle: typography.caption.copyWith(
      color: colors.content.textTertiary.withValues(alpha: 0.68),
      fontWeight: FontWeight.w500,
    ),
    summaryStyle: typography.caption.copyWith(
      color: colors.content.textTertiary.withValues(alpha: 0.78),
    ),
    emptyMonthBorderColor: colors.lines.borderSubtle,
  );
}

ConversationSignatureCardStyle _favouriteConversationSignatureCardStyle(
  ThemeColors colors,
  ThemeTypography typography,
) {
  return ConversationSignatureCardStyle(
    backgroundColor: colors.surfaces.surface.withValues(alpha: 0.38),
    hoverBackgroundColor: colors.surfaces.hover,
    selectedBackgroundColor: colors.surfaces.selected,
    borderColor: colors.lines.borderSubtle.withValues(alpha: 0.18),
    hoverBorderColor: colors.lines.borderSubtle.withValues(alpha: 0.42),
    selectedBorderColor: colors.accents.selection.withValues(alpha: 0.6),
    titleStyle: typography.callout.copyWith(
      color: colors.content.textPrimary,
      fontWeight: FontWeight.w600,
    ),
    selectedTitleStyle: typography.callout.copyWith(
      color: colors.content.textPrimary,
      fontWeight: FontWeight.w700,
    ),
    participantSuffixStyle: typography.caption.copyWith(
      color: colors.content.textTertiary.withValues(alpha: 0.72),
      fontWeight: FontWeight.w500,
    ),
    summaryStyle: typography.caption.copyWith(
      color: colors.content.textTertiary.withValues(alpha: 0.8),
    ),
    emptyMonthBorderColor: colors.lines.borderSubtle,
  );
}
