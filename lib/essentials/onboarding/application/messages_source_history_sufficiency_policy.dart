const int maximumSparseMessagesSourceHistoryRowCount = 10;

bool isMessagesSourceHistorySufficient(int rowCount) {
  return rowCount > maximumSparseMessagesSourceHistoryRowCount;
}
