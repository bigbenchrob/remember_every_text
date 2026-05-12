import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/models/snapshot_delta.dart';
import '../integrators/snapshot_delta_integrator_provider.dart';

class DeltaRefreshOrchestrator {
  DeltaRefreshOrchestrator(this._ref);

  final Ref _ref;
  Timer? _pollingTimer;

  //“A refresh cycle has started but has not yet completed.”
  bool _refreshInFlight = false;
  MessageSnapshotDelta? _lastObservedDelta;

  Future<MessageSnapshotDelta> refreshOnce() async {
    _ref.invalidate(snapshotDeltaIntegratorProvider);
    return _ref.read(snapshotDeltaIntegratorProvider.future);
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
              if (delta != _lastObservedDelta) {
                debugPrint(
                  'Shadow message snapshot polling delta: '
                  'rowIdDelta=${delta.rowIdDelta}, '
                  'messageCountDelta=${delta.messageCountDelta}, '
                  'isLiveSourceRowAhead=${delta.isLiveSourceRowAhead}',
                );
              }
              _lastObservedDelta = delta;
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
