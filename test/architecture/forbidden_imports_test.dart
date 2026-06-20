import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';

const Set<String> _trackedSidebarPresentationImportExceptions = <String>{};

const Set<String> _trackedWidgetPayloadExceptions = <String>{};

const Set<String> _sidebarSemanticActionTransportFiles = {
  'lib/essentials/sidebar/domain/sidebar_action_intent.dart',
  'lib/essentials/sidebar/domain/sidebar_body_model.dart',
  'lib/essentials/sidebar/domain/sidebar_body_option.dart',
  'lib/essentials/sidebar/domain/sidebar_list_item_model.dart',
};

const Set<String> _retainedArchiveMetadataStoreProviderAllowedFiles = {};

const Set<String> _retainedArchiveMetadataFileAllowedFiles = {
  'lib/essentials/db/feature_level_providers.dart',
  'lib/essentials/onboarding/application/message_data_reset_service.dart',
};

const Set<String> _retainedHistoricalWorkingFileAllowedFiles = {
  'lib/essentials/db/feature_level_providers.dart',
  'lib/essentials/onboarding/application/message_data_reset_service.dart',
};

const Set<String> _retainedDatabaseFilenameLiteralAllowedFiles = {
  'lib/essentials/db/feature_level_providers.dart',
};

const Set<String> _overlayDatabaseFilenameLiteralAllowedFiles = {
  'lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart',
};

const Set<String> _sourceScopedDatabaseFilenameLiteralAllowedFiles = {
  'lib/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart',
  'lib/essentials/source_scoped_import/infrastructure/import_database_provider.dart',
};

const Set<String> _sourceScopedSqlBitExtractionAllowedFiles = {
  'lib/essentials/source_scoped_import/domain/source_scoped_row_key.dart',
  'lib/essentials/source_scoped_import/domain/source_scoped_row_sql.dart',
};

const Set<String> _legacyTerminologyAllowedFiles = <String>{};

const Set<String> _retainedOverlayIdentityBridgeAllowedFiles = <String>{};

const Set<String> _retainedOverlayIdentityBridgeTestAllowedFiles = <String>{};

const Set<String> _retiredContactNameVariantAllowedFiles = <String>{};

const List<String> _retiredSourceSpecificMessageRendererSymbols = <String>[
  'ContactMessageRenderer',
  'ConversationMessageRenderer',
  'SearchResultMessageRenderer',
  'RecoveredMessageRenderer',
];

const List<String> _retiredSourceSpecificMessageRendererPathFragments =
    <String>[
      'contact_message_renderer.dart',
      'conversation_message_renderer.dart',
      'search_result_message_renderer.dart',
      'recovered_message_renderer.dart',
    ];

const List<String> _retiredMessageTimelineSymbols = <String>[
  'MessageTimelineScope',
  'MessagesTimelineView',
];

const List<String> _retiredMessageTimelinePathFragments = <String>[
  'messages_timeline_view.dart',
  'message_timeline_scope.dart',
  '/presentation/view_model/timeline/',
  '/application/strategies/',
];

const Set<String> _rawPrintAllowedFiles = {'lib/main.dart'};

const List<String> _retiredImportMigrationExecutionSymbols = <String>[
  'DbImportControl',
  'HandlesMigrationService',
  'ImportOrchestrator',
  'OrchestratedLedgerImportService',
  'RetainedLegacyArchivePipeline',
  'SqfliteImportDatabase',
  'TableImporter',
  'TableMigrator',
  'runImportAndMigration',
  'sqfliteImportDatabase',
  'sqfliteImportDatabaseProvider',
  'retainedArchiveMetadataDatabaseProvider',
];

const List<String> _retiredImportMigrationPathFragments = <String>[
  '/db_importers/application/importers/',
  '/db_importers/application/orchestrator/',
  '/db_importers/application/services/retained_legacy_archive_pipeline',
  '/db_importers/presentation/view/db_import_control_panel',
  '/db_migrate/application/migrators/',
  '/db_migrate/application/orchestrator/',
  'sqflite_import_database.dart',
];

const Set<String> _retainedImportWrapperImportAllowedFiles = {};

const Set<String> _databaseConstructionAllowedFiles = {
  'lib/essentials/db/feature_level_providers.dart',
  'lib/essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart',
  'lib/essentials/db/infrastructure/data_sources/local/import/retained_archive_metadata_database.dart',
  'lib/essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart',
  'lib/essentials/source_scoped_import/infrastructure/import_database_provider.dart',
};

const Set<String> _archiveCompatibilityKeyConstructionAllowedFiles = {
  'lib/essentials/retained_archive/domain/archive_compatibility_key.dart',
};

