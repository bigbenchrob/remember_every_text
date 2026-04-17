import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import 'support_bundle_export_service.dart';

const _defaultDiagnosticRecipientEmail = 'bigbenchrob@gmail.com';
const _defaultAttachedEmailBodyLines = <String>[
  'MessageLens attached the support bundle to this draft.',
  '',
  'Describe the issue here:',
];
const _defaultManualAttachmentEmailBodyLines = <String>[
  'MessageLens prepared a support bundle but could not attach it automatically.',
  'It has been revealed in Finder so it can be attached manually.',
  '',
  'Describe the issue here:',
];

class DiagnosticReportPresentationResult {
  const DiagnosticReportPresentationResult({
    required this.exportPath,
    required this.attachedToMailDraft,
  });

  final String? exportPath;
  final bool attachedToMailDraft;
}

/// Collects log files, prepends a system info header, and presents the
/// exported log to the user via email (mailto:) and Finder reveal.
class LogExportService {
  final SupportBundleExportService _supportBundleExportService;

  LogExportService(this._supportBundleExportService);

  /// Export logs, open email client, and reveal file in Finder.
  ///
  /// Returns the exported report path and whether it was attached to an Apple
  /// Mail draft automatically.
  Future<DiagnosticReportPresentationResult> exportAndPresent({
    String recipientEmail = _defaultDiagnosticRecipientEmail,
    String subjectPrefix = 'MessageLens Diagnostic Report',
    List<String> attachedEmailBodyLines = _defaultAttachedEmailBodyLines,
    List<String> manualAttachmentEmailBodyLines =
        _defaultManualAttachmentEmailBodyLines,
    List<String> headerLines = const <String>[],
  }) async {
    try {
      final bundle = await _supportBundleExportService.export(
        headerLines: headerLines,
      );
      final exportPath = bundle.bundleDirectory.path;
      final subject =
          '$subjectPrefix - ${bundle.bundleDirectory.uri.pathSegments.last}';
      final mailAttachmentArchive = await createSupportBundleMailArchive(
        bundle.bundleDirectory,
      );
      final attachedToMailDraft = mailAttachmentArchive == null
          ? false
          : await _tryComposeAppleMailDraft(
              attachmentFiles: [mailAttachmentArchive],
              recipientEmail: recipientEmail,
              subject: subject,
              emailBodyLines: attachedEmailBodyLines,
            );

      if (attachedToMailDraft) {
        return DiagnosticReportPresentationResult(
          exportPath: exportPath,
          attachedToMailDraft: true,
        );
      }

      // Fallback: open the default email client and reveal the report in Finder
      // so it can be attached manually.
      final mailto = Uri(
        scheme: 'mailto',
        path: recipientEmail,
        queryParameters: {
          'subject': subject,
          'body': manualAttachmentEmailBodyLines.join('\n'),
        },
      );
      await launchUrl(mailto);

      // Reveal the exported bundle in Finder.
      await Process.run('open', ['-R', exportPath]);

      return DiagnosticReportPresentationResult(
        exportPath: exportPath,
        attachedToMailDraft: false,
      );
    } catch (e) {
      debugPrint('LogExportService: export failed: $e');
      return const DiagnosticReportPresentationResult(
        exportPath: null,
        attachedToMailDraft: false,
      );
    }
  }

  Future<bool> _tryComposeAppleMailDraft({
    required List<File> attachmentFiles,
    required String recipientEmail,
    required String subject,
    required List<String> emailBodyLines,
  }) async {
    if (!Platform.isMacOS) {
      return false;
    }

    try {
      final result = await Process.run(
        'osascript',
        buildAppleMailComposeScriptArgs(
          attachmentFilePaths: attachmentFiles
              .map((file) => file.path)
              .toList(),
          recipientEmail: recipientEmail,
          subject: subject,
          bodyText: emailBodyLines.join(' '),
        ),
      );

      if (result.exitCode == 0) {
        return true;
      }

      debugPrint(
        'LogExportService: Apple Mail compose failed: ${result.stderr}',
      );
      return false;
    } catch (e) {
      debugPrint('LogExportService: Apple Mail compose threw: $e');
      return false;
    }
  }
}

Future<File?> createSupportBundleMailArchive(Directory bundleDirectory) async {
  if (!Platform.isMacOS) {
    return null;
  }

  final bundleName = bundleDirectory.uri.pathSegments
      .where((segment) => segment.isNotEmpty)
      .last;
  final archiveFile = File('${bundleDirectory.parent.path}/$bundleName.zip');

  try {
    if (archiveFile.existsSync()) {
      await archiveFile.delete();
    }

    final result = await Process.run('/usr/bin/ditto', [
      '-c',
      '-k',
      '--sequesterRsrc',
      '--keepParent',
      bundleDirectory.path,
      archiveFile.path,
    ]);

    if (result.exitCode != 0 || !archiveFile.existsSync()) {
      debugPrint(
        'LogExportService: support bundle archive failed: ${result.stderr}',
      );
      return null;
    }

    return archiveFile;
  } catch (error) {
    debugPrint('LogExportService: support bundle archive threw: $error');
    return null;
  }
}

List<String> buildAppleMailComposeScriptArgs({
  required List<String> attachmentFilePaths,
  required String recipientEmail,
  required String subject,
  required String bodyText,
}) {
  final recipient = _toAppleScriptString(recipientEmail);
  final escapedSubject = _toAppleScriptString(subject);
  final escapedBody = _toAppleScriptString(bodyText);
  final attachmentStatements = <String>[
    for (var index = 0; index < attachmentFilePaths.length; index++)
      'set attachmentFile${index + 1} to POSIX file "${_toAppleScriptString(attachmentFilePaths[index])}"',
  ];
  final attachmentAddStatements = <String>[
    for (var index = 0; index < attachmentFilePaths.length; index++)
      'make new attachment with properties {file name:attachmentFile${index + 1}} at after the last paragraph',
  ];

  return [
    for (final statement in attachmentStatements) ...['-e', statement],
    '-e',
    'tell application "Mail"',
    '-e',
    'set newMessage to make new outgoing message with properties {subject:"$escapedSubject", content:"$escapedBody", visible:true}',
    '-e',
    'tell newMessage',
    '-e',
    'make new to recipient at end of to recipients with properties {address:"$recipient"}',
    for (final statement in attachmentAddStatements) ...['-e', statement],
    '-e',
    'end tell',
    '-e',
    'activate',
    '-e',
    'end tell',
  ];
}

String _toAppleScriptString(String value) {
  return value.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
}
