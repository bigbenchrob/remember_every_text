import '../../infrastructure/repositories/recovered_unlinked_messages_provider.dart';
import 'ordinal_strategy.dart';

class RecoveredListOrdinalStrategy implements OrdinalStrategy {
  RecoveredListOrdinalStrategy(List<RecoveredUnlinkedMessageItem> items)
    : _items = List<RecoveredUnlinkedMessageItem>.unmodifiable(items),
      _ordinalByMessageId = {
        for (var index = 0; index < items.length; index += 1)
          items[index].id: index,
      };

  final List<RecoveredUnlinkedMessageItem> _items;
  final Map<int, int> _ordinalByMessageId;

  @override
  Future<int> getTotalCount() async {
    return _items.length;
  }

  @override
  Future<int?> getFirstOrdinalOnOrAfter(DateTime date) async {
    for (var index = 0; index < _items.length; index += 1) {
      final sentAt = _items[index].sentAt;
      if (sentAt == null) {
        continue;
      }
      if (!sentAt.isBefore(date)) {
        return index;
      }
    }

    return null;
  }

  @override
  Future<int?> getFirstOrdinalForMonth(String monthKey) async {
    for (var index = 0; index < _items.length; index += 1) {
      if (_monthKeyForDate(_items[index].sentAt) == monthKey) {
        return index;
      }
    }

    return null;
  }

  @override
  Future<int?> getMessageIdByOrdinal(int ordinal) async {
    if (ordinal < 0 || ordinal >= _items.length) {
      return null;
    }

    return _items[ordinal].id;
  }

  @override
  Future<String?> getMonthKeyByOrdinal(int ordinal) async {
    if (ordinal < 0 || ordinal >= _items.length) {
      return null;
    }

    return _monthKeyForDate(_items[ordinal].sentAt);
  }

  @override
  Future<int?> getOrdinalForMessage(int messageId) async {
    return _ordinalByMessageId[messageId];
  }
}

String? _monthKeyForDate(DateTime? date) {
  if (date == null) {
    return null;
  }

  final month = date.month.toString().padLeft(2, '0');
  return '${date.year}-$month';
}
