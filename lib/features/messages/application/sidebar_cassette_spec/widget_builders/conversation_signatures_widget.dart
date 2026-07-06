import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../config/theme/colors/theme_colors.dart';
import '../../../../../config/theme/spacing/app_spacing.dart';
import '../../../../../config/theme/theme_typography.dart';
import '../../../../../config/theme/widgets/theme_widgets.dart';
import '../../../../../core/util/count_label_formatter.dart';
import '../../../../../core/util/date_label_formatter.dart';
import '../../../../../essentials/conversation_graph/feature_level_providers.dart'
    show conversationFavouritesControllerProvider;
import '../../../../../essentials/conversation_graph/presentation/widgets/conversation_favourite_button.dart';
import '../../../../../essentials/conversation_graph/presentation/widgets/conversation_signature_card.dart';
import '../../../../../essentials/sidebar/feature_level_providers.dart'
    show sidebarFlowProvider;
import '../../../../../essentials/sidebar/presentation/view/sidebar_grouped_control_section_surface.dart';
import '../../../presentation/widgets/conversation_signature_card_presentation.dart';
import '../resolver_tools/conversation_navigation_actions_provider.dart';
import '../resolver_tools/conversation_signature_display_provider.dart';
import '../resolver_tools/conversation_signature_preferences_actions_provider.dart';
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
    final cardStyle = conversationSignatureCardStyle(colors, typography);
    final preferences = ref.watch(
      conversationSignaturePreferencesControllerProvider,
    );
    final favourites = ref.watch(conversationFavouritesControllerProvider);
    final favouriteConversationIds = favourites.coreConversationIds;
    final selectedConversationId = ref.watch(
      sidebarFlowProvider.select((state) => state.selectedConversationId),
    );
    final browseSignaturesAsync =
        preferences.mode == ConversationSignatureMode.browse
        ? ref.watch(
            conversationSignatureDisplayProvider(
              searchQuery: _searchQuery,
              filter: preferences.filter,
              sort: preferences.sort,
            ),
          )
        : null;
    final isSortEnabled =
        browseSignaturesAsync?.maybeWhen(
          data: (signatures) => signatures.length > 6,
          orElse: () => true,
        ) ??
        true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ConversationSignatureModeToggle(
          mode: preferences.mode,
          onChanged: (mode) {
            unawaited(
              ref
                  .read(
                    conversationSignaturePreferencesActionsProvider.notifier,
                  )
                  .setMode(mode),
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        if (preferences.mode == ConversationSignatureMode.browse) ...[
          _ConversationSignatureControls(
            searchController: _searchController,
            filter: preferences.filter,
            sort: preferences.sort,
            isSortEnabled: isSortEnabled,
            onSearchChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            onFilterChanged: (value) {
              unawaited(
                ref
                    .read(
                      conversationSignaturePreferencesActionsProvider.notifier,
                    )
                    .setFilter(value),
              );
            },
            onSortChanged: (value) {
              unawaited(
                ref
                    .read(
                      conversationSignaturePreferencesActionsProvider.notifier,
                    )
                    .setSort(value),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _conversationSignatureListInset,
            ),
            child: preferences.mode == ConversationSignatureMode.favourites
                ? _ConversationSignatureListAsync(
                    signaturesAsync: ref.watch(
                      favouriteConversationSignatureDisplayProvider(
                        conversationIds: favouriteConversationIds,
                      ),
                    ),
                    emptyMessage:
                        'No favourite conversations yet.\n'
                        'Click the star beside a conversation to add it here.',
                    loadingMessage: 'Loading favourites...',
                    errorMessagePrefix: 'Unable to load favourites.',
                    selectedConversationId: selectedConversationId,
                    cardStyle: favouriteConversationSignatureCardStyle(
                      colors,
                      typography,
                    ),
                  )
                : _ConversationSignatureListAsync(
                    signaturesAsync: browseSignaturesAsync!,
                    titleContextForSignature: _titleContextForSort(
                      preferences.sort,
                    ),
                    summaryHighlightForSignature: _summaryHighlightForSort(
                      preferences.sort,
                    ),
                    highlightedMonthForSignature: _highlightedMonthForSort(
                      preferences.sort,
                    ),
                    emptyMessage: 'No matching conversations.',
                    loadingMessage: 'Loading conversations...',
                    errorMessagePrefix:
                        'Unable to load conversation signatures.',
                    selectedConversationId: selectedConversationId,
                    cardStyle: cardStyle,
                  ),
          ),
        ),
      ],
    );
  }
}

