# Riverpod Provider Patterns - MANDATORY PATTERNS

## 🚨 CRITICAL RULES 🚨

### ✅ ALWAYS USE CODE GENERATION
- **MANDATORY**: All providers MUST use `@riverpod` annotation
- **NEVER** create manual `StateNotifierProvider` instances
- **REQUIRED**: Include `part 'filename.g.dart';` directive

### ✅ FUNCTION PROVIDER PATTERN (Recommended)
```dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_provider.g.dart';

// ✅ CORRECT: Use Ref type for function providers
@riverpod
Widget myWidget(Ref ref, int parameter) {
  return Text('Value: $parameter');
}

// ✅ CORRECT: Family provider with Ref
@riverpod
String myData(Ref ref, String id) {
  return 'Data for $id';
}
```

### ✅ CLASS PROVIDER PATTERN
```dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_notifier.g.dart';

// ✅ CORRECT: Class extends generated base
@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  int build() => 0;
  
  void increment() => state++;
}

// This generates: myNotifierProvider
// Class name: MyNotifier  → Provider name: myNotifierProvider
```

## 🚫 COMMON MISTAKES TO AVOID

### ❌ WRONG: Using Generated Type for Function Parameters
```dart
// ❌ WRONG: Don't use generated type as parameter
@riverpod
Widget myWidget(MyWidgetRef ref, int parameter) {
  // This causes compile errors!
}
```

### ❌ WRONG: Manual Provider Creation  
```dart
// ❌ WRONG: Never create providers manually
final myProvider = StateNotifierProvider<MyNotifier, int>((ref) {
  return MyNotifier();
});
```

### ❌ WRONG: Missing Code Generation
```dart
// ❌ WRONG: Missing @riverpod annotation
final myProvider = Provider<String>((ref) => 'data');
```

## ✅ USAGE PATTERNS

### Reading Providers
```dart
// In widgets or other providers:
final value = ref.watch(myWidgetProvider(42));
final notifier = ref.read(myNotifierProvider.notifier);
```

### File Naming Convention
- File: `my_feature_provider.dart` 
- Generated: `my_feature_provider.g.dart`
- Class: `MyFeature extends _$MyFeature`
- Provider Naming Rule: In `foo_provider.dart`, annotated class `Foo` generates `fooProvider`.
  - Examples:
    - Class `ImportUiState` → `importUiStateProvider`
    - Class `SelectedPageIndex` → `selectedPageIndexProvider`
    - Class `IsDarkMode` → `isDarkModeProvider`

## 🔧 TROUBLESHOOTING

### Build Runner Commands
```bash
# Generate code
dart run build_runner build

# Clean and rebuild
dart run build_runner build --delete-conflicting-outputs
```

### Common Errors
1. **"Undefined class '_$MyProvider'"** → Run code generation
2. **"MyProviderRef isn't defined"** → Use `Ref` for function providers
3. **"Missing part directive"** → Add `part 'filename.g.dart';`

## 📋 CHECKLIST FOR NEW PROVIDERS

- [ ] File has `@riverpod` annotation
- [ ] File has `part 'filename.g.dart';` directive  
- [ ] Function providers use `Ref ref` parameter
- [ ] Class providers extend `_$ClassName`
- [ ] Code generation has been run
- [ ] No manual provider creation used
- [ ] Using `hooks_riverpod` import (not `flutter_riverpod`)