void main() {
  group('Architecture tripwires', () {
    test('Do not import flutter_riverpod', () async {
      final libDir = Directory('lib');
      final bad = <String>[];
      await for (final entity in libDir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final lines = await entity.readAsLines();
          var inBlockComment = false;
          for (final rawLine in lines) {
            final line = rawLine;
            if (inBlockComment) {
              if (line.contains('*/')) {
                inBlockComment = false;
              }
              continue;
            }
            final trimmed = line.trimLeft();
            if (trimmed.startsWith('/*')) {
              inBlockComment = true;
              continue;
            }
            if (trimmed.startsWith('//')) {
              continue;
            }
            final importPattern = RegExp(
              r'''^import\s+['"]package:flutter_riverpod/flutter_riverpod\.dart['"];\s*''',
            );
            if (importPattern.hasMatch(trimmed)) {
              bad.add(entity.path);
              break;
            }
          }
        }
      }
      expect(
        bad,
        isEmpty,
        reason: 'Found flutter_riverpod imports in:\n${bad.join('\n')}',
      );
    });

    test('Hand-written providers use Riverpod code generation', () async {
      final offenders = await _findManualProviderDeclarationOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Use @riverpod / @Riverpod code generation for provider '
            'declarations. Manual Provider/FutureProvider/etc declarations '
            'drift from the documented app pattern.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Discourage withOpacity usage', () async {
      final libDir = Directory('lib');
      final offenders = <String>[];
      await for (final entity in libDir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final lines = await entity.readAsLines();
          var inBlockComment = false;
          for (final rawLine in lines) {
            final line = rawLine;
            if (inBlockComment) {
              if (line.contains('*/')) {
                inBlockComment = false;
              }
              continue;
            }
            final trimmed = line.trimLeft();
            if (trimmed.startsWith('/*')) {
              inBlockComment = true;
              continue;
            }
            if (trimmed.startsWith('//')) {
              continue;
            }
            if (trimmed.contains('.withOpacity(')) {
              offenders.add(entity.path);
              break;
            }
          }
        }
      }
      expect(
        offenders,
        isEmpty,
        reason:
            'Use withValues(alpha:) instead of withOpacity() in:\n${offenders.join('\n')}',
      );
    });

    test(
      'Active code uses app theme providers instead of framework themes',
      () async {
        final offenders = await _findFrameworkThemeLookupOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'Active UI code should use themeColorsProvider and '
              'themeTypographyProvider, not Theme.of(context), '
              'MacosTheme.of(context), or CupertinoTheme.of(context).\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test('Hand-written lib Dart files contain active code', () async {
      final offenders = await _findAllCommentLibDartFiles();

      expect(
        offenders,
        isEmpty,
        reason:
            'Hand-written Dart files under lib/ must not be all-comment '
            'scratch files. Move retained notes to documentation, or delete '
            'retired experiments.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Active Dart code contains no TODO or FIXME markers', () async {
      final offenders = await _findActiveTodoFixmeOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'TODO/FIXME markers in active Dart code defer ownership and '
            'invite architectural drift. Resolve the issue, document it in '
            'the appropriate planning file, or keep explanatory context in '
            'comments outside executable code.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Active Dart code does not throw raw strings', () async {
      final offenders = await _findRawStringThrowOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Throw typed exceptions or errors, not raw strings. Raw string '
            'throws lose type information and make failure boundaries harder '
            'to reason about.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Active Dart code does not throw generic Exception', () async {
      final offenders = await _findGenericExceptionThrowOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Use a typed error or domain failure instead of throwing generic '
            'Exception from hand-written Dart code.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Active lib code contains no UnimplementedError markers', () async {
      final offenders = await _findLibUnimplementedErrorOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'UnimplementedError in active lib/ code indicates an unfinished '
            'runtime path. Use an explicit typed failure for unsupported '
            'state, or complete the implementation.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test(
      'Raw print usage stays behind approved diagnostic boundaries',
      () async {
        final offenders = await _findRawPrintOffenders();

        expect(
          offenders,
          orderedEquals(_rawPrintAllowedFiles.toList()..sort()),
          reason:
              'Raw print calls should not spread through application code. Use '
              'the app logger or an explicit diagnostic boundary instead.\n'
              'Actual users:\n${offenders.join('\n')}',
        );
      },
    );

    test(
      'Sidebar semantic/application imports do not grow beyond tracked temporary exceptions',
      () async {
        final offenders = await _findSidebarPresentationImportOffenders();

        expect(
          offenders,
          orderedEquals(
            _trackedSidebarPresentationImportExceptions.toList()..sort(),
          ),
          reason:
              'Sidebar resolver/coordinator presentation imports changed. '
              'Remove offenders as the migration progresses, or explicitly '
              'track any narrow temporary exception in TEMPORARY_EXCEPTIONS.md.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test('Sidebar payload transport contains no runtime UI types', () async {
      final payloadFiles = await _collectSidebarPayloadFiles();
      final offenders = await _findPayloadTypeOffenders(payloadFiles);

      expect(
        offenders,
        orderedEquals(_trackedWidgetPayloadExceptions.toList()..sort()),
        reason:
            'Payload transport picked up forbidden runtime UI types.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Sidebar semantic action transport stays data-only', () async {
      final offenders = await _findSemanticActionTransportOffenders(
        _sidebarSemanticActionTransportFiles.toList()..sort(),
      );

      expect(
        offenders,
        isEmpty,
        reason:
            'Sidebar semantic action transport must not carry callbacks, '
            'dispatcher objects, or widget/runtime execution types.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test(
      'Message presentation invokes panel actions instead of panel stack state',
      () async {
        final offenders = await _findMessagePresentationPanelStateOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'Message presentation widgets may render local close controls, '
              'but panel-stack mutation belongs to the navigation action '
              'boundary. Use panelActionsProvider instead of '
              'panelsViewStateProvider or WindowPanel in message presentation.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test('Sidebar parked overlay invokes panel actions', () async {
      final offenders = await _findSidebarParkedOverlayPanelStateOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Sidebar parked overlay may render cancel/recheck controls, but '
            'panel-stack mutation belongs to the navigation action boundary.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Panel stack surface uses panel action boundary', () async {
      final offenders = await _findPanelStackSurfaceActionBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'PanelStackSurface may render tabs and observed panel pages, but '
            'tab activation/close and diagnostic logging belong behind '
            'PanelActions.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Parked center actions use semantic cancellation naming', () async {
      final offenders = await _findParkedCenterActionNamingOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Parked center-panel actions should describe the user intent '
            '(canceling a parked operation), not preserve generic clear-panel '
            'repair vocabulary.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test(
      'Sidebar parked overlay delegates onboarding readiness actions',
      () async {
        final offenders =
            await _findSidebarParkedOverlayOnboardingActionOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'Sidebar parked overlay may render readiness re-check controls, '
              'but clearing developer simulations and refreshing onboarding '
              'environment state belongs to the onboarding action boundary.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test(
      'App mode toggle delegates mode mutation to action boundary',
      () async {
        final offenders = await _findAppModeToggleActionBoundaryOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'AppModeToggle may render the selected sidebar mode, but mode '
              'mutation and cleanup side effects should cross AppModeActions.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test('Mac app shell toolbar controls use action boundary', () async {
      final offenders = await _findMacosAppShellActionBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'MacosAppShell may render toolbar controls and observe toolbar '
            'state, but developer-mode and theme mutations should cross '
            'AppShellActions.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Sidebar utility top menus use action boundary', () async {
      final offenders = await _findSidebarUtilityTopMenuActionOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Sidebar utility top-menu widgets may render menu choices and '
            'forward selections, but top-menu sidebar intent construction '
            'belongs behind SidebarTopMenuActions.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Settings action list uses action boundary', () async {
      final offenders = await _findSettingsActionListActionOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'SettingsActionList may render action descriptors and forward '
            'selection, but enabled-state dispatch and sidebar intent '
            'construction belong behind SettingsActionListActions.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test(
      'Feature presentation does not construct panel navigation specs',
      () async {
        final offenders =
            await _findFeaturePresentationNavigationSpecOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'Feature presentation should render typed view data and dispatch '
              'semantic actions. It must not construct ViewSpec/MessagesSpec '
              'or mutate WindowPanel state directly; route through the sidebar '
              'flow, sidebar action dispatcher, or navigation action boundary.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test('Sidebar widget contract uses semantic action wording', () async {
      final offenders = await _findStaleSidebarWidgetContractOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Sidebar widget comments should not preserve the retired guidance '
            'that widgets construct panel specs on interaction. Widgets render '
            'typed inputs and dispatch semantic actions; sidebar flow or '
            'navigation action boundaries own panel spec derivation.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test(
      'Sidebar widget builders do not invalidate providers directly',
      () async {
        final offenders = await _findSidebarWidgetInvalidationOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'Sidebar widget builders may render retry/refresh controls, but '
              'provider invalidation belongs behind resolver/action boundaries. '
              'Direct widget invalidation is an imperative repair pattern.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test('Sidebar body model renderer uses action boundary', () async {
      final offenders = await _findSidebarBodyModelRendererActionOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'SidebarBodyModelContent may render typed body models, but option '
            'disabled policy and sidebar dispatch belong behind '
            'SidebarBodyModelActions.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Grouped contact selector uses refresh action boundary', () async {
      final offenders = await _findGroupedContactSelectorRefreshOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Grouped contact selector may render retry controls and watch '
            'picker view models, but refresh invalidation belongs behind the '
            'contact sidebar refresh action boundary.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Chats view model dispatches sidebar actions', () async {
      final offenders = await _findChatsViewModelFlowMutationOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'The chats selection controller may translate chat selections into '
            'semantic chat-selection actions, but sidebar intent construction '
            'and dispatch belong behind ChatSelectionActions. Graph read-model '
            'composition belongs in the chats application layer, not '
            'presentation view models.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test(
      'Retained archive metadata provider stays behind retention boundaries',
      () async {
        final offenders = await _findRetainedArchiveMetadataProviderOffenders();

        expect(
          offenders,
          orderedEquals(
            _retainedArchiveMetadataStoreProviderAllowedFiles.toList()..sort(),
          ),
          reason:
              'retainedArchiveMetadataStoreProvider has been retired. '
              'Retained macos_import.db is cleanup/reference storage only, so '
              'ordinary app behavior must not recreate a provider authority '
              'for it.\n'
              'Actual users:\n${offenders.join('\n')}',
        );
      },
    );

    test(
      'Retained import metadata file stays behind metadata boundaries',
      () async {
        final offenders = await _findRetainedArchiveMetadataFileOffenders();

        expect(
          offenders,
          orderedEquals(
            _retainedArchiveMetadataFileAllowedFiles.toList()..sort(),
          ),
          reason:
              'Retained macos_import.db is archive-source metadata storage. '
              'Ordinary code must not add new retained import file access.\n'
              'Actual users:\n${offenders.join('\n')}',
        );
      },
    );

    test('Onboarding source-scoped fixtures use source-scoped names', () async {
      final offenders =
          await _findOnboardingSourceScopedProbeFixtureOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Onboarding sourceScopedImportDatabase fixtures must use the '
            'source-scoped import database name, not retained macos_import.db '
            'metadata compatibility names.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test(
      'Retained working database file stays behind reference boundaries',
      () async {
        final offenders = await _findRetainedHistoricalWorkingFileOffenders();

        expect(
          offenders,
          orderedEquals(
            _retainedHistoricalWorkingFileAllowedFiles.toList()..sort(),
          ),
          reason:
              'Retained working.db is historical/reference storage only. '
              'Ordinary code must not add new retained working file access.\n'
              'Actual users:\n${offenders.join('\n')}',
        );
      },
    );

    test('Retained database filename literals stay centralized', () async {
      final offenders = await _findRetainedDatabaseFilenameLiteralOffenders();

      expect(
        offenders,
        orderedEquals(
          _retainedDatabaseFilenameLiteralAllowedFiles.toList()..sort(),
        ),
        reason:
            'Use retained database filename constants from '
            'feature_level_providers.dart instead of hard-coded retained '
            'database names in code.\n'
            'Actual users:\n${offenders.join('\n')}',
      );
    });

    test('Legacy terminology does not appear in active lib code', () async {
      final offenders = await _findLegacyTerminologyOffenders();

      expect(
        offenders,
        orderedEquals(_legacyTerminologyAllowedFiles.toList()..sort()),
        reason:
            'Active lib/ code should not grow legacy-named concepts. '
            'Retained storage and compatibility bridges must be named for '
            'their current architectural role.\n'
            'Actual users:\n${offenders.join('\n')}',
      );
    });

    test('Retained overlay identity bridge usage stays tracked', () async {
      final offenders =
          await _findRetainedOverlayIdentityBridgeImportOffenders();

      expect(
        offenders,
        orderedEquals(
          _retainedOverlayIdentityBridgeAllowedFiles.toList()..sort(),
        ),
        reason:
            'retained_overlay_identity_bridge.dart has been retired. '
            'Retained overlay compatibility must stay localized inside named '
            'feature/infrastructure boundaries instead of returning as a '
            'shared bridge import.\n'
            'Actual users:\n${offenders.join('\n')}',
      );
    });

    test('Retained overlay identity bridge tests do not return', () async {
      final offenders =
          await _findRetainedOverlayIdentityBridgeTestImportOffenders();

      expect(
        offenders,
        orderedEquals(
          _retainedOverlayIdentityBridgeTestAllowedFiles.toList()..sort(),
        ),
        reason:
            'retained_overlay_identity_bridge.dart has been retired. Feature '
            'tests should assert their own repository/read-model contracts '
            'rather than restoring shared transitional bridge semantics.\n'
            'Actual test users:\n${offenders.join('\n')}',
      );
    });

    test('Handle blacklist overlays preserve graph-id precedence', () async {
      final offenders = await _findHandleBlacklistVariantExpansionOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Handle visibility blacklist rows must not be expanded into '
            'retained/graph variants before filtering graph rows. Exact '
            'graph-id overlay intent must win over retained compatibility '
            'variants; resolve with overlayValueForHandleId at the handle '
            'being evaluated.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Recent contact overlays dedupe before visible limiting', () async {
      final offenders = await _findRecentContactPreDedupeLimitOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Recent contact overlay readers must fetch enough candidates to '
            'collapse retained/graph identity variants before applying the '
            'visible recents cap. Limiting to the visible count first lets '
            'compatibility duplicates consume picker slots.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Overlay database filename literal stays centralized', () async {
      final offenders = await _findOverlayDatabaseFilenameLiteralOffenders();

      expect(
        offenders,
        orderedEquals(
          _overlayDatabaseFilenameLiteralAllowedFiles.toList()..sort(),
        ),
        reason:
            'Use overlayDatabaseFileName instead of hard-coded user_overlays.db '
            'literals in production code.\n'
            'Actual users:\n${offenders.join('\n')}',
      );
    });

    test('Source-scoped database filename literals stay centralized', () async {
      final offenders =
          await _findSourceScopedDatabaseFilenameLiteralOffenders();

      expect(
        offenders,
        orderedEquals(
          _sourceScopedDatabaseFilenameLiteralAllowedFiles.toList()..sort(),
        ),
        reason:
            'Use source-scoped database filename constants instead of '
            'hard-coded macos_import_ss.db / working_ss.db literals in '
            'production code.\n'
            'Actual users:\n${offenders.join('\n')}',
      );
    });

    test('Source-scoped SQL bit extraction uses helper boundary', () async {
      final offenders = await _findSourceScopedSqlBitExtractionOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'SQL repositories should use SourceScopedRowSql when extracting '
            'source id or source rowid from packed ss_id values. Open-coded '
            'bit shifts/masks make source-scoped identity derivation harder '
            'to audit.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Retired import/migration execution paths do not return', () async {
      final offenders = await _findRetiredImportMigrationExecutionOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Retired import/migration execution symbols or paths were found. '
            'Ordinary import/projection must use source-scoped graph lifecycle; '
            'do not reintroduce retained execution paths.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Retired import/projection folders do not return', () {
      final retiredPaths = <String>[
        'lib/essentials/db_importers',
        'lib/essentials/db_migrate',
        'lib/essentials/incremental_update_ss',
        'lib/essentials/db/infrastructure/data_sources/local/working',
        'lib/features/chats/application/conversation_browser',
        'lib/features/chats/presentation/view/conversation_browser_view.dart',
        'test/essentials/db_importers',
        'test/essentials/db_migrate',
        'test/essentials/incremental_update_ss',
        'test/essentials/db/infrastructure/data_sources/local/working',
        'test/features/chats/application/conversation_browser',
      ];
      final existingPaths = retiredPaths
          .where((path) => Directory(path).existsSync())
          .toList();

      expect(
        existingPaths,
        isEmpty,
        reason:
            'The old db_importers, db_migrate, incremental_update_ss, and '
            'retained Drift working-schema folders have been retired. The old '
            'conversation browser has also been retired. Live source monitoring '
            'belongs to conversation_graph lifecycle code, source fact importers '
            'belong to source_scoped_import, ordinary conversation browsing '
            'belongs to the conversation signature/evidence spine, and retained '
            'DB diagnostics belong to essentials/db.\n'
            'Existing retired paths:\n${existingPaths.join('\n')}',
      );
    });

    test('Retired retained-overlay identity domain bridge does not return', () {
      const retiredFiles = <String>[
        'lib/essentials/conversation_graph/domain/identity_key_bridge.dart',
        'test/essentials/conversation_graph/domain/identity_key_bridge_test.dart',
        'lib/essentials/conversation_graph/application/identity/retained_overlay_identity_bridge.dart',
        'test/essentials/conversation_graph/application/identity/retained_overlay_identity_bridge_test.dart',
      ];
      final existingFiles = retiredFiles
          .where((path) => File(path).existsSync())
          .toList();

      expect(
        existingFiles,
        isEmpty,
        reason:
            'Retained-overlay id conversion is transitional compatibility '
            'logic and must stay localized inside named feature or '
            'infrastructure boundaries; do not restore shared graph/domain '
            'identity bridges.\n'
            'Existing retired files:\n${existingFiles.join('\n')}',
      );
    });

    test(
      'Retained archive metadata database imports stay quarantined',
      () async {
        final offenders = await _findRetainedImportWrapperImportOffenders();

        expect(
          offenders,
          orderedEquals(
            _retainedImportWrapperImportAllowedFiles.toList()..sort(),
          ),
          reason:
              'Do not import the retained archive metadata database from '
              'ordinary code. Active Historical Archives metadata belongs to '
              'the settings repository backed by overlay storage; retained '
              'macos_import.db files are cleanup/reference storage only.\n'
              'Actual users:\n${offenders.join('\n')}',
        );
      },
    );

    test('App database construction stays behind provider boundaries', () async {
      final offenders = await _findDatabaseConstructionOffenders();

      expect(
        offenders,
        orderedEquals(_databaseConstructionAllowedFiles.toList()..sort()),
        reason:
            'App database instances must be created only by their database '
            'classes or central provider boundaries. Feature code should read '
            'the named providers instead of constructing databases directly.\n'
            'Actual users:\n${offenders.join('\n')}',
      );
    });

    test('UI rendering code does not own database access', () async {
      final offenders = await _findUiRenderingDatabaseAccessOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'UI rendering code should render typed models and callbacks. '
            'Database providers, concrete database adapters, and SQL calls '
            'belong behind application/infrastructure boundaries, including '
            'when widgets live under spec/cassette builder folders.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Database health query contract stays file-system agnostic', () async {
      final offenders = await _findDatabaseHealthQueryLayerFileIoOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'DatabaseHealthQueryLayer is an application query contract. '
            'Filesystem existence checks belong in concrete infrastructure '
            'query-layer implementations.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test(
      'Conversation graph readiness provider uses checker boundary',
      () async {
        final offenders =
            await _findConversationGraphReadinessProviderBoundaryOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'The public graph readiness provider should expose lifecycle '
              'readiness semantics and delegate filesystem/SQLite probing to '
              'infrastructure.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test('Database health audit service stays IO agnostic', () async {
      final offenders = await _findDatabaseHealthAuditServiceIoOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'DatabaseHealthAuditService owns audit semantics. Runtime platform '
            'metadata and report file writes belong behind dedicated ports.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test(
      'Source-scoped import application layer does not import sqflite',
      () async {
        final offenders =
            await _findSourceScopedImportApplicationSqfliteOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'Source-scoped application importers should depend on the '
              'SourceDatabaseOpener port. sqflite belongs in infrastructure '
              'adapters only.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test(
      'Source-scoped import services do not import concrete import database',
      () async {
        final offenders =
            await _findSourceScopedImportServiceImportDatabaseOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'Source-scoped import application services should depend on '
              'ImportLedger, not the concrete ImportDatabase infrastructure '
              'wrapper. Use sourceScopedImportLedgerProvider for provider '
              'composition.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test(
      'Source-scoped import application uses public feature boundaries',
      () async {
        final offenders =
            await _findSourceScopedImportApplicationFeatureInfrastructureOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'Source-scoped import application code may depend on public '
              'feature-level providers, but must not reach into feature '
              'infrastructure files directly.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test(
      'Conversation graph application avoids concrete import database',
      () async {
        final offenders =
            await _findConversationGraphApplicationImportDatabaseOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'Conversation graph application code should depend on '
              'source-scoped import ports or public feature-level providers, '
              'not the concrete import database infrastructure provider.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test(
      'Graph cross-snapshot mapper avoids concrete import database',
      () async {
        final offenders =
            await _findGraphCrossSnapshotMapperImportDatabaseOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'GraphCrossSnapshotMapper should depend on typed attachment '
              'snapshot lookups, not the concrete source-scoped import DB. '
              'The concrete lookup adapter belongs in attachments '
              'infrastructure.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test(
      'Deterministic recovery stays behind attachment recovery ports',
      () async {
        final offenders =
            await _findDeterministicRecoveryInfrastructureImportOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'Deterministic recovery should orchestrate recovery phases '
              'through application ports and feature-level providers, not '
              'construct concrete infrastructure mappers or archive writers.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test('Other systems use attachments feature boundary', () async {
      final offenders =
          await _findCrossSystemAttachmentProviderImportOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Systems outside attachments should consume attachment resolver, '
            'archive service, archive settings, and recovery providers through '
            'features/attachments/feature_level_providers.dart. Direct imports '
            'of attachment application provider files create provider islands.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Other systems use chats feature boundary', () async {
      final offenders = await _findCrossSystemChatProviderImportOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Systems outside chats should consume chat view-model providers '
            'and read models through features/chats/feature_level_providers.dart. '
            'Direct imports of chats presentation providers recreate provider '
            'islands and leak feature internals.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Other systems use settings feature boundary', () async {
      final offenders =
          await _findCrossSystemSettingsApplicationImportOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Systems outside settings should consume settings application '
            'providers, coordinators, and resolvers through '
            'features/settings/feature_level_providers.dart. Direct imports '
            'of settings application internals recreate provider islands.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Archive settings uses stats reader port', () async {
      final offenders =
          await _findArchiveSettingsStatsRepositoryImportOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'ArchiveSettings should read archive stats through the '
            'AttachmentArchiveStatsReader port. Concrete repository wiring '
            'belongs in the attachments feature-level provider.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Archive settings uses settings store port', () async {
      final offenders =
          await _findArchiveSettingsOverlayDatabaseImportOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'ArchiveSettings should read and write archive preferences '
            'through AttachmentArchiveSettingsStore. Overlay table access '
            'belongs in attachments infrastructure.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Archive settings uses file-operations port', () async {
      final offenders = await _findArchiveSettingsFileOperationsOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'ArchiveSettings should coordinate archive user intent through '
            'AttachmentArchiveFileOperations. Native file picking and '
            'directory/file IO belong in attachments infrastructure.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Historical archives workflow uses folder chooser port', () async {
      final offenders =
          await _findHistoricalArchivesFolderChooserBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'HistoricalArchivesWorkflow should coordinate archive folder '
            'selection through HistoricalArchiveFolderChooser. Native folder '
            'dialogs belong in settings infrastructure.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Attachment resolver uses archive read-store port', () async {
      final offenders =
          await _findAttachmentResolverArchiveStorageImportOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'AttachmentResolver should resolve archive records and recovery '
            'hints through AttachmentArchiveReadStore. Overlay tables and '
            'hint storage details belong in infrastructure.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Attachment resolver derives archive key from evidence', () async {
      final offenders =
          await _findAttachmentResolverPrimitiveKeyParameterOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'attachmentResolverProvider should accept AttachmentInfo evidence '
            'only. Current archive compatibility keys should be derived inside '
            'the resolver, not exposed as provider-family parameters.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Message attachment evidence uses file-access boundary', () async {
      final offenders =
          await _findMessageAttachmentEvidenceFileAccessBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Message attachment evidence may classify attachments, but file '
            'existence checks and home-directory expansion belong behind the '
            'AttachmentFileAccess boundary.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('AttachmentFileAccess remains path-based', () async {
      final offenders = await _findAttachmentFileAccessContractOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'AttachmentFileAccess is an application boundary and should speak '
            'in path strings. Concrete File objects belong at infrastructure '
            'or presentation rendering edges.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('AttachmentInfo remains data-only', () async {
      final offenders = await _findAttachmentInfoDataOnlyOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'AttachmentInfo is message metadata. File-system path expansion '
            'and existence checks belong behind attachment feature boundaries.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('MediaTileAttachment remains data-only', () async {
      final offenders = await _findMediaTileAttachmentDataOnlyOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'MediaTileAttachment is a rendering DTO. File resolution and '
            'path expansion belong behind AttachmentFileAccess, not inside '
            'the DTO.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test(
      'Message display widgets use typed media archive compatibility keys',
      () async {
        final offenders =
            await _findMessageDisplayArchiveCompatibilityKeyOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'Message display widgets should consume '
              'MediaTileAttachment.archiveCompatibilityKey instead of '
              'reconstructing archive compatibility keys from primitive '
              'messageGuid/importAttachmentId fields.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test('Message display recovery controls use attachment actions', () async {
      final offenders =
          await _findMessageDisplayAttachmentRecoveryActionOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Message display widgets may render unavailable attachment '
            'controls, but recovery-priority writes should cross '
            'AttachmentRecoveryActions instead of invoking archive services '
            'directly.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Message URL previews use external URI opener boundary', () async {
      final offenders = await _findMessageUrlPreviewOpenerBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Message URL previews may render tappable links, but external '
            'launch mechanics belong behind ExternalUriOpener.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('ResolvedAttachment remains path-based data', () async {
      final offenders = await _findResolvedAttachmentPathOnlyOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'ResolvedAttachment should describe attachment availability and '
            'resolved file paths. Concrete File handles belong at rendering or '
            'infrastructure boundaries.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Search application uses graph search contract', () async {
      final offenders = await _findSearchApplicationRepositoryImportOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Search application and message evidence code should depend on '
            'the graph search application contract, not the concrete SQL '
            'repository implementation.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Display identity application stays semantic', () async {
      final offenders =
          await _findDisplayIdentityApplicationInfrastructureOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Display identity application code should define semantic identity '
            'models/contracts only. Concrete graph/overlay repository '
            'composition belongs in the contacts feature-level provider.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Conversation signature presentation uses display models', () async {
      final offenders =
          await _findConversationSignaturePresentationRawProviderOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'ConversationSignature is a graph-fact read model. Presentation '
            'and widget-builder code must consume resolved display models so '
            'user display-name overrides can win before rendering.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Conversation signature selection uses action boundary', () async {
      final offenders =
          await _findConversationSignatureSelectionActionBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'ConversationSignaturesWidget may render signature rows and '
            'report selected ids, but sidebar intent construction and dispatch '
            'belong behind ConversationNavigationActions.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Conversation signature preferences use action boundary', () async {
      final offenders =
          await _findConversationSignaturePreferencesActionBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'ConversationSignaturesWidget may render filter/sort controls, '
            'but persisted preference mutation belongs behind '
            'ConversationSignaturePreferencesActions.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Conversation message header uses context boundary', () async {
      final offenders =
          await _findConversationMessageHeaderContextBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'ConversationMessagesPreviewView renders message evidence. '
            'Conversation title/date/count composition should stay behind the '
            'ConversationEvidenceHeaderContext provider so raw graph '
            'participant facts do not become user-facing labels in widgets.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Contact message header uses context boundary', () async {
      final offenders =
          await _findContactMessageHeaderContextBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'ContactMessagesEvidenceView renders message evidence. Contact '
            'title/date/count/selected-handle composition should stay behind '
            'the ContactEvidenceHeaderContext provider so raw graph and '
            'identity facts do not become widget-owned semantics.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Contact conversation section uses display boundary', () async {
      final offenders =
          await _findContactConversationSectionDisplayBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'ContactGraphConversationSection renders conversation signature '
            'cards. It should consume display-ready contact conversation '
            'signatures instead of opening raw contact graph snapshots inside '
            'presentation. Conversation selection should dispatch a typed '
            'sidebar action, not mutate SidebarFlow or push center-panel '
            'content imperatively.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Contact conversation section uses action boundary', () async {
      final offenders =
          await _findContactConversationSectionActionBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'ContactGraphConversationSection may render conversation signature '
            'cards and report selected ids, but sidebar intent construction '
            'and dispatch belong behind ContactConversationNavigationActions.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test(
      'Messages heatmap widget uses contact context identity boundary',
      () async {
        final offenders =
            await _findMessagesHeatmapWidgetContactContextBoundaryOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'MessagesHeatmapWidget renders the heatmap/contact conversation '
              'toggle. It should use a named contact context identity boundary '
              'instead of importing raw graph contact providers directly.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test('Contact context identity uses identity boundary', () async {
      final offenders =
          await _findContactContextIdentityProviderImportOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Contact context matching should depend on the contact-page graph '
            'identity boundary, not the contact graph provider. Providers '
            'compose reads; they should not be imported as identity utilities.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Conversation browser is not a message evidence spec route', () async {
      final offenders = await _findConversationBrowserSpecRouteOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Conversations navigation derives selected conversation '
            'evidence from sidebar flow. The old center-panel conversation '
            'browser must not return as a MessagesSpec route, coordinator '
            'branch, panel compatibility branch, or navigation-log variant.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Retired conversation browser is not publicly exported', () async {
      final offenders =
          await _findRetiredConversationBrowserPublicExportOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'The old ConversationBrowserView has been retired. It must not be '
            'exported from feature_level_providers.dart where ordinary feature '
            'consumers can rediscover it as a normal public chats surface.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Retired conversation browser files do not return', () async {
      final offenders = await _findRetiredConversationBrowserFileOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'The old conversation browser view and integrator are retired. '
            'Conversation browsing belongs to the graph sidebar/evidence spine, '
            'not a restored center-panel browser path.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Retired conversation browser internals do not return', () async {
      final offenders =
          await _findRetiredConversationBrowserInternalImportOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'The old conversation browser integrator/view have been retired. '
            'Ordinary app code must use graph/evidence-spine read models '
            'instead of importing this retired browser internals path.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Message user metadata application stays semantic', () async {
      final offenders =
          await _findMessageUserMetadataApplicationInfrastructureOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Message user-metadata application code should define graph-keyed '
            'user-intent contracts/controllers only. Concrete graph/overlay '
            'bridge composition belongs in the messages feature-level '
            'provider.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Recovered message evidence uses public feature boundary', () async {
      final offenders =
          await _findRecoveredMessageEvidenceInfrastructureProviderOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Recovered message evidence consumers should use the messages '
            'feature-level provider boundary, not a concrete infrastructure '
            'provider file.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Source-specific message renderers do not return', () async {
      final offenders = await _findSourceSpecificMessageRendererOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Message evidence scopes may differ by source, but evidence '
            'presentation must converge through the shared evidence spine. '
            'Do not restore source-specific message renderer classes or '
            'files.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Retired message timeline path does not return', () async {
      final offenders = await _findRetiredMessageTimelineOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'The old ordinal MessageTimelineScope / MessagesTimelineView path '
            'has been retired. Message evidence must use typed '
            'MessageEvidenceScope skeletons, visible-row hydration, and the '
            'shared MessageEvidenceTimelineView.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Message evidence spine keeps limits scoped to hydration', () async {
      final offenders = await _findMessageEvidenceScopeLimitOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Timeline-like message evidence scopes must preserve the full '
            'logical selected message universe. Bounded values in the message '
            'evidence spine must be explicit hydration windows, not selected '
            'scope limits.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Handle lens review actions use handles feature boundary', () async {
      final offenders = await _findHandleLensOverlayDatabaseOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'HandleLensView may render unfamiliar-source evidence and collect '
            'form/dialog input, but link/create/dismiss side effects belong '
            'behind HandleLensActions. It must not import central database '
            'providers, overlay infrastructure, or manual-link/review '
            'services directly.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Contact hero actions use contact feature boundaries', () async {
      final offenders = await _findContactHeroOverlayDatabaseOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'ContactHeroSummaryWidget may collect the user-edited display '
            'name, but overlay persistence must stay behind a contact '
            'display-name action boundary. Favourite mutations should also '
            'flow through contact action providers rather than local '
            'repository/invalidation plumbing.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Handle filter unlink uses manual-link action boundary', () async {
      final offenders = await _findHandleFilterManualLinkBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'HandleFilterWidget may request a manual unlink, but affected '
            'contact/handle read invalidation belongs inside '
            'ManualHandleLinkService rather than widget-level repair logic.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Stray handle cassettes use handles action boundary', () async {
      final offenders = await _findStrayHandleCassetteActionBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Stray handle sidebar cassettes may render open/filter/review '
            'controls, but sidebar intent construction, dispatch, and handle '
            'normalization belong behind StrayHandleSidebarActions.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Recovered message sidebar uses navigation action boundary', () async {
      final offenders =
          await _findRecoveredMessageSidebarNavigationBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Recovered message sidebar widgets may render heatmaps/buttons, '
            'but recovered sidebar intent construction and dispatch belong '
            'behind RecoveredMessageNavigationActions.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test(
      'Contact application/presentation uses the contacts feature boundary',
      () async {
        final offenders =
            await _findContactPresentationContactsListRepositoryOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'Contact application/presentation may render or compose contact '
              'summaries, handles, and virtual contacts, but it should consume '
              'them through the contacts feature-level public API rather than '
              'importing concrete contact infrastructure read-model files.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test(
      'Contact display-name override actions stay storage agnostic',
      () async {
        final offenders =
            await _findContactDisplayNameOverrideActionStorageOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'ContactDisplayNameOverrideActions owns user-intent action '
              'semantics and invalidation only. Overlay store construction '
              'belongs in the contacts feature-level provider boundary.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test(
      'Contact favourite invalidation contract names action owner',
      () async {
        final offenders =
            await _findContactFavoriteInvalidationContractOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'Contact favourite read providers should not document generic '
              'caller-owned invalidation. Mutations and dependent read refresh '
              'belong to ContactFavoriteActions.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test('Retired contact name variants stay out of active identity', () async {
      final offenders = await _findRetiredContactNameVariantOffenders();

      expect(
        offenders,
        orderedEquals(_retiredContactNameVariantAllowedFiles.toList()..sort()),
        reason:
            'Short-name, nickname, and name-mode identity variants are retired '
            'as app-facing display identity concepts. The only user-authored '
            'contact name override is participant_overrides.display_name_override. '
            'Physical retained schema compatibility may remain in the overlay '
            'database only.\n'
            'Actual users:\n${offenders.join('\n')}',
      );
    });

    test('Contact overlay stores stay feature-boundary owned', () {
      const retiredProviderPaths = <String>[
        'lib/features/contacts/application/sidebar_cassette_spec/resolver_tools/favorite_contacts_repository_provider.dart',
        'lib/features/contacts/infrastructure/repositories/contacts_list_repository.dart',
        'lib/features/contacts/infrastructure/repositories/contact_display_name_override_store_provider.dart',
        'lib/features/contacts/infrastructure/repositories/contact_profile_provider.dart',
        'lib/features/contacts/infrastructure/repositories/favorite_contacts_repository_provider.dart',
        'lib/features/contacts/infrastructure/repositories/handles_for_contact_provider.dart',
        'lib/features/contacts/infrastructure/repositories/manual_handle_link_store_provider.dart',
        'lib/features/contacts/infrastructure/repositories/picker_filter_mode_store_provider.dart',
        'lib/features/contacts/infrastructure/repositories/recent_contacts_repository.dart',
        'lib/features/contacts/infrastructure/repositories/virtual_participants_provider.dart',
      ];

      for (final retiredPath in retiredProviderPaths) {
        expect(
          File(retiredPath).existsSync(),
          isFalse,
          reason:
              'Contact user-intent store/repository composition opens overlay '
              'storage and belongs in contacts feature_level_providers.dart, '
              'not resolver tools or infrastructure provider islands.',
        );
      }
    });

    test('Other features use contacts feature boundary', () async {
      final offenders = await _findCrossFeatureContactInfrastructureOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Features outside contacts should consume contact profile, handle, '
            'and virtual participant providers through '
            'features/contacts/feature_level_providers.dart, not by importing '
            'contacts infrastructure files directly.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Manual handle-link service stays overlay-storage agnostic', () async {
      final offenders = await _findManualHandleLinkServiceStorageOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'ManualHandleLinkService owns semantic validation and action '
            'invalidation only. Overlay table APIs must stay behind the '
            'ManualHandleLinkStore infrastructure boundary.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Conversation signature preferences stay storage agnostic', () async {
      final offenders =
          await _findConversationSignaturePreferencesStorageOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'ConversationSignaturePreferencesController owns sidebar '
            'preference semantics only. Overlay settings read/write details '
            'must stay behind the preferences store boundary.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test(
      'Conversation signature preferences store stays feature-boundary owned',
      () {
        const retiredInfrastructureProvider =
            'lib/features/messages/infrastructure/repositories/conversation_signature_preferences_store_provider.dart';

        expect(
          File(retiredInfrastructureProvider).existsSync(),
          isFalse,
          reason:
              'ConversationSignaturePreferencesStore is an application '
              'contract, but provider composition imports concrete overlay '
              'storage and belongs in the messages feature-level provider '
              'boundary.',
        );
      },
    );

    test('Contact picker filter mode stays storage agnostic', () async {
      final offenders = await _findPickerFilterModeStorageOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'PickerFilter owns contact-picker preference semantics only. '
            'Overlay settings read/write details must stay behind the picker '
            'filter mode store boundary.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Contact picker filter toggle uses action boundary', () async {
      final offenders = await _findPickerFilterToggleActionBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'PickerFilterToggle may render the current filter mode, but '
            'persisted picker-filter mutation should cross '
            'PickerFilterActions rather than calling the state provider '
            'notifier directly.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Contact picker selection uses action boundary', () async {
      final offenders = await _findContactPickerSelectionActionOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Contact picker widgets may render contact choices and forward '
            'selection/hover intents, but sidebar contact-selection dispatch '
            'and contact evidence prewarming belong behind '
            'ContactPickerActions.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Contact handle filter uses action boundary', () async {
      final offenders = await _findHandleFilterActionBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'HandleFilterWidget may render handle-filter controls, but handle '
            'selection, unlinking, and follow-up navigation should cross '
            'HandleFilterActions.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Contact message scope toggle uses action boundary', () async {
      final offenders =
          await _findContactMessageScopeToggleActionBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'ContactMessageScopeToggleWidget may render current/recovered '
            'scope controls, but cassette-indexed sidebar intent construction '
            'and dispatch belong behind ContactMessageScopeActions.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Conversation favourites stay storage agnostic', () async {
      final offenders = await _findConversationFavouritesStorageOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'ConversationFavouritesController owns global conversation '
            'favourite semantics only. Overlay settings read/write details '
            'must stay behind the favourites store boundary.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Conversation favourite button uses action boundary', () async {
      final offenders =
          await _findConversationFavouriteButtonActionBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'ConversationFavouriteButton may render favourite state, but '
            'toggle writes should cross ConversationFavouriteActions.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Handle spam management stays visibility-storage agnostic', () async {
      final offenders = await _findSpamManagementStorageOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'SpamManagement owns handle visibility semantics and invalidation '
            'only. Overlay visibility table APIs must stay behind the handle '
            'visibility store boundary.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Handle overlay repositories stay feature-boundary owned', () {
      const retiredProviderPaths = <String>[
        'lib/features/handles/infrastructure/repositories/handle_visibility_store_provider.dart',
        'lib/features/handles/infrastructure/repositories/manual_linking_read_repository_provider.dart',
        'lib/features/handles/infrastructure/repositories/spam_handles_repository_provider.dart',
        'lib/features/handles/infrastructure/repositories/handle_display_name_provider.dart',
        'lib/features/handles/infrastructure/repositories/stray_handles_provider.dart',
      ];

      for (final retiredPath in retiredProviderPaths) {
        expect(
          File(retiredPath).existsSync(),
          isFalse,
          reason:
              'Handle overlay/repository composition opens graph or overlay '
              'storage and belongs in handles feature_level_providers.dart, '
              'not infrastructure provider islands.',
        );
      }
    });

    test(
      'Handle application/presentation uses the handles feature boundary',
      () async {
        final offenders =
            await _findHandleApplicationInfrastructureProviderOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'Handle application/presentation may render or compose handle '
              'display and stray-handle read models, but it should consume '
              'them through the handles feature-level public API rather than '
              'importing concrete handle infrastructure provider files.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test('Other features use handles feature boundary', () async {
      final offenders = await _findCrossFeatureHandleInfrastructureOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Features outside handles should consume handle display/stray '
            'handle providers through features/handles/feature_level_providers.dart, '
            'not by importing handles infrastructure files directly.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Developer mode stays overlay-storage agnostic', () async {
      final offenders = await _findDeveloperModeStorageOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'DeveloperMode owns default/debug-mode semantics only. Overlay '
            'setting read/write APIs must stay behind the developer-mode store '
            'boundary.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Developer mode store provider stays feature-boundary owned', () {
      const retiredInfrastructureProvider =
          'lib/essentials/debug/infrastructure/persistence/developer_mode_store_provider.dart';

      expect(
        File(retiredInfrastructureProvider).existsSync(),
        isFalse,
        reason:
            'DeveloperModeStore is an application contract, but provider '
            'composition imports concrete overlay storage and belongs in the '
            'debug feature-level provider boundary.',
      );
    });

    test('Manual linking actions use the manual-link service boundary', () async {
      final offenders = await _findManualLinkingActionStorageOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'ManualLinking may still compose graph/overlay read models during '
            'transition, but manual-link mutations must flow through '
            'ManualHandleLinkService instead of writing overlay tables directly.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Manual linking read providers use repository boundary', () async {
      final offenders = await _findManualLinkingReadBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Manual-linking providers should expose intent/read providers and '
            'delegate graph/overlay query composition to infrastructure '
            'repositories.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Sidebar flow state stays overlay-storage agnostic', () async {
      final offenders = await _findSidebarFlowStorageOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'SidebarFlow owns deterministic sidebar state and projection only. '
            'Overlay setting read/write mechanics must stay behind the sidebar '
            'flow preference store.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Sidebar flow preference provider stays feature-boundary owned', () {
      const retiredInfrastructureProvider =
          'lib/essentials/sidebar/infrastructure/persistence/sidebar_flow_preference_store_provider.dart';

      expect(
        File(retiredInfrastructureProvider).existsSync(),
        isFalse,
        reason:
            'SidebarFlowPreferenceStore is an application contract, but '
            'provider composition imports concrete overlay storage and belongs '
            'in the sidebar feature-level provider boundary.',
      );
    });

    test('Sidebar action dispatcher stays storage agnostic', () async {
      final offenders = await _findSidebarActionDispatcherStorageOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Sidebar action dispatch should route intents to feature-owned '
            'actions. Overlay read/write mechanics must stay behind feature '
            'stores or infrastructure repositories.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test(
      'Sidebar action dispatcher does not push message evidence panels',
      () async {
        final offenders =
            await _findSidebarActionDispatcherPanelPushOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'Sidebar action dispatch may mutate sidebar flow or call '
              'feature-owned action boundaries, but message evidence center '
              'content must derive from SidebarFlowState rather than direct '
              'panel pushes.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test('Pipeline incident tracker stays overlay-storage agnostic', () async {
      final offenders = await _findPipelineIncidentTrackerStorageOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'PipelineIncidentTracker owns incident semantics and lifecycle, '
            'not overlay storage construction or audit-log file writing. '
            'Overlay read/write and logging file mechanics must stay behind '
            'logging infrastructure ports.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('App logger consumers use logging feature boundary', () async {
      final offenders = await _findAppLoggerFeatureBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'AppLogger is exposed through the logging feature-level API. '
            'Other systems should not import the application logger file '
            'directly.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Graph health provider uses repository boundary', () async {
      final offenders = await _findGraphHealthProviderBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Graph health application providers should read through the '
            'GraphHealthRepository boundary. Concrete DB wiring and recovery '
            'source paths belong in infrastructure.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Chat summary provider uses repository boundary', () async {
      final offenders = await _findChatSummaryProviderBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Chat summary application providers should depend on the '
            'ChatSummaryRepository boundary. Graph DB, overlay DB, and archive '
            'lookup construction belong in infrastructure.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Conversation reader provider uses repository boundary', () async {
      final offenders =
          await _findConversationReaderProviderBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Conversation reader application providers should depend on the '
            'ConversationRepository boundary. Graph DB and concrete SQLite '
            'repository construction belong in infrastructure.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Contact graph provider uses repository boundary', () async {
      final offenders = await _findContactGraphProviderBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Contact graph application providers should depend on the '
            'ContactGraphRepository boundary. Graph DB and concrete SQLite '
            'repository construction belong in infrastructure.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Message graph reader provider uses repository boundary', () async {
      final offenders =
          await _findMessageGraphReaderProviderBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Message graph reader application providers should depend on the '
            'MessageGraphRepository boundary. Graph DB and concrete SQLite '
            'repository construction belong in infrastructure.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Graph read repositories stay feature-boundary owned', () {
      const retiredProviderPaths = <String>[
        'lib/essentials/conversation_graph/infrastructure/repositories/chat_summary_repository_provider.dart',
        'lib/essentials/conversation_graph/infrastructure/repositories/contact_graph_repository_provider.dart',
        'lib/essentials/conversation_graph/infrastructure/repositories/conversation_repository_provider.dart',
        'lib/essentials/conversation_graph/infrastructure/repositories/graph_health_repository_provider.dart',
        'lib/essentials/conversation_graph/infrastructure/repositories/message_graph_repository_provider.dart',
      ];

      for (final retiredPath in retiredProviderPaths) {
        expect(
          File(retiredPath).existsSync(),
          isFalse,
          reason:
              'Graph read repository composition opens graph, overlay, archive, '
              'or retained recovery resources and belongs in the '
              'conversation_graph feature-level provider boundary, not '
              'infrastructure provider islands.',
        );
      }
    });

    test('Message graph repository uses graph identity boundary', () async {
      final offenders =
          await _findMessageGraphRepositoryIdentityBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'MessageGraphRepository may normalize retained/live context ids, '
            'but that compatibility derivation belongs behind '
            'canonicalLiveChatGraphId. The repository should not pack '
            'SourceScopedRowKey ids directly.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Message projector provider uses repository boundary', () async {
      final offenders = await _findMessageProjectorProviderBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Message projector application providers should depend on the '
            'MessageProjectionRepository boundary. Import DB, graph DB, and '
            'concrete SQLite repository construction belong in infrastructure.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Graph projector providers use repository boundaries', () async {
      final offenders = await _findGraphProjectorProviderBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Graph projector application providers should depend on projection '
            'repository boundaries. Import DB, graph DB, and concrete SQLite '
            'repository construction belong in infrastructure providers.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Graph projection repositories stay feature-boundary owned', () {
      const retiredProviderPaths = <String>[
        'lib/essentials/conversation_graph/infrastructure/repositories/attachment_projection_repository_provider.dart',
        'lib/essentials/conversation_graph/infrastructure/repositories/chat_projection_repository_provider.dart',
        'lib/essentials/conversation_graph/infrastructure/repositories/chat_to_handle_projection_repository_provider.dart',
        'lib/essentials/conversation_graph/infrastructure/repositories/chat_to_message_projection_repository_provider.dart',
        'lib/essentials/conversation_graph/infrastructure/repositories/contact_projection_repository_provider.dart',
        'lib/essentials/conversation_graph/infrastructure/repositories/graph_projection_resetter_provider.dart',
        'lib/essentials/conversation_graph/infrastructure/repositories/handle_projection_repository_provider.dart',
        'lib/essentials/conversation_graph/infrastructure/repositories/message_projection_repository_provider.dart',
        'lib/essentials/conversation_graph/infrastructure/repositories/message_to_attachment_projection_repository_provider.dart',
      ];

      for (final retiredPath in retiredProviderPaths) {
        expect(
          File(retiredPath).existsSync(),
          isFalse,
          reason:
              'Graph projection repository/resetter composition opens import '
              'or graph databases and belongs in the conversation_graph '
              'feature-level provider boundary, not infrastructure provider '
              'islands.',
        );
      }
    });

    test('Graph status provider uses repository boundary', () async {
      final offenders = await _findGraphStatusProviderBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Graph status application providers should expose status semantics '
            'without opening source/import/graph databases or constructing '
            'the concrete status repository directly.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Graph status sheet controls use action boundary', () async {
      final offenders = await _findGraphStatusSheetControlBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Conversation graph status sheet controls may render refresh/build '
            'buttons, but provider invalidation, graph build execution, and '
            'status run logging belong in the application action boundary.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Onboarding presentation renders graph build state only', () async {
      final offenders = await _findOnboardingGraphBuildPresentationOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Onboarding presentation may render graph build state/report DTOs, '
            'but it must not import graph build orchestrator implementation '
            'details directly.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Graph status and favourites stores stay feature-boundary owned', () {
      const retiredProviderPaths = <String>[
        'lib/essentials/conversation_graph/infrastructure/repositories/conversation_favourites_store_provider.dart',
        'lib/essentials/conversation_graph/infrastructure/repositories/conversation_graph_status_repository_provider.dart',
      ];

      for (final retiredPath in retiredProviderPaths) {
        expect(
          File(retiredPath).existsSync(),
          isFalse,
          reason:
              'Conversation graph favourites/status provider composition opens '
              'overlay, source, import, or graph resources and belongs in the '
              'conversation_graph feature-level provider boundary, not '
              'infrastructure provider islands.',
        );
      }
    });

    test('Archive graph removal uses resetter boundary', () async {
      final offenders =
          await _findArchiveGraphRemovalResetterBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Archive graph removal may request graph projection clearing, but '
            'application code should depend on the GraphProjectionResetter '
            'port instead of opening or importing the graph database directly.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Settings graph reads use repository boundaries', () async {
      final offenders = await _findSettingsGraphReadBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Settings application/presentation code may compose report and '
            'workflow semantics, but concrete conversation graph database '
            'access belongs behind named infrastructure repositories.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Chat DB monitor uses probe reader boundaries', () async {
      final offenders = await _findChatDbMonitorImportLedgerBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'ChatDbChangeMonitor owns live-source polling decisions, but '
            'source-scoped import ledger cursor/count reads and source chat.db '
            'row/platform probes should stay behind reader boundaries.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Chat DB monitor probe providers stay feature-boundary owned', () {
      const retiredProviderPaths = <String>[
        'lib/essentials/conversation_graph/infrastructure/repositories/chat_db_source_probe_reader_provider.dart',
        'lib/essentials/conversation_graph/infrastructure/repositories/import_ledger_probe_reader_provider.dart',
        'lib/essentials/conversation_graph/infrastructure/system/chat_db_monitor_runtime_environment_provider.dart',
      ];

      for (final retiredPath in retiredProviderPaths) {
        expect(
          File(retiredPath).existsSync(),
          isFalse,
          reason:
              'Chat DB monitor probe/runtime provider composition belongs in '
              'the conversation_graph feature-level provider boundary. The '
              'monitor should own lifecycle decisions and consume probe ports, '
              'not import infrastructure provider islands.',
        );
      }
    });

    test(
      'Graph refresh consumers avoid broad database provider import',
      () async {
        final offenders = await _findGraphRefreshBroadDatabaseImportOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'Providers that only watch messageDataVersionProvider or graph '
              'readiness should import the narrow provider files instead of the '
              'central database dependency entry point.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test(
      'Attachment archive service uses source attachment path lookup boundary',
      () async {
        final offenders =
            await _findAttachmentArchiveSourceLookupBoundaryOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'AttachmentArchiveService may orchestrate archive policy, but '
              'current Messages attachment path lookup must stay behind the '
              'CurrentMessagesAttachmentPathLookup boundary.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test('Attachment archive service uses file-store boundary', () async {
      final offenders =
          await _findAttachmentArchiveFileStoreBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'AttachmentArchiveService may orchestrate archive policy, but '
            'file copying, hashing, home expansion, existence checks, and '
            'archive integrity file reads belong behind '
            'AttachmentArchiveFileStore.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test(
      'Attachment archive application uses archive directory boundary',
      () async {
        final offenders =
            await _findAttachmentArchiveDirectoryBoundaryOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'Attachment archive application providers should read the archive '
              'directory through the attachments feature boundary. Direct use '
              'of the central attachmentArchiveDirectoryProvider recreates a '
              'database-provider dependency island.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test(
      'Attachment archive service uses graph candidate reader boundary',
      () async {
        final offenders =
            await _findAttachmentArchiveGraphCandidateBoundaryOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'AttachmentArchiveService may orchestrate archive policy, but '
              'graph attachment candidate SQL and graph database selection '
              'belong behind GraphAttachmentArchiveCandidateReader.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test(
      'Attachment archive service uses archive write-store boundary',
      () async {
        final offenders =
            await _findAttachmentArchiveWriteStoreBoundaryOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'AttachmentArchiveService may orchestrate archive policy, but '
              'archive record persistence, recovery hints, and integrity rows '
              'belong behind AttachmentArchiveWriteStore.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test('Attachment archive stores use typed compatibility key', () async {
      final offenders = await _findAttachmentArchiveStoreTypedKeyOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Attachment archive read/write stores should accept '
            'ArchiveCompatibilityKey for archive record lookup, idempotency, '
            'and recovery hints instead of primitive key pairs.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Attachment archive service uses typed compatibility key', () async {
      final offenders = await _findAttachmentArchiveServiceTypedKeyOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'AttachmentArchiveService archive/recovery entry points should '
            'accept ArchiveCompatibilityKey instead of primitive retained '
            'archive key pairs.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test(
      'Graph archive lookup contract uses compatibility-key language',
      () async {
        final offenders =
            await _findGraphArchiveLookupContractIdentityLanguageOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'GraphAttachmentArchiveLookup is a graph-facing application '
              'contract. It may expose archive compatibility keys, but should '
              'not name those values as retained import identity.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test(
      'Graph archive candidate contract uses compatibility-key language',
      () async {
        final offenders =
            await _findGraphArchiveCandidateContractIdentityLanguageOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'GraphAttachmentArchiveCandidate is an application read model '
              'derived from graph rows. It may carry archive compatibility '
              'keys, but should not expose retained overlay column names as '
              'its public contract.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test(
      'Graph archive candidate de-duplication uses typed compatibility key',
      () async {
        final offenders = await _findGraphArchiveCandidateAdHocKeyOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'Graph archive candidate de-duplication should use '
              'ArchiveCompatibilityKey rather than ad hoc string tuple keys.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test('Graph health diagnostics use typed archive keys', () async {
      final offenders = await _findGraphHealthAdHocArchiveKeyOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Graph health diagnostics compare archive/recovery evidence, but '
            'should use ArchiveCompatibilityKey rather than ad hoc string tuple '
            'keys.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Archive compatibility tuple serialization stays centralized', () async {
      final offenders =
          await _findArchiveCompatibilityTupleSerializationOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Archive compatibility tuple serialization should stay centralized '
            'on ArchiveCompatibilityKey and the recovery-hint setting wrapper. '
            'Other code should pass typed ArchiveCompatibilityKey values rather '
            'than constructing string tuples.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test(
      'Archive compatibility key construction stays in named boundaries',
      () async {
        final offenders =
            await _findArchiveCompatibilityKeyConstructionOffenders();

        expect(
          offenders,
          orderedEquals(
            _archiveCompatibilityKeyConstructionAllowedFiles.toList()..sort(),
          ),
          reason:
              'ArchiveCompatibilityKey construction should remain limited to '
              'named evidence/resolver/diagnostic derivation boundaries. '
              'Other code should pass typed keys rather than rebuilding them.\n'
              'Actual users:\n${offenders.join('\n')}',
        );
      },
    );

    test('Conversation graph repositories use import-ledger naming', () async {
      final offenders =
          await _findConversationGraphImportLedgerNamingOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Conversation graph projection/status repositories should name '
            'the source-scoped import database as an import ledger. Generic '
            'importDatabase identifiers blur active source-scoped ledger '
            'ownership with retained import compatibility storage.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test(
      'Attachment source-scoped import provider access stays feature-boundary owned',
      () async {
        final offenders =
            await _findAttachmentSourceScopedImportProviderBoundaryOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'Attachment code may define infrastructure adapters over the '
              'source-scoped import ledger, but provider composition for the '
              'concrete sourceScopedImportDatabaseProvider belongs in '
              'features/attachments/feature_level_providers.dart.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test('Onboarding environment report uses probe reader boundary', () async {
      final offenders =
          await _findOnboardingEnvironmentProbeBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'OnboardingEnvironmentReport may classify setup state, but '
            'filesystem and SQLite probing belong behind '
            'OnboardingDatabaseProbeReader.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Onboarding provider composition stays feature-boundary owned', () {
      const retiredInfrastructureProviders = <String>[
        'lib/essentials/onboarding/infrastructure/persistence/onboarding_database_probe_reader_provider.dart',
        'lib/essentials/onboarding/infrastructure/persistence/onboarding_failure_storage_provider.dart',
        'lib/essentials/onboarding/infrastructure/persistence/derived_message_data_file_store_provider.dart',
        'lib/essentials/onboarding/infrastructure/system/full_disk_access_provider.dart',
      ];

      final existingProviders = retiredInfrastructureProviders
          .where((path) => File(path).existsSync())
          .toList();

      expect(
        existingProviders,
        isEmpty,
        reason:
            'Onboarding application code should depend on application '
            'contracts via the onboarding feature-level provider boundary. '
            'Concrete FDA, probe, failure-store, and file-store provider '
            'composition must not move back under infrastructure.\n'
            'Existing retired providers:\n${existingProviders.join('\n')}',
      );
    });

    test('Onboarding center sync observer delegates panel policy', () async {
      final offenders = await _findOnboardingCenterSyncObserverOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'OnboardingCenterPanelSyncObserver is a presentation observer. '
            'Readiness/incident panel policy and panel-stack mutation belong '
            'in the navigation application sync controller.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Onboarding dev panel reset uses action boundary', () async {
      final offenders = await _findOnboardingDevPanelActionBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Onboarding dev panel may render reset/refresh controls, but reset '
            'sequencing and provider refresh ownership belong behind an '
            'application action boundary.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Onboarding overlay controls use action boundary', () async {
      final offenders = await _findOnboardingOverlayActionBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Onboarding overlay may watch gate state, but button callbacks '
            'should report onboarding intents through OnboardingOverlayActions '
            'instead of calling the gate notifier directly.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Environment readiness panel uses action boundary', () async {
      final offenders =
          await _findEnvironmentReadinessPanelActionBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'EnvironmentReadinessPanelView may render readiness state and '
            'diagnostic report actions, but onboarding lifecycle mutations '
            'and developer simulation cleanup should cross the feature action '
            'boundary.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Pipeline incident panel uses action boundary', () async {
      final offenders =
          await _findPipelineIncidentPanelActionBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'PipelineIncidentPanelView may render incident state and export '
            'reports, but retry/dismiss lifecycle mutations should cross the '
            'feature action boundary.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Full Disk Access uses access boundary', () async {
      final offenders = await _findFullDiskAccessBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Onboarding and settings code should consume FullDiskAccess or '
            'the onboarding path/FDA providers. macOS file probes and System '
            'Settings process launches belong in onboarding infrastructure.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Message data reset uses file-store boundary', () async {
      final offenders = await _findMessageDataResetFileStoreBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'MessageDataResetService may orchestrate reset semantics, but '
            'database file probing/deletion belongs behind '
            'DerivedMessageDataFileStore.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test(
      'Historical archive source identity uses folder resolver boundary',
      () async {
        final offenders =
            await _findHistoricalArchiveFolderResolverBoundaryOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'Historical archive source registration/removal may use a '
              'source-folder resolver, but filesystem validation and source-key '
              'path normalization belong behind that resolver boundary.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );

    test('Graph status logging uses writer boundary', () async {
      final offenders = await _findGraphStatusLoggingBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Graph status log formatting may live in application code, but '
            'filesystem writes belong to the infrastructure writer and '
            'presentation should consume the writer provider.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Graph status archived-file actions use opener boundary', () async {
      final offenders =
          await _findGraphStatusArchivedFileOpenerBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Graph status presentation may expose archived-file actions, but '
            'external launch mechanics belong behind '
            'ArchivedAttachmentFileOpener.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Diagnostic report presentation uses logging action boundary', () async {
      final offenders =
          await _findDiagnosticReportPresentationInfrastructureOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Presentation code may trigger diagnostic report actions and render '
            'the domain result, but it must not import the LogExportService '
            'implementation directly.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Diagnostic report actions use exporter boundary', () async {
      final offenders =
          await _findDiagnosticReportActionInfrastructureOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Diagnostic report action helpers should compose report semantics '
            'through DiagnosticReportExporter. Concrete support bundle, log '
            'writer, and launch mechanics belong in logging infrastructure.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Historical archives UI uses source inspection boundary', () async {
      final offenders =
          await _findHistoricalArchivesInspectionBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Historical Archives presentation/view-model code should request '
            'archive source inspection through the ArchiveSourceInspector '
            'application boundary. SQLite and filesystem inspection belong in '
            'settings infrastructure.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Historical archives UI uses workflow action boundary', () async {
      final offenders =
          await _findHistoricalArchivesWorkflowActionBoundaryOffenders();

      expect(
        offenders,
        isEmpty,
        reason:
            'Historical Archives UI may render workflow state and controls, '
            'but user actions should cross HistoricalArchivesWorkflowActions '
            'instead of mutating the workflow notifier directly.\n'
            'Actual offenders:\n${offenders.join('\n')}',
      );
    });

    test('Archive source inspector provider stays feature-boundary owned', () {
      const retiredApplicationProvider =
          'lib/features/settings/application/archive_source_inspector_provider.dart';

      expect(
        File(retiredApplicationProvider).existsSync(),
        isFalse,
        reason:
            'ArchiveSourceInspector is an application contract, but provider '
            'composition imports concrete source-inspection infrastructure '
            'and belongs in the settings feature-level provider boundary.',
      );
    });

    test(
      'Historical archives folder chooser provider stays feature-boundary owned',
      () {
        const retiredApplicationProvider =
            'lib/features/settings/application/historical_archive_folder_chooser_provider.dart';
        const retiredInfrastructureProvider =
            'lib/features/settings/infrastructure/repositories/historical_archive_folder_chooser_provider.dart';

        expect(
          File(retiredApplicationProvider).existsSync(),
          isFalse,
          reason:
              'The HistoricalArchiveFolderChooser contract belongs to settings '
              'application code, but provider composition imports concrete '
              'folder-picker infrastructure and belongs in the settings '
              'feature-level provider boundary.',
        );
        expect(
          File(retiredInfrastructureProvider).existsSync(),
          isFalse,
          reason:
              'The HistoricalArchiveFolderChooser contract belongs to settings '
              'application code. Native folder picker mechanics may remain in '
              'infrastructure, but provider composition belongs in the settings '
              'feature-level provider boundary, not infrastructure.',
        );
      },
    );

    test('Historical archives workflow provider stays application-owned', () {
      const retiredPresentationProvider =
          'lib/features/settings/presentation/view_model/historical_archives_workflow_panel_model_provider.dart';

      expect(
        File(retiredPresentationProvider).existsSync(),
        isFalse,
        reason:
            'HistoricalArchivesWorkflow coordinates archive workflow state and '
            'is consumed by both settings presentation and sidebar application '
            'widgets. It belongs in settings application, not presentation '
            'view-model storage.',
      );
    });

    test('Current visible month provider stays application-owned', () {
      const retiredPresentationProvider =
          'lib/features/messages/presentation/view_model/timeline/current_visible_month_provider.dart';

      expect(
        File(retiredPresentationProvider).existsSync(),
        isFalse,
        reason:
            'CurrentVisibleMonth coordinates shared message evidence timeline '
            'state across heatmap and evidence surfaces. It belongs in the '
            'messages application evidence layer, not presentation view-model '
            'storage.',
      );
    });

    test('Message history coverage providers stay feature-boundary owned', () {
      const retiredProviderPaths = <String>[
        'lib/features/settings/infrastructure/repositories/message_history_coverage_repository_provider.dart',
        'lib/features/settings/infrastructure/repositories/message_history_coverage_report_exporter_provider.dart',
      ];

      for (final retiredPath in retiredProviderPaths) {
        expect(
          File(retiredPath).existsSync(),
          isFalse,
          reason:
              'Message history coverage provider composition belongs in the '
              'settings feature-level provider boundary. Application code '
              'should consume coverage/exporter contracts through the public '
              'settings API, not infrastructure provider islands.',
        );
      }
    });

    test(
      'Historical archive source metadata consumers use application boundary',
      () async {
        final offenders =
            await _findHistoricalArchiveSourcesRepositoryBoundaryOffenders();

        expect(
          offenders,
          isEmpty,
          reason:
              'Historical archive source metadata is an application read/write '
              'contract. Presentation and application consumers should use '
              'HistoricalArchiveSources, while retained metadata persistence '
              'stays behind settings infrastructure.\n'
              'Actual offenders:\n${offenders.join('\n')}',
        );
      },
    );
  });
}

Future<List<String>> _findSidebarPresentationImportOffenders() async {
  final offenders = <String>{};
  final files = await _collectSidebarSemanticLayerFiles();

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);

    for (final importTarget in _extractImports(uncommented)) {
      if (importTarget.endsWith('sidebar_cassette_card_view_model.dart')) {
        continue;
      }

      final isForbiddenFeatureImport =
          importTarget.contains('/widget_builders/') ||
          importTarget.contains('/presentation/');
      final isForbiddenFlutterImport = RegExp(
        r'^package:flutter/(widgets|material|cupertino)\.dart$',
      ).hasMatch(importTarget);

      if (isForbiddenFeatureImport || isForbiddenFlutterImport) {
        offenders.add(filePath);
        break;
      }
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>>
_findDiagnosticReportPresentationInfrastructureOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart')) {
      return false;
    }
    return path.startsWith('lib/') && path.contains('/presentation/');
  });
  final offenders = <String>{};

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    final importsLogExportService = imports.any(
      (importTarget) => importTarget.endsWith(
        'logging/infrastructure/log_export_service.dart',
      ),
    );

    if (importsLogExportService) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>>
_findDiagnosticReportActionInfrastructureOffenders() async {
  const filePath =
      'lib/essentials/logging/application/diagnostic_report_actions.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.contains('/infrastructure/'))
        '$filePath imports $importTarget',
  ];

  return offenders..sort();
}

Future<List<String>>
_findHistoricalArchivesInspectionBoundaryOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart')) {
      return false;
    }
    return path.startsWith('lib/features/settings/') &&
        (path.contains('/presentation/') || path.contains('/view_model/'));
  });
  final offenders = <String>{};

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    final importsInspectionRepository = imports.any(
      (importTarget) => importTarget.endsWith(
        'settings/infrastructure/repositories/archive_source_inspection_repository.dart',
      ),
    );

    if (importsInspectionRepository) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>>
_findHistoricalArchivesWorkflowActionBoundaryOffenders() async {
  const filePaths = <String>[
    'lib/features/settings/presentation/view/historical_archives_panel.dart',
    'lib/features/settings/application/sidebar_cassette_spec/widget_builders/historical_archives_settings_supplemental_content.dart',
  ];
  final offenders = <String>[];

  for (final filePath in filePaths) {
    final file = File(filePath);
    if (!file.existsSync()) {
      continue;
    }

    final uncommented = _stripComments(await file.readAsString());
    if (uncommented.contains('historicalArchivesWorkflowProvider.notifier')) {
      offenders.add('$filePath mutates historical archive workflow directly');
    }
  }

  return offenders..sort();
}

Future<List<String>>
_findHistoricalArchiveSourcesRepositoryBoundaryOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart')) {
      return false;
    }
    if (!path.startsWith('lib/features/settings/')) {
      return false;
    }
    if (path.startsWith('lib/features/settings/infrastructure/')) {
      return false;
    }
    return true;
  });
  final offenders = <String>{};

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    final importsSourcesRepository = imports.any(
      (importTarget) => importTarget.endsWith(
        'settings/infrastructure/repositories/historical_archive_sources_repository.dart',
      ),
    );

    if (importsSourcesRepository) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>> _findPayloadTypeOffenders(List<String> filePaths) async {
  final offenders = <String>{};
  final forbiddenTypePattern = RegExp(
    r'\b(Widget|WidgetBuilder|BuildContext|WidgetRef|Ref|ScrollController|FocusNode|VoidCallback|Function)\b',
  );

  for (final filePath in filePaths) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);

    if (forbiddenTypePattern.hasMatch(uncommented)) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>> _findSemanticActionTransportOffenders(
  List<String> filePaths,
) async {
  final offenders = <String>{};
  final forbiddenTypePattern = RegExp(
    r'\b(Widget|WidgetBuilder|BuildContext|WidgetRef|Ref|ScrollController|FocusNode|VoidCallback|Function|SidebarActionDispatcher)\b',
  );
  final forbiddenFlutterImportPattern = RegExp(
    r'^package:flutter/(widgets|material|cupertino)\.dart$',
  );
  final forbiddenRiverpodImportPattern = RegExp(r'^package:(hooks_)?riverpod');

  for (final filePath in filePaths) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);

    final hasForbiddenImport = imports.any((importTarget) {
      return forbiddenFlutterImportPattern.hasMatch(importTarget) ||
          forbiddenRiverpodImportPattern.hasMatch(importTarget) ||
          importTarget.contains('/application/');
    });

    if (hasForbiddenImport || forbiddenTypePattern.hasMatch(uncommented)) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>> _findRetainedArchiveMetadataProviderOffenders() async {
  final files = await _collectDartFiles((path) => !path.endsWith('.g.dart'));
  final offenders = <String>{};

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    if (uncommented.contains('retainedArchiveMetadataStoreProvider')) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>> _findRetainedArchiveMetadataFileOffenders() async {
  final files = await _collectDartFiles((path) => !path.endsWith('.g.dart'));
  final offenders = <String>{};

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    if (uncommented.contains('retainedArchiveMetadataDatabaseFileName')) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>> _findOnboardingSourceScopedProbeFixtureOffenders() async {
  final offenders = <String>[];
  final testDir = Directory('test/essentials/onboarding');
  if (!testDir.existsSync()) {
    return offenders;
  }

  await for (final entity in testDir.list(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) {
      continue;
    }
    final source = await entity.readAsString();
    final uncommented = _stripComments(source);
    final sourceScopedProbeUsesRetainedName = RegExp(
      r'sourceScopedImportDatabase\s*:\s*(?:const\s+)?'
      r'OnboardingDatabaseProbe\s*\([^)]*'
      r'path\s*:\s*retainedArchiveMetadataDatabaseFileName',
      multiLine: true,
      dotAll: true,
    ).hasMatch(uncommented);
    if (sourceScopedProbeUsesRetainedName) {
      offenders.add(entity.path);
    }
  }

  return offenders..sort();
}

Future<List<String>> _findRetainedHistoricalWorkingFileOffenders() async {
  final files = await _collectDartFiles((path) => !path.endsWith('.g.dart'));
  final offenders = <String>{};

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    if (uncommented.contains('retainedHistoricalReferenceDatabaseFileName')) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>> _findRetainedDatabaseFilenameLiteralOffenders() async {
  final files = await _collectDartFiles((path) => !path.endsWith('.g.dart'));
  final offenders = <String>{};
  final retainedFilenameLiteralPattern = RegExp(
    r'''['"](macos_import|working)\.db['"]''',
  );

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    if (retainedFilenameLiteralPattern.hasMatch(uncommented)) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>> _findLegacyTerminologyOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart')) {
      return false;
    }
    return path.startsWith('lib/');
  });
  final offenders = <String>{};
  final legacyTerminologyPattern = RegExp(r'[Ll]egacy');

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    if (legacyTerminologyPattern.hasMatch(uncommented)) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>> _findRetainedOverlayIdentityBridgeImportOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart')) {
      return false;
    }
    return path.startsWith('lib/');
  });
  final offenders = <String>{};

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    final importsRetainedOverlayIdentityBridge = imports.any(
      (importTarget) =>
          importTarget.endsWith('retained_overlay_identity_bridge.dart'),
    );

    if (importsRetainedOverlayIdentityBridge) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>>
_findRetainedOverlayIdentityBridgeTestImportOffenders() async {
  final files = await _collectProjectDartFiles((path) {
    if (path.endsWith('.g.dart')) {
      return false;
    }
    return path.startsWith('test/');
  });
  final offenders = <String>{};

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    final importsRetainedOverlayIdentityBridge = imports.any(
      (importTarget) =>
          importTarget.endsWith('retained_overlay_identity_bridge.dart'),
    );

    if (importsRetainedOverlayIdentityBridge) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>> _findHandleBlacklistVariantExpansionOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart')) {
      return false;
    }
    return path.startsWith('lib/');
  });
  final offenders = <String>{};

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final lines = uncommented.split('\n');
    for (var index = 0; index < lines.length; index += 1) {
      final line = lines[index];
      final expandsVariants =
          line.contains('handleOverlayKeyVariants(') ||
          line.contains('_graphHandleIdsForOverlayId(');
      if (!expandsVariants) {
        continue;
      }

      final start = math.max(0, index - 3);
      final end = math.min(lines.length, index + 4);
      final localContext = lines.sublist(start, end).join('\n');
      if (localContext.contains('isBlacklisted') ||
          localContext.contains('blacklistedHandleIds')) {
        offenders.add('$filePath:${index + 1}');
      }
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>> _findRecentContactPreDedupeLimitOffenders() async {
  const filePath =
      'lib/features/contacts/infrastructure/repositories/'
      'overlay_recent_contacts_reader.dart';
  final source = await File(filePath).readAsString();
  final uncommented = _stripComments(source);
  final offenders = <String>[];

  final preDedupeLimitPattern = RegExp(
    r'getRecentContacts\s*\(\s*limit\s*:\s*(3|kMaxRecents)\s*\)',
  );
  final match = preDedupeLimitPattern.firstMatch(uncommented);
  if (match != null) {
    offenders.add(filePath);
  }

  return offenders;
}

Future<List<String>> _findOverlayDatabaseFilenameLiteralOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart')) {
      return false;
    }
    return path.startsWith('lib/');
  });
  final offenders = <String>{};
  final overlayFilenameLiteralPattern = RegExp(
    r'''['"]user_overlays\.db['"]''',
  );

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    if (overlayFilenameLiteralPattern.hasMatch(uncommented)) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>> _findSourceScopedDatabaseFilenameLiteralOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart')) {
      return false;
    }
    return path.startsWith('lib/');
  });
  final offenders = <String>{};
  final sourceScopedFilenameLiteralPattern = RegExp(
    r'''['"](macos_import_ss|working_ss)\.db['"]''',
  );

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    if (sourceScopedFilenameLiteralPattern.hasMatch(uncommented)) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>> _findSourceScopedSqlBitExtractionOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
      return false;
    }
    return path.startsWith('lib/');
  });
  final offenders = <String>{};
  final packedIdBitExtraction = RegExp(
    r'\b(?:ss_id|message_ss_id|attachment_ss_id|chat_ss_id|handle_ss_id|contact_ss_id|[a-zA-Z_][\w.]*\.ss_id)\s*(?:>>|&)',
  );

  for (final filePath in files) {
    if (_sourceScopedSqlBitExtractionAllowedFiles.contains(filePath)) {
      continue;
    }
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    if (packedIdBitExtraction.hasMatch(uncommented)) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>> _findRetiredImportMigrationExecutionOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart')) {
      return false;
    }
    return path.startsWith('lib/');
  });
  final offenders = <String>{};
  final symbolPattern = RegExp(
    '\\b(${_retiredImportMigrationExecutionSymbols.map(RegExp.escape).join('|')})\\b',
  );

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    final hasRetiredImport = imports.any((importTarget) {
      return _retiredImportMigrationPathFragments.any(importTarget.contains);
    });

    if (hasRetiredImport || symbolPattern.hasMatch(uncommented)) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>> _findRetainedImportWrapperImportOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart')) {
      return false;
    }
    return path.startsWith('lib/');
  });
  final offenders = <String>{};

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    final importsRetainedWrapper = imports.any(
      (importTarget) =>
          importTarget.endsWith('retained_archive_metadata_database.dart'),
    );

    if (importsRetainedWrapper) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>> _findAppLoggerFeatureBoundaryOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
      return false;
    }
    if (path == 'lib/essentials/logging/feature_level_providers.dart') {
      return false;
    }
    return path.startsWith('lib/');
  });
  final offenders = <String>[];

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    offenders.addAll([
      for (final importTarget in imports)
        if (importTarget.endsWith('logging/application/app_logger.dart'))
          '$filePath imports $importTarget',
    ]);
  }

  return offenders..sort();
}

Future<List<String>> _findDatabaseConstructionOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart')) {
      return false;
    }
    return path.startsWith('lib/');
  });
  final offenders = <String>{};
  final constructionPattern = RegExp(
    r'\b(ImportDatabase\.open|RetainedArchiveMetadataDatabase|ConversationGraphDatabase|OverlayDatabase)\s*\(',
  );

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    if (constructionPattern.hasMatch(uncommented)) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>> _findUiRenderingDatabaseAccessOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
      return false;
    }

    return path.contains('/presentation/') ||
        path.contains('/widget_builders/') ||
        path.contains('/widgets/');
  });
  final offenders = <String>{};

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);

    for (final importTarget in imports) {
      if (importTarget == 'package:sqlite3/sqlite3.dart' ||
          importTarget.startsWith('package:sqflite') ||
          importTarget.endsWith('essentials/db/feature_level_providers.dart') ||
          importTarget.endsWith(
            'source_scoped_import/infrastructure/import_database_provider.dart',
          ) ||
          importTarget.endsWith(
            'essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart',
          ) ||
          importTarget.endsWith(
            'essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart',
          )) {
        offenders.add('$filePath imports $importTarget');
      }
    }

    const forbiddenTokens = <String>[
      'overlayDatabaseProvider',
      'driftConversationGraphDatabaseProvider',
      'importDatabaseProvider',
      'retainedArchiveMetadataStoreProvider',
      'sqlite3.open',
      'openDatabase(',
      '.rawQuery(',
      '.customSelect(',
      '.selectRows(',
      '.executeSql(',
    ];
    for (final token in forbiddenTokens) {
      if (uncommented.contains(token)) {
        offenders.add('$filePath uses $token');
      }
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>> _findDatabaseHealthQueryLayerFileIoOffenders() async {
  const filePath =
      'lib/essentials/db/application/database_health_audit/database_health_query_layer.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget == 'dart:io') '$filePath imports $importTarget',
  ];

  if (RegExp(r'(^|[^\w.])File\(').hasMatch(uncommented) ||
      uncommented.contains('existsSync(')) {
    offenders.add('$filePath performs filesystem probing directly');
  }

  return offenders..sort();
}

Future<List<String>>
_findConversationGraphReadinessProviderBoundaryOffenders() async {
  const filePath =
      'lib/essentials/db/feature_level_providers/conversation_graph_readiness_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget == 'dart:io' ||
          importTarget == 'package:sqlite3/sqlite3.dart')
        '$filePath imports $importTarget',
  ];

  if (RegExp(r'(^|[^\w.])File\(').hasMatch(uncommented) ||
      uncommented.contains('sqlite3.open(') ||
      uncommented.contains('existsSync(') ||
      uncommented.contains('lengthSync(')) {
    offenders.add('$filePath performs readiness probing directly');
  }

  return offenders..sort();
}

Future<List<String>> _findDatabaseHealthAuditServiceIoOffenders() async {
  const filePath =
      'lib/essentials/db/application/database_health_audit/database_health_audit_service.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget == 'dart:io' ||
          importTarget == 'dart:convert' ||
          importTarget == 'package:path/path.dart')
        '$filePath imports $importTarget',
  ];

  if (RegExp(r'(^|[^\w.])File\(').hasMatch(uncommented) ||
      RegExp(r'(^|[^\w.])Directory\(').hasMatch(uncommented) ||
      uncommented.contains('Platform.')) {
    offenders.add('$filePath performs runtime/file IO directly');
  }

  return offenders..sort();
}

Future<List<String>>
_findSourceScopedImportApplicationSqfliteOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart')) {
      return false;
    }
    return path.startsWith('lib/essentials/source_scoped_import/application/');
  });
  final offenders = <String>{};

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    if (imports.any(
      (importTarget) => importTarget.startsWith('package:sqflite'),
    )) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>>
_findSourceScopedImportServiceImportDatabaseOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart')) {
      return false;
    }
    return path.startsWith('lib/essentials/source_scoped_import/application/');
  });
  final offenders = <String>{};

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    if (imports.any((importTarget) {
      return importTarget.endsWith(
        'infrastructure/import_database_provider.dart',
      );
    })) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>>
_findSourceScopedImportApplicationFeatureInfrastructureOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart')) {
      return false;
    }
    return path.startsWith('lib/essentials/source_scoped_import/application/');
  });
  final offenders = <String>{};

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    if (imports.any((importTarget) {
      return importTarget.contains('/features/') &&
          importTarget.contains('/infrastructure/');
    })) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>>
_findConversationGraphApplicationImportDatabaseOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart')) {
      return false;
    }
    return path.startsWith('lib/essentials/conversation_graph/application/');
  });
  final offenders = <String>{};

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    if (imports.any((importTarget) {
      return importTarget.endsWith(
        'source_scoped_import/infrastructure/import_database_provider.dart',
      );
    })) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>>
_findGraphCrossSnapshotMapperImportDatabaseOffenders() async {
  const filePath =
      'lib/features/attachments/infrastructure/repositories/graph_cross_snapshot_mapper.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  if (imports.any((importTarget) {
    return importTarget.endsWith(
      'source_scoped_import/infrastructure/import_database_provider.dart',
    );
  })) {
    return <String>[filePath];
  }
  return const <String>[];
}

Future<List<String>>
_findDeterministicRecoveryInfrastructureImportOffenders() async {
  const filePath =
      'lib/features/attachments/application/deterministic_recovery_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.contains('/infrastructure/') ||
          importTarget.contains('../infrastructure/'))
        '$filePath imports $importTarget',
  ];
  return offenders..sort();
}

Future<List<String>> _findCrossSystemAttachmentProviderImportOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
      return false;
    }
    if (path.startsWith('lib/features/attachments/')) {
      return false;
    }
    return path.startsWith('lib/features/') ||
        path.startsWith('lib/essentials/');
  });
  final offenders = <String>{};

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    for (final importTarget in imports) {
      if (importTarget.endsWith(
            'features/attachments/application/archive_compatibility_key.dart',
          ) ||
          importTarget.endsWith(
            'features/attachments/application/archive_settings_provider.dart',
          ) ||
          importTarget.endsWith(
            'features/attachments/application/attachment_file_access.dart',
          ) ||
          importTarget.endsWith(
            'features/attachments/application/attachment_archive_service_provider.dart',
          ) ||
          importTarget.endsWith(
            'features/attachments/application/attachment_resolver_provider.dart',
          ) ||
          importTarget.endsWith(
            'features/attachments/application/deterministic_recovery_provider.dart',
          ) ||
          importTarget.endsWith(
            'features/attachments/application/graph_attachment_archive_lookup.dart',
          ) ||
          importTarget.endsWith(
            'features/attachments/infrastructure/repositories/overlay_archive_compatibility_lookup.dart',
          ) ||
          importTarget.endsWith(
            'features/attachments/infrastructure/services/video_thumbnail_cache_service.dart',
          ) ||
          importTarget.endsWith(
            'attachments/application/archive_compatibility_key.dart',
          ) ||
          importTarget.endsWith(
            'attachments/application/archive_settings_provider.dart',
          ) ||
          importTarget.endsWith(
            'attachments/application/attachment_file_access.dart',
          ) ||
          importTarget.endsWith(
            'attachments/application/attachment_archive_service_provider.dart',
          ) ||
          importTarget.endsWith(
            'attachments/application/attachment_resolver_provider.dart',
          ) ||
          importTarget.endsWith(
            'attachments/application/deterministic_recovery_provider.dart',
          ) ||
          importTarget.endsWith(
            'attachments/application/graph_attachment_archive_lookup.dart',
          ) ||
          importTarget.endsWith(
            'attachments/infrastructure/repositories/overlay_archive_compatibility_lookup.dart',
          ) ||
          importTarget.endsWith(
            'attachments/infrastructure/services/video_thumbnail_cache_service.dart',
          )) {
        offenders.add('$filePath imports $importTarget');
      }
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>> _findCrossSystemChatProviderImportOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
      return false;
    }
    if (path.startsWith('lib/features/chats/')) {
      return false;
    }
    return path.startsWith('lib/features/') ||
        path.startsWith('lib/essentials/');
  });
  final offenders = <String>{};

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    for (final importTarget in imports) {
      if (importTarget.endsWith(
            'features/chats/presentation/view_model/chats_view_model_provider.dart',
          ) ||
          importTarget.endsWith(
            'chats/presentation/view_model/chats_view_model_provider.dart',
          )) {
        offenders.add('$filePath imports $importTarget');
      }
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>>
_findCrossSystemSettingsApplicationImportOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
      return false;
    }
    if (path.startsWith('lib/features/settings/')) {
      return false;
    }
    return path.startsWith('lib/features/') ||
        path.startsWith('lib/essentials/');
  });
  final offenders = <String>{};

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    for (final importTarget in imports) {
      if (importTarget.contains('features/settings/application/') ||
          importTarget.contains('settings/application/')) {
        offenders.add('$filePath imports $importTarget');
      }
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>>
_findArchiveSettingsStatsRepositoryImportOffenders() async {
  const filePath =
      'lib/features/attachments/application/archive_settings_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.endsWith(
            'features/attachments/infrastructure/repositories/attachment_archive_stats_repository.dart',
          ) ||
          importTarget.endsWith(
            '../infrastructure/repositories/attachment_archive_stats_repository.dart',
          ))
        '$filePath imports $importTarget',
  ];
  return offenders..sort();
}

Future<List<String>>
_findArchiveSettingsOverlayDatabaseImportOffenders() async {
  const filePath =
      'lib/features/attachments/application/archive_settings_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.endsWith(
        'essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart',
      ))
        '$filePath imports $importTarget',
  ];
  return offenders..sort();
}

Future<List<String>> _findArchiveSettingsFileOperationsOffenders() async {
  const filePath =
      'lib/features/attachments/application/archive_settings_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget == 'dart:io' ||
          importTarget ==
              'package:file_selector_platform_interface/file_selector_platform_interface.dart' ||
          importTarget == 'package:path/path.dart')
        '$filePath imports $importTarget',
  ];

  if (RegExp(r'(^|[^\w.])File\(').hasMatch(uncommented) ||
      RegExp(r'(^|[^\w.])Directory\(').hasMatch(uncommented) ||
      uncommented.contains('FileSelectorPlatform.instance')) {
    offenders.add('$filePath performs archive filesystem work directly');
  }

  return offenders..sort();
}

Future<List<String>>
_findAttachmentResolverArchiveStorageImportOffenders() async {
  const filePath =
      'lib/features/attachments/application/attachment_resolver_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget == 'dart:io' ||
          importTarget.endsWith(
            'essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart',
          ) ||
          importTarget.endsWith('attachment_recovery_hint_storage.dart'))
        '$filePath imports $importTarget',
  ];

  if (uncommented.contains('File(') || uncommented.contains('existsSync(')) {
    offenders.add('$filePath performs attachment filesystem access directly');
  }

  return offenders..sort();
}

Future<List<String>>
_findAttachmentResolverPrimitiveKeyParameterOffenders() async {
  const filePath =
      'lib/features/attachments/application/attachment_resolver_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final uncommented = _stripComments(await file.readAsString());
  final providerDeclaration = RegExp(
    r'Future<ResolvedAttachment>\s+attachmentResolver\s*\([^)]*\)',
    multiLine: true,
    dotAll: true,
  ).firstMatch(uncommented);

  if (providerDeclaration == null) {
    return <String>['$filePath missing attachmentResolver declaration'];
  }

  final declaration = providerDeclaration.group(0) ?? '';
  final offenders = <String>[];
  if (declaration.contains('messageGuid') ||
      declaration.contains('importAttachmentId')) {
    offenders.add('$filePath exposes primitive archive key provider parameter');
  }

  return offenders..sort();
}

Future<List<String>>
_findMessageAttachmentEvidenceFileAccessBoundaryOffenders() async {
  const files = <String>{
    'lib/features/messages/application/message_evidence/message_attachment_evidence.dart',
    'lib/features/messages/application/message_evidence/message_evidence_spine_provider.dart',
  };
  final offenders = <String>[];

  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) {
      continue;
    }

    final source = await file.readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    offenders.addAll([
      for (final importTarget in imports)
        if (importTarget == 'dart:io') '$filePath imports $importTarget',
    ]);

    if (RegExp(r'(^|[^\w.])File\(').hasMatch(uncommented) ||
        uncommented.contains('existsSync(') ||
        uncommented.contains('Platform.environment')) {
      offenders.add('$filePath performs attachment file access directly');
    }
  }

  return offenders..sort();
}

Future<List<String>> _findAttachmentFileAccessContractOffenders() async {
  const filePath =
      'lib/features/attachments/application/attachment_file_access.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget == 'dart:io') '$filePath imports $importTarget',
  ];

  if (RegExp(r'(^|[^\w.])File\??\b').hasMatch(uncommented) ||
      uncommented.contains('existingFileAt')) {
    offenders.add('$filePath exposes concrete file objects');
  }

  return offenders..sort();
}

Future<List<String>> _findAttachmentInfoDataOnlyOffenders() async {
  const filePath = 'lib/features/messages/domain/entities/attachment_info.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget == 'dart:io' ||
          importTarget == 'package:path/path.dart' ||
          importTarget.endsWith('attachment_file_access.dart'))
        '$filePath imports $importTarget',
  ];

  if (RegExp(r'(^|[^\w.])File\(').hasMatch(uncommented) ||
      RegExp(r'(^|[^\w.])Directory\(').hasMatch(uncommented) ||
      uncommented.contains('Platform.environment') ||
      uncommented.contains('existsSync(') ||
      uncommented.contains('resolvedLocalPath')) {
    offenders.add('$filePath performs attachment file/path access directly');
  }
  if ((uncommented.contains('messageGuid') ||
          uncommented.contains('importAttachmentId')) &&
      !source.contains('archive compatibility key')) {
    offenders.add(
      '$filePath exposes archive compatibility keys without documenting them',
    );
  }

  return offenders..sort();
}

Future<List<String>> _findMediaTileAttachmentDataOnlyOffenders() async {
  const filePath =
      'lib/features/messages/presentation/widgets/message_evidence/media_tile_attachment.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget == 'dart:io' ||
          importTarget == 'package:path/path.dart' ||
          importTarget.endsWith('attachment_file_access.dart'))
        '$filePath imports $importTarget',
  ];

  if (RegExp(r'(^|[^\w.])File\(').hasMatch(uncommented) ||
      RegExp(r'(^|[^\w.])Directory\(').hasMatch(uncommented) ||
      uncommented.contains('Platform.environment') ||
      uncommented.contains('existsSync(') ||
      uncommented.contains('displayableFile') ||
      uncommented.contains('resolvedLocalPath')) {
    offenders.add('$filePath performs attachment file/path access directly');
  }
  if ((uncommented.contains('messageGuid') ||
          uncommented.contains('importAttachmentId')) &&
      !source.contains('archive compatibility key')) {
    offenders.add(
      '$filePath exposes archive compatibility keys without documenting them',
    );
  }

  return offenders..sort();
}

Future<List<String>>
_findMessageDisplayArchiveCompatibilityKeyOffenders() async {
  const filePath =
      'lib/features/messages/presentation/view_model/shared/display_widgets/new_display_widgets.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final offenders = <String>[];

  if (uncommented.contains('ArchiveCompatibilityKey(')) {
    offenders.add('$filePath constructs ArchiveCompatibilityKey directly');
  }
  if (uncommented.contains('.messageGuid') ||
      uncommented.contains('.importAttachmentId')) {
    offenders.add('$filePath reads primitive archive compatibility fields');
  }

  return offenders..sort();
}

Future<List<String>>
_findMessageDisplayAttachmentRecoveryActionOffenders() async {
  const filePath =
      'lib/features/messages/presentation/view_model/shared/display_widgets/new_display_widgets.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final uncommented = _stripComments(await file.readAsString());
  final offenders = <String>[];
  if (uncommented.contains('attachmentArchiveServiceProvider.notifier')) {
    offenders.add('$filePath invokes attachment archive service directly');
  }
  if (uncommented.contains('.prioritizeRecovery(') &&
      !uncommented.contains('attachmentRecoveryActionsProvider.notifier')) {
    offenders.add('$filePath prioritizes recovery outside action boundary');
  }

  return offenders..sort();
}

Future<List<String>> _findMessageUrlPreviewOpenerBoundaryOffenders() async {
  const files = <String>{
    'lib/features/messages/presentation/widgets/url_preview_widget.dart',
    'lib/features/messages/presentation/view_model/shared/display_widgets/new_display_widgets.dart',
  };
  final offenders = <String>[];

  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) {
      continue;
    }

    final source = await file.readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    offenders.addAll([
      for (final importTarget in imports)
        if (importTarget == 'package:url_launcher/url_launcher.dart')
          '$filePath imports $importTarget',
    ]);

    if (RegExp(r'(^|[^\w.])launchUrl\(').hasMatch(uncommented) ||
        uncommented.contains('LaunchMode.externalApplication')) {
      offenders.add('$filePath launches URL previews directly');
    }
  }

  return offenders..sort();
}

Future<List<String>> _findResolvedAttachmentPathOnlyOffenders() async {
  const files = <String>{
    'lib/features/attachments/domain/entities/resolved_attachment.dart',
    'lib/features/attachments/domain/entities/resolved_attachment.freezed.dart',
  };
  final offenders = <String>[];

  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) {
      continue;
    }

    final source = await file.readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    offenders.addAll([
      for (final importTarget in imports)
        if (importTarget == 'dart:io') '$filePath imports $importTarget',
    ]);

    if (RegExp(r'\bFile\??\b').hasMatch(uncommented) ||
        uncommented.contains('resolvedFile;') ||
        uncommented.contains('resolvedFile,') ||
        uncommented.contains('resolvedFile:')) {
      offenders.add('$filePath exposes concrete file handles');
    }
  }

  return offenders..sort();
}

Future<List<String>> _findSearchApplicationRepositoryImportOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart')) {
      return false;
    }
    return path == 'lib/essentials/search/application/search_service.dart' ||
        path ==
            'lib/features/messages/application/message_evidence/message_evidence_spine_provider.dart';
  });
  final offenders = <String>{};

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    if (imports.any(
      (importTarget) => importTarget.endsWith(
        'essentials/search/infrastructure/repositories/graph_search_repository.dart',
      ),
    )) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>>
_findDisplayIdentityApplicationInfrastructureOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart')) {
      return false;
    }
    return path.startsWith(
      'lib/features/contacts/application/display_identity/',
    );
  });
  final offenders = <String>{};

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    if (imports.any(
      (importTarget) =>
          importTarget.contains('/infrastructure/') ||
          importTarget.contains('/essentials/db/feature_level_providers.dart'),
    )) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>>
_findConversationSignaturePresentationRawProviderOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
      return false;
    }
    return path.contains('/presentation/') ||
        path.contains('/widget_builders/');
  });
  final offenders = <String>{};

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    if (imports.any(
      (importTarget) => importTarget.endsWith(
        'essentials/conversation_graph/application/conversation_signatures/conversation_signature_provider.dart',
      ),
    )) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>>
_findConversationSignatureSelectionActionBoundaryOffenders() async {
  const filePath =
      'lib/features/messages/application/sidebar_cassette_spec/widget_builders/conversation_signatures_widget.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final uncommented = _stripComments(await file.readAsString());
  final offenders = <String>[];
  const forbiddenTokens = <String>[
    'sidebarActionDispatcherProvider',
    'SidebarActionDispatchContext',
    'ConversationSelected',
  ];

  for (final token in forbiddenTokens) {
    if (uncommented.contains(token)) {
      offenders.add('$filePath uses $token');
    }
  }

  return offenders..sort();
}

Future<List<String>>
_findConversationSignaturePreferencesActionBoundaryOffenders() async {
  const filePath =
      'lib/features/messages/application/sidebar_cassette_spec/widget_builders/conversation_signatures_widget.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final uncommented = _stripComments(await file.readAsString());
  final offenders = <String>[];
  if (uncommented.contains(
    'conversationSignaturePreferencesControllerProvider.notifier',
  )) {
    offenders.add('$filePath mutates signature preferences directly');
  }

  return offenders..sort();
}

Future<List<String>>
_findConversationMessageHeaderContextBoundaryOffenders() async {
  const filePath =
      'lib/features/messages/presentation/view/conversation_messages_preview_view.dart';
  final source = await File(filePath).readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  const forbiddenImports = <String>{
    '../../../../essentials/conversation_graph/application/conversations/conversation.dart',
    '../../../../essentials/conversation_graph/application/conversations/conversation_reader_provider.dart',
    '../../../contacts/feature_level_providers.dart',
  };

  return [
    for (final importTarget in imports)
      if (forbiddenImports.contains(importTarget)) '$filePath -> $importTarget',
  ]..sort();
}

Future<List<String>> _findContactMessageHeaderContextBoundaryOffenders() async {
  const filePath =
      'lib/features/messages/presentation/view/contact_messages_evidence_view.dart';
  final source = await File(filePath).readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  const forbiddenImports = <String>{
    '../../../../essentials/conversation_graph/application/contacts/contact_graph.dart',
    '../../../../essentials/conversation_graph/application/contacts/contact_graph_provider.dart',
    '../../../contacts/feature_level_providers.dart',
  };

  return [
    for (final importTarget in imports)
      if (forbiddenImports.contains(importTarget)) '$filePath -> $importTarget',
  ]..sort();
}

Future<List<String>>
_findContactConversationSectionDisplayBoundaryOffenders() async {
  const filePath =
      'lib/features/messages/presentation/widgets/contact_graph_conversation_section.dart';
  final source = await File(filePath).readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  const forbiddenImports = <String>{
    '../../../../essentials/conversation_graph/application/contacts/contact_graph.dart',
    '../../../../essentials/conversation_graph/application/contacts/contact_graph_provider.dart',
    '../../../../essentials/navigation/feature_level_providers.dart',
    '../../../../essentials/navigation/domain/entities/view_spec.dart',
    '../../../../essentials/navigation/domain/navigation_constants.dart',
  };
  final offenders = <String>[
    for (final importTarget in imports)
      if (forbiddenImports.contains(importTarget)) '$filePath -> $importTarget',
  ];

  const forbiddenTokens = <String>[
    'panelsViewStateProvider',
    'WindowPanel.center',
    'ViewSpec.messages',
    'MessagesSpec.forConversation',
    'sidebarFlowProvider',
  ];
  for (final token in forbiddenTokens) {
    if (uncommented.contains(token)) {
      offenders.add('$filePath uses $token');
    }
  }

  return offenders..sort();
}

Future<List<String>>
_findContactConversationSectionActionBoundaryOffenders() async {
  const filePath =
      'lib/features/messages/presentation/widgets/contact_graph_conversation_section.dart';
  final source = await File(filePath).readAsString();
  final uncommented = _stripComments(source);
  final offenders = <String>[];
  const forbiddenTokens = <String>[
    'sidebarActionDispatcherProvider',
    'SidebarActionDispatchContext',
    'ContactConversationSelected',
  ];

  for (final token in forbiddenTokens) {
    if (uncommented.contains(token)) {
      offenders.add('$filePath uses $token');
    }
  }

  return offenders..sort();
}

Future<List<String>>
_findMessagesHeatmapWidgetContactContextBoundaryOffenders() async {
  const filePath =
      'lib/features/messages/application/sidebar_cassette_spec/widget_builders/messages_heatmap_widget.dart';
  final source = await File(filePath).readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  const forbiddenImports = <String>{
    '../../../../../essentials/conversation_graph/application/contacts/contact_graph_provider.dart',
  };
  final offenders = <String>[
    for (final importTarget in imports)
      if (forbiddenImports.contains(importTarget)) '$filePath -> $importTarget',
  ];
  const forbiddenTokens = <String>[
    'sidebarActionDispatcherProvider',
    'SidebarActionDispatchContext',
    'HeatMapMonthFocused',
    'ContactProjectionChanged',
  ];

  for (final token in forbiddenTokens) {
    if (uncommented.contains(token)) {
      offenders.add('$filePath uses $token');
    }
  }

  return offenders..sort();
}

Future<List<String>>
_findContactContextIdentityProviderImportOffenders() async {
  const filePath =
      'lib/features/messages/application/sidebar_cassette_spec/resolver_tools/contact_context_identity.dart';
  final source = await File(filePath).readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  const forbiddenImports = <String>{
    '../../../../../essentials/conversation_graph/application/contacts/contact_graph_provider.dart',
  };

  return <String>[
    for (final importTarget in imports)
      if (forbiddenImports.contains(importTarget)) '$filePath -> $importTarget',
  ]..sort();
}

Future<List<String>> _findConversationBrowserSpecRouteOffenders() async {
  const routeFiles = <String>{
    'lib/features/messages/domain/spec_classes/messages_view_spec.dart',
    'lib/features/messages/application/view_spec/coordinators/view_spec_coordinator.dart',
    'lib/essentials/navigation/application/panel_widget_providers.dart',
    'lib/essentials/logging/application/navigation_logger.dart',
  };
  final offenders = <String>[];

  for (final filePath in routeFiles) {
    final file = File(filePath);
    if (!file.existsSync()) {
      continue;
    }

    final uncommented = _stripComments(await file.readAsString());
    if (uncommented.contains('conversationBrowser')) {
      offenders.add(filePath);
    }
  }

  return offenders..sort();
}

Future<List<String>>
_findRetiredConversationBrowserPublicExportOffenders() async {
  const exportFile = 'lib/features/chats/feature_level_providers.dart';
  final file = File(exportFile);
  if (!file.existsSync()) {
    return const [];
  }

  final uncommented = _stripComments(await file.readAsString());
  if (!uncommented.contains('conversation_browser_view.dart')) {
    return const [];
  }

  return const ['$exportFile exports retained conversation_browser_view.dart'];
}

Future<List<String>> _findRetiredConversationBrowserFileOffenders() async {
  const retiredFiles = <String>[
    'lib/features/chats/application/conversation_browser/conversation_browser_integrator.dart',
    'lib/features/chats/presentation/view/conversation_browser_view.dart',
  ];

  return [
    for (final filePath in retiredFiles)
      if (File(filePath).existsSync()) filePath,
  ];
}

Future<List<String>>
_findRetiredConversationBrowserInternalImportOffenders() async {
  const retainedViewPath =
      'lib/features/chats/presentation/view/conversation_browser_view.dart';
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
      return false;
    }
    if (path == retainedViewPath) {
      return false;
    }
    if (path.startsWith(
      'lib/features/chats/application/conversation_browser/',
    )) {
      return false;
    }
    return path.startsWith('lib/features/') ||
        path.startsWith('lib/essentials/');
  });
  final offenders = <String>{};

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    for (final importTarget in imports) {
      if (importTarget.endsWith(
            'features/chats/application/conversation_browser/conversation_browser_integrator.dart',
          ) ||
          importTarget.endsWith(
            'chats/application/conversation_browser/conversation_browser_integrator.dart',
          )) {
        offenders.add('$filePath imports $importTarget');
      }
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>>
_findMessageUserMetadataApplicationInfrastructureOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart')) {
      return false;
    }
    return path.startsWith('lib/features/messages/application/user_metadata/');
  });
  final offenders = <String>{};

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    if (imports.any(
      (importTarget) =>
          importTarget.contains('/infrastructure/') ||
          importTarget.contains('/essentials/db/feature_level_providers.dart'),
    )) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>>
_findRecoveredMessageEvidenceInfrastructureProviderOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart')) {
      return false;
    }
    return path.startsWith('lib/features/messages/application/') ||
        path.startsWith('lib/features/messages/presentation/');
  });
  final offenders = <String>{};

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    if (imports.any(
      (importTarget) => importTarget.endsWith(
        'features/messages/infrastructure/repositories/recovered_unlinked_messages_provider.dart',
      ),
    )) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>> _findSourceSpecificMessageRendererOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
      return false;
    }
    return path.startsWith('lib/');
  });
  final offenders = <String>{};

  for (final filePath in files) {
    if (_retiredSourceSpecificMessageRendererPathFragments.any(
      filePath.endsWith,
    )) {
      offenders.add(filePath);
      continue;
    }

    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    for (final symbol in _retiredSourceSpecificMessageRendererSymbols) {
      if (RegExp('\\b$symbol\\b').hasMatch(uncommented)) {
        offenders.add('$filePath uses $symbol');
      }
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>> _findRetiredMessageTimelineOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
      return false;
    }
    return path.startsWith('lib/');
  });
  final offenders = <String>{};

  for (final filePath in files) {
    if (_retiredMessageTimelinePathFragments.any(filePath.contains)) {
      offenders.add(filePath);
      continue;
    }

    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    for (final symbol in _retiredMessageTimelineSymbols) {
      if (RegExp('\\b$symbol\\b').hasMatch(uncommented)) {
        offenders.add('$filePath uses $symbol');
      }
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>> _findMessageEvidenceScopeLimitOffenders() async {
  const filePath =
      'lib/features/messages/application/message_evidence/message_evidence_spine_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final offenders = <String>[];
  const disallowedPatterns = <String>[
    r'\bint\s+limit\s*=',
    r'\blimit\s*:\s*500\b',
    r'\bLIMIT\s+500\b',
    r'\btake\s*\(\s*500\s*\)',
  ];

  for (final pattern in disallowedPatterns) {
    if (RegExp(pattern, caseSensitive: false).hasMatch(uncommented)) {
      offenders.add('$filePath matches /$pattern/');
    }
  }

  return offenders..sort();
}

Future<List<String>> _findHandleLensOverlayDatabaseOffenders() async {
  const filePath =
      'lib/features/messages/presentation/view/handle_lens_view.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.endsWith('essentials/db/feature_level_providers.dart') ||
          importTarget.endsWith(
            'essentials/logging/feature_level_providers.dart',
          ) ||
          importTarget.endsWith(
            'contacts/application/services/manual_handle_link_service.dart',
          ) ||
          importTarget.endsWith(
            'essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart',
          ))
        '$filePath imports $importTarget',
  ];
  const forbiddenTokens = <String>[
    'manualHandleLinkServiceProvider.notifier',
    'handleReviewActionsProvider.notifier',
    'appLoggerProvider.notifier',
  ];

  for (final token in forbiddenTokens) {
    if (uncommented.contains(token)) {
      offenders.add('$filePath uses $token');
    }
  }

  return offenders..sort();
}

Future<List<String>> _findManualHandleLinkServiceStorageOffenders() async {
  const filePath =
      'lib/features/contacts/application/services/manual_handle_link_service.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.endsWith(
        'essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart',
      ))
        '$filePath imports $importTarget',
  ];
  if (uncommented.contains('overlayDatabaseProvider') ||
      uncommented.contains('OverlayDatabase') ||
      uncommented.contains('overlayDb') ||
      uncommented.contains('_overlayDatabase')) {
    offenders.add('$filePath handles overlay table operations directly');
  }
  return offenders..sort();
}

Future<List<String>> _findCrossFeatureContactInfrastructureOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
      return false;
    }
    return path.startsWith('lib/features/') &&
        !path.startsWith('lib/features/contacts/');
  });
  final offenders = <String>{};

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    for (final importTarget in imports) {
      if (importTarget.endsWith(
            'features/contacts/application/display_identity/display_identity.dart',
          ) ||
          importTarget.endsWith(
            'features/contacts/infrastructure/repositories/contacts_list_repository.dart',
          ) ||
          importTarget.endsWith(
            'features/contacts/infrastructure/repositories/contact_profile_provider.dart',
          ) ||
          importTarget.endsWith(
            'features/contacts/infrastructure/repositories/handles_for_contact_provider.dart',
          ) ||
          importTarget.endsWith(
            'features/contacts/infrastructure/repositories/recent_contacts_repository.dart',
          ) ||
          importTarget.endsWith(
            'features/contacts/infrastructure/repositories/virtual_participants_provider.dart',
          ) ||
          importTarget.endsWith(
            'features/contacts/presentation/widgets/contact_picker_dialog.dart',
          ) ||
          importTarget.endsWith(
            'contacts/application/display_identity/display_identity.dart',
          ) ||
          importTarget.endsWith(
            'contacts/infrastructure/repositories/contacts_list_repository.dart',
          ) ||
          importTarget.endsWith(
            'contacts/infrastructure/repositories/contact_profile_provider.dart',
          ) ||
          importTarget.endsWith(
            'contacts/infrastructure/repositories/handles_for_contact_provider.dart',
          ) ||
          importTarget.endsWith(
            'contacts/infrastructure/repositories/recent_contacts_repository.dart',
          ) ||
          importTarget.endsWith(
            'contacts/infrastructure/repositories/virtual_participants_provider.dart',
          ) ||
          importTarget.endsWith(
            'contacts/presentation/widgets/contact_picker_dialog.dart',
          )) {
        offenders.add('$filePath imports $importTarget');
      }
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>>
_findConversationSignaturePreferencesStorageOffenders() async {
  const filePath =
      'lib/features/messages/application/sidebar_cassette_spec/resolver_tools/conversation_signature_preferences_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.endsWith('essentials/db/feature_level_providers.dart') ||
          importTarget.endsWith(
            'essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart',
          ))
        '$filePath imports $importTarget',
  ];
  if (uncommented.contains('overlayDatabaseProvider') ||
      uncommented.contains('OverlayDatabase') ||
      uncommented.contains('readOverlaySetting') ||
      uncommented.contains('writeOverlaySetting')) {
    offenders.add('$filePath handles overlay settings storage directly');
  }
  return offenders..sort();
}

Future<List<String>> _findPickerFilterModeStorageOffenders() async {
  const filePath =
      'lib/features/contacts/application/sidebar_cassette_spec/resolver_tools/picker_filter_mode_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.endsWith('essentials/db/feature_level_providers.dart') ||
          importTarget.endsWith(
            'essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart',
          ))
        '$filePath imports $importTarget',
  ];
  if (uncommented.contains('overlayDatabaseProvider') ||
      uncommented.contains('OverlayDatabase') ||
      uncommented.contains('readOverlaySetting') ||
      uncommented.contains('writeOverlaySetting')) {
    offenders.add('$filePath handles overlay settings storage directly');
  }
  return offenders..sort();
}

Future<List<String>> _findPickerFilterToggleActionBoundaryOffenders() async {
  const filePath =
      'lib/features/contacts/presentation/widgets/picker_filter_toggle.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final uncommented = _stripComments(await file.readAsString());
  final offenders = <String>[];
  if (uncommented.contains('pickerFilterProvider.notifier')) {
    offenders.add('$filePath mutates picker filter state directly');
  }

  return offenders..sort();
}

Future<List<String>> _findContactPickerSelectionActionOffenders() async {
  const filePaths = <String>[
    'lib/features/contacts/application/sidebar_cassette_spec/widget_builders/contact_selection_control_widget.dart',
    'lib/features/contacts/application/sidebar_cassette_spec/widget_builders/contact_flat_list_widget.dart',
    'lib/features/contacts/application/sidebar_cassette_spec/widget_builders/contact_grouped_picker_widget.dart',
    'lib/features/contacts/application/sidebar_cassette_spec/widget_builders/recent_contacts_section.dart',
  ];
  final offenders = <String>[];
  const forbiddenTokens = <String>[
    'sidebarActionDispatcherProvider',
    'SidebarActionDispatchContext',
    'ContactChosen',
    'ChooseAnotherContact',
    'contactProfileProvider',
    'prewarmContactMessagesProvider',
  ];

  for (final filePath in filePaths) {
    final file = File(filePath);
    if (!file.existsSync()) {
      continue;
    }

    final uncommented = _stripComments(await file.readAsString());
    for (final token in forbiddenTokens) {
      if (uncommented.contains(token)) {
        offenders.add('$filePath uses $token');
      }
    }
  }

  return offenders..sort();
}

Future<List<String>> _findHandleFilterActionBoundaryOffenders() async {
  const filePath =
      'lib/features/contacts/application/sidebar_cassette_spec/widget_builders/handle_filter_widget.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final uncommented = _stripComments(await file.readAsString());
  final offenders = <String>[];
  if (uncommented.contains('manualHandleLinkServiceProvider.notifier')) {
    offenders.add('$filePath mutates manual handle links directly');
  }
  if (uncommented.contains('sidebarActionDispatcherProvider.notifier')) {
    offenders.add('$filePath dispatches sidebar follow-up actions directly');
  }

  return offenders..sort();
}

Future<List<String>>
_findContactMessageScopeToggleActionBoundaryOffenders() async {
  const filePath =
      'lib/features/contacts/application/sidebar_cassette_spec/widget_builders/contact_message_scope_toggle_widget.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final uncommented = _stripComments(await file.readAsString());
  final offenders = <String>[];
  const forbiddenTokens = <String>[
    'sidebarActionDispatcherProvider',
    'SidebarActionDispatchContext',
    'ContactMessageScopeChanged',
  ];

  for (final token in forbiddenTokens) {
    if (uncommented.contains(token)) {
      offenders.add('$filePath uses $token');
    }
  }

  return offenders..sort();
}

Future<List<String>> _findConversationFavouritesStorageOffenders() async {
  const filePath =
      'lib/essentials/conversation_graph/application/conversation_favourites/conversation_favourites_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.endsWith('essentials/db/feature_level_providers.dart') ||
          importTarget.endsWith(
            'essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart',
          ))
        '$filePath imports $importTarget',
  ];
  if (uncommented.contains('overlayDatabaseProvider') ||
      uncommented.contains('OverlayDatabase') ||
      uncommented.contains('readOverlaySetting') ||
      uncommented.contains('writeOverlaySetting')) {
    offenders.add('$filePath handles overlay settings storage directly');
  }
  return offenders..sort();
}

Future<List<String>>
_findConversationFavouriteButtonActionBoundaryOffenders() async {
  const filePath =
      'lib/essentials/conversation_graph/presentation/widgets/conversation_favourite_button.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final uncommented = _stripComments(await file.readAsString());
  final offenders = <String>[];
  if (uncommented.contains(
    'conversationFavouritesControllerProvider.notifier',
  )) {
    offenders.add('$filePath mutates conversation favourites directly');
  }

  return offenders..sort();
}

Future<List<String>> _findSpamManagementStorageOffenders() async {
  const filePath =
      'lib/features/handles/application/settings_cassette_spec/resolver_tools/spam_management_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.endsWith('essentials/db/feature_level_providers.dart') ||
          importTarget.endsWith(
            'essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart',
          ) ||
          importTarget.endsWith('conversation_graph_database.dart'))
        '$filePath imports $importTarget',
  ];
  if (uncommented.contains('overlayDatabaseProvider') ||
      uncommented.contains('driftConversationGraphDatabaseProvider') ||
      uncommented.contains('OverlayDatabase') ||
      uncommented.contains('ConversationGraphDatabase') ||
      uncommented.contains('HandleVisibilityOverride') ||
      uncommented.contains('getAllHandleVisibilities') ||
      uncommented.contains('setHandleVisibility') ||
      uncommented.contains('deleteHandleVisibility')) {
    offenders.add('$filePath handles overlay visibility storage directly');
  }
  return offenders..sort();
}

Future<List<String>>
_findHandleApplicationInfrastructureProviderOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
      return false;
    }
    return path.startsWith('lib/features/handles/application/') ||
        path.startsWith('lib/features/handles/presentation/');
  });
  final offenders = <String>{};

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    for (final importTarget in imports) {
      if (importTarget.endsWith(
            'features/handles/infrastructure/repositories/handle_display_name_provider.dart',
          ) ||
          importTarget.endsWith(
            'features/handles/infrastructure/repositories/stray_handles_provider.dart',
          ) ||
          importTarget.endsWith(
            'handles/infrastructure/repositories/handle_display_name_provider.dart',
          ) ||
          importTarget.endsWith(
            'handles/infrastructure/repositories/stray_handles_provider.dart',
          ) ||
          importTarget.endsWith('handle_display_name_provider.dart') ||
          importTarget.endsWith('stray_handles_provider.dart')) {
        offenders.add('$filePath imports $importTarget');
      }
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>> _findCrossFeatureHandleInfrastructureOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
      return false;
    }
    return path.startsWith('lib/features/') &&
        !path.startsWith('lib/features/handles/');
  });
  final offenders = <String>{};

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    for (final importTarget in imports) {
      if (importTarget.endsWith(
            'features/handles/infrastructure/repositories/handle_display_name_provider.dart',
          ) ||
          importTarget.endsWith(
            'features/handles/infrastructure/repositories/stray_handles_provider.dart',
          ) ||
          importTarget.endsWith(
            'handles/infrastructure/repositories/handle_display_name_provider.dart',
          ) ||
          importTarget.endsWith(
            'handles/infrastructure/repositories/stray_handles_provider.dart',
          )) {
        offenders.add('$filePath imports $importTarget');
      }
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>> _findDeveloperModeStorageOffenders() async {
  const filePath =
      'lib/essentials/debug/application/developer_mode_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.endsWith('essentials/db/feature_level_providers.dart') ||
          importTarget.endsWith(
            'essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart',
          ))
        '$filePath imports $importTarget',
  ];
  if (uncommented.contains('overlayDatabaseProvider') ||
      uncommented.contains('OverlayDatabase') ||
      uncommented.contains('readOverlaySetting') ||
      uncommented.contains('writeOverlaySetting')) {
    offenders.add('$filePath handles overlay settings storage directly');
  }
  return offenders..sort();
}

Future<List<String>> _findManualLinkingActionStorageOffenders() async {
  const filePath =
      'lib/features/handles/application/settings_cassette_spec/resolver_tools/manual_linking_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final offenders = <String>[];
  final forbiddenWritePatterns = <String>[
    'overlayDb.setHandleOverride',
    'overlayDb.setHandleVirtualParticipantOverride',
    'overlayDb.deleteHandleOverride',
    'overlayDb.createVirtualParticipant',
  ];
  for (final pattern in forbiddenWritePatterns) {
    if (uncommented.contains(pattern)) {
      offenders.add('$filePath calls $pattern directly');
    }
  }
  return offenders..sort();
}

Future<List<String>> _findManualLinkingReadBoundaryOffenders() async {
  const filePath =
      'lib/features/handles/application/settings_cassette_spec/resolver_tools/manual_linking_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.endsWith('essentials/db/feature_level_providers.dart') ||
          importTarget.endsWith(
            'essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart',
          ) ||
          importTarget.endsWith(
            'essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart',
          ) ||
          importTarget.endsWith(
            'contacts/infrastructure/repositories/participant_merge_utils.dart',
          ))
        '$filePath imports $importTarget',
  ];
  if (uncommented.contains('overlayDatabaseProvider') ||
      uncommented.contains('driftConversationGraphDatabaseProvider') ||
      uncommented.contains('OverlayDatabase') ||
      uncommented.contains('ConversationGraphDatabase') ||
      uncommented.contains('selectRows(') ||
      uncommented.contains('getAllHandleVisibilities') ||
      uncommented.contains('getAllHandleOverrides') ||
      uncommented.contains('getHandleOverride') ||
      uncommented.contains('participantOverridesById') ||
      uncommented.contains('overlayHandleCountsByParticipant')) {
    offenders.add('$filePath performs manual-linking read storage directly');
  }
  return offenders..sort();
}

Future<List<String>> _findSidebarFlowStorageOffenders() async {
  const filePath =
      'lib/essentials/sidebar/application/sidebar_flow_state_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.endsWith('essentials/db/feature_level_providers.dart') ||
          importTarget.endsWith(
            'essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart',
          ))
        '$filePath imports $importTarget',
  ];
  if (uncommented.contains('overlayDatabaseProvider') ||
      uncommented.contains('OverlayDatabase') ||
      uncommented.contains('readOverlaySetting') ||
      uncommented.contains('writeOverlaySetting')) {
    offenders.add('$filePath handles overlay settings storage directly');
  }
  return offenders..sort();
}

Future<List<String>> _findSidebarActionDispatcherStorageOffenders() async {
  const filePath =
      'lib/essentials/sidebar/application/sidebar_action_dispatcher.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.endsWith('essentials/db/feature_level_providers.dart') ||
          importTarget.endsWith(
            'essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart',
          ))
        '$filePath imports $importTarget',
  ];
  if (uncommented.contains('overlayDatabaseProvider') ||
      uncommented.contains('OverlayDatabase') ||
      uncommented.contains('readOverlaySetting') ||
      uncommented.contains('writeOverlaySetting') ||
      uncommented.contains('.trackContactAccess(') ||
      uncommented.contains('.dismissHandle(') ||
      uncommented.contains('.restoreHandle(') ||
      uncommented.contains('.writer')) {
    offenders.add('$filePath handles storage-backed mutations directly');
  }
  return offenders..sort();
}

