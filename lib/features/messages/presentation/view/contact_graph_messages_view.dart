import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/colors/theme_colors.dart';
import '../../../../essentials/conversation_graph/application/contacts/contact_graph.dart';
import '../../../../essentials/conversation_graph/application/contacts/contact_graph_provider.dart';
import '../../../../essentials/conversation_graph/application/conversations/conversation.dart';
import '../../../contacts/infrastructure/repositories/contact_profile_provider.dart';
import '../widgets/message_evidence/graph_message_evidence_row.dart';
import '../widgets/message_evidence/message_evidence_fade_overlay.dart';
import '../widgets/message_evidence/message_evidence_header.dart';

class ContactGraphMessagesView extends ConsumerStatefulWidget {
  const ContactGraphMessagesView({
    required this.contactId,
    this.monthAnchor,
    super.key,
  });

  final int contactId;
  final DateTime? monthAnchor;

  @override
  ConsumerState<ContactGraphMessagesView> createState() =>
      _ContactGraphMessagesViewState();
}

class _ContactGraphMessagesViewState
    extends ConsumerState<ContactGraphMessagesView> {
  late final int _messageLimit = widget.monthAnchor == null ? 500 : 5000;

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(
      contactPageGraphMessagesProvider(
        contactId: widget.contactId,
        limit: _messageLimit,
        monthAnchor: widget.monthAnchor,
      ),
    );
    final snapshotAsync = ref.watch(
      contactPageGraphSnapshotProvider(contactId: widget.contactId),
    );
    final profileAsync = ref.watch(
      contactProfileProvider(contactId: widget.contactId),
    );

    return messagesAsync.when(
      data: (messages) {
        return _ContactGraphMessagesTimeline(
          contactId: widget.contactId,
          contactName: profileAsync.valueOrNull?.shortName,
          snapshot: snapshotAsync.valueOrNull,
          messages: messages,
          messageLimit: _messageLimit,
          monthAnchor: widget.monthAnchor,
        );
      },
      loading: () => const Center(child: Text('Loading contact messages...')),
      error: (error, stackTrace) =>
          Center(child: Text('Contact graph messages failed: $error')),
    );
  }
}

class _ContactGraphMessagesTimeline extends ConsumerWidget {
  const _ContactGraphMessagesTimeline({
    required this.contactId,
    required this.contactName,
    required this.snapshot,
    required this.messages,
    required this.messageLimit,
    required this.monthAnchor,
  });

  final int contactId;
  final String? contactName;
  final ContactGraphSnapshot? snapshot;
  final List<ConversationMessage> messages;
  final int messageLimit;
  final DateTime? monthAnchor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeColorsProvider);
    final colors = ref.read(themeColorsProvider.notifier);
    final backgroundColor = colors.messagePanels.coolPanelSurface;
    final chronologicalMessages = messages.reversed.toList(growable: false);

    return ColoredBox(
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MessageEvidenceHeader(
            data: MessageEvidenceHeaderData(
              title: 'All messages from ${_contactLabel()}',
              subtitleParts: _subtitleParts(),
              statusLine: _statusLine(),
            ),
          ),
          Expanded(
            child: MessageEvidenceFadeOverlay(
              backgroundColor: backgroundColor,
              child: chronologicalMessages.isEmpty
                  ? Center(child: Text(_emptyMessage()))
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: _buildGroupedRows(chronologicalMessages),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _subtitleParts() {
    final monthLabel = _monthLabel(monthAnchor);
    if (monthLabel != null) {
      return [monthLabel, '${_formatCount(messages.length)} loaded messages'];
    }

    final activity = snapshot?.messageActivity;
    if (activity == null) {
      return ['${_formatCount(messages.length)} loaded messages'];
    }

    return [
      _dateSpan(activity.firstMessageAtUtc, activity.lastMessageAtUtc),
      '${_formatCount(activity.totalMessageCount)} messages',
    ];
  }

  String _statusLine() {
    if (monthAnchor != null) {
      return 'selected month • graph evidence • limit ${_formatCount(messageLimit)}';
    }
    return 'graph evidence • latest ${_formatCount(messageLimit)} loaded';
  }

  String _emptyMessage() {
    if (monthAnchor != null) {
      return 'No graph messages found for this contact in the selected month.';
    }
    return 'No graph messages found for this contact.';
  }

  String _contactLabel() {
    final label = contactName?.trim();
    if (label != null && label.isNotEmpty) {
      return label;
    }
    return 'contact $contactId';
  }

  List<Widget> _buildGroupedRows(List<ConversationMessage> messages) {
    final rows = <Widget>[];
    String? activeDayLabel;
    for (final message in messages) {
      final dayLabel = _dayLabel(message.dateUtc);
      if (dayLabel != activeDayLabel) {
        activeDayLabel = dayLabel;
        rows.add(_DayDivider(label: dayLabel));
      }
      rows.add(GraphMessageEvidenceRow(message: message));
    }
    return rows;
  }
}

class _DayDivider extends StatelessWidget {
  const _DayDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        label,
        style: DefaultTextStyle.of(
          context,
        ).style.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

String _dayLabel(String? value) {
  final parsed = value == null ? null : DateTime.tryParse(value);
  if (parsed == null) {
    return 'No date';
  }
  return DateFormat.yMMMd().format(parsed.toLocal());
}

String? _monthLabel(DateTime? value) {
  if (value == null) {
    return null;
  }
  return DateFormat.yMMMM().format(value);
}

String _dateSpan(String? first, String? last) {
  final firstLabel = _dateLabel(first);
  final lastLabel = _dateLabel(last);
  if (firstLabel == null && lastLabel == null) {
    return 'No date range';
  }
  if (firstLabel == null) {
    return 'through $lastLabel';
  }
  if (lastLabel == null || firstLabel == lastLabel) {
    return firstLabel;
  }
  return '$firstLabel to $lastLabel';
}

String? _dateLabel(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  final parsed = DateTime.tryParse(value);
  if (parsed == null) {
    return value;
  }
  return DateFormat.yMMMd().format(parsed.toLocal());
}

String _formatCount(int count) {
  return NumberFormat.decimalPattern().format(count);
}
