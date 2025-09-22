# Quick Facts for AI Agents

## Critical Project Structure
- **Drift DB module**: `lib/essentials/databases/infrastructure/data_sources/local/working/`
- **Import DB (SQLite)**: `lib/essentials/import/infrastructure/persistence/`
- **Main features**: `lib/features/` (contacts, chats, emails, etc.)
- **Core essentials**: `lib/essentials/` (navigation, import, window state)

## Common Code Generation & Commands
```bash
# Regenerate code after model changes
dart run build_runner build --delete-conflicting-outputs

# Test commands
dart test --plain-name "<pattern>"        # Pure Dart tests
flutter test --plain-name "<pattern>"     # Flutter widget tests

# Run app
flutter run -d macos
```

## Flutter/Dart Code Standards - ALWAYS FOLLOW

### Required Import Pattern
- **NEVER use**: `import 'package:flutter_riverpod/flutter_riverpod.dart'`
- **ALWAYS use**: `import 'package:hooks_riverpod/hooks_riverpod.dart'`

### Deprecated Flutter Methods - ALWAYS REPLACE
```dart
// OLD (deprecated) - causes warnings
Colors.red.withOpacity(0.5)

// NEW (required)
Colors.red.withValues(alpha: 0.5)
```

### Control Flow Formatting - ALWAYS FOLLOW
```dart
// WRONG - violates always_put_control_body_on_new_line
if (condition) return;
if (condition) doSomething();

// CORRECT - required format
if (condition) {
  return;
}
if (condition) {
  doSomething();
}
```

### Widget Optimization - ALWAYS FOLLOW
```dart
// WRONG - inefficient
Container(color: Colors.red, child: widget)

// CORRECT - performance optimized
ColoredBox(color: Colors.red, child: widget)

// WRONG - missing const
Widget(child: Text('Hello'))

// CORRECT - const constructors
const Widget(child: Text('Hello'))
```

### Async Functions - ALWAYS CORRECT
```dart
// WRONG - linting error
void myFunction() async { ... }

// CORRECT - proper return type
Future<void> myFunction() async { ... }
```

### String Interpolation - Avoid Unnecessary Braces
Use `$identifier` for simple variables. Only use `${...}` for expressions, method calls, or property access.

```dart
// WRONG - triggers unnecessary_brace_in_string_interpolation
final msg = 'Total messages: ${totalMessages}';

// CORRECT - simple identifier needs no braces
final msg = 'Total messages: $totalMessages';

// Braces are REQUIRED for expressions/property access
final info = 'User: ${user.name}';
final next = 'Next: ${count + 1}';
final safe = 'Trimmed: ${value?.trim() ?? 'N/A'}';
```

## Linting Rules - ENFORCE IMMEDIATELY
- `always_put_control_body_on_new_line` - No single-line if/for/while statements
- `prefer_const_constructors` - Use const wherever possible
- `use_colored_box` - Use ColoredBox instead of Container with only color
- `avoid_void_async` - Async functions must return Future<void>
- `directives_ordering` - Sort imports alphabetically
- `unnecessary_brace_in_string_interpolation` - Do not wrap simple identifiers with `${...}`

## Testing Strategy
- Widget tests → `flutter test`
- Pure Dart logic → `dart test`
- Integration tests → `flutter test integration_test/`

## Pre-Commit Checklist
- [ ] Run `dart run build_runner build -d` if models changed
- [ ] Fix all linting violations immediately
- [ ] Use correct import packages (hooks_riverpod, not flutter_riverpod)
- [ ] Replace all deprecated methods (withOpacity → withValues)
- [ ] Ensure all control structures use proper bracing
- [ ] Add const to constructors where possible
