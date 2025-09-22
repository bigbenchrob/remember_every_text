# Agent Context - Master Documentation Index

This file serves as the master index for all critical documentation that AI agents MUST reference when working on this project. **EVERY AGENT MUST READ THIS FILE AND THE REFERENCED DOCUMENTATION BEFORE MAKING CODE CHANGES.**

## 🚨 CRITICAL READING ORDER 🚨

**READ THESE FILES IN THIS EXACT ORDER:**

### 1. Code Standards & Common Issues ⭐ MANDATORY
📁 **`00-code-standards.md`** 
- **REQUIRED FIRST READ** - Contains all the repeated mistakes agents make
- Flutter/Dart linting rules and patterns
- Import requirements (hooks_riverpod vs flutter_riverpod)
- Control flow formatting rules, deprecated method warnings
- Performance optimizations (ColoredBox vs Container, withValues vs withOpacity)

### 2. AddressBook Database Resolution ⚠️ CRITICAL FOR IMPORTS
📁 **`01-addressbook-database-resolution.md`**
- **ESSENTIAL FOR ANY IMPORT WORK** - Prevents 90% of import failures
- Explains why agents pick wrong AddressBook database paths
- Details the MANDATORY use of `getFolderAggregateEitherProvider`
- Shows the correct vs incorrect database folder structure
- **IGNORE THIS AT YOUR PERIL** - Wrong path = import failure

### 3. Project Architecture & DDD Structure
📁 **`02-architecture-overview.md`**
- Domain Driven Development (DDD) structure explanation
- Feature organization and layer responsibilities
- Naming conventions and file organization patterns
- Infrastructure/Application/Domain layer separation

### 4. Riverpod Provider Patterns ⚠️ MANDATORY PATTERNS
📁 **`05-riverpod-provider-patterns.md`**
- **CRITICAL**: All providers MUST use riverpod_annotation code generation
- **NEVER** create manual StateNotifierProvider instances
- Required file naming: `feature_name_provider.dart`
- Required class pattern: `class FeatureName extends _$FeatureName {}`
- Usage patterns: `ref.watch(featureNameProvider)`, `ref.read(featureNameProvider.notifier)`
- **IMPORTANT**: Function providers use `Ref ref` parameter, NOT generated types

## Quick Reference Standards
- **Primary import**: Always use `hooks_riverpod`, never `flutter_riverpod`
- **Color opacity**: Use `withValues(alpha: 0.5)`, never `withOpacity(0.5)`
- **Control flow**: Always use braces, never single-line statements  
- **Async functions**: Return `Future<void>`, never `void`
- **Containers**: Use `ColoredBox` when only setting color
- **AddressBook imports**: MUST use `getFolderAggregateEitherProvider` for path resolution
- **Riverpod providers**: MUST use `@riverpod` annotation, NEVER manual providers

## Project Overview
This is a macOS-native Flutter application that imports and manages Messages and AddressBook data using:
- Domain Driven Development (DDD) architecture
- Riverpod for state management (hooks_riverpod specifically)
- Drift for database operations  
- macOS UI components for native feel

### Navigation System (Current State - September 2025)
**ViewSpec-Based Architecture**: The navigation system uses **sealed classes** and **reactive Riverpod providers** for type-safe navigation:

- **ViewSpec & MessagesSpec sealed classes**: Strongly-typed navigation specifications with compile-time guarantees
- **PanelsViewState**: Simple Map<WindowPanel, ViewSpec?> state management
- **Bottom-up provider chain**: ViewSpec → Feature Coordinators → Widget Builders → UI
- **Reactive panel providers**: Automatically rebuild UI when navigation state changes
- **Panel Layout**: Left sidebar, center content area, right sidebar

**Key Pattern**: 
```dart
ref.read(panelsViewStateProvider.notifier).show(
  panel: WindowPanel.center,
  spec: const ViewSpec.messages(MessagesSpec.forChat(chatId: 42)),
);
```

**Adding New Features**:
1. Create feature spec sealed class (e.g., ChatsSpec)
2. Add ViewSpec variant (e.g., ViewSpec.chats)  
3. Create feature coordinator with buildForSpec() method
4. Wire into panel coordinator
5. Create widget builders

**HOLY RULE**: Features coordinate through ViewSpec declarations only. No direct cross-feature commands or state mutations.

See `03-navigation-overview.md` for complete architecture, implementation layers, and usage patterns.

## File Organization
```
_AGENT_CONTEXT/
├── AGENT_CONTEXT.md                        # This master index file
├── 00-code-standards.md                    # ⭐ MANDATORY - Code rules & patterns
├── 01-addressbook-database-resolution.md  # ⚠️ CRITICAL - Import path resolution
├── 02-architecture-overview.md            # DDD structure & naming conventions
├── 03-navigation-overview.md              # ⭐ ESSENTIAL - Navigation system with explicit event fields
├── 05-riverpod-provider-patterns.md       # ⚠️ MANDATORY - Provider code generation rules
└── [Additional numbered files as needed]
```

## Usage Instructions for Agents

1. **ALWAYS** read this file first when assigned to the project
2. **MANDATORY** - Read `00-code-standards.md` before any code changes
3. **IF WORKING WITH IMPORTS** - Read `01-addressbook-database-resolution.md` 
4. **FOR ARCHITECTURE QUESTIONS** - Reference `02-architecture-overview.md`
5. **FOR UI/NAVIGATION WORK** - Read `03-navigation-overview.md` to understand explicit event fields
6. **FOR PROVIDERS** - Follow `05-riverpod-provider-patterns.md` for code generation patterns
7. When in doubt, ask for clarification rather than guessing

**Remember**: Following these guidelines prevents the most common agent mistakes and ensures code quality.
