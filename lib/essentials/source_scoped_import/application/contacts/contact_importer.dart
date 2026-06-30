import '../../../../core/util/date_converter.dart';
import '../../../db/shared/handle_identifier_utils.dart';
import '../../domain/known_sources.dart';
import '../../domain/ports/import_ledger_port.dart';
import '../../domain/ports/source_database_port.dart';
import '../../domain/source_scoped_row_key.dart';

class ContactImportResult {
  const ContactImportResult({
    required this.examinedContactCount,
    required this.insertedContactCount,
    required this.insertedChannelCount,
  });

  final int examinedContactCount;
  final int insertedContactCount;
  final int insertedChannelCount;
}

class ContactImporter {
  const ContactImporter({
    required this.addressBookDbPath,
    required this.importLedger,
    required this.sourceDatabaseOpener,
    this.sourceId = liveAddressBookSourceId,
  });

  final String addressBookDbPath;
  final ImportLedger importLedger;
  final SourceDatabaseOpener sourceDatabaseOpener;
  final int sourceId;

  Future<ContactImportResult> importContacts() async {
    final sourceDb = await sourceDatabaseOpener.openReadOnly(addressBookDbPath);
    final batchId = await importLedger.insertImportBatch(
      sourceId: sourceId,
      startedAtUtc: DateTime.now().toUtc().toIso8601String(),
    );

    try {
      final contactRows = await sourceDb.query(
        'ZABCDRECORD',
        orderBy: 'Z_PK ASC',
      );
      final emailRows = await sourceDb.query(
        'ZABCDEMAILADDRESS',
        orderBy: 'ZOWNER ASC, ZADDRESS ASC',
      );
      final phoneRows = await sourceDb.query(
        'ZABCDPHONENUMBER',
        orderBy: 'ZOWNER ASC, ZFULLNUMBER ASC',
      );

      var insertedContactCount = 0;
      var insertedChannelCount = 0;
      await importLedger.writeTransaction((txn) async {
        final validContactRowIds = <int>{};
        for (final row in contactRows) {
          final sourceRowId = _readNullableInt(row['Z_PK']);
          if (sourceRowId == null) {
            continue;
          }
          validContactRowIds.add(sourceRowId);

          final first = _trim(row['ZFIRSTNAME']);
          final middle = _trim(row['ZMIDDLENAME']);
          final last = _trim(row['ZLASTNAME']);
          final organization = _trim(row['ZORGANIZATION']);
          final insertedId = await txn
              .insertIgnore('contacts', <String, Object?>{
                'ss_id': SourceScopedRowKey.pack(
                  sourceId: sourceId,
                  sourceRowId: sourceRowId,
                ),
                'source_id': sourceId,
                'source_rowid': sourceRowId,
                'display_name': _buildContactDisplayName(
                  firstName: first,
                  middleName: middle,
                  lastName: last,
                  organization: organization,
                ),
                'first_name': first,
                'last_name': last,
                'organization': organization,
                'created_at_utc': DateConverter.appleToIsoString(
                  row['ZCREATIONDATE'],
                ),
                'batch_id': batchId,
              });
          if (insertedId != 0) {
            insertedContactCount += 1;
          }
        }

        for (final row in emailRows) {
          final owner = _readNullableInt(row['ZOWNER']);
          final address =
              _trim(row['ZADDRESS']) ?? _trim(row['ZADDRESSNORMALIZED']);
          if (owner == null ||
              !validContactRowIds.contains(owner) ||
              address == null) {
            continue;
          }
          final insertedId = await _insertChannel(
            txn,
            sourceContactRowId: owner,
            kind: 'email',
            value: address.toLowerCase(),
            label: _trim(row['ZLABEL']),
            batchId: batchId,
          );
          if (insertedId != 0) {
            insertedChannelCount += 1;
          }
        }

        for (final row in phoneRows) {
          final owner = _readNullableInt(row['ZOWNER']);
          final rawNumber = _trim(row['ZFULLNUMBER']) ?? _trim(row['ZVALUE']);
          if (owner == null ||
              !validContactRowIds.contains(owner) ||
              rawNumber == null) {
            continue;
          }
          final insertedId = await _insertChannel(
            txn,
            sourceContactRowId: owner,
            kind: 'phone',
            value: normalizeHandleIdentifier(rawNumber) ?? rawNumber,
            label: _trim(row['ZLABEL']),
            batchId: batchId,
          );
          if (insertedId != 0) {
            insertedChannelCount += 1;
          }
        }
      });

      return ContactImportResult(
        examinedContactCount: contactRows.length,
        insertedContactCount: insertedContactCount,
        insertedChannelCount: insertedChannelCount,
      );
    } finally {
      await sourceDb.close();
    }
  }

  Future<int> _insertChannel(
    ImportLedgerWriteTransaction txn, {
    required int sourceContactRowId,
    required String kind,
    required String value,
    required int batchId,
    String? label,
  }) {
    return txn.insertIgnore('contact_channels', <String, Object?>{
      'source_id': sourceId,
      'source_contact_rowid': sourceContactRowId,
      'contact_ss_id': SourceScopedRowKey.pack(
        sourceId: sourceId,
        sourceRowId: sourceContactRowId,
      ),
      'kind': kind,
      'value': value,
      'label': label,
      'batch_id': batchId,
    });
  }
}

int? _readNullableInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.round();
  }
  return null;
}

String? _trim(Object? value) {
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
  return null;
}

String _buildContactDisplayName({
  String? firstName,
  String? middleName,
  String? lastName,
  String? organization,
}) {
  final parts = <String>[
    if (firstName != null) firstName,
    if (middleName != null) middleName,
    if (lastName != null) lastName,
  ];

  if (parts.isNotEmpty) {
    return parts.join(' ');
  }
  if (organization != null) {
    return organization;
  }
  return 'Unknown Contact';
}