Future<List<String>> _findSidebarActionDispatcherPanelPushOffenders() async {
  const filePath =
      'lib/essentials/sidebar/application/sidebar_action_dispatcher.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final uncommented = _stripComments(await file.readAsString());
  final forbiddenTokens = [
    'panelsViewStateProvider',
    'WindowPanel.',
    'ViewSpec.messages',
    'MessagesSpec.',
  ];
  return [
    for (final token in forbiddenTokens)
      if (uncommented.contains(token)) '$filePath contains $token',
  ]..sort();
}

Future<List<String>> _findPipelineIncidentTrackerStorageOffenders() async {
  const filePath =
      'lib/essentials/logging/application/pipeline_incident_tracker_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.endsWith('essentials/db/feature_level_providers.dart') ||
          importTarget.contains('/logging/infrastructure/') ||
          importTarget.endsWith(
            'essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart',
          ))
        '$filePath imports $importTarget',
  ];
  if (uncommented.contains('overlayDatabaseProvider') ||
      uncommented.contains('OverlayDatabase') ||
      uncommented.contains('readOverlaySetting') ||
      uncommented.contains('writeOverlaySetting')) {
    offenders.add('$filePath handles overlay storage directly');
  }
  return offenders..sort();
}

Future<List<String>> _findGraphHealthProviderBoundaryOffenders() async {
  const filePath =
      'lib/essentials/conversation_graph/application/health/graph_health_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.endsWith('essentials/db/feature_level_providers.dart') ||
          importTarget.endsWith(
            'conversation_graph/infrastructure/repositories/graph_health_repository.dart',
          ) ||
          importTarget.endsWith(
            'essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart',
          ) ||
          importTarget.endsWith(
            'essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart',
          ))
        '$filePath imports $importTarget',
  ];
  if (uncommented.contains('overlayDatabaseProvider') ||
      uncommented.contains('driftConversationGraphDatabaseProvider') ||
      uncommented.contains('attachmentArchiveDirectoryProvider') ||
      uncommented.contains('SqliteGraphHealthRepository') ||
      uncommented.contains('/Volumes/')) {
    offenders.add('$filePath constructs graph-health infrastructure directly');
  }
  return offenders..sort();
}

