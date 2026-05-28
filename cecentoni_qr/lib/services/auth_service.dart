import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario_model.dart';
import '../core/errors/app_exceptions.dart';

/// Servicio de autenticación.
///
/// Esta clase encapsula TODA la lógica de Firebase Auth.
/// Los providers/screens NO interactúan directamente con Firebase;
/// siempre pasan por este servicio. Esto es el Repository Pattern.
///
/// Beneficios:
/// - Podemos cambiar el proveedor de auth sin tocar la UI
/// - Podemos hacer tests mockeando este servicio
/// - La lógica de error se centraliza aquí
class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // ── Estado de autenticación ──────────────────────────────────────────────

  /// Stream del usuario de Firebase. Emite null cuando no hay sesión.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Usuario actual de Firebase (puede ser null)
  User? get currentUser => _auth.currentUser;

  /// UID del usuario actual (null si no hay sesión)
  String? get currentUid => _auth.currentUser?.uid;

  // ── Login ────────────────────────────────────────────────────────────────

  /// Inicia sesión con email y password.
  /// Lanza [AuthException] si hay error.
  Future<UsuarioModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = credential.user!.uid;
      return await _getUserData(uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseCode(e.code);
    } catch (e) {
      throw AuthException('Error inesperado: ${e.toString()}');
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _auth.signOut();
  }

  // ── Datos del usuario en Firestore ───────────────────────────────────────

  /// Obtiene los datos del usuario desde la colección "usuarios" de Firestore.
  /// Si no existe el documento (primera vez), crea uno con rol "empleado".
  Future<UsuarioModel> _getUserData(String uid) async {
    final doc = await _firestore.collection('usuarios').doc(uid).get();

    if (!doc.exists || doc.data() == null) {
      // Primera vez: crear perfil básico
      final currentUser = _auth.currentUser!;
      final nuevoUsuario = UsuarioModel(
        uid: uid,
        email: currentUser.email ?? '',
        nombre: currentUser.displayName ?? 'Empleado',
        rol: RolUsuario.empleado,
      );
      await _firestore.collection('usuarios').doc(uid).set(nuevoUsuario.toMap());
      return nuevoUsuario;
    }

    return UsuarioModel.fromFirestore(doc.data()!, uid);
  }

  /// Obtiene los datos actualizados del usuario autenticado.
  Future<UsuarioModel?> getCurrentUserData() async {
    final uid = currentUid;
    if (uid == null) return null;
    return _getUserData(uid);
  }
}