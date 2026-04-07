import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../essentials/debug/application/developer_mode_provider.dart';
import '../../domain/value_objects/message_timeline_scope.dart';

class ContactTimelineScrollProbe {
  static const Duration _flushDelay = Duration(milliseconds: 1200);

  static final Stopwatch _sessionStopwatch = Stopwatch();
  static final Map<String, int> _counts = <String, int>{};
  static final Map<String, _ProbeDurationAggregate> _durations =
      <String, _ProbeDurationAggregate>{};

  static Timer? _flushTimer;
  static int _sessionId = 0;
  static String _scopeLabel = 'unknown';
  static String _flushReason = 'idle';

  static bool shouldEnable(WidgetRef ref) {
    if (kReleaseMode) {
      return false;
    }

    final developerMode = ref.read(developerModeProvider).valueOrNull;
    return developerMode != DeveloperModeValue.user;
  }

  static bool get isActive {
    return !kReleaseMode && _sessionStopwatch.isRunning;
  }

  static void startSession({
    required MessageTimelineScope scope,
    required String trigger,
  }) {
    if (kReleaseMode || scope is! ContactTimelineScope) {
      return;
    }

    _flushTimer?.cancel();
    _flushTimer = null;

    if (!_sessionStopwatch.isRunning) {
      _sessionId += 1;
      _scopeLabel = _describeScope(scope);
      _flushReason = 'active';
      _counts.clear();
      _durations.clear();
      _sessionStopwatch
        ..reset()
        ..start();
      debugPrint(
        '[TimelineProbe] session#$_sessionId start '
        'scope=$_scopeLabel trigger=$trigger',
      );
    }

    count('scroll.session_start');
    count('scroll.trigger.$trigger');
  }

  static void scheduleFlush({required String reason}) {
    if (!isActive) {
      return;
    }

    _flushReason = reason;
    count('scroll.trigger.$reason');
    _flushTimer?.cancel();
    _flushTimer = Timer(_flushDelay, _flush);
  }

  static void count(String key, {int by = 1}) {
    if (!isActive) {
      return;
    }

    _counts.update(key, (value) => value + by, ifAbsent: () => by);
  }

  static T traceSync<T>(String key, T Function() action) {
    if (!isActive) {
      return action();
    }

    final stopwatch = Stopwatch()..start();
    try {
      return action();
    } finally {
      stopwatch.stop();
      _recordDuration(key, stopwatch.elapsedMicroseconds);
    }
  }

  static Future<T> traceAsync<T>(
    String key,
    Future<T> Function() action,
  ) async {
    if (!isActive) {
      return action();
    }

    final stopwatch = Stopwatch()..start();
    try {
      return await action();
    } finally {
      stopwatch.stop();
      _recordDuration(key, stopwatch.elapsedMicroseconds);
    }
  }

  static void _recordDuration(String key, int elapsedMicroseconds) {
    if (!isActive) {
      return;
    }

    final aggregate = _durations.putIfAbsent(key, _ProbeDurationAggregate.new);
    aggregate.record(elapsedMicroseconds);
  }

  static void _flush() {
    if (!_sessionStopwatch.isRunning) {
      return;
    }

    _sessionStopwatch.stop();
    final elapsedMilliseconds = _sessionStopwatch.elapsedMilliseconds;
    debugPrint(
      '[TimelineProbe] session#$_sessionId summary '
      'scope=$_scopeLabel elapsed=${elapsedMilliseconds}ms '
      'reason=$_flushReason',
    );

    final sortedCounts = _counts.entries.toList(growable: false)
      ..sort((left, right) {
        final countCompare = right.value.compareTo(left.value);
        if (countCompare != 0) {
          return countCompare;
        }
        return left.key.compareTo(right.key);
      });
    if (sortedCounts.isEmpty) {
      debugPrint('[TimelineProbe] counts none');
    } else {
      for (final entry in sortedCounts) {
        debugPrint('[TimelineProbe] count ${entry.key}=${entry.value}');
      }
    }

    final sortedDurations = _durations.entries.toList(growable: false)
      ..sort((left, right) {
        final totalCompare = right.value.totalMicroseconds.compareTo(
          left.value.totalMicroseconds,
        );
        if (totalCompare != 0) {
          return totalCompare;
        }
        return left.key.compareTo(right.key);
      });
    if (sortedDurations.isEmpty) {
      debugPrint('[TimelineProbe] timings none');
    } else {
      for (final entry in sortedDurations) {
        final aggregate = entry.value;
        debugPrint(
          '[TimelineProbe] time ${entry.key} '
          'count=${aggregate.count} '
          'total=${aggregate.totalMicroseconds}us '
          'avg=${aggregate.averageMicroseconds}us '
          'max=${aggregate.maxMicroseconds}us',
        );
      }
    }

    _counts.clear();
    _durations.clear();
    _sessionStopwatch.reset();
    _flushReason = 'idle';
  }

  static String _describeScope(MessageTimelineScope scope) {
    return switch (scope) {
      ContactTimelineScope(:final contactId, :final filterHandleId) =>
        'contact(contactId=$contactId, filterHandleId=$filterHandleId)',
      GlobalTimelineScope() => 'global',
      ChatTimelineScope(:final chatId) => 'chat(chatId=$chatId)',
      RecoveredTimelineScope() => 'recovered',
    };
  }
}

class _ProbeDurationAggregate {
  int count = 0;
  int totalMicroseconds = 0;
  int maxMicroseconds = 0;

  int get averageMicroseconds {
    if (count == 0) {
      return 0;
    }

    return totalMicroseconds ~/ count;
  }

  void record(int elapsedMicroseconds) {
    count += 1;
    totalMicroseconds += elapsedMicroseconds;
    if (elapsedMicroseconds > maxMicroseconds) {
      maxMicroseconds = elapsedMicroseconds;
    }
  }
}