Future<List<String>> _findChatSummaryProviderBoundaryOffenders() async {
  const filePath =
      'lib/essentials/conversation_graph/application/chat_summaries/chat_summary_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.endsWith('essentials/db/feature_level_providers.dart') ||
          importTarget.endsWith(
            'conversation_graph/infrastructure/repositories/chat_summary_repository.dart',
          ) ||
          importTarget.endsWith(
            'features/attachments/infrastructure/repositories/overlay_archive_compatibility_lookup.dart',
          ))
        '$filePath imports $importTarget',
  ];
  if (uncommented.contains('overlayDatabaseProvider') ||
      uncommented.contains('driftConversationGraphDatabaseProvider') ||
      uncommented.contains('attachmentArchiveDirectoryProvider') ||
      uncommented.contains('SqliteChatSummaryRepository') ||
      uncommented.contains('OverlayArchiveCompatibilityLookup')) {
    offenders.add('$filePath constructs chat-summary infrastructure directly');
  }
  return offenders..sort();
}

Future<List<String>> _findConversationReaderProviderBoundaryOffenders() async {
  const filePath =
      'lib/essentials/conversation_graph/application/conversations/conversation_reader_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.endsWith(
        'conversation_graph/infrastructure/repositories/conversation_repository.dart',
      ))
        '$filePath imports $importTarget',
  ];
  if (uncommented.contains('driftConversationGraphDatabaseProvider') ||
      uncommented.contains('SqliteConversationRepository')) {
    offenders.add(
      '$filePath constructs conversation-reader infrastructure directly',
    );
  }
  return offenders..sort();
}

