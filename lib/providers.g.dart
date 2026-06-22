// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$platformBrightnessHash() =>
    r'10acf764fbcc7d0e82e155478ef189c0127e851a';

/// Root providers shared by multiple features or initialized asynchronously.
///
/// Copied from [platformBrightness].
@ProviderFor(platformBrightness)
final platformBrightnessProvider = AutoDisposeProvider<Brightness>.internal(
  platformBrightness,
  name: r'platformBrightnessProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$platformBrightnessHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PlatformBrightnessRef = AutoDisposeProviderRef<Brightness>;
String _$pathsHelperHash() => r'5252def1042151aa97852715b35adf65a0a9bb1c';

/// The asynchronous provider of [PathsHelper].
///
/// Copied from [pathsHelper].
@ProviderFor(pathsHelper)
final pathsHelperProvider = AutoDisposeFutureProvider<PathsHelper>.internal(
  pathsHelper,
  name: r'pathsHelperProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pathsHelperHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PathsHelperRef = AutoDisposeFutureProviderRef<PathsHelper>;
String _$switchableDarkModeHash() =>
    r'a6a6949ba4e7cfc5d9aaf03151601a351b7373c8';

/// App theme-mode override.
///
/// Defaults to `ThemeMode.system` and can be cycled from the toolbar.
///
/// Copied from [SwitchableDarkMode].
@ProviderFor(SwitchableDarkMode)
final switchableDarkModeProvider =
    AutoDisposeNotifierProvider<SwitchableDarkMode, ThemeMode>.internal(
      SwitchableDarkMode.new,
      name: r'switchableDarkModeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$switchableDarkModeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SwitchableDarkMode = AutoDisposeNotifier<ThemeMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
