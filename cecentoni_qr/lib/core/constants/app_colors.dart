import 'package:flutter/material.dart';

/// Paleta de colores oficial de Cecentoni QR.
/// Centralizar colores aquí garantiza consistencia visual
/// y facilita cambios de branding en el futuro.
class AppColors {
  AppColors._(); // Clase no instanciable

  // ── Colores primarios ────────────────────────────────────────────────────
  /// Azul oscuro corporativo — botones principales, AppBar
  static const Color primary = Color(0xFF1A2E4A);

  /// Azul medio — estados hover, elementos secundarios
  static const Color primaryLight = Color(0xFF2D4F73);

  /// Dorado arena — acento de marca, iconos destacados
  static const Color accent = Color(0xFFCBA86F);

  // ── Neutros ──────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEEEEEE);
  static const Color onSurface = Color(0xFF212121);
  static const Color onSurfaceLight = Color(0xFF757575);

  // ── Estado ───────────────────────────────────────────────────────────────
  /// Verde éxito — piso correcto ✓
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);

  /// Rojo error — piso incorrecto ✗
  static const Color error = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFFFEBEE);

  /// Naranja advertencia
  static const Color warning = Color(0xFFE65100);
  static const Color warningLight = Color(0xFFFFF3E0);

  // ── Separadores ──────────────────────────────────────────────────────────
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);
}