const double _conversationSignatureListInset = 12;
const double _conversationSignatureControlInset = 12;

class _ConversationSignatureStatus extends StatelessWidget {
  const _ConversationSignatureStatus({
    required this.message,
    required this.colors,
    required this.typography,
  });

  final String message;
  final ThemeColors colors;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: typography.caption.copyWith(color: colors.content.textSecondary),
    );
  }
}

class _ConversationSignatureListAsync extends ConsumerWidget {
  const _ConversationSignatureListAsync({
    required this.signaturesAsync,
    required this.emptyMessage,
    required this.loadingMessage,
    required this.errorMessagePrefix,
    required this.selectedConversationId,
    required this.cardStyle,
    this.summaryHighlightForSignature,
    this.highlightedMonthForSignature,
    this.titleContextForSignature,
  });

  final AsyncValue<List<ConversationSignatureDisplayModel>> signaturesAsync;
  final String emptyMessage;
  final String loadingMessage;
  final String errorMessagePrefix;
  final int? selectedConversationId;
  final ConversationSignatureCardStyle cardStyle;
  final ConversationSignatureSummaryHighlight Function(
    ConversationSignatureDisplayModel signature,
  )?
  summaryHighlightForSignature;
  final ConversationSignatureMonthMarker? Function(
    ConversationSignatureDisplayModel signature,
  )?
  highlightedMonthForSignature;
  final String? Function(ConversationSignatureDisplayModel signature)?
  titleContextForSignature;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final typography = ref.watch(themeTypographyProvider);

    return signaturesAsync.when(
      data: (signatures) {
        if (signatures.isEmpty) {
          return Center(
            child: _ConversationSignatureStatus(
              message: emptyMessage,
              colors: colors,
              typography: typography,
            ),
          );
        }

        return ListView.separated(
          itemCount: signatures.length,
          separatorBuilder: (context, index) => const SizedBox(height: 7),
          itemBuilder: (context, index) {
            final signature = signatures[index];
            return ConversationSignatureCard(
              signature: conversationSignatureCardDataFromDisplay(
                signature,
                titleContextLabel: titleContextForSignature?.call(signature),
                summaryHighlight:
                    summaryHighlightForSignature?.call(signature) ??
                    ConversationSignatureSummaryHighlight.none,
                highlightedMonth: highlightedMonthForSignature?.call(signature),
              ),
              style: cardStyle,
              monthColorForMessageCount:
                  conversationSignatureMonthColorForMessageCount,
              isSelected: signature.conversationId == selectedConversationId,
              trailing: ConversationFavouriteButton(
                conversationId: signature.conversationId,
              ),
              onPressed: () {
                ref
                    .read(conversationNavigationActionsProvider.notifier)
                    .selectConversation(
                      conversationId: signature.conversationId,
                    );
              },
            );
          },
        );
      },
      loading: () => Center(
        child: _ConversationSignatureStatus(
          message: loadingMessage,
          colors: colors,
          typography: typography,
        ),
      ),
      error: (error, _) => Center(
        child: _ConversationSignatureStatus(
          message: '$errorMessagePrefix $error',
          colors: colors,
          typography: typography,
        ),
      ),
    );
  }
}

class _ConversationSignatureModeToggle extends ConsumerWidget {
  const _ConversationSignatureModeToggle({
    required this.mode,
    required this.onChanged,
  });

