import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/sealed_unions/import_decision.dart';
import '../integrators/import_decision_provider.dart';
import '../readers/import_ledger_message_snapshot_provider.dart';
import '../readers/live_chat_db_message_snapshot_provider.dart';

class SyncStatePollingOrchestrator {
  SyncStatePollingOrchestrator(this._ref);

  final Ref _ref;
  Timer? _pollingTimer;

  //“A refresh cycle has started but has not yet completed.”
  bool _refreshInFlight = false;
  ImportDecision? _lastObservedDecision;

  Future<ImportDecision> refreshOnce() async {
    _ref.invalidate(liveChatDbMessageSnapshotProvider);
    _ref.invalidate(importLedgerMessageSnapshotProvider);
    return _ref.read(importDecisionProvider.future);
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
            .then((decision) {
              if (decision != _lastObservedDecision) {
                debugPrint(
                  'Shadow import decision transition: \n'
                  'Previous: ${_extractSemanticImportDecisionMeaning(_lastObservedDecision)}, '
                  'Current: ${_extractSemanticImportDecisionMeaning(decision)}',
                );
              }
              _lastObservedDecision = decision;
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

String _extractSemanticImportDecisionMeaning(ImportDecision? decision) {
  return switch (decision) {
    null => 'No previous import decision observed.',
    ImportDecisionDoNothing() => 'doNothing',
    ImportDecisionConsiderIncrementalImport() => 'considerIncrementalImport',
    ImportDecisionBlockAndReportLedgerAhead() => 'blockAndReportLedgerAhead',
  };
}
