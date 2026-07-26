import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/message_evidence/message_evidence_search_mode.dart';

part 'handle_lens_session_provider.g.dart';

/// Interaction state shared by a handle lens and its page-level Track
/// presentations.
final class HandleLensSessionState {
  const HandleLensSessionState({
    this.query = '',
    this.searchMode = MessageEvidenceSearchMode.allTerms,
    this.isCreatingContact = false,
    this.isBusy = false,
    this.errorMessage,
  });

  final String query;
  final MessageEvidenceSearchMode searchMode;
  final bool isCreatingContact;
  final bool isBusy;
  final String? errorMessage;

  HandleLensSessionState copyWith({
    String? query,
    MessageEvidenceSearchMode? searchMode,
    bool? isCreatingContact,
    bool? isBusy,
    Object? errorMessage = _unchanged,
  }) {
    return HandleLensSessionState(
      query: query ?? this.query,
      searchMode: searchMode ?? this.searchMode,
      isCreatingContact: isCreatingContact ?? this.isCreatingContact,
      isBusy: isBusy ?? this.isBusy,
      errorMessage: identical(errorMessage, _unchanged)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const Object _unchanged = Object();

/// Owns the interaction state for one unfamiliar-source evidence lens.
@Riverpod(keepAlive: true)
class HandleLensSession extends _$HandleLensSession {
  @override
  HandleLensSessionState build({required int handleId}) {
    return const HandleLensSessionState();
  }

  void setQuery(String query) {
    if (state.query == query) {
      return;
    }
    state = state.copyWith(query: query);
  }

  void setSearchMode(MessageEvidenceSearchMode mode) {
    if (state.searchMode == mode) {
      return;
    }
    state = state.copyWith(searchMode: mode);
  }

  void toggleCreateContact() {
    final nextValue = !state.isCreatingContact;
    state = state.copyWith(isCreatingContact: nextValue, errorMessage: null);
  }

  void setBusy({required bool isBusy}) {
    if (state.isBusy == isBusy) {
      return;
    }
    state = state.copyWith(isBusy: isBusy);
  }

  void setErrorMessage(String? errorMessage) {
    state = state.copyWith(errorMessage: errorMessage);
  }

  void finishCreatingContact() {
    state = state.copyWith(isCreatingContact: false, errorMessage: null);
  }
}
