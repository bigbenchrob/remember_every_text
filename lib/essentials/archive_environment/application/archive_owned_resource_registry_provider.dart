import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'archive_owned_resource_registry_provider.g.dart';

typedef ArchiveOwnedResourceCloser = FutureOr<void> Function();

/// Tracks only resources that have already been opened.
///
/// Complete installation erase can therefore close live stores without
/// resolving providers and accidentally opening or migrating legacy data.
final class ArchiveOwnedResourceRegistry {
  final Map<Object, ({String label, ArchiveOwnedResourceCloser close})>
  _resources = {};

  void register({
    required Object identity,
    required String label,
    required ArchiveOwnedResourceCloser close,
  }) {
    _resources[identity] = (label: label, close: close);
  }

  void unregister(Object identity) {
    _resources.remove(identity);
  }

  Future<void> closeAll() async {
    final resources = _resources.entries.toList().reversed.toList();
    _resources.clear();
    for (final entry in resources) {
      await entry.value.close();
    }
  }

  int get openResourceCount => _resources.length;
}

@Riverpod(keepAlive: true)
ArchiveOwnedResourceRegistry archiveOwnedResourceRegistry(
  ArchiveOwnedResourceRegistryRef ref,
) {
  return ArchiveOwnedResourceRegistry();
}
