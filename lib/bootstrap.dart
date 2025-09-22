// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import './config/providers.dart' as providers;

// /// Initializes services and controllers before the start of the application
// Future<ProviderContainer> bootstrap() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   final container = ProviderContainer(
//     overrides: [], //supabaseProvider.overrideWithValue(Supabase.instance)
//     observers: [_Logger()],
//   );
//   await providers.initializeAsyncProviders(container);
//   return container;
// }

// class _Logger extends ProviderObserver {
//   @override
//   void didUpdateProvider(
//     ProviderBase<dynamic> provider,
//     Object? previousValue,
//     Object? newValue,
//     ProviderContainer container,
//   ) {
//     debugPrint(
//       '''
//       {
//       "provider": "${provider.name ?? provider.runtimeType}",
//       "newValue": "$newValue"
//       }''',
//     );
//   }
// }
