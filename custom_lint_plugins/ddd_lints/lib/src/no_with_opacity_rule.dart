import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart' as cl;

class NoWithOpacityRule extends cl.DartLintRule {
  const NoWithOpacityRule()
    : super(
        code: const cl.LintCode(
          name: 'no_with_opacity',
          problemMessage: 'Use withValues(alpha:) instead of withOpacity().',
        ),
      );

  @override
  void run(
    cl.CustomLintResolver resolver,
    ErrorReporter reporter,
    cl.CustomLintContext context,
  ) {
    // Rule disabled in plugin; enforced via tests under test/architecture.
  }
}
