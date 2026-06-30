import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../essentials/db/feature_level_providers.dart'
    show overlayDatabaseProvider;
import '../../infrastructure/repositories/favorite_contacts_repository.dart';

part 'favorite_contacts_repository_provider.g.dart';

@riverpod
Future<FavoriteContactsRepository> favoriteContactsRepository(Ref ref) async {
  final overlayDatabase = await ref.watch(overlayDatabaseProvider.future);
  return FavoriteContactsRepository(overlayDatabase);
}
