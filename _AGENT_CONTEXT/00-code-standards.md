# Quick Facts for AI Agents

## 🚨 MOST COMMON AGENT MISTAKE: Single-Line Control Flow

**WARNING**: Agents repeatedly generate single-line if statements that violate `always_put_control_body_on_new_line`. This is the #1 cause of linting failures.

```dart
// ❌ AGENTS ALWAYS GENERATE THESE VIOLATIONS:
if (id == null) continue;
if (text.isEmpty) return '';
if (!condition) break;

// ✅ REQUIRED FORMAT - ALWAYS USE BRACES:
if (id == null) {
  continue;
}
if (text.isEmpty) {
  return '';
}
if (!condition) {
  break;
}
```

**🔍 MANDATORY VERIFICATION**: Before submitting ANY code, search for:

- `if.*continue;`
- `if.*return;`
- `if.*break;`
- `for.*in.*[^{].*;`

**ZERO matches required** or linting will fail!

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

**🚨 CRITICAL**: The `always_put_control_body_on_new_line` rule REQUIRES braces on new lines for ALL control statements. Single-line statements are FORBIDDEN.

```dart
// WRONG - violates always_put_control_body_on_new_line (COMMON AGENT MISTAKES)
if (condition) return;                    // ❌ AGENT REPEATS THIS PATTERN
if (condition) doSomething();            // ❌ AGENT REPEATS THIS PATTERN
if (id == null) continue;                // ❌ AGENT REPEATS THIS PATTERN
if (text.isEmpty) return '';             // ❌ AGENT REPEATS THIS PATTERN
for (item in items) print(item);        // ❌ AGENT REPEATS THIS PATTERN
while (running) process();               // ❌ AGENT REPEATS THIS PATTERN

// CORRECT - required format (MANDATORY PATTERNS)
if (condition) {                         // ✅ ALWAYS USE BRACES
  return;
}
if (condition) {                         // ✅ ALWAYS USE BRACES
  doSomething();
}
if (id == null) {                        // ✅ NULL CHECKS WITH BRACES
  continue;
}
if (text.isEmpty) {                      // ✅ EMPTY CHECKS WITH BRACES
  return '';
}
for (final item in items) {              // ✅ LOOPS WITH BRACES
  print(item);
}
while (running) {                        // ✅ WHILE LOOPS WITH BRACES
  process();
}
```

### String Literals - ALWAYS FOLLOW

````dart
// WRONG - violates prefer_single_quotes
final message = "Hello world";
final path = "lib/core/util/date_converter.dart";

// CORRECT - required format
final message = 'Hello world';
final path = 'lib/core/util/date_converter.dart';

// EXCEPTION - Double quotes acceptable when containing single quotes
final sqlStatement = "CREATE TABLE users (name TEXT CHECK(name IN ('admin','user')))";
final jsonString = "{'name': 'John', 'type': 'admin'}";

// AVOID - Escaping single quotes when double quotes are cleaner
final awkward = 'CREATE TABLE users (name TEXT CHECK(name IN (\'admin\',\'user\')))';
### Type Annotations - ALWAYS FOLLOW

**🚨 CRITICAL**: The `omit_local_variable_types` rule requires removing obvious type annotations on local variables. This is violated repeatedly in agent code - BE VIGILANT!

```dart
// WRONG - violates omit_local_variable_types (COMMON AGENT MISTAKES)
final String name = getName();
final List<String> items = getItems();
final DateFormat formatter = DateFormat('yyyy-MM-dd');
String displayName = '';                    // ❌ AGENT REPEATS THIS
int timestamp;                              // ❌ AGENT REPEATS THIS
String? bestName = existingName;            // ❌ AGENT REPEATS THIS
bool isValid = false;                       // ❌ AGENT REPEATS THIS
Map<int, int> idMap = <int, int>{};        // ❌ AGENT REPEATS THIS

// CORRECT - omit obvious types (REQUIRED PATTERNS)
final name = getName();
final items = getItems();
final formatter = DateFormat('yyyy-MM-dd');
var displayName = '';                       // ✅ USE var FOR SIMPLE TYPES
var timestamp = 0;                          // ✅ INITIALIZE WITH VALUE
var bestName = existingName;                // ✅ DART INFERS NULLABILITY
var isValid = false;                        // ✅ OBVIOUS BOOLEAN
final idMap = <int, int>{};                // ✅ TYPE IN CONSTRUCTOR

// KEEP explicit types ONLY when truly helpful for clarity
final String? nullableName = maybeGetName();     // OK - shows nullability intent
final Map<String, dynamic> config = loadConfig(); // OK - complex generic
````

**🔥 AGENT ANTI-PATTERNS** (FIX IMMEDIATELY):

- `String variableName = '';` → `var variableName = '';`
- `int count = 0;` → `var count = 0;`
- `bool flag = false;` → `var flag = false;`
- `Type? nullable = existing;` → `var nullable = existing;` (unless nullability is non-obvious)
- `List<Type> items = [];` → `final items = <Type>[];`
- `Map<K,V> map = {};` → `final map = <K,V>{};`

### Parameter Defaults - ALWAYS FOLLOW

```dart
// WRONG - violates avoid_redundant_argument_values
Container(color: Colors.red, width: null);
Text('Hello', textAlign: null);

