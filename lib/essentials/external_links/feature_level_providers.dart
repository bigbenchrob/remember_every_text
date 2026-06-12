import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'application/external_uri_opener.dart';
import 'infrastructure/url_launcher_external_uri_opener.dart';

part 'feature_level_providers.g.dart';

@riverpod
ExternalUriOpener externalUriOpener(Ref ref) {
  return const UrlLauncherExternalUriOpener();
}
