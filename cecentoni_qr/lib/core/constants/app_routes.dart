/// Constantes de rutas nombradas para GoRouter.
/// Usar constantes evita errores de tipeo en navegación.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String pedidos = '/pedidos';
  static const String pedidoDetalle = '/pedidos/:id';
  static const String qrScanner = '/qr-scanner';
  static const String resultado = '/resultado';
  static const String historial = '/historial';
  static const String perfil = '/perfil';
}