Future<List<String>> _findContactGraphProviderBoundaryOffenders() async {
  const filePath =
      'lib/essentials/conversation_graph/application/contacts/contact_graph_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.endsWith(
        'conversation_graph/infrastructure/repositories/contact_graph_repository.dart',
      ))
        '$filePath imports $importTarget',
  ];
  if (uncommented.contains('SqliteContactGraphRepository')) {
    offenders.add('$filePath constructs contact-graph infrastructure directly');
  }
  return offenders..sort();
}

Future<List<String>> _findMessageGraphReaderProviderBoundaryOffenders() async {
  const filePath =
      'lib/essentials/conversation_graph/application/messages/message_graph_reader_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.endsWith('essentials/db/feature_level_providers.dart') ||
          importTarget.endsWith(
            'conversation_graph/infrastructure/repositories/message_graph_repository.dart',
          ))
        '$filePath imports $importTarget',
  ];
  if (uncommented.contains('driftConversationGraphDatabaseProvider') ||
      uncommented.contains('SqliteMessageGraphRepository')) {
    offenders.add('$filePath constructs message-graph infrastructure directly');
  }
  return offenders..sort();
}

Future<List<String>>
_findMessageGraphRepositoryIdentityBoundaryOffenders() async {
  const filePath =
      'lib/essentials/conversation_graph/infrastructure/repositories/message_graph_repository.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.endsWith(
            'source_scoped_import/domain/source_scoped_row_key.dart',
          ) ||
          importTarget.endsWith(
            'source_scoped_import/domain/known_sources.dart',
          ))
        '$filePath imports $importTarget',
  ];

  if (uncommented.contains('SourceScopedRowKey.pack') ||
      uncommented.contains('SourceScopedRowKey.unpack') ||
      uncommented.contains('liveChatDbSourceId')) {
    offenders.add('$filePath performs graph id normalization directly');
  }

  return offenders..sort();
}

