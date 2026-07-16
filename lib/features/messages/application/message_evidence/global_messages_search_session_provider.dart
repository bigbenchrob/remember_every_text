import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/message_evidence/message_evidence_search_mode.dart';

part 'global_messages_search_session_provider.g.dart';

/// Search interaction state shared by the global message evidence view and
/// its page-level Track presentations.
final class GlobalMessagesSearchSessionState {
  const GlobalMessagesSearchSessionState({
    this.query = '',
    this.mode = MessageEvidenceSearchMode.allTerms,
  });

  final String query;
  final MessageEvidenceSearchMode mode;

  GlobalMessagesSearchSessionState copyWith({
    String? query,
    MessageEvidenceSearchMode? mode,
  }) {
    return GlobalMessagesSearchSessionState(
      query: query ?? this.query,
      mode: mode ?? this.mode,
    );
  }
}

/// Owns one global-message Search interaction for the selected month context.
///
/// The month is a family key so changing the center-panel context preserves
/// the previous behavior of starting a fresh Search interaction.
@riverpod
class GlobalMessagesSearchSession extends _$GlobalMessagesSearchSession {
  @override
  GlobalMessagesSearchSessionState build({DateTime? monthAnchor}) {
    return const GlobalMessagesSearchSessionState();
  }

  void setQuery(String query) {
    if (state.query == query) {
      return;
    }
    state = state.copyWith(query: query);
  }

  void setMode(MessageEvidenceSearchMode mode) {
    if (state.mode == mode) {
      return;
    }
    state = state.copyWith(mode: mode);
  }
}
