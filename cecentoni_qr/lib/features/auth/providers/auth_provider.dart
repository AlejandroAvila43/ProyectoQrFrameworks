import 'package:cecentoni_qr/core/errors/app_exceptions.dart';
import 'package:cecentoni_qr/models/usuario_model.dart';
import 'package:cecentoni_qr/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ── Servicios ────────────────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ── Stream de Firebase Auth ──────────────────────────────────────────────────

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// ── Usuario actual desde Firestore ───────────────────────────────────────────
// FIX: antes usaba authState.when() dentro del FutureProvider, lo que hacía
// que retornara null mientras el stream cargaba → perfil siempre en error.
// Ahora esperamos a que el stream tenga dato antes de consultar Firestore.

final currentUserProvider = FutureProvider<UsuarioModel?>((ref) async {
  // Esperamos el primer valor del stream de auth
  final user = await ref.watch(
    authStateProvider.selectAsync((u) => u),
  );
  if (user == null) return null;
  return ref.read(authServiceProvider).getCurrentUserData();
});

// ── Estado de Login ──────────────────────────────────────────────────────────

class LoginState {
  final bool isLoading;
  final String? errorMessage;
  final UsuarioModel? usuario;

  const LoginState({
    this.isLoading = false,
    this.errorMessage,
    this.usuario,
  });

  LoginState copyWith({
    bool? isLoading,
    String? errorMessage,
    UsuarioModel? usuario,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      usuario: usuario ?? this.usuario,
    );
  }
}

// FIX: migrado de StateNotifier → Notifier (API moderna Riverpod 2.x)
class LoginNotifier extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final usuario = await ref.read(authServiceProvider).login(
            email: email,
            password: password,
          );
      state = state.copyWith(isLoading: false, usuario: usuario);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error inesperado. Intenta de nuevo.',
      );
    }
  }

  Future<void> logout() async {
    await ref.read(authServiceProvider).logout();
    state = const LoginState();
  }

  void limpiarError() {
    state = state.copyWith(errorMessage: null);
  }
}

final loginProvider = NotifierProvider<LoginNotifier, LoginState>(
  LoginNotifier.new,
);