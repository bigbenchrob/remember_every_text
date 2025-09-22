import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../presentation/view/macos_app_shell.dart';

/// Minimal router that just opens the macOS app window
/// All navigation is handled by the navigation orchestrator and panel system
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const MacosAppShell(),
      ),

      // Optional: Add future special routes here if needed
      // GoRoute(
      //   path: '/special-feature',
      //   name: 'special-feature',
      //   builder: (context, state) {
      //     // Could trigger specific orchestrator configuration
      //     return const AppShell();
      //   },
      // ),
    ],
  );
});