Future<List<String>> _findMessageProjectorProviderBoundaryOffenders() async {
  const filePath =
      'lib/essentials/conversation_graph/application/messages/message_projector_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.endsWith('essentials/db/feature_level_providers.dart') ||
          importTarget == 'package:sqlite3/sqlite3.dart' ||
          importTarget.endsWith(
            'source_scoped_import/feature_level_providers.dart',
          ) ||
          importTarget.endsWith(
            'conversation_graph/infrastructure/repositories/message_projection_repository.dart',
          ))
        '$filePath imports $importTarget',
  ];
  if (uncommented.contains('sourceScopedImportDatabaseProvider') ||
      uncommented.contains('driftConversationGraphDatabaseProvider') ||
      uncommented.contains('SqliteMessageProjectionRepository')) {
    offenders.add(
      '$filePath constructs message-projection infrastructure directly',
    );
  }
  return offenders..sort();
}

Future<List<String>> _findGraphProjectorProviderBoundaryOffenders() async {
  const providerFiles = <String, List<String>>{
    'lib/essentials/conversation_graph/application/chats/chat_projector_provider.dart':
        <String>['SqliteChatProjectionRepository'],
    'lib/essentials/conversation_graph/application/handles/handle_projector_provider.dart':
        <String>['SqliteHandleProjectionRepository'],
    'lib/essentials/conversation_graph/application/attachments/attachment_projector_provider.dart':
        <String>['SqliteAttachmentProjectionRepository'],
    'lib/essentials/conversation_graph/application/contacts/contact_projector_provider.dart':
        <String>['SqliteContactProjectionRepository'],
    'lib/essentials/conversation_graph/application/messages/message_projector_provider.dart':
        <String>['SqliteMessageProjectionRepository'],
    'lib/essentials/conversation_graph/application/chat_message_joins/chat_to_message_projector_provider.dart':
        <String>['SqliteChatToMessageProjectionRepository'],
    'lib/essentials/conversation_graph/application/chat_handle_joins/chat_to_handle_projector_provider.dart':
        <String>['SqliteChatToHandleProjectionRepository'],
    'lib/essentials/conversation_graph/application/message_attachment_joins/message_to_attachment_projector_provider.dart':
        <String>['SqliteMessageToAttachmentProjectionRepository'],
  };

  final offenders = <String>[];
  for (final entry in providerFiles.entries) {
    final file = File(entry.key);
    if (!file.existsSync()) {
      continue;
    }

    final source = await file.readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    for (final importTarget in imports) {
      if (importTarget.endsWith('essentials/db/feature_level_providers.dart') ||
          importTarget.endsWith(
            'source_scoped_import/feature_level_providers.dart',
          ) ||
          importTarget.contains(
                'conversation_graph/infrastructure/repositories/',
              ) &&
              importTarget.endsWith('_projection_repository.dart')) {
        offenders.add('${entry.key} imports $importTarget');
      }
    }

    if (uncommented.contains('sourceScopedImportDatabaseProvider') ||
        uncommented.contains('driftConversationGraphDatabaseProvider')) {
      offenders.add('${entry.key} opens graph/import DB providers directly');
    }

    for (final concreteType in entry.value) {
      if (uncommented.contains(concreteType)) {
        offenders.add('${entry.key} constructs $concreteType directly');
      }
    }
  }

  return offenders..sort();
}

Future<List<String>> _findGraphStatusProviderBoundaryOffenders() async {
  const filePath =
      'lib/essentials/conversation_graph/application/status/conversation_graph_status_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget != '../../feature_level_providers.dart' &&
          (importTarget.endsWith('providers.dart') ||
              importTarget.endsWith(
                'essentials/db/feature_level_providers.dart',
              ) ||
              importTarget.endsWith(
                'source_scoped_import/feature_level_providers.dart',
              ) ||
              importTarget.endsWith(
                'source_scoped_import/domain/known_sources.dart',
              ) ||
              importTarget.endsWith(
                'conversation_graph/infrastructure/repositories/conversation_graph_status_repository.dart',
              ) ||
              importTarget.endsWith('conversation_graph_database.dart')))
        '$filePath imports $importTarget',
  ];

  if (uncommented.contains('pathsHelperProvider') ||
      uncommented.contains('sourceScopedImportDatabaseProvider') ||
      uncommented.contains('driftConversationGraphDatabaseProvider') ||
      uncommented.contains('ConversationGraphStatusRepository') ||
      uncommented.contains('liveChatDbSourceId')) {
    offenders.add('$filePath constructs graph-status infrastructure directly');
  }
  return offenders..sort();
}

Future<List<String>> _findGraphStatusSheetControlBoundaryOffenders() async {
  const filePath =
      'lib/essentials/conversation_graph/presentation/status/conversation_graph_status_sheet.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.endsWith('conversation_graph_status_log_writer.dart') ||
          importTarget.endsWith('conversation_graph_build_orchestrator.dart'))
        '$filePath imports $importTarget',
  ];

  if (uncommented.contains('ref.invalidate(') ||
      uncommented.contains('widget.ref.invalidate(') ||
      uncommented.contains('chatsViewModelProvider.notifier') ||
      uncommented.contains('writeRun(') ||
      uncommented.contains('.runOnce(owner:')) {
    offenders.add('$filePath owns graph status refresh/build action details');
  }

  return offenders..sort();
}

Future<List<String>> _findOnboardingGraphBuildPresentationOffenders() async {
  const filePaths = <String>{
    'lib/essentials/onboarding/presentation/onboarding_dev_panel.dart',
    'lib/essentials/onboarding/presentation/onboarding_overlay.dart',
  };
  final offenders = <String>[];

  for (final filePath in filePaths) {
    final file = File(filePath);
    if (!file.existsSync()) {
      continue;
    }
    final source = await file.readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    offenders.addAll([
      for (final importTarget in imports)
        if (importTarget.endsWith('conversation_graph_build_orchestrator.dart'))
          '$filePath imports $importTarget',
    ]);
  }

  return offenders..sort();
}

Future<List<String>> _findArchiveGraphRemovalResetterBoundaryOffenders() async {
  const files = <String>{
    'lib/essentials/conversation_graph/application/archives/source_scoped_archive_graph_removal_service.dart',
    'lib/essentials/conversation_graph/application/archives/source_scoped_archive_graph_removal_service_provider.dart',
  };
  final offenders = <String>[];

  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) {
      continue;
    }

    final source = await file.readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    for (final importTarget in imports) {
      if (importTarget.endsWith('essentials/db/feature_level_providers.dart') ||
          importTarget.endsWith('conversation_graph_database.dart')) {
        offenders.add('$filePath imports $importTarget');
      }
    }

    if (uncommented.contains('driftConversationGraphDatabaseProvider') ||
        uncommented.contains('ConversationGraphDatabase') ||
        uncommented.contains('graphDatabase.clearProjectionRows')) {
      offenders.add('$filePath bypasses GraphProjectionResetter boundary');
    }
  }

  return offenders..sort();
}

Future<List<String>> _findSettingsGraphReadBoundaryOffenders() async {
  const files = <String>{
    'lib/features/settings/application/sidebar_cassette_spec/resolvers/message_history_coverage_settings_resolver.dart',
    'lib/features/settings/application/historical_archives_workflow_panel_model_provider.dart',
  };
  final offenders = <String>[];

  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) {
      continue;
    }

    final source = await file.readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    for (final importTarget in imports) {
      if (importTarget.endsWith('conversation_graph_database.dart') ||
          importTarget.endsWith('essentials/db/feature_level_providers.dart')) {
        offenders.add('$filePath imports $importTarget');
      }
    }

    if (uncommented.contains('driftConversationGraphDatabaseProvider') ||
        uncommented.contains('ConversationGraphDatabase')) {
      offenders.add('$filePath opens conversation graph storage directly');
    }
  }

  return offenders..sort();
}

