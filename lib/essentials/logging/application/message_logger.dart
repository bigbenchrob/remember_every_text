import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'message_logger.g.dart';

class MessageLogEntry {
  final String id;
  final DateTime timestamp;
  final String level; // info, warn, error
  final String message;
  final String? source; // feature or class name
  final Map<String, dynamic> context;

  const MessageLogEntry({
    required this.id,
    required this.timestamp,
    required this.level,
    required this.message,
    this.source,
    this.context = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'level': level,
    'message': message,
    'source': source,
    'context': context,
  };
}

@Riverpod(keepAlive: true)
class MessageLogger extends _$MessageLogger {
  final List<MessageLogEntry> _logs = [];

  @override
  List<MessageLogEntry> build() {
    return _logs;
  }

  void _add(
    String level,
    String message, {
    String? source,
    Map<String, dynamic> context = const {},
  }) {
    final entry = MessageLogEntry(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}_${_logs.length}',
      timestamp: DateTime.now(),
      level: level,
      message: message,
      source: source,
      context: context,
    );
    _logs.add(entry);
    state = List.of(_logs);
  }

  void info(
    String message, {
    String? source,
    Map<String, dynamic> context = const {},
  }) => _add('info', message, source: source, context: context);
  void warn(
    String message, {
    String? source,
    Map<String, dynamic> context = const {},
  }) => _add('warn', message, source: source, context: context);
  void error(
    String message, {
    String? source,
    Map<String, dynamic> context = const {},
  }) => _add('error', message, source: source, context: context);

  void clear() {
    _logs.clear();
    state = [];
  }

  String exportJson() => jsonEncode(_logs.map((e) => e.toJson()).toList());
}
