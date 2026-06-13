import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../feature_level_providers.dart';
import 'graph_health_reader.dart';
import 'graph_health_report.dart';

part 'graph_health_provider.g.dart';

@riverpod
Future<GraphHealthReport> graphHealthReport(Ref ref) async {
  final repository = await ref.watch(graphHealthRepositoryProvider.future);
  return GraphHealthReader(repository: repository).readHealthReport();
}
