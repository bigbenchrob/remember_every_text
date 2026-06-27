import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'search_service.dart';

part 'search_service_provider.g.dart';

@riverpod
SearchService searchService(Ref ref) {
  return SearchService(ref: ref);
}
