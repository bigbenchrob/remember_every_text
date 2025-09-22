# Dart Lints and Patterns

## unnecessary_brace_in_string_interpolation

Prefer `$identifier` for simple variables, and reserve `${...}` for expressions, property access, or method calls.

Examples:
```dart
// Don’t
final s1 = 'Count: ${count}';

// Do
final s2 = 'Count: $count';

// Braces are needed for expressions / access
final s3 = 'Next: ${count + 1}';
final s4 = 'Name: ${user.name}';
```

Why: Removes visual noise and satisfies the linter rule `unnecessary_brace_in_string_interpolation`.

Reference: https://dart.dev/tools/linter-rules/unnecessary_brace_in_string_interpolation

