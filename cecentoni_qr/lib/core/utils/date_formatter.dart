import 'package:intl/intl.dart';

/// Formatea fechas de manera consistente en toda la app.
class DateFormatter {
  DateFormatter._();

  /// 10/05/2026
  static String toShort(DateTime date) =>
      DateFormat('dd/MM/yyyy').format(date);

  /// 10 May 2026
  static String toMedium(DateTime date) =>
      DateFormat('dd MMM yyyy', 'es').format(date);

  /// 10/05/2026 14:32
  static String toFull(DateTime date) =>
      DateFormat('dd/MM/yyyy HH:mm').format(date);

  /// 14:32
  static String timeOnly(DateTime date) =>
      DateFormat('HH:mm').format(date);

  /// Solo la hora para guardar en Firestore
  static String horaString(DateTime date) =>
      DateFormat('HH:mm:ss').format(date);
}