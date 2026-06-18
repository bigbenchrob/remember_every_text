import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';

import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/buttons/buttons.dart';
import '../../../contacts/feature_level_providers.dart';
import '../../../handles/feature_level_providers.dart';
import '../../application/handle_lens/handle_lens_actions_provider.dart';
import '../../application/message_evidence/message_evidence_spine_provider.dart';
import '../../domain/message_evidence/message_evidence_scope.dart';
import '../../domain/message_evidence/message_evidence_search_mode.dart';
import '../../domain/message_evidence/message_evidence_skeleton.dart';
import '../widgets/message_evidence/message_evidence_header.dart';
import '../widgets/message_evidence/message_evidence_timeline_view.dart';

/// Triage view for a single stray handle.
///
/// Shows a header with the handle value, three action buttons (Create Contact,
/// Link to Existing, Dismiss), and a shared graph-backed message evidence
/// timeline for identifying the correspondent.
class HandleLensView extends HookConsumerWidget {
  const HandleLensView({required this.handleId, super.key});

  final int handleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(themeTypographyProvider);
    final asyncHandles = ref.watch(strayHandlesProvider);
    final asyncDisplayName = ref.watch(
      handleDisplayNameProvider(handleId: handleId),
    );
    final isCreating = useState(false);
    final nameController = useTextEditingController();
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final searchMode = useState(MessageEvidenceSearchMode.allTerms);
    final isBusy = useState(false);

    useEffect(() {
      void listener() {
        searchQuery.value = searchController.text;
      }

      searchController.addListener(listener);
      return () {
        searchController.removeListener(listener);
      };
    }, [searchController]);

    // Find the stray handle summary for header info.
    final handleSummary = asyncHandles.whenOrNull(
      data: (handles) {
        final matches = handles.where((h) => h.handleId == handleId);
        return matches.isNotEmpty ? matches.first : null;
      },
    );

    // Use resolved display name (virtual contact > real contact > raw handle).
    // While identity resolution is loading, prefer the raw handle fact already
    // present in the selected stray-handle summary over an internal id label.
    final handleValue =
        asyncDisplayName.valueOrNull ??
        handleSummary?.handleValue ??
        'Handle #$handleId';

    return MacosScaffold(
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _HandleLensEvidencePane(
                    handleId: handleId,
                    handleValue: handleValue,
                    messageCount: handleSummary?.totalMessages ?? 0,
                    searchController: searchController,
                    searchQuery: searchQuery.value.trim(),
                    searchMode: searchMode.value,
                    onSearchModeChanged: (mode) {
                      searchMode.value = mode;
                    },
                    actions: _ActionBar(
                      handleId: handleId,
                      isCreating: isCreating,
                      nameController: nameController,
                      isBusy: isBusy,
                    ),
                    details: isCreating.value
                        ? _CreateContactForm(
                            handleId: handleId,
                            nameController: nameController,
                            isBusy: isBusy,
                            isCreating: isCreating,
                            typography: typography,
                          )
                        : null,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// =============================================================================
// Action bar
// =============================================================================

class _ActionBar extends HookConsumerWidget {
  const _ActionBar({
    required this.handleId,
    required this.isCreating,
    required this.nameController,
    required this.isBusy,
  });

  final int handleId;
  final ValueNotifier<bool> isCreating;
  final TextEditingController nameController;
  final ValueNotifier<bool> isBusy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        AppHeaderActionButton(
          icon: isCreating.value
              ? CupertinoIcons.xmark
              : CupertinoIcons.person_add,
          label: isCreating.value ? 'Cancel' : 'Create Contact',
          isEnabled: !isBusy.value,
          onPressed: () {
            isCreating.value = !isCreating.value;
            if (!isCreating.value) {
              nameController.clear();
            }
          },
        ),
        AppHeaderActionButton(
          icon: CupertinoIcons.link,
          label: 'Link to Existing',
          isEnabled: !isBusy.value,
          onPressed: () => _linkToExisting(context, ref),
        ),
        AppHeaderActionButton(
          icon: CupertinoIcons.checkmark_circle,
          label: 'Dismiss',
          isEnabled: !isBusy.value,
          onPressed: () => _dismiss(ref),
        ),
      ],
    );
  }

