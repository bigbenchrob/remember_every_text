import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/util/paths_helper.dart';

part 'paths_helper_provider.g.dart';

@riverpod
Future<PathsHelper> pathsHelper(Ref ref) async {
  return PathsHelper.asyncInstance;
}
