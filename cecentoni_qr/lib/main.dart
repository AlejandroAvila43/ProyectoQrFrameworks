import 'package:cecentoni_qr/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';

// ── Pantallas ────────────────────────────────────────────────────────────────
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/pedidos/screens/pedidos_list_screen.dart';
import 'features/pedidos/screens/pedido_detalle_screen.dart';
import 'features/pedidos/screens/crear_pedido_screen.dart';
import 'features/qr/screens/qr_scanner_screen.dart';
import 'features/validacion/screens/resultado_screen.dart';
import 'features/historial/screens/historial_screen.dart';
import 'features/perfil/screens/perfil_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

 await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,

 );

  await initializeDateFormatting('es', null);

  runApp(
    const ProviderScope(
      child: CecentoniApp(),
    ),
  );
}

class CecentoniApp extends ConsumerWidget {
  const CecentoniApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = _buildRouter(ref);

    return MaterialApp.router(
      title: 'Cecentoni QR',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }

  GoRouter _buildRouter(WidgetRef ref) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: _AuthListenable(ref),
      redirect: (context, state) {
        final authState = ref.read(authStateProvider);
        final isAuthenticated = authState.asData?.value != null;
        final location = state.matchedLocation;

        // Splash siempre pasa
        if (location == AppRoutes.splash) return null;

        // Sin sesión → login
        if (!isAuthenticated && location != AppRoutes.login) {
          return AppRoutes.login;
        }

        // Con sesión en login → home
        if (isAuthenticated && location == AppRoutes.login) {
          return AppRoutes.home;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (_, __) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (_, __) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (_, __) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.pedidos,
          builder: (_, __) => const PedidosListScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, state) => PedidoDetalleScreen(
                pedidoId: state.pathParameters['id'] ?? '',
              ),
            ),
          ],
        ),
        GoRoute(
          path: AppRoutes.qrScanner,
          builder: (_, __) => const QrScannerScreen(),
        ),
        GoRoute(
          path: AppRoutes.crearPedido,
          builder: (_, __) => const CrearPedidoScreen(),
        ),
        GoRoute(
          path: AppRoutes.resultado,
          builder: (_, __) => const ResultadoScreen(),
        ),
        GoRoute(
          path: AppRoutes.historial,
          builder: (_, __) => const HistorialScreen(),
        ),
        GoRoute(
          path: AppRoutes.perfil,
          builder: (_, __) => const PerfilScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Página no encontrada')),
        body: Center(child: Text('Ruta no encontrada: ${state.uri}')),
      ),
    );
  }
}

/// Puente entre Riverpod y GoRouter para que el redirect
/// se re-evalúe automáticamente cuando cambia el estado de auth.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(WidgetRef ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}