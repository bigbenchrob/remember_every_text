import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

const _contactEvidenceRetention = Duration(minutes: 10);

/// Retains a prepared contact evidence projection across short-lived UI exits.
///
/// The selected contact survives top-level sidebar category changes. Keeping
/// its read models warm for the same browsing session avoids rebuilding the
/// heatmap and evidence spine when the user returns, while the bounded
/// retention prevents every visited contact from remaining cached forever.
void retainPreparedContactEvidence(Ref ref) {
  final link = ref.keepAlive();
  Timer? timer;

  ref.onCancel(() {
    timer = Timer(_contactEvidenceRetention, link.close);
  });
  ref.onResume(() {
    timer?.cancel();
    timer = null;
  });
  ref.onDispose(() {
    timer?.cancel();
  });
}
