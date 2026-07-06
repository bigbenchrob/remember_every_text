import 'package:intl/intl.dart';

class CountLabelFormatter {
  CountLabelFormatter._();

  static String formatCount(int count) {
    return NumberFormat.decimalPattern().format(count);
  }

  static String formatNoun({
    required int count,
    required String singular,
    required String plural,
  }) {
    return '${formatCount(count)} ${count == 1 ? singular : plural}';
  }

  static String messages(int count) {
    return formatNoun(count: count, singular: 'message', plural: 'messages');
  }

  static String recoveredMessages(int count) {
    return '${formatCount(count)} recovered '
        '${count == 1 ? 'message' : 'messages'}';
  }

  static String users(int count) {
    return formatNoun(count: count, singular: 'user', plural: 'users');
  }

  static String handles(int count) {
    return formatNoun(count: count, singular: 'handle', plural: 'handles');
  }

  static String contacts(int count) {
    return formatNoun(count: count, singular: 'contact', plural: 'contacts');
  }

  static String conversations(int count) {
    return formatNoun(
      count: count,
      singular: 'conversation',
      plural: 'conversations',
    );
  }

  static String attachments(int count) {
    return formatNoun(
      count: count,
      singular: 'attachment',
      plural: 'attachments',
    );
  }

  static String chats(int count) {
    return formatNoun(count: count, singular: 'chat', plural: 'chats');
  }

  static String rows(int count) {
    return formatNoun(count: count, singular: 'row', plural: 'rows');
  }

  static String files(int count) {
    return formatNoun(count: count, singular: 'file', plural: 'files');
  }

  static String sources(int count) {
    return formatNoun(count: count, singular: 'source', plural: 'sources');
  }
}
