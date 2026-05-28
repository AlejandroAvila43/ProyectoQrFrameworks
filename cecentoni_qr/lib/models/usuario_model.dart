/// Roles del sistema
enum RolUsuario {
  empleado,
  administrador;

  String get label => switch (this) {
        RolUsuario.empleado => 'Empleado de bodega',
        RolUsuario.administrador => 'Administrador',
      };
}

/// Modelo que representa al usuario autenticado.
/// Los datos adicionales (nombre, rol) se guardan en Firestore
/// bajo la colección "usuarios", usando el UID de Firebase Auth como ID.
class UsuarioModel {
  final String uid;
  final String email;
  final String nombre;
  final RolUsuario rol;

  const UsuarioModel({
    required this.uid,
    required this.email,
    required this.nombre,
    required this.rol,
  });

  factory UsuarioModel.fromFirestore(Map<String, dynamic> map, String uid) {
    final rolStr = map['rol'] as String? ?? 'empleado';
    final rol = RolUsuario.values.firstWhere(
      (r) => r.name == rolStr,
      orElse: () => RolUsuario.empleado,
    );

    return UsuarioModel(
      uid: uid,
      email: map['email'] as String? ?? '',
      nombre: map['nombre'] as String? ?? 'Empleado',
      rol: rol,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nombre': nombre,
      'rol': rol.name,
    };
  }

  /// ¿Tiene permisos de administrador?
  bool get esAdmin => rol == RolUsuario.administrador;
}