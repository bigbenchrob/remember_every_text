import 'package:custom_lint_builder/custom_lint_builder.dart' as cl;

import 'src/no_flutter_riverpod_import.dart';
import 'src/no_with_opacity_rule.dart';

cl.PluginBase createPlugin() => _DddLints();

class _DddLints extends cl.PluginBase {
  @override
  List<cl.LintRule> getLintRules(cl.CustomLintConfigs _) {
    return <cl.LintRule>[
      const NoFlutterRiverpodImport(),
      const NoWithOpacityRule(),
    ];
  }
}
