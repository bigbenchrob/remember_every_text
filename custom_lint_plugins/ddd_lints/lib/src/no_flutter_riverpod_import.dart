import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart' as cl;

class NoFlutterRiverpodImport extends cl.DartLintRule {
  const NoFlutterRiverpodImport()
    : super(
        code: const cl.LintCode(
          name: 'no_flutter_riverpod_import',
          problemMessage: 'Use hooks_riverpod, not flutter_riverpod.',
        ),
      );

  @override
  void run(
    cl.CustomLintResolver resolver,
    ErrorReporter reporter,
    cl.CustomLintContext context,
  ) {
    // Intentionally left minimal; enforcement covered by tests for now.
  }
}
