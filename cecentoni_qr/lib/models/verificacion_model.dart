import 'package:cloud_firestore/cloud_firestore.dart';
import 'producto_model.dart';

/// Modelo que representa una verificación registrada en Firestore.
///
/// Cada vez que un empleado escanea un QR y se valida el pedido,
/// se crea una instancia de este modelo y se guarda en la colección
/// "verificaciones" de Firestore.
///
/// Esto crea un historial auditable de todas las operaciones.
class VerificacionModel {
  final String? id;              // ID autogenerado por Firestore
  final String empleadoEmail;    // Email del empleado que realizó el escaneo
  final String empleadoNombre;
  final String pedidoId;         // ID del pedido verificado
  final String numeroPedido;
  final String cliente;
  final ProductoModel productoEscaneado;  // Lo que leyó el QR
  final bool resultado;          // true = correcto, false = incorrecto
  final DateTime fecha;
  final String hora;

  const VerificacionModel({
    this.id,
    required this.empleadoEmail,
    required this.empleadoNombre,
    required this.pedidoId,
    required this.numeroPedido,
    required this.cliente,
    required this.productoEscaneado,
    required this.resultado,
    required this.fecha,
    required this.hora,
  });

  // ── Fábrica desde Firestore ──────────────────────────────────────────────
  factory VerificacionModel.fromFirestore(
      Map<String, dynamic> map, String docId) {
    final productoMap = map['productoEscaneado'] as Map<String, dynamic>? ?? {};

    return VerificacionModel(
      id: docId,
      empleadoEmail: map['empleadoEmail'] as String? ?? '',
      empleadoNombre: map['empleadoNombre'] as String? ?? '',
      pedidoId: map['pedidoId'] as String? ?? '',
      numeroPedido: map['numeroPedido'] as String? ?? '',
      cliente: map['cliente'] as String? ?? '',
      productoEscaneado: ProductoModel(
        modelo: productoMap['modelo'] as String? ?? '',
        color: productoMap['color'] as String? ?? '',
        medida: productoMap['medida'] as String? ?? '',
        lote: productoMap['lote'] as String? ?? '',
      ),
      resultado: map['resultado'] as bool? ?? false,
      fecha: (map['fecha'] as Timestamp).toDate(),
      hora: map['hora'] as String? ?? '',
    );
  }

  // ── Serialización ────────────────────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'empleadoEmail': empleadoEmail,
      'empleadoNombre': empleadoNombre,
      'pedidoId': pedidoId,
      'numeroPedido': numeroPedido,
      'cliente': cliente,
      'productoEscaneado': productoEscaneado.toMap(),
      'resultado': resultado,
      'fecha': Timestamp.fromDate(fecha),
      'hora': hora,
    };
  }
}