Future<List<String>>
_findHistoricalArchivesFolderChooserBoundaryOffenders() async {
  const filePath =
      'lib/features/settings/application/historical_archives_workflow_panel_model_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget ==
              'package:file_selector_platform_interface/file_selector_platform_interface.dart' ||
          importTarget.contains('file_selector'))
        '$filePath imports $importTarget',
  ];

  if (uncommented.contains('FileSelectorPlatform') ||
      uncommented.contains('FileDialogOptions') ||
      uncommented.contains('getDirectoryPathWithOptions')) {
    offenders.add('$filePath opens native folder picker directly');
  }

  return offenders..sort();
}

Future<List<String>> _findChatDbMonitorImportLedgerBoundaryOffenders() async {
  const filePath =
      'lib/essentials/conversation_graph/application/monitor/chat_db_change_monitor_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget == 'dart:io' ||
          importTarget.endsWith('essentials/db/feature_level_providers.dart') ||
          importTarget.endsWith(
            'source_scoped_import/feature_level_providers.dart',
          ) ||
          importTarget.endsWith(
            'source_scoped_import/infrastructure/import_database_provider.dart',
          ))
        '$filePath imports $importTarget',
  ];

  if (uncommented.contains('sourceScopedImportDatabaseProvider') ||
      uncommented.contains('ImportDatabase') ||
      uncommented.contains('maxMessageSourceRowIdForSource') ||
      uncommented.contains('messageCountForSource') ||
      uncommented.contains('sqlite3.open') ||
      uncommented.contains('OpenMode.readOnly') ||
      uncommented.contains('Platform.isMacOS') ||
      uncommented.contains('SELECT MAX(ROWID)')) {
    offenders.add('$filePath opens import/source probe storage directly');
  }

  return offenders..sort();
}

Future<List<String>> _findGraphRefreshBroadDatabaseImportOffenders() async {
  const files = <String>{
    'lib/essentials/conversation_graph/application/chat_summaries/chat_summary_provider.dart',
    'lib/essentials/conversation_graph/application/contacts/contact_graph_provider.dart',
    'lib/essentials/conversation_graph/application/conversations/conversation_reader_provider.dart',
    'lib/essentials/conversation_graph/application/conversation_graph_build_controller_provider.dart',
    'lib/features/messages/application/message_evidence/message_evidence_spine_provider.dart',
    'lib/features/messages/application/sidebar_cassette_spec/resolver_tools/contact_timeline_provider.dart',
  };
  final offenders = <String>[];

  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) {
      continue;
    }
    final source = await file.readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    for (final importTarget in imports) {
      if (importTarget.endsWith('essentials/db/feature_level_providers.dart')) {
        offenders.add('$filePath imports $importTarget');
      }
    }
  }

  return offenders..sort();
}

Future<List<String>>
_findAttachmentArchiveSourceLookupBoundaryOffenders() async {
  const filePath =
      'lib/features/attachments/application/attachment_archive_service_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget == 'package:sqlite3/sqlite3.dart' ||
          importTarget.startsWith('package:sqflite') ||
          importTarget.endsWith(
            'source_scoped_import/domain/ports/source_database_port.dart',
          ) ||
          importTarget.endsWith(
            'source_scoped_import/infrastructure/source_database/sqflite_source_database.dart',
          ))
        '$filePath imports $importTarget',
  ];

  if (uncommented.contains('sqlite3.open') ||
      uncommented.contains('openDatabase(') ||
      uncommented.contains('SourceDatabaseOpener') ||
      uncommented.contains('ReadOnlySourceDatabase')) {
    offenders.add('$filePath performs source attachment path lookup directly');
  }

  return offenders..sort();
}

Future<List<String>> _findAttachmentArchiveFileStoreBoundaryOffenders() async {
  const filePath =
      'lib/features/attachments/application/attachment_archive_service_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget == 'dart:io' ||
          importTarget == 'package:crypto/crypto.dart' ||
          importTarget == 'package:path/path.dart')
        '$filePath imports $importTarget',
  ];

  if (RegExp(r'(^|[^\w.])File\(').hasMatch(uncommented) ||
      RegExp(r'(^|[^\w.])Directory\(').hasMatch(uncommented) ||
      uncommented.contains('Platform.environment') ||
      uncommented.contains('sha256.convert')) {
    offenders.add('$filePath performs archive file-store work directly');
  }

  return offenders..sort();
}

Future<List<String>> _findAttachmentArchiveDirectoryBoundaryOffenders() async {
  const filePaths = <String>[
    'lib/features/attachments/application/archive_settings_provider.dart',
    'lib/features/attachments/application/attachment_archive_service_provider.dart',
  ];
  final offenders = <String>[];

  for (final filePath in filePaths) {
    final file = File(filePath);
    if (!file.existsSync()) {
      continue;
    }

    final source = await file.readAsString();
    final uncommented = _stripComments(source);
    if (uncommented.contains('attachmentArchiveDirectoryProvider')) {
      offenders.add(
        '$filePath reads central attachmentArchiveDirectoryProvider directly',
      );
    }
  }

  return offenders..sort();
}

Future<List<String>>
_findAttachmentArchiveGraphCandidateBoundaryOffenders() async {
  const filePath =
      'lib/features/attachments/application/attachment_archive_service_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.endsWith(
            'essentials/db/infrastructure/data_sources/local/conversation_graph/conversation_graph_database.dart',
          ) ||
          importTarget.endsWith(
            'essentials/source_scoped_import/domain/source_scoped_row_key.dart',
          ) ||
          importTarget.endsWith(
            'essentials/source_scoped_import/domain/known_sources.dart',
          ))
        '$filePath imports $importTarget',
  ];

  if (uncommented.contains('driftConversationGraphDatabaseProvider') ||
      uncommented.contains('ConversationGraphDatabase') ||
      uncommented.contains('SourceScopedRowKey') ||
      uncommented.contains('liveChatDbSourceId') ||
      uncommented.contains('SELECT DISTINCT') ||
      uncommented.contains('JOIN message_to_attachment')) {
    offenders.add('$filePath performs graph attachment candidate reads');
  }

  return offenders..sort();
}

Future<List<String>> _findAttachmentArchiveWriteStoreBoundaryOffenders() async {
  const filePath =
      'lib/features/attachments/application/attachment_archive_service_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget == 'package:drift/drift.dart' ||
          importTarget.endsWith(
            'essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart',
          ))
        '$filePath imports $importTarget',
  ];

  if (uncommented.contains('overlayDatabaseProvider') ||
      uncommented.contains('OverlayDatabase') ||
      uncommented.contains('ArchivedAttachmentsCompanion') ||
      uncommented.contains('archivedAttachments') ||
      uncommented.contains('readOverlaySetting') ||
      uncommented.contains('writeOverlaySetting') ||
      uncommented.contains('customSelect(')) {
    offenders.add('$filePath performs archive record storage directly');
  }

  return offenders..sort();
}

Future<List<String>> _findAttachmentArchiveStoreTypedKeyOffenders() async {
  const filePaths = <String>[
    'lib/features/attachments/application/attachment_archive_file_store.dart',
    'lib/features/attachments/application/attachment_archive_read_store.dart',
    'lib/features/attachments/application/attachment_archive_write_store.dart',
  ];
  final offenders = <String>[];

  for (final filePath in filePaths) {
    final file = File(filePath);
    if (!file.existsSync()) {
      continue;
    }

    final uncommented = _stripComments(await file.readAsString());
    if (!uncommented.contains('ArchiveCompatibilityKey')) {
      offenders.add('$filePath does not use ArchiveCompatibilityKey');
    }
    final methodBlocks = RegExp(
      r'(writeArchiveEntry|readArchiveRecord|hasArchiveRecord|readRecoveryHint|writeRecoveryHint|clearRecoveryHint)\s*\([^;{]*[;{]',
      multiLine: true,
      dotAll: true,
    ).allMatches(uncommented);
    for (final match in methodBlocks) {
      final block = match.group(0) ?? '';
      if (block.contains('messageGuid') ||
          block.contains('importAttachmentId')) {
        offenders.add('$filePath exposes primitive archive key method: $block');
      }
    }
  }

  return offenders..sort();
}

Future<List<String>> _findAttachmentArchiveServiceTypedKeyOffenders() async {
  const filePath =
      'lib/features/attachments/application/attachment_archive_service_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final uncommented = _stripComments(await file.readAsString());
  final methodBlocks = RegExp(
    r'Future<[^>]+>\s+(archiveAttachment|prioritizeRecovery)\s*\(\{[^}]*\}\)\s*async\s*\{',
    multiLine: true,
    dotAll: true,
  ).allMatches(uncommented);
  final offenders = <String>[];

  for (final match in methodBlocks) {
    final block = match.group(0) ?? '';
    if (!block.contains('ArchiveCompatibilityKey')) {
      offenders.add('$filePath entry point lacks ArchiveCompatibilityKey');
    }
    if (block.contains('messageGuid') || block.contains('importAttachmentId')) {
      offenders.add('$filePath exposes primitive archive key method: $block');
    }
  }

  return offenders..sort();
}

Future<List<String>>
_findGraphArchiveLookupContractIdentityLanguageOffenders() async {
  const filePath =
      'lib/features/attachments/application/graph_attachment_archive_lookup.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final uncommented = _stripComments(await file.readAsString());
  final offenders = <String>[];
  if (uncommented.contains('retainedImportAttachmentId') ||
      uncommented.contains('retained import attachment') ||
      uncommented.contains('archiveCompatibilityAttachmentId')) {
    offenders.add('$filePath exposes retained import attachment identity');
  }

  return offenders;
}

Future<List<String>>
_findGraphArchiveCandidateContractIdentityLanguageOffenders() async {
  const filePath =
      'lib/features/attachments/application/graph_attachment_archive_candidate_reader.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final uncommented = _stripComments(await file.readAsString());
  final offenders = <String>[];
  if (uncommented.contains('messageGuid') ||
      uncommented.contains('importAttachmentId')) {
    offenders.add('$filePath exposes retained archive column names');
  }

  return offenders;
}

Future<List<String>> _findGraphArchiveCandidateAdHocKeyOffenders() async {
  const filePath =
      'lib/features/attachments/infrastructure/repositories/sqlite_graph_attachment_archive_candidate_reader.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final uncommented = _stripComments(await file.readAsString());
  final offenders = <String>[];
  if (uncommented.contains('::')) {
    offenders.add('$filePath builds archive compatibility keys as strings');
  }
  if (!uncommented.contains('ArchiveCompatibilityKey')) {
    offenders.add('$filePath does not use ArchiveCompatibilityKey');
  }

  return offenders;
}

Future<List<String>> _findGraphHealthAdHocArchiveKeyOffenders() async {
  const filePath =
      'lib/essentials/conversation_graph/infrastructure/repositories/graph_health_repository.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final uncommented = _stripComments(await file.readAsString());
  final offenders = <String>[];
  if (uncommented.contains('::')) {
    offenders.add('$filePath builds archive compatibility keys as strings');
  }
  if (!uncommented.contains('ArchiveCompatibilityKey')) {
    offenders.add('$filePath does not use ArchiveCompatibilityKey');
  }

  return offenders;
}

Future<List<String>>
_findArchiveCompatibilityTupleSerializationOffenders() async {
  const allowedFiles = <String>{
    'lib/essentials/retained_archive/domain/archive_compatibility_key.dart',
    'lib/features/attachments/application/attachment_recovery_hint_storage.dart',
  };
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
      return false;
    }
    return path.startsWith('lib/features/attachments/') ||
        path.startsWith('lib/features/messages/') ||
        path.startsWith('lib/essentials/conversation_graph/');
  });
  final offenders = <String>[];

  for (final filePath in files) {
    if (allowedFiles.contains(filePath)) {
      continue;
    }
    final uncommented = _stripComments(await File(filePath).readAsString());
    if (uncommented.contains('::')) {
      offenders.add('$filePath builds archive compatibility tuples as strings');
    }
  }

  return offenders..sort();
}

Future<List<String>> _findArchiveCompatibilityKeyConstructionOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
      return false;
    }
    return path.startsWith('lib/');
  });
  final offenders = <String>{};

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    if (uncommented.contains('ArchiveCompatibilityKey(')) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>> _findConversationGraphImportLedgerNamingOffenders() async {
  final files = await _collectProjectDartFiles((path) {
    if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
      return false;
    }
    return path.startsWith(
          'lib/essentials/conversation_graph/infrastructure/repositories/',
        ) ||
        path.startsWith('test/essentials/conversation_graph/application/');
  });
  final offenders = <String>[];
  final genericImportDatabaseIdentifier = RegExp(r'\bimportDatabase\b');

  for (final filePath in files) {
    final uncommented = _stripComments(await File(filePath).readAsString());
    if (genericImportDatabaseIdentifier.hasMatch(uncommented)) {
      offenders.add('$filePath uses generic importDatabase naming');
    }
  }

  return offenders..sort();
}

Future<List<String>>
_findAttachmentSourceScopedImportProviderBoundaryOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
      return false;
    }
    if (path == 'lib/features/attachments/feature_level_providers.dart') {
      return false;
    }
    return path.startsWith('lib/features/attachments/');
  });
  final offenders = <String>[];

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    for (final importTarget in imports) {
      if (importTarget.endsWith(
        'source_scoped_import/feature_level_providers.dart',
      )) {
        offenders.add('$filePath imports $importTarget');
      }
    }
    if (uncommented.contains('sourceScopedImportDatabaseProvider')) {
      offenders.add('$filePath watches sourceScopedImportDatabaseProvider');
    }
  }

  return offenders..sort();
}

Future<List<String>> _findOnboardingEnvironmentProbeBoundaryOffenders() async {
  const filePath =
      'lib/essentials/onboarding/application/onboarding_environment_report_provider.dart';
  const files = <String>[
    filePath,
    'lib/essentials/onboarding/application/database_existence_checker.dart',
  ];
  final offenders = <String>[];

  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) {
      continue;
    }

    final source = await file.readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    offenders.addAll([
      for (final importTarget in imports)
        if (importTarget == 'dart:io' ||
            importTarget == 'package:sqlite3/sqlite3.dart' ||
            importTarget.startsWith('package:sqflite') ||
            importTarget.endsWith('conversation_graph_database.dart'))
          '$filePath imports $importTarget',
    ]);

    if (uncommented.contains('sqlite3.open') ||
        uncommented.contains('OpenMode.readOnly') ||
        uncommented.contains('ConversationGraphReadinessChecker')) {
      offenders.add('$filePath performs onboarding database probing directly');
    }
  }

  return offenders..sort();
}

Future<List<String>> _findOnboardingCenterSyncObserverOffenders() async {
  const filePath =
      'lib/essentials/navigation/presentation/widgets/onboarding_center_panel_sync_observer.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.endsWith('panels_view_state_provider.dart') ||
          importTarget.endsWith('sidebar_mode_provider.dart') ||
          importTarget.endsWith('environment_readiness_view_spec.dart') ||
          importTarget.endsWith('navigation_constants.dart'))
        '$filePath imports $importTarget',
  ];

  if (uncommented.contains('panelsViewStateProvider') ||
      uncommented.contains('WindowPanel.') ||
      uncommented.contains('ViewSpec.environmentReadiness') ||
      uncommented.contains('EnvironmentReadinessSpec.')) {
    offenders.add('$filePath owns onboarding center-panel sync policy');
  }

  return offenders..sort();
}

Future<List<String>> _findOnboardingDevPanelActionBoundaryOffenders() async {
  const filePath =
      'lib/essentials/onboarding/presentation/onboarding_dev_panel.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final uncommented = _stripComments(await file.readAsString());
  final offenders = <String>[];
  if (uncommented.contains('onboardingGateProvider.notifier') ||
      uncommented.contains('onboardingDevOverridesProvider.notifier') ||
      uncommented.contains('onboardingReadinessActionsProvider.notifier') ||
      uncommented.contains('ref.invalidate(') ||
      uncommented.contains('widget.ref.invalidate(') ||
      uncommented.contains('refreshEnvironment()') ||
      uncommented.contains('resetDerivedData()')) {
    offenders.add('$filePath owns reset refresh details directly');
  }

  return offenders..sort();
}

Future<List<String>> _findOnboardingOverlayActionBoundaryOffenders() async {
  const filePath =
      'lib/essentials/onboarding/presentation/onboarding_overlay.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final uncommented = _stripComments(await file.readAsString());
  final offenders = <String>[];
  if (uncommented.contains('onboardingGateProvider.notifier')) {
    offenders.add('$filePath calls onboarding gate notifier directly');
  }

  return offenders..sort();
}

Future<List<String>>
_findEnvironmentReadinessPanelActionBoundaryOffenders() async {
  const filePath =
      'lib/features/environment_readiness/presentation/view/environment_readiness_panel_view.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final uncommented = _stripComments(await file.readAsString());
  final offenders = <String>[];
  if (uncommented.contains('onboardingGateProvider.notifier')) {
    offenders.add('$filePath calls onboarding gate notifier directly');
  }
  if (uncommented.contains('onboardingDevOverridesProvider.notifier')) {
    offenders.add('$filePath mutates onboarding dev overrides directly');
  }
  if (uncommented.contains('onboardingReadinessActionsProvider.notifier')) {
    offenders.add('$filePath bypasses environment readiness actions');
  }

  return offenders..sort();
}

Future<List<String>> _findPipelineIncidentPanelActionBoundaryOffenders() async {
  const filePath =
      'lib/features/environment_readiness/presentation/view/pipeline_incident_panel_view.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final uncommented = _stripComments(await file.readAsString());
  final offenders = <String>[];
  if (uncommented.contains('onboardingGateProvider.notifier')) {
    offenders.add('$filePath calls onboarding gate notifier directly');
  }
  if (uncommented.contains('pipelineIncidentTrackerProvider.notifier')) {
    offenders.add('$filePath mutates pipeline incident tracker directly');
  }

  return offenders..sort();
}

Future<List<String>>
_findContactDisplayNameOverrideActionStorageOffenders() async {
  const filePath =
      'lib/features/contacts/application/sidebar_cassette_spec/resolver_tools/contact_display_name_override_actions_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.endsWith('essentials/db/feature_level_providers.dart') ||
          importTarget.endsWith(
            'essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart',
          ) ||
          importTarget.endsWith(
            'overlay_contact_display_name_override_store.dart',
          ))
        '$filePath imports $importTarget',
  ];
  if (uncommented.contains('overlayDatabaseProvider') ||
      uncommented.contains('OverlayDatabase') ||
      uncommented.contains('OverlayContactDisplayNameOverrideStore')) {
    offenders.add('$filePath constructs overlay display-name storage directly');
  }
  return offenders..sort();
}