// CORRECT - omit parameters that equal defaults
Container(color: Colors.red);
Text('Hello');
```

### Nullable Casting - CRITICAL SAFETY

```dart
// WRONG - violates cast_nullable_to_non_nullable (dangerous!)
final id = row['id'] as int;           // Can throw if null
final name = data['name'] as String;   // Runtime error if null
final count = map['count'] as double;  // Crash if null

// CORRECT - safe nullable casting with null handling
final id = row['id'] as int?;
if (id == null) continue;             // Skip invalid records

final name = data['name'] as String? ?? 'Unknown';  // Provide fallback
final count = map['count'] as double? ?? 0.0;       // Default value

// PATTERN: For required values, cast nullable then check
final importId = contact['id'] as int?;
if (importId == null) {
  // Log warning and skip this record
  continue;
}
// Now safely use importId as non-null int
```

**Why Critical:**

- SQLite queries return `Map<String, dynamic>` where values can be null
- Casting `null` to non-nullable type causes runtime crashes
- Always cast to nullable type first, then handle null case
- Use continue/return/fallback values for null cases`

### Date Conversion - MANDATORY USAGE

**🚨 CRITICAL**: ALWAYS use the centralized `DateConverter` class for date operations. NEVER create ad-hoc date conversion methods.

```dart
import '../../../../core/util/date_converter.dart';

// WRONG - ad-hoc conversion methods
int? _toIntSafe(dynamic value) { /* custom logic */ }
String? _appleEpochToIsoString(dynamic raw) { /* custom logic */ }

// CORRECT - use DateConverter methods
final intValue = DateConverter.toIntSafe(sqliteValue);
final isoString = DateConverter.appleToIsoString(appleTimestamp);
final dateTime = DateConverter.appleToDateTime(appleTimestamp);

// Common patterns for SQLite/Apple date handling:
final created = DateConverter.toIntSafe(row['creation_date']);
final createdIso = DateConverter.appleToIsoString(row['creation_date']);
final lastSeen = DateConverter.toIntSafe(row['last_read_date']) ??
                 DateConverter.toIntSafe(row['last_use']);
```

**Available DateConverter Methods:**

- `toIntSafe(dynamic)` - Safely convert SQLite int/double to int
- `appleToIsoString(dynamic)` - Apple timestamp → ISO 8601 UTC string
- `appleToDateTime(dynamic)` - Apple timestamp → DateTime object
- `apple2Dart(int)` - Apple nanoseconds → Dart milliseconds
- `dateString2Apple(String)` - Date string → Apple timestamp
- Plus many other conversion utilities

**Why Required:**

- Handles SQLite type casting issues (int vs double)
- Consistent Apple epoch conversion (nanoseconds since 2001-01-01)
- Centralized logic prevents conversion bugs
- Properly handles null/zero values

````

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

### Local Variable Type Inference

- **Do not** add redundant local variable type annotations. Let Dart infer the type to satisfy `omit_local_variable_types`.
- When you need a specific generic shape, use collection literals with type arguments (e.g. `<String, int>{}`) instead of prefixing the variable with the type.

### Equality Overrides on Mutable Classes

- **Never** override `==`/`hashCode` on mutable classes. If value equality is required, make the class immutable (all `final` fields) and annotate it with `@immutable`, or prefer dedicated value objects.

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

## Custom Lint Setup

- The project depends on the upstream `custom_lint` package (>=0.7.6) which resolves the macOS `dartaotruntime` crash.
- Keep the versions of `custom_lint` and `custom_lint_builder` in sync (currently `^0.7.6`) across `pubspec.yaml` and `custom_lint_plugins/ddd_lints/pubspec.yaml`.
- Do not restore the old `_third_party_tmp/custom_lint` override unless a new upstream regression requires it.
- After upgrading lint tooling, run `dart analyze` to confirm the analyzer boots as expected.

## Preventing Recurring Linting Issues ⚠️

### Pre-Commit Checklist

Before committing code, ensure compliance with these rules:

**✅ Control Flow**: All if/for/while statements use braces on new lines
**✅ String Literals**: Use single quotes for all strings (unless escaping required)
**✅ Local Variables**: Use `var` or `final` - NO `String x =`, `int y =`, `bool z =`
**✅ Parameter Defaults**: Don't pass values that equal parameter defaults
**✅ Nullable Casting**: Cast to nullable types first (`as int?`) then handle nulls
**✅ Import Order**: hooks_riverpod (never flutter_riverpod)
**✅ Color Methods**: withValues(alpha:) (never withOpacity())
**✅ Date Conversion**: DateConverter methods (never ad-hoc conversion)

