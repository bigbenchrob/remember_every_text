abstract interface class ConversationFavouritesStore {
  Future<String?> readCoreFavourites();

  Future<void> writeCoreFavourites(String storageValue);
}