  final ConversationSignatureMode mode;
  final ValueChanged<ConversationSignatureMode> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _conversationSignatureControlInset,
      ),
      child: AppSegmentedModeControl<ConversationSignatureMode>(
        options: ConversationSignatureMode.values,
        selectedOption: mode,
        onSelected: onChanged,
        labelBuilder: (option) {
          return switch (option) {
            ConversationSignatureMode.favourites => 'Favourites',
            ConversationSignatureMode.browse => 'Browse',
          };
        },
      ),
    );
  }
}

class _ConversationSignatureControls extends ConsumerWidget {
  const _ConversationSignatureControls({
    required this.searchController,
    required this.filter,
    required this.sort,
    required this.isSortEnabled,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onSortChanged,
  });

  final TextEditingController searchController;
  final ConversationSignatureFilter filter;
  final ConversationSignatureSort sort;
  final bool isSortEnabled;
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
                isEnabled: isSortEnabled,
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

String? Function(ConversationSignatureDisplayModel signature)?
_titleContextForSort(ConversationSignatureSort sort) {
  return switch (sort) {
    ConversationSignatureSort.mostRecentlyUpdated => _todayLastUpdatedTime,
    ConversationSignatureSort.longestRunning => _firstToLastSpanContext,
    _ => null,
  };
}

ConversationSignatureSummaryHighlight Function(
  ConversationSignatureDisplayModel signature,
)
_summaryHighlightForSort(ConversationSignatureSort sort) {
  return switch (sort) {
    ConversationSignatureSort.mostRecentlyUpdated =>
      _recentUpdateSummaryHighlight,
    ConversationSignatureSort.mostTotalMessages =>
      (_) => ConversationSignatureSummaryHighlight.messageCount,
    ConversationSignatureSort.byDateOfCreation =>
      (_) => ConversationSignatureSummaryHighlight.firstDate,
    ConversationSignatureSort.startedMostRecently =>
      (_) => ConversationSignatureSummaryHighlight.firstDate,
    ConversationSignatureSort.longestRunning =>
      (_) => ConversationSignatureSummaryHighlight.dateRange,
    ConversationSignatureSort.dormant =>
      (_) => ConversationSignatureSummaryHighlight.none,
  };
}

ConversationSignatureSummaryHighlight _recentUpdateSummaryHighlight(
  ConversationSignatureDisplayModel signature,
) {
  if (_todayLastUpdatedTime(signature) != null) {
    return ConversationSignatureSummaryHighlight.none;
  }
  return ConversationSignatureSummaryHighlight.lastDate;
}

ConversationSignatureMonthMarker? Function(
  ConversationSignatureDisplayModel signature,
)?
_highlightedMonthForSort(ConversationSignatureSort sort) {
  return switch (sort) {
    ConversationSignatureSort.dormant => _lastMessageMonthMarker,
    _ => null,
  };
}

ConversationSignatureMonthMarker? _lastMessageMonthMarker(
  ConversationSignatureDisplayModel signature,
) {
  final parsed = DateLabelFormatter.parseIso(
    signature.lastMessageAtUtc,
  )?.toLocal();
  if (parsed == null) {
    return null;
  }
  return ConversationSignatureMonthMarker(
    year: parsed.year,
    month: parsed.month,
  );
}

String? _todayLastUpdatedTime(ConversationSignatureDisplayModel signature) {
  return DateLabelFormatter.localTimeIfTodayFromIso(signature.lastMessageAtUtc);
}

String? _firstToLastSpanContext(ConversationSignatureDisplayModel signature) {
  final first = DateLabelFormatter.parseIso(
    signature.firstMessageAtUtc,
  )?.toLocal();
  final last = DateLabelFormatter.parseIso(
    signature.lastMessageAtUtc,
  )?.toLocal();
  if (first == null || last == null || last.isBefore(first)) {
    return null;
  }
  final months = (last.year - first.year) * 12 + last.month - first.month;
  return CountLabelFormatter.formatNoun(
    count: months,
    singular: 'month',
    plural: 'months',
  );
}
