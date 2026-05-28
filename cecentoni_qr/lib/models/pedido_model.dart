import 'package:cloud_firestore/cloud_firestore.dart';
import 'producto_model.dart';

/// Estatuses posibles de un pedido
enum EstatusPedido {
  pendiente,
  verificado,
  entregado,
  error;

  String get label => switch (this) {
        EstatusPedido.pendiente => 'Pendiente',
        EstatusPedido.verificado => 'Verificado',
        EstatusPedido.entregado => 'Entregado',
        EstatusPedido.error => 'Error',
      };
}

/// Modelo que representa un pedido de cliente.
///
/// Contiene el producto ESPERADO y los datos del cliente.
/// La validación compara este producto esperado con el
/// producto escaneado desde el QR.
class PedidoModel {
  final String id;               // ID del documento Firestore (ej: "pedido_1284")
  final String numeroPedido;     // Número visible (ej: "1284")
  final String cliente;
  final ProductoModel productoEsperado;
  final EstatusPedido estatus;
  final DateTime? fechaEntrega;

  const PedidoModel({
    required this.id,
    required this.numeroPedido,
    required this.cliente,
    required this.productoEsperado,
    required this.estatus,
    this.fechaEntrega,
  });

  // ── Fábrica desde Firestore ──────────────────────────────────────────────
  factory PedidoModel.fromFirestore(Map<String, dynamic> map, String docId) {
    // Extraer número de pedido del ID (ej: "pedido_1284" → "1284")
    final numeroPedido = docId.replaceAll('pedido_', '');

    // Construir el producto esperado desde los campos del pedido
    final productoEsperado = ProductoModel(
      modelo: map['productoEsperado'] as String? ?? '',
      color: map['color'] as String? ?? '',
      medida: map['medida'] as String? ?? '',
      lote: map['lote'] as String? ?? '',
    );

    // Convertir string de estatus al enum
    final estatusStr = map['estatus'] as String? ?? 'pendiente';
    final estatus = EstatusPedido.values.firstWhere(
      (e) => e.name == estatusStr,
      orElse: () => EstatusPedido.pendiente,
    );

    // Convertir Timestamp de Firestore a DateTime
    DateTime? fechaEntrega;
    if (map['fechaEntrega'] != null) {
      fechaEntrega = (map['fechaEntrega'] as Timestamp).toDate();
    }

    return PedidoModel(
      id: docId,
      numeroPedido: numeroPedido,
      cliente: map['cliente'] as String? ?? 'Sin nombre',
      productoEsperado: productoEsperado,
      estatus: estatus,
      fechaEntrega: fechaEntrega,
    );
  }

  // ── Serialización ────────────────────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'cliente': cliente,
      'productoEsperado': productoEsperado.modelo,
      'color': productoEsperado.color,
      'medida': productoEsperado.medida,
      'lote': productoEsperado.lote,
      'estatus': estatus.name,
      if (fechaEntrega != null) 'fechaEntrega': Timestamp.fromDate(fechaEntrega!),
    };
  }

  PedidoModel copyWith({
    String? id,
    String? numeroPedido,
    String? cliente,
    ProductoModel? productoEsperado,
    EstatusPedido? estatus,
    DateTime? fechaEntrega,
  }) {
    return PedidoModel(
      id: id ?? this.id,
      numeroPedido: numeroPedido ?? this.numeroPedido,
      cliente: cliente ?? this.cliente,
      productoEsperado: productoEsperado ?? this.productoEsperado,
      estatus: estatus ?? this.estatus,
      fechaEntrega: fechaEntrega ?? this.fechaEntrega,
    );
  }
}