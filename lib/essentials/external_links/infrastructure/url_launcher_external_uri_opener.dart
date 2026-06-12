import 'package:url_launcher/url_launcher.dart';

import '../application/external_uri_opener.dart';

class UrlLauncherExternalUriOpener implements ExternalUriOpener {
  const UrlLauncherExternalUriOpener();

  @override
  Future<bool> open(Uri uri) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
