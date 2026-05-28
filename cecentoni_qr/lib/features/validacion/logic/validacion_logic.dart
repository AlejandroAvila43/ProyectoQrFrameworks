

import 'package:cecentoni_qr/core/utils/date_formatter.dart';
import 'package:cecentoni_qr/models/pedido_model.dart';
import 'package:cecentoni_qr/models/producto_model.dart';
import 'package:cecentoni_qr/models/verificacion_model.dart';

/// Resultado de una validación.
/// Encapsula el resultado booleano y detalles del error si aplica.
class ResultadoValidacion {
  final bool esValido;
  final ProductoModel productoEsperado;
  final ProductoModel productoEscaneado;
  final List<String> diferencias; // Campos que no coinciden

  const ResultadoValidacion({
    required this.esValido,
    required this.productoEsperado,
    required this.productoEscaneado,
    required this.diferencias,
  });

  /// Si es válido, no hay diferencias
  bool get sinDiferencias => diferencias.isEmpty;
}

/// Lógica pura de validación de pedidos.
///
/// Esta clase es PURA: no depende de Firebase, UI, ni Flutter.
/// Solo recibe modelos y retorna resultados.
///
/// Esto la hace fácilmente testeable con unit tests.
class ValidacionLogic {
  const ValidacionLogic();

  // ── Validación principal ─────────────────────────────────────────────────

  /// Valida si el producto escaneado coincide con el pedido.
  ///
  /// LÓGICA DE COMPARACIÓN:
  /// Compara campo por campo: modelo, color, medida, lote.
  /// Usa normalización (lowercase + trim) para evitar falsos negativos.
  ///
  /// Retorna un [ResultadoValidacion] con el detalle completo.
  ResultadoValidacion validar({
    required PedidoModel pedido,
    required ProductoModel productoEscaneado,
  }) {
    final esperado = pedido.productoEsperado;
    final diferencias = <String>[];

    // Comparar cada campo y registrar diferencias
    if (_diferente(esperado.modelo, productoEscaneado.modelo)) {
      diferencias.add(
        'Modelo: esperado "${esperado.modelo}", escaneado "${productoEscaneado.modelo}"',
      );
    }

    if (_diferente(esperado.color, productoEscaneado.color)) {
      diferencias.add(
        'Color: esperado "${esperado.color}", escaneado "${productoEscaneado.color}"',
      );
    }

    if (_diferente(esperado.medida, productoEscaneado.medida)) {
      diferencias.add(
        'Medida: esperada "${esperado.medida}", escaneada "${productoEscaneado.medida}"',
      );
    }

    if (_diferente(esperado.lote, productoEscaneado.lote)) {
      diferencias.add(
        'Lote: esperado "${esperado.lote}", escaneado "${productoEscaneado.lote}"',
      );
    }

    return ResultadoValidacion(
      esValido: diferencias.isEmpty,
      productoEsperado: esperado,
      productoEscaneado: productoEscaneado,
      diferencias: diferencias,
    );
  }

  /// Compara dos strings normalizados
  bool _diferente(String a, String b) {
    return _normalizar(a) != _normalizar(b);
  }

  String _normalizar(String valor) => valor.toLowerCase().trim();

  // ── Construcción de VerificacionModel ────────────────────────────────────

  /// Crea el modelo de verificación para guardar en Firestore.
  /// Se llama DESPUÉS de validar, con el resultado.
  VerificacionModel crearVerificacion({
    required String empleadoEmail,
    required String empleadoNombre,
    required PedidoModel pedido,
    required ProductoModel productoEscaneado,
    required bool resultado,
  }) {
    final ahora = DateTime.now();
    return VerificacionModel(
      empleadoEmail: empleadoEmail,
      empleadoNombre: empleadoNombre,
      pedidoId: pedido.id,
      numeroPedido: pedido.numeroPedido,
      cliente: pedido.cliente,
      productoEscaneado: productoEscaneado,
      resultado: resultado,
      fecha: ahora,
      hora: DateFormatter.horaString(ahora),
    );
  }
}