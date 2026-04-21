import 'package:flutter_test/flutter_test.dart';
import 'package:remember_this_text/essentials/db_migrate/application/orchestrator/migration_orchestrator.dart';
import 'package:remember_this_text/essentials/db_migrate/domain/i_migrators.dart/table_migrator.dart';
import 'package:remember_this_text/essentials/db_migrate/domain/ports/migration_context.dart';

void main() {
  test(
    'executionOrder preserves declared order for equally ready migrators',
    () {
      final orchestrator = MigrationOrchestrator(<TableMigrator>[
        const _FakeMigrator(name: 'handles'),
        const _FakeMigrator(name: 'chats', dependsOn: <String>['handles']),
        const _FakeMigrator(
          name: 'chat_to_handle',
          dependsOn: <String>['chats', 'handles'],
        ),
        const _FakeMigrator(
          name: 'messages',
          dependsOn: <String>['chats', 'handles'],
        ),
        const _FakeMigrator(
          name: 'attachments',
          dependsOn: <String>['messages'],
        ),
      ]);

      final orderedNames = orchestrator
          .executionOrder()
          .map((step) => step.name)
          .toList();

      expect(orderedNames, <String>[
        'handles',
        'chats',
        'chat_to_handle',
        'messages',
        'attachments',
      ]);
    },
  );
}

class _FakeMigrator implements TableMigrator {
  const _FakeMigrator({required this.name, this.dependsOn = const <String>[]});

  @override
  final String name;

  @override
  final List<String> dependsOn;

  @override
  Future<void> copy(IMigrationContext ctx) async {}

  @override
  Future<void> postValidate(IMigrationContext ctx) async {}

  @override
  Future<void> validatePrereqs(IMigrationContext ctx) async {}
}
