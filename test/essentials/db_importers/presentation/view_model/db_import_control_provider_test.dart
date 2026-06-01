import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remember_this_text/essentials/db_importers/presentation/view_model/db_import_control_provider.dart';
import 'package:remember_this_text/essentials/onboarding/application/message_data_reset_service.dart';

void main() {
  group('DbImportControlViewModel resetAllDatabases', () {
    test('delegates broad reset to MessageDataResetService', () async {
      final resetService = _FakeMessageDataResetService();
      final container = ProviderContainer(
        overrides: [
          messageDataResetServiceProvider.overrideWith((ref) => resetService),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(dbImportControlViewModelProvider.notifier)
          .resetAllDatabases();

      expect(resetService.resetCallCount, 1);
      final state = container.read(dbImportControlViewModelProvider);
      expect(state.isProcessing, isFalse);
      expect(
        state.statusMessage,
        'Databases reset. Import and graph databases deleted (overlay preserved).',
      );
    });

    test('reports reset service failures through status state', () async {
      final resetService = _FakeMessageDataResetService(
        resetError: StateError('boom'),
      );
      final container = ProviderContainer(
        overrides: [
          messageDataResetServiceProvider.overrideWith((ref) => resetService),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(dbImportControlViewModelProvider.notifier)
          .resetAllDatabases();

      expect(resetService.resetCallCount, 1);
      final state = container.read(dbImportControlViewModelProvider);
      expect(state.isProcessing, isFalse);
      expect(state.statusMessage, contains('Reset failed'));
      expect(state.statusMessage, contains('boom'));
    });
  });

  group('DbImportControlViewModel clearImportDatabase', () {
    test('delegates import-ledger clear to MessageDataResetService', () async {
      final resetService = _FakeMessageDataResetService();
      final container = ProviderContainer(
        overrides: [
          messageDataResetServiceProvider.overrideWith((ref) => resetService),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(dbImportControlViewModelProvider.notifier)
          .clearImportDatabase();

      expect(resetService.clearImportLedgersCallCount, 1);
      final state = container.read(dbImportControlViewModelProvider);
      expect(state.isProcessing, isFalse);
      expect(
        state.statusMessage,
        'Import ledgers deleted and will be recreated on demand. Run Import again to repopulate them.',
      );
    });

    test('reports import-ledger clear failures through status state', () async {
      final resetService = _FakeMessageDataResetService(
        clearImportLedgersError: StateError('ledger boom'),
      );
      final container = ProviderContainer(
        overrides: [
          messageDataResetServiceProvider.overrideWith((ref) => resetService),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(dbImportControlViewModelProvider.notifier)
          .clearImportDatabase();

      expect(resetService.clearImportLedgersCallCount, 1);
      final state = container.read(dbImportControlViewModelProvider);
      expect(state.isProcessing, isFalse);
      expect(state.statusMessage, contains('Failed to clear import database'));
      expect(state.statusMessage, contains('ledger boom'));
    });
  });
}

final class _FakeMessageDataResetService implements MessageDataResetService {
  _FakeMessageDataResetService({this.resetError, this.clearImportLedgersError});

  final Object? resetError;
  final Object? clearImportLedgersError;
  int resetCallCount = 0;
  int clearImportLedgersCallCount = 0;

  @override
  Future<void> resetDerivedData() async {
    resetCallCount += 1;
    final error = resetError;
    if (error != null) {
      throw error;
    }
  }

  @override
  Future<void> clearImportLedgers() async {
    clearImportLedgersCallCount += 1;
    final error = clearImportLedgersError;
    if (error != null) {
      throw error;
    }
  }

  @override
  Future<void> confirmResetAndPrepareReimport() async {}
}