  Future<void> _linkToExisting(BuildContext context, WidgetRef ref) async {
    final participantId = await ContactPickerDialog.show(context);
    if (participantId == null) {
      return;
    }

    isBusy.value = true;
    try {
      await ref
          .read(handleLensActionsProvider.notifier)
          .linkToExistingContact(
            handleId: handleId,
            participantId: participantId,
          );
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> _dismiss(WidgetRef ref) async {
    isBusy.value = true;
    try {
      await ref
          .read(handleLensActionsProvider.notifier)
          .dismissHandle(handleId: handleId);
    } finally {
      isBusy.value = false;
    }
  }
}

// =============================================================================
// Inline create contact form
// =============================================================================

class _CreateContactForm extends HookConsumerWidget {
  const _CreateContactForm({
    required this.handleId,
    required this.nameController,
    required this.isBusy,
    required this.isCreating,
    required this.typography,
  });

  final int handleId;
  final TextEditingController nameController;
  final ValueNotifier<bool> isBusy;
  final ValueNotifier<bool> isCreating;
  final ThemeTypography typography;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorMessage = useState<String?>(null);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: MacosTextField(
                controller: nameController,
                placeholder: 'Contact name...',
                autofocus: true,
                onSubmitted: (_) => _submit(ref, errorMessage),
              ),
            ),
            const SizedBox(width: 8),
            PushButton(
              controlSize: ControlSize.regular,
              onPressed: isBusy.value ? null : () => _submit(ref, errorMessage),
              child: isBusy.value
                  ? const CupertinoActivityIndicator()
                  : const Text('Create & Link'),
            ),
          ],
        ),
        if (errorMessage.value != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              errorMessage.value!,
              style: typography.caption.copyWith(
                color: const Color(0xFFD64545),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _submit(
    WidgetRef ref,
    ValueNotifier<String?> errorMessage,
  ) async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    errorMessage.value = null;
    isBusy.value = true;
    try {
      final failureMessage = await ref
          .read(handleLensActionsProvider.notifier)
          .createContactAndLinkHandle(handleId: handleId, displayName: name);

      if (failureMessage != null) {
        errorMessage.value = failureMessage;
        return;
      }

      isCreating.value = false;
      nameController.clear();
    } finally {
      isBusy.value = false;
    }
  }
}

class _HandleLensEvidencePane extends ConsumerWidget {
  const _HandleLensEvidencePane({
    required this.handleId,
    required this.handleValue,
    required this.messageCount,
    required this.searchController,
    required this.searchQuery,
    required this.searchMode,
    required this.onSearchModeChanged,
    required this.actions,
    this.details,
  });

  final int handleId;
  final String handleValue;
  final int messageCount;
  final TextEditingController searchController;
  final String searchQuery;
  final MessageEvidenceSearchMode searchMode;
  final ValueChanged<MessageEvidenceSearchMode> onSearchModeChanged;
  final Widget actions;
  final Widget? details;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final evidenceScope = HandleMessagesEvidenceScope(handleId: handleId);
    final skeletonAsync = ref.watch(
      messageEvidenceTimelineSkeletonProvider(scope: evidenceScope),
    );
    final matchingIdsAsync = searchQuery.isEmpty
        ? null
        : ref.watch(
            messageEvidenceTextMatchIdsProvider(
              scope: evidenceScope,
              query: searchQuery,
              mode: searchMode,
            ),
          );

    return skeletonAsync.when(
      skipLoadingOnReload: true,
      skipLoadingOnRefresh: true,
      data: (skeleton) {
        return MessageEvidenceTimelineView(
          evidenceScope: evidenceScope,
          skeleton: skeleton,
          headerData: MessageEvidenceHeaderModel(
            title: handleValue,
            identityContextLine: 'Unfamiliar source',
            dateRangeLabel: _dateSpan(skeleton.entries),
            countLabel: _countLabel(
              totalCount: messageCount == 0
                  ? skeleton.totalCount
                  : messageCount,
              query: searchQuery,
              matchingIds: matchingIdsAsync?.valueOrNull,
              isMatchingLoaded: matchingIdsAsync?.hasValue ?? false,
            ),
            activeScopeLabel: searchQuery.isEmpty
                ? null
                : 'Message text contains "$searchQuery"',
            statusLine:
                'evidence skeleton • handle scope • hydrate visible rows',
            searchConfig: MessageEvidenceHeaderSearchConfig(
              controller: searchController,
              placeholder: 'Search messages from this handle',
              mode: searchMode,
              onModeChanged: onSearchModeChanged,
            ),
            actions: actions,
            details: details,
          ),
          emptyMessage: 'No messages found for this handle.',
          highlightQuery: searchQuery,
        );
      },
      loading: () => const Center(child: ProgressCircle()),
      error: (error, stackTrace) =>
          Center(child: Text('Unable to load handle evidence: $error')),
    );
  }
}

String _countLabel({
  required int totalCount,
  required String query,
  required List<int>? matchingIds,
  required bool isMatchingLoaded,
}) {
  if (query.isNotEmpty) {
    if (isMatchingLoaded) {
      return '${_formatCount(matchingIds?.length ?? 0)} of '
          '${_formatCount(totalCount)} messages match "$query"';
    }
    return 'matching messages...';
  }
  return '${_formatCount(totalCount)} messages';
}

String _dateSpan(List<MessageEvidenceSkeletonEntry> entries) {
  final dates = [
    for (final entry in entries)
      if (_parseDate(entry.dateUtc) case final DateTime date) date,
  ];
  if (dates.isEmpty) {
    return 'No dated messages';
  }
  dates.sort();
  final first = _formatDateLabel(dates.first);
  final last = _formatDateLabel(dates.last);
  if (first == last) {
    return first;
  }
  return '$first to $last';
}

DateTime? _parseDate(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}

String _formatDateLabel(DateTime value) {
  return DateFormat.yMMMd().format(value.toLocal());
}

String _formatCount(int count) {
  return NumberFormat.decimalPattern().format(count);
}
