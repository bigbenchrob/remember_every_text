import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../essentials/archive_environment/domain/archive_environment.dart';
import '../../../essentials/archive_environment/feature_level_providers.dart'
    show archiveAccessAuthorityProvider;
import '../../../essentials/onboarding/application/contacts_source_readiness_test_agent.dart';
import '../../../essentials/onboarding/feature_level_providers.dart'
    show realContactsSourceReadinessTestAgentProvider;
import '../../../essentials/presence/domain/services/test_agent.dart';
import '../../address_book_folders/infrastructure/data_sources/local/address_book_folder_path_finder.dart';
import '../../address_book_folders/infrastructure/repositories/address_book_folder_repository.dart';
import '../infrastructure/development/development_contacts_source_mode_store.dart';
import '../infrastructure/development/development_contacts_source_readiness_test_agent.dart';

part 'development_contacts_source_provider.g.dart';

const _testConfigurationPath =
    'development-tests/contacts-source-readiness/source-mode.txt';
const _missingSourcesRootPath =
    'development-tests/contacts-source-readiness/missing-sources';

@Riverpod(keepAlive: true)
class DevelopmentContactsSourceSelection
    extends _$DevelopmentContactsSourceSelection {
  late DevelopmentContactsSourceModeStore _store;

  @override
  Future<DevelopmentContactsSourceMode> build() async {
    final archiveAuthority = ref.watch(archiveAccessAuthorityProvider);
    _requireDevelopmentArchive(archiveAuthority.identity.environment);
    _store = DevelopmentContactsSourceModeStore(
      configurationFile: File(
        archiveAuthority.resolvePath(_testConfigurationPath),
      ),
    );
    return _store.read();
  }

  Future<void> select(DevelopmentContactsSourceMode mode) async {
    await _store.write(mode);
    state = AsyncData<DevelopmentContactsSourceMode>(mode);
  }
}

@Riverpod(keepAlive: true)
Future<TestAgent> developmentContactsSourceReadinessTestAgent(Ref ref) async {
  await ref.read(developmentContactsSourceSelectionProvider.future);
  final archiveAuthority = ref.watch(archiveAccessAuthorityProvider);
  _requireDevelopmentArchive(archiveAuthority.identity.environment);
  final realTestAgent = await ref.watch(
    realContactsSourceReadinessTestAgentProvider.future,
  );
  final disposableRepository = AddressBookFolderRepository(
    folderPathsFinder: AddressBookFolderPathsFinder.atSourcesRoot(
      sourcesRootPath: archiveAuthority.resolvePath(_missingSourcesRootPath),
    ),
  );
  final disposableUnavailableTestAgent = ContactsSourceReadinessTestAgent(
    repository: disposableRepository,
  );

  return DevelopmentContactsSourceReadinessTestAgent(
    testAgentForCurrentMode: () async {
      final mode = await ref.read(
        developmentContactsSourceSelectionProvider.future,
      );
      return switch (mode) {
        DevelopmentContactsSourceMode.realSource => realTestAgent,
        DevelopmentContactsSourceMode.disposableUnavailableSource =>
          disposableUnavailableTestAgent,
      };
    },
  );
}

void _requireDevelopmentArchive(ArchiveEnvironment environment) {
  if (environment != ArchiveEnvironment.development) {
    throw StateError(
      'The disposable Contacts source control requires a development archive.',
    );
  }
}
