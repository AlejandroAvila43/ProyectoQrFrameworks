/// Excepciones personalizadas de Cecentoni QR.
///
/// Usamos excepciones tipadas en lugar de Strings genéricos
/// para poder capturarlas de forma específica con try/catch
/// y mostrar mensajes de error útiles al usuario.

/// Excepción base de la aplicación
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// Error de autenticación Firebase
class AuthException extends AppException {
  const AuthException(super.message);

  /// Convierte códigos de error de Firebase a mensajes en español
  factory AuthException.fromFirebaseCode(String code) {
    return switch (code) {
      'user-not-found' => const AuthException('No existe una cuenta con ese correo.'),
      'wrong-password' => const AuthException('Contraseña incorrecta.'),
      'invalid-email' => const AuthException('El correo electrónico no es válido.'),
      'user-disabled' => const AuthException('Esta cuenta ha sido deshabilitada.'),
      'too-many-requests' => const AuthException('Demasiados intentos. Intenta más tarde.'),
      'network-request-failed' => const AuthException('Sin conexión a internet.'),
      'invalid-credential' => const AuthException('Credenciales inválidas. Verifica tu correo y contraseña.'),
      _ => AuthException('Error de autenticación: $code'),
    };
  }
}

/// Error al leer/parsear el QR
class QrException extends AppException {
  const QrException(super.message);

  factory QrException.invalidFormat() =>
      const QrException('El código QR no tiene el formato correcto.');

  factory QrException.missingFields() =>
      const QrException('El QR no contiene todos los campos requeridos (modelo, color, medida, lote).');
}

/// Error de Firestore
class FirestoreException extends AppException {
  const FirestoreException(super.message);

  factory FirestoreException.notFound(String coleccion) =>
      FirestoreException('No se encontró el documento en $coleccion.');

  factory FirestoreException.permissionDenied() =>
      const FirestoreException('Sin permisos para acceder a los datos.');
}

/// Error de red/conectividad
class NetworkException extends AppException {
  const NetworkException() : super('Sin conexión a internet. Verifica tu red.');
}