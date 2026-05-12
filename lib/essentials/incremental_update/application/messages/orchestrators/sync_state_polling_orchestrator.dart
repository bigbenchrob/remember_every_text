import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/sealed_unions/sync_state.dart';
import '../integrators/sync_assessment_integrator_provider.dart';

class SyncStatePollingOrchestrator {
  SyncStatePollingOrchestrator(this._ref);

  final Ref _ref;
  Timer? _pollingTimer;

  //“A refresh cycle has started but has not yet completed.”
  bool _refreshInFlight = false;
  MessageSyncState? _lastObservedState;

  Future<MessageSyncState> refreshOnce() async {
    _ref.invalidate(messageSyncStateProvider);
    return _ref.read(messageSyncStateProvider.future);
  }

  void startPolling({Duration interval = const Duration(seconds: 15)}) {
    if (_pollingTimer != null) {
      debugPrint('Shadow message snapshot polling already running.');
      return;
    }

    debugPrint(
      'Shadow message snapshot polling started: '
      'interval=${interval.inSeconds}s',
    );
    // every [interval], trigger a refresh of the message snapshot delta,
    // but only if a refresh isn't already in flight.
    _pollingTimer = Timer.periodic(interval, (_) {
      if (_refreshInFlight) {
        debugPrint(
          'Shadow message snapshot polling skipped: refresh in flight.',
        );
        return;
      }

      _refreshInFlight = true;
      unawaited(
        refreshOnce()
            .then((delta) {
              if (delta != _lastObservedState) {
                debugPrint(
                  'Shadow message sync-state transition: \n'
                  'Previous: ${_extractSemanticSyncStateMeaning(_lastObservedState)}, '
                  'Current: ${_extractSemanticSyncStateMeaning(delta)}',
                );
              }
              _lastObservedState = delta;
            })
            //Whether success or failure, release the orchestration lock.
            .whenComplete(() {
              _refreshInFlight = false;
            }),
      );
    });
  }

  void stopPolling() {
    if (_pollingTimer == null) {
      debugPrint('Shadow message snapshot polling already stopped.');
      return;
    }

    _pollingTimer?.cancel();
    _pollingTimer = null;
    debugPrint('Shadow message snapshot polling stopped.');
  }

  void dispose() {
    stopPolling();
  }
}

String _extractSemanticSyncStateMeaning(MessageSyncState? state) {
  return switch (state) {
    null => 'No previous sync state observed.',
    MessageSyncCursorsMatch() => 'none',
    MessageSyncSourceAheadOfLedger() => 'sourceAheadOfLedger',
    MessageSyncLedgerAheadOfSource() => 'ledgerAheadOfSource',
  };
}
