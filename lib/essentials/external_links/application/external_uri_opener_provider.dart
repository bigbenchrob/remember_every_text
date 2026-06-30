import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../infrastructure/url_launcher_external_uri_opener.dart';
import 'external_uri_opener.dart';

part 'external_uri_opener_provider.g.dart';

@riverpod
ExternalUriOpener externalUriOpener(Ref ref) {
  return const UrlLauncherExternalUriOpener();
}