### IDE Configuration

Configure your IDE to auto-format on save:

```json
// VS Code settings.json
{
  "dart.lineLength": 80,
  "editor.formatOnSave": true,
  "dart.previewCommitCharacters": false,
  "[dart]": {
    "editor.formatOnSave": true,
    "editor.rulers": [80]
  }
}
```

### Quick Lint Check

```bash
# Run before committing
dart analyze lib/
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

**🚨 CRITICAL**: These rules are enforced by `analysis_options.yaml` and will cause CI failures if violated. Fix ALL linting issues immediately - do not commit code with linting violations.

## 🤖 Agent Code Generation - PREVENT RECURRING MISTAKES

**PROBLEM**: AI agents repeatedly generate the same linting violations. These patterns MUST be avoided:

### ❌ Repeated Agent Violations (CHECK EVERY TIME)

```dart
// ❌ AGENTS ALWAYS DO THIS - CHECK FOR THESE PATTERNS
String displayName = '';           // → var displayName = '';
int count = 0;                    // → var count = 0;
bool isValid = false;             // → var isValid = false;
String? result = existing;        // → var result = existing;
List<String> items = [];          // → final items = <String>[];
Map<int, String> map = {};        // → final map = <int, String>{};

if (condition) return;            // → if (condition) { return; }
for (item in items) print(item); // → for (final item in items) { print(item); }

row['id'] as int                  // → row['id'] as int?
"text with 'quotes'"              // → "text with 'quotes'" (OK in SQL)
```

### ✅ Required Patterns (USE THESE INSTEAD)

```dart
// ✅ CORRECT PATTERNS - ALWAYS USE THESE
var displayName = '';             // Inferred String
var count = 0;                    // Inferred int
var isValid = false;              // Inferred bool
var result = existing;            // Inferred nullability
final items = <String>[];         // Type in constructor
final map = <int, String>{};      // Type in constructor

if (condition) {                  // Always braces
  return;
}
for (final item in items) {       // Always braces
  print(item);
}

final id = row['id'] as int?;     // Safe nullable cast
if (id == null) continue;         // Handle nulls explicitly
```

### 🎯 Agent Checklist (MANDATORY BEFORE SUBMITTING)

**🚨 CRITICAL**: ALWAYS run these searches before submitting ANY code changes:

1. **Search for `String \w+ =`** - Replace with `var`
2. **Search for `int \w+ =`** - Replace with `var`
3. **Search for `bool \w+ =`** - Replace with `var`
4. **Search for `as int[^?]`** - Add `?` for safety
5. **Count single quotes vs double quotes** - Prefer single except SQL

### 🔍 Single-Line If Statement Detection (MANDATORY)

**SEARCH PATTERNS** to find ALL single-line control flow violations:

```bash
# Critical searches - MUST return ZERO results:
grep -n "if.*[^{]$" file.dart              # Find if without opening brace
grep -n "for.*[^{]$" file.dart             # Find for without opening brace
grep -n "while.*[^{]$" file.dart           # Find while without opening brace

# Common single-line patterns that AGENTS create:
grep -n "if.*continue;" file.dart          # if (condition) continue;
grep -n "if.*return.*;" file.dart          # if (condition) return;
grep -n "if.*break;" file.dart             # if (condition) break;
grep -n "if.*throw.*;" file.dart           # if (condition) throw Error();

# Example violations to look for:
grep -n "if (.*== null) continue;" file.dart
grep -n "if (.*isEmpty) return" file.dart
grep -n "if (.*isNotEmpty) continue;" file.dart
```

### 🛠️ Quick Fix Patterns for Single-Line Statements

```dart
// FIND THESE PATTERNS:          →  FIX TO THIS FORMAT:
if (id == null) continue;        →  if (id == null) {
                                     continue;
                                   }

if (text.isEmpty) return '';     →  if (text.isEmpty) {
                                     return '';
                                   }

if (!map.containsKey(key)) break; → if (!map.containsKey(key)) {
                                     break;
                                   }

for (item in list) print(item);   → for (final item in list) {
                                     print(item);
                                   }
```

### 🔥 Agent Anti-Pattern Prevention

**BEFORE SUBMITTING**: Verify ZERO matches for these regex patterns:

- `if\s*\([^)]+\)\s*[^{].*;\s*$` - Single-line if statements
- `for\s*\([^)]+\)\s*[^{].*;\s*$` - Single-line for loops
- `while\s*\([^)]+\)\s*[^{].*;\s*$` - Single-line while loops

**AGENTS**: These patterns WILL cause linting failures. Check EVERY generated file!
````