Future<List<String>> _findContactFavoriteInvalidationContractOffenders() async {
  const filePath =
      'lib/features/contacts/application/sidebar_cassette_spec/resolver_tools/contact_is_favorite_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  if (source.contains('caller must `ref.invalidate') ||
      source.contains('caller must ref.invalidate') ||
      source.contains('caller-owned invalidation')) {
    return <String>['$filePath documents caller-owned favourite invalidation'];
  }

  return const <String>[];
}

Future<List<String>> _findRetiredContactNameVariantOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
      return false;
    }
    return path.startsWith('lib/');
  });
  final retiredNameVariantPattern = RegExp(
    r'\b(shortName|short_name|nickname|nameMode|name_mode)\b',
  );
  final offenders = <String>{};

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source)
        .replaceAll(
          RegExp(
            r'''await\s+m\.dropColumn\(\s*participantOverrides\s*,\s*['"]nickname['"]\s*\)\s*;''',
          ),
          '',
        )
        .replaceAll(
          RegExp(
            r'''await\s+m\.dropColumn\(\s*participantOverrides\s*,\s*['"]name_mode['"]\s*\)\s*;''',
          ),
          '',
        )
        .replaceAll(
          RegExp(
            r'''await\s+m\.dropColumn\(\s*virtualParticipants\s*,\s*['"]short_name['"]\s*\)\s*;''',
          ),
          '',
        );
    if (retiredNameVariantPattern.hasMatch(uncommented)) {
      offenders.add(filePath);
    }
  }

  return offenders.toList()..sort();
}

Future<List<String>> _findFullDiskAccessBoundaryOffenders() async {
  const removedCheckerPath =
      'lib/essentials/onboarding/application/fda_checker.dart';
  const files = <String>{
    'lib/essentials/onboarding/application/onboarding_environment_report_provider.dart',
    'lib/essentials/onboarding/application/onboarding_gate_provider.dart',
    'lib/features/settings/application/historical_archives_workflow_panel_model_provider.dart',
  };
  final offenders = <String>[];

  if (File(removedCheckerPath).existsSync()) {
    offenders.add('$removedCheckerPath reintroduced direct FDA checker');
  }

  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) {
      continue;
    }

    final source = await file.readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    offenders.addAll([
      for (final importTarget in imports)
        if (importTarget == 'dart:io' ||
            importTarget.endsWith('application/fda_checker.dart'))
          '$filePath imports $importTarget',
    ]);

    if (uncommented.contains('Process.run(') ||
        RegExp(r'(^|[^\w.])File\(').hasMatch(uncommented) ||
        uncommented.contains('openSync(') ||
        uncommented.contains('Platform.environment')) {
      offenders.add('$filePath performs Full Disk Access probing directly');
    }
  }

  return offenders..sort();
}

Future<List<String>> _findMessageDataResetFileStoreBoundaryOffenders() async {
  const filePath =
      'lib/essentials/onboarding/application/message_data_reset_service.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget == 'dart:io') '$filePath imports $importTarget',
  ];

  if (RegExp(r'(^|[^\w.])File\(').hasMatch(uncommented) ||
      RegExp(r'(^|[^\w.])Directory\(').hasMatch(uncommented) ||
      uncommented.contains('existsSync(') ||
      uncommented.contains('.delete(')) {
    offenders.add('$filePath performs reset file access directly');
  }

  return offenders..sort();
}

Future<List<String>>
_findHistoricalArchiveFolderResolverBoundaryOffenders() async {
  const files = <String>{
    'lib/essentials/source_scoped_import/application/archives/historical_messages_archive_source_registrar.dart',
    'lib/essentials/conversation_graph/application/archives/source_scoped_archive_graph_removal_service.dart',
  };
  final offenders = <String>[];

  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) {
      continue;
    }

    final source = await file.readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    offenders.addAll([
      for (final importTarget in imports)
        if (importTarget == 'dart:io' ||
            importTarget == 'package:path/path.dart')
          '$filePath imports $importTarget',
    ]);

    if (uncommented.contains('File(') ||
        uncommented.contains('Directory(') ||
        uncommented.contains('FileSystemException') ||
        uncommented.contains('path.join(')) {
      offenders.add('$filePath performs archive folder resolution directly');
    }
  }

  return offenders..sort();
}

Future<List<String>> _findGraphStatusLoggingBoundaryOffenders() async {
  const applicationFilePath =
      'lib/essentials/conversation_graph/application/status/conversation_graph_status_log_writer.dart';
  const retiredProviderPath =
      'lib/essentials/conversation_graph/application/status/conversation_graph_status_log_writer_provider.dart';
  const presentationFilePath =
      'lib/essentials/conversation_graph/presentation/status/conversation_graph_status_sheet.dart';
  final offenders = <String>[];

  if (File(retiredProviderPath).existsSync()) {
    offenders.add(
      '$retiredProviderPath exists; provider composition belongs in feature_level_providers.dart',
    );
  }

  final applicationFile = File(applicationFilePath);
  if (applicationFile.existsSync()) {
    final source = await applicationFile.readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    offenders.addAll([
      for (final importTarget in imports)
        if (importTarget == 'dart:io' ||
            importTarget == 'package:path/path.dart')
          '$applicationFilePath imports $importTarget',
    ]);

    if (uncommented.contains('File(') ||
        uncommented.contains('Directory(') ||
        uncommented.contains('writeAsString(')) {
      offenders.add('$applicationFilePath writes status logs directly');
    }
  }

  final presentationFile = File(presentationFilePath);
  if (presentationFile.existsSync()) {
    final source = await presentationFile.readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    offenders.addAll([
      for (final importTarget in imports)
        if (importTarget.endsWith(
          'application/status/conversation_graph_status_log_writer.dart',
        ))
          '$presentationFilePath imports $importTarget',
    ]);

    if (uncommented.contains('ConversationGraphStatusLogWriter()') ||
        uncommented.contains('const ConversationGraphStatusLogWriter')) {
      offenders.add('$presentationFilePath constructs log writer directly');
    }
  }

  return offenders..sort();
}

Future<List<String>>
_findGraphStatusArchivedFileOpenerBoundaryOffenders() async {
  const applicationFilePath =
      'lib/essentials/conversation_graph/application/status/archived_attachment_file_opener.dart';
  const retiredProviderPath =
      'lib/essentials/conversation_graph/application/status/archived_attachment_file_opener_provider.dart';
  const presentationFilePath =
      'lib/essentials/conversation_graph/presentation/status/conversation_graph_status_sheet.dart';
  final offenders = <String>[];

  if (File(retiredProviderPath).existsSync()) {
    offenders.add(
      '$retiredProviderPath exists; provider composition belongs in feature_level_providers.dart',
    );
  }

  final applicationFile = File(applicationFilePath);
  if (applicationFile.existsSync()) {
    final source = await applicationFile.readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    offenders.addAll([
      for (final importTarget in imports)
        if (importTarget == 'package:url_launcher/url_launcher.dart' ||
            importTarget == 'dart:io')
          '$applicationFilePath imports $importTarget',
    ]);

    if (uncommented.contains('launchUrl(') ||
        uncommented.contains('LaunchMode.') ||
        uncommented.contains('Process.run(')) {
      offenders.add('$applicationFilePath opens archived files directly');
    }
  }

  final presentationFile = File(presentationFilePath);
  if (presentationFile.existsSync()) {
    final source = await presentationFile.readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    offenders.addAll([
      for (final importTarget in imports)
        if (importTarget == 'package:url_launcher/url_launcher.dart')
          '$presentationFilePath imports $importTarget',
    ]);

    if (uncommented.contains('launchUrl(') ||
        uncommented.contains('LaunchMode.') ||
        uncommented.contains('Uri.file(') ||
        uncommented.contains('Process.run(')) {
      offenders.add('$presentationFilePath opens archived files directly');
    }
  }

  return offenders..sort();
}

Future<List<String>> _findContactHeroOverlayDatabaseOffenders() async {
  const filePath =
      'lib/features/contacts/application/sidebar_cassette_spec/widget_builders/contact_hero_summary_widget.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final source = await file.readAsString();
  final uncommented = _stripComments(source);
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.endsWith('essentials/db/feature_level_providers.dart') ||
          importTarget.endsWith('favorite_contacts_repository_provider.dart') ||
          importTarget.endsWith('favorite_contacts_provider.dart') ||
          importTarget.endsWith('unified_picker_sections_provider.dart') ||
          importTarget.endsWith(
            'essentials/db/infrastructure/data_sources/local/overlay/overlay_database.dart',
          ))
        '$filePath imports $importTarget',
  ];
  if (uncommented.contains('overlayDatabaseProvider') ||
      uncommented.contains('setParticipantDisplayNameOverride') ||
      uncommented.contains('favoriteContactsRepositoryProvider') ||
      uncommented.contains('ref.invalidate(favoriteContactsProvider') ||
      uncommented.contains('ref.invalidate(unifiedPickerSectionsProvider')) {
    offenders.add('$filePath handles contact overlay action details directly');
  }
  return offenders..sort();
}

Future<List<String>> _findHandleFilterManualLinkBoundaryOffenders() async {
  const filePath =
      'lib/features/contacts/application/sidebar_cassette_spec/widget_builders/handle_filter_widget.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final uncommented = _stripComments(await file.readAsString());
  final offenders = <String>[];
  if (uncommented.contains('ref.invalidate(')) {
    offenders.add('$filePath invalidates provider reads after unlink');
  }

  return offenders..sort();
}

Future<List<String>> _findStrayHandleCassetteActionBoundaryOffenders() async {
  const filePaths = <String>[
    'lib/features/handles/application/sidebar_cassette_spec/widget_builders/stray_handles_review_cassette.dart',
    'lib/features/handles/application/sidebar_cassette_spec/widget_builders/stray_handles_mode_switcher_cassette.dart',
    'lib/features/handles/application/sidebar_cassette_spec/widget_builders/stray_handles_type_switcher_cassette.dart',
  ];
  const forbiddenTokens = <String>[
    'sidebarActionDispatcherProvider',
    'SidebarActionDispatcher',
    'SidebarActionIntent',
    'StrayHandleOpened',
    'StrayHandleDismissed',
    'StrayHandleRestored',
    'StrayHandleModeChanged',
    'StrayHandleFilterChanged',
    'normalizeHandleIdentifier',
  ];

  final offenders = <String>[];
  for (final filePath in filePaths) {
    final file = File(filePath);
    if (!file.existsSync()) {
      continue;
    }

    final uncommented = _stripComments(await file.readAsString());
    for (final token in forbiddenTokens) {
      if (uncommented.contains(token)) {
        offenders.add('$filePath uses $token');
      }
    }
  }

  return offenders..sort();
}

Future<List<String>>
_findRecoveredMessageSidebarNavigationBoundaryOffenders() async {
  const filePaths = <String>[
    'lib/features/messages/presentation/widgets/recovered_messages_heatmap_sidebar.dart',
    'lib/features/messages/application/sidebar_cassette_spec/widget_builders/recovered_no_handle_from_me_navigator_widget.dart',
  ];
  const forbiddenTokens = <String>[
    'sidebarActionDispatcherProvider',
    'SidebarActionDispatchContext',
    'RecoveredMonthFocused',
    'RecoveredNoHandleFromMeOpened',
  ];

  final offenders = <String>[];
  for (final filePath in filePaths) {
    final file = File(filePath);
    if (!file.existsSync()) {
      continue;
    }

    final uncommented = _stripComments(await file.readAsString());
    for (final token in forbiddenTokens) {
      if (uncommented.contains(token)) {
        offenders.add('$filePath uses $token');
      }
    }
  }

  return offenders..sort();
}

Future<List<String>> _findMessagePresentationPanelStateOffenders() async {
  final files = await _collectDartFiles((path) {
    return path.startsWith('lib/features/messages/presentation/') &&
        !path.endsWith('.g.dart') &&
        !path.endsWith('.freezed.dart');
  });
  final offenders = <String>[];

  for (final filePath in files) {
    final content = await File(filePath).readAsString();
    if (content.contains('panelsViewStateProvider') ||
        content.contains('WindowPanel.')) {
      offenders.add(filePath);
    }
  }

  return offenders..sort();
}

Future<List<String>> _findSidebarParkedOverlayPanelStateOffenders() async {
  const filePath =
      'lib/essentials/navigation/presentation/view/sidebar_parked_overlay.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final uncommented = _stripComments(await file.readAsString());
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.endsWith('panels_view_state_provider.dart') ||
          importTarget.endsWith('navigation_constants.dart'))
        '$filePath imports $importTarget',
  ];
  if (uncommented.contains('panelsViewStateProvider') ||
      uncommented.contains('WindowPanel.')) {
    offenders.add('$filePath mutates panel stack directly');
  }

  return offenders..sort();
}

Future<List<String>> _findPanelStackSurfaceActionBoundaryOffenders() async {
  const filePath =
      'lib/essentials/navigation/presentation/view/panel_stack_surface.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final uncommented = _stripComments(await file.readAsString());
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.endsWith('feature_level_providers.dart') &&
          importTarget.contains('logging'))
        '$filePath imports $importTarget',
  ];
  if (uncommented.contains('panelsViewStateProvider') ||
      uncommented.contains('appLoggerProvider.notifier') ||
      uncommented.contains('.activate(panel:') ||
      uncommented.contains('.closeAt(panel:')) {
    offenders.add('$filePath owns panel-stack action details directly');
  }

  return offenders..sort();
}

Future<List<String>> _findParkedCenterActionNamingOffenders() async {
  const files = <String>[
    'lib/essentials/navigation/application/panel_actions_provider.dart',
    'lib/essentials/navigation/presentation/view/sidebar_parked_overlay.dart',
  ];
  final offenders = <String>[];

  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) {
      continue;
    }

    final uncommented = _stripComments(await file.readAsString());
    if (uncommented.contains('clearCenterPanel')) {
      offenders.add('$filePath uses clearCenterPanel vocabulary');
    }
  }

  return offenders..sort();
}

Future<List<String>>
_findSidebarParkedOverlayOnboardingActionOffenders() async {
  const filePath =
      'lib/essentials/navigation/presentation/view/sidebar_parked_overlay.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final uncommented = _stripComments(await file.readAsString());
  final imports = _extractImports(uncommented);
  final offenders = <String>[
    for (final importTarget in imports)
      if (importTarget.endsWith('onboarding_gate_provider.dart'))
        '$filePath imports $importTarget',
  ];

  if (uncommented.contains('refreshEnvironment()')) {
    offenders.add('$filePath refreshes onboarding environment directly');
  }
  if (uncommented.contains('.clearAll()')) {
    offenders.add('$filePath clears onboarding simulation overrides directly');
  }

  return offenders..sort();
}

Future<List<String>> _findAppModeToggleActionBoundaryOffenders() async {
  const filePath =
      'lib/essentials/navigation/presentation/widgets/app_mode_toggle.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final uncommented = _stripComments(await file.readAsString());
  final offenders = <String>[];
  if (uncommented.contains('activeSidebarModeProvider.notifier')) {
    offenders.add('$filePath mutates active sidebar mode directly');
  }

  return offenders..sort();
}

Future<List<String>> _findMacosAppShellActionBoundaryOffenders() async {
  const filePath =
      'lib/essentials/navigation/presentation/view/macos_app_shell.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final uncommented = _stripComments(await file.readAsString());
  final offenders = <String>[];
  if (uncommented.contains('developerModeProvider.notifier')) {
    offenders.add('$filePath mutates developer mode directly');
  }
  if (uncommented.contains('switchableDarkModeProvider.notifier')) {
    offenders.add('$filePath mutates theme mode directly');
  }

  return offenders..sort();
}

Future<List<String>> _findSidebarUtilityTopMenuActionOffenders() async {
  const filePaths = <String>[
    'lib/features/sidebar_utilities/application/sidebar_cassette_spec/widget_builders/settings_top_menu_widget.dart',
    'lib/features/sidebar_utilities/application/sidebar_cassette_spec/widget_builders/top_chat_menu_widget.dart',
  ];
  final offenders = <String>[];
  const forbiddenTokens = <String>[
    'sidebarActionDispatcherProvider',
    'SidebarActionDispatchContext',
    'TopMenuChanged',
    '_mapTopMenuChoice',
  ];

  for (final filePath in filePaths) {
    final file = File(filePath);
    if (!file.existsSync()) {
      continue;
    }

    final uncommented = _stripComments(await file.readAsString());
    for (final token in forbiddenTokens) {
      if (uncommented.contains(token)) {
        offenders.add('$filePath uses $token');
      }
    }
  }

  return offenders..sort();
}

Future<List<String>> _findSettingsActionListActionOffenders() async {
  const filePath =
      'lib/features/settings/application/sidebar_cassette_spec/widget_builders/settings_action_list.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final uncommented = _stripComments(await file.readAsString());
  final offenders = <String>[];
  const forbiddenTokens = <String>[
    'sidebarActionDispatcherProvider',
    'SidebarActionDispatchContext',
    'SidebarMode.settings',
    '.dispatch(',
    '!action.isEnabled',
  ];

  for (final token in forbiddenTokens) {
    if (uncommented.contains(token)) {
      offenders.add('$filePath uses $token');
    }
  }

  return offenders..sort();
}

Future<List<String>> _findFeaturePresentationNavigationSpecOffenders() async {
  final files = await _collectDartFiles((path) {
    return path.startsWith('lib/features/') &&
        path.contains('/presentation/') &&
        !path.endsWith('.g.dart') &&
        !path.endsWith('.freezed.dart');
  });
  final offenders = <String>[];

  for (final filePath in files) {
    final content = await File(filePath).readAsString();
    if (content.contains('ViewSpec.') ||
        content.contains('MessagesSpec.') ||
        content.contains('WindowPanel.') ||
        content.contains('panelsViewStateProvider')) {
      offenders.add(filePath);
    }
  }

  return offenders..sort();
}

Future<List<String>> _findStaleSidebarWidgetContractOffenders() async {
  final files = await _collectDartFiles((path) {
    return path.startsWith('lib/features/') &&
        path.contains('/sidebar_cassette_spec/widget_builders/') &&
        !path.endsWith('.g.dart') &&
        !path.endsWith('.freezed.dart');
  });
  final offenders = <String>[];

  for (final filePath in files) {
    final content = await File(filePath).readAsString();
    if (content.contains('Construct specs only on user interaction') ||
        content.contains('narrows the center panel') ||
        content.contains('dispatches [MessagesSpec')) {
      offenders.add(filePath);
    }
  }

  return offenders..sort();
}

Future<List<String>> _findSidebarWidgetInvalidationOffenders() async {
  final files = await _collectDartFiles((path) {
    return path.startsWith('lib/features/') &&
        path.contains('/sidebar_cassette_spec/widget_builders/') &&
        !path.endsWith('.g.dart') &&
        !path.endsWith('.freezed.dart');
  });
  final offenders = <String>[];

  for (final filePath in files) {
    final uncommented = _stripComments(await File(filePath).readAsString());
    if (uncommented.contains('ref.invalidate(') ||
        uncommented.contains('widget.ref.invalidate(')) {
      offenders.add(filePath);
    }
  }

  return offenders..sort();
}

Future<List<String>> _findSidebarBodyModelRendererActionOffenders() async {
  const filePath =
      'lib/essentials/sidebar/presentation/view/sidebar_body_model_content.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final uncommented = _stripComments(await file.readAsString());
  final offenders = <String>[];
  const forbiddenTokens = <String>[
    'sidebarActionDispatcherProvider',
    'SidebarActionDispatchContext',
    '.dispatch(',
    'option.isDisabled',
  ];

  for (final token in forbiddenTokens) {
    if (uncommented.contains(token)) {
      offenders.add('$filePath uses $token');
    }
  }

  return offenders..sort();
}

Future<List<String>> _findGroupedContactSelectorRefreshOffenders() async {
  const filePath =
      'lib/features/contacts/presentation/widgets/grouped_contact_selector.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final uncommented = _stripComments(await file.readAsString());
  final offenders = <String>[];
  if (uncommented.contains('ref.invalidate(') ||
      uncommented.contains('widget.ref.invalidate(')) {
    offenders.add('$filePath owns picker refresh invalidation directly');
  }

  return offenders..sort();
}

Future<List<String>> _findChatsViewModelFlowMutationOffenders() async {
  const filePath =
      'lib/features/chats/presentation/view_model/chats_view_model_provider.dart';
  final file = File(filePath);
  if (!file.existsSync()) {
    return const <String>[];
  }

  final uncommented = _stripComments(await file.readAsString());
  final offenders = <String>[];
  final imports = _extractImports(uncommented);
  for (final importTarget in imports) {
    if (importTarget.contains('/conversation_graph/application/')) {
      offenders.add('$filePath imports $importTarget');
    }
  }
  if (uncommented.contains('sidebarFlowProvider')) {
    offenders.add('$filePath imports or mutates sidebarFlowProvider');
  }
  const forbiddenTokens = <String>[
    'sidebarActionDispatcherProvider',
    'SidebarActionDispatchContext',
    'ConversationSelected',
  ];

  for (final token in forbiddenTokens) {
    if (uncommented.contains(token)) {
      offenders.add('$filePath uses $token');
    }
  }

  return offenders..sort();
}

Future<List<String>>
_findContactPresentationContactsListRepositoryOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
      return false;
    }
    return path.startsWith('lib/features/contacts/application/') ||
        path.startsWith('lib/features/contacts/presentation/');
  });
  final offenders = <String>[];

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    final imports = _extractImports(uncommented);
    offenders.addAll([
      for (final importTarget in imports)
        if (importTarget.endsWith('contacts_list_repository.dart') ||
            importTarget.endsWith('contact_profile_provider.dart') ||
            importTarget.endsWith('handles_for_contact_provider.dart') ||
            importTarget.endsWith('recent_contacts_repository.dart') ||
            importTarget.endsWith('virtual_participants_provider.dart'))
          '$filePath imports $importTarget',
    ]);
  }

  return offenders..sort();
}

Future<List<String>> _collectSidebarSemanticLayerFiles() async {
  return _collectDartFiles((path) {
    if (path.endsWith('.g.dart')) {
      return false;
    }

    final isSidebarApplicationArea =
        path.contains('/application/sidebar_cassette_spec/') ||
        path.contains('/application/settings_cassette_spec/') ||
        path.contains('/application/info_cassette_spec/');
    final isSemanticSubfolder =
        path.contains('/resolvers/') ||
        path.contains('/coordinators/') ||
        path.contains('/resolver_tools/');

    return isSidebarApplicationArea && isSemanticSubfolder;
  });
}

Future<List<String>> _findFrameworkThemeLookupOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
      return false;
    }
    return true;
  });
  final offenders = <String>[];

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    if (uncommented.contains('Theme.of(') ||
        uncommented.contains('MacosTheme.of(') ||
        uncommented.contains('CupertinoTheme.of(')) {
      offenders.add(filePath);
    }
  }

  return offenders..sort();
}

Future<List<String>> _findManualProviderDeclarationOffenders() async {
  final files = await _collectDartFiles((path) {
    return path.startsWith('lib/') && !path.endsWith('.g.dart');
  });
  final manualProviderPattern = RegExp(
    r'\b(?:StateNotifierProvider|FutureProvider|StreamProvider|ChangeNotifierProvider|Provider)\s*(?:<|\()',
  );

  return [
    for (final filePath in files)
      if (manualProviderPattern.hasMatch(
        _stripComments(await File(filePath).readAsString()),
      ))
        filePath,
  ]..sort();
}

Future<List<String>> _findAllCommentLibDartFiles() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
      return false;
    }
    return path.startsWith('lib/');
  });
  final offenders = <String>[];

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source).trim();
    if (uncommented.isEmpty) {
      offenders.add(filePath);
    }
  }

  return offenders..sort();
}

Future<List<String>> _findActiveTodoFixmeOffenders() async {
  final files = await _collectProjectDartFiles((path) {
    if (path.endsWith('.g.dart') ||
        path.endsWith('.freezed.dart') ||
        path == 'lib/frb_generated.dart') {
      return false;
    }
    return path.startsWith('lib/') || path.startsWith('test/');
  });
  final markerPattern = RegExp(r'\b(?:TODO|FIXME)\b');
  final offenders = <String>[];

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    if (markerPattern.hasMatch(uncommented)) {
      offenders.add(filePath);
    }
  }

  return offenders..sort();
}

Future<List<String>> _findRawStringThrowOffenders() async {
  final files = await _collectProjectDartFiles((path) {
    if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
      return false;
    }
    return path.startsWith('lib/') || path.startsWith('test/');
  });
  final rawStringThrowPattern = RegExp(r'''throw\s+['"]''');
  final offenders = <String>[];

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    if (rawStringThrowPattern.hasMatch(uncommented)) {
      offenders.add(filePath);
    }
  }

  return offenders..sort();
}

Future<List<String>> _findGenericExceptionThrowOffenders() async {
  final files = await _collectProjectDartFiles((path) {
    if (path.endsWith('.g.dart') ||
        path.endsWith('.freezed.dart') ||
        path == 'lib/frb_generated.dart') {
      return false;
    }
    return path.startsWith('lib/') || path.startsWith('test/');
  });
  final genericExceptionThrowPattern = RegExp(r'\bthrow\s+Exception\(');
  final offenders = <String>[];

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    if (genericExceptionThrowPattern.hasMatch(uncommented)) {
      offenders.add(filePath);
    }
  }

  return offenders..sort();
}

Future<List<String>> _findLibUnimplementedErrorOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart') ||
        path.endsWith('.freezed.dart') ||
        path == 'lib/frb_generated.dart') {
      return false;
    }
    return path.startsWith('lib/');
  });
  final unimplementedErrorPattern = RegExp(r'\bUnimplementedError\(');
  final offenders = <String>[];

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    if (unimplementedErrorPattern.hasMatch(uncommented)) {
      offenders.add(filePath);
    }
  }

  return offenders..sort();
}

Future<List<String>> _findRawPrintOffenders() async {
  final files = await _collectDartFiles((path) {
    if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
      return false;
    }
    return path.startsWith('lib/');
  });
  final rawPrintPattern = RegExp(r'\bprint\(');
  final offenders = <String>[];

  for (final filePath in files) {
    final source = await File(filePath).readAsString();
    final uncommented = _stripComments(source);
    if (rawPrintPattern.hasMatch(uncommented)) {
      offenders.add(filePath);
    }
  }

  return offenders..sort();
}

Future<List<String>> _collectSidebarPayloadFiles() async {
  return _collectDartFiles((path) {
    if (path.endsWith('.g.dart')) {
      return false;
    }

    return path ==
            'lib/essentials/sidebar/presentation/view_model/sidebar_cassette_card_view_model.dart' ||
        path.contains('/application/') && path.contains('/payloads/');
  });
}

Future<List<String>> _collectDartFiles(
  bool Function(String path) include,
) async {
  final libDir = Directory('lib');
  final files = <String>[];

  await for (final entity in libDir.list(recursive: true, followLinks: false)) {
    if (entity is! File) {
      continue;
    }

    final normalizedPath = entity.path.replaceAll(r'\', '/');
    if (!normalizedPath.endsWith('.dart')) {
      continue;
    }

    if (include(normalizedPath)) {
      files.add(normalizedPath);
    }
  }

  files.sort();
  return files;
}

Future<List<String>> _collectProjectDartFiles(
  bool Function(String path) include,
) async {
  final roots = <Directory>[Directory('lib'), Directory('test')];
  final files = <String>[];

  for (final root in roots) {
    if (!root.existsSync()) {
      continue;
    }

    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is! File) {
        continue;
      }

      final normalizedPath = entity.path.replaceAll(r'\', '/');
      if (!normalizedPath.endsWith('.dart')) {
        continue;
      }

      if (include(normalizedPath)) {
        files.add(normalizedPath);
      }
    }
  }

  files.sort();
  return files;
}

Iterable<String> _extractImports(String source) sync* {
  final importPattern = RegExp(
    r'''^import\s+['\"]([^'\"]+)['\"];''',
    multiLine: true,
  );

  for (final match in importPattern.allMatches(source)) {
    final importTarget = match.group(1);
    if (importTarget != null) {
      yield importTarget;
    }
  }
}

String _stripComments(String source) {
  final withoutBlockComments = source.replaceAll(
    RegExp(r'/\*[\s\S]*?\*/', multiLine: true),
    '',
  );

  return withoutBlockComments.replaceAll(RegExp(r'//.*$', multiLine: true), '');
}
