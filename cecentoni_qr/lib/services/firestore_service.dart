import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pedido_model.dart';
import '../models/verificacion_model.dart';
import '../core/errors/app_exceptions.dart';

class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference get _pedidos => _db.collection('pedidos');
  CollectionReference get _verificaciones => _db.collection('verificaciones');

  // ── PEDIDOS ──────────────────────────────────────────────────────────────

  /// Todos los pedidos — sin orderBy para no requerir índice compuesto
  Stream<List<PedidoModel>> getPedidosStream() {
    return _pedidos
        .snapshots()
        .map((snapshot) {
      final lista = snapshot.docs.map((doc) {
        return PedidoModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      // Ordenar en memoria por fechaEntrega (evita índice en Firestore)
      lista.sort((a, b) {
        if (a.fechaEntrega == null && b.fechaEntrega == null) return 0;
        if (a.fechaEntrega == null) return 1;
        if (b.fechaEntrega == null) return -1;
        return a.fechaEntrega!.compareTo(b.fechaEntrega!);
      });

      return lista;
    });
  }

  /// Pedidos pendientes — filtramos en memoria para evitar índice compuesto
  Stream<List<PedidoModel>> getPedidosPendientesStream() {
    return _pedidos
        .snapshots()
        .map((snapshot) {
      final lista = snapshot.docs.map((doc) {
        return PedidoModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      // Filtrar pendientes y ordenar — todo en memoria, sin índice
      return lista
          .where((p) => p.estatus == EstatusPedido.pendiente)
          .toList()
        ..sort((a, b) {
          if (a.fechaEntrega == null && b.fechaEntrega == null) return 0;
          if (a.fechaEntrega == null) return 1;
          if (b.fechaEntrega == null) return -1;
          return a.fechaEntrega!.compareTo(b.fechaEntrega!);
        });
    });
  }

  Future<PedidoModel> getPedidoPorId(String pedidoId) async {
    try {
      final doc = await _pedidos.doc(pedidoId).get();
      if (!doc.exists) throw FirestoreException.notFound('pedidos');
      return PedidoModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    } on FirestoreException {
      rethrow;
    } catch (e) {
      throw FirestoreException('Error al obtener pedido: ${e.toString()}');
    }
  }

  Future<void> actualizarEstatusPedido(
    String pedidoId,
    EstatusPedido estatus,
  ) async {
    await _pedidos.doc(pedidoId).update({'estatus': estatus.name});
  }

  Future<String> crearPedido(PedidoModel pedido) async {
    try {
      final docRef = _pedidos.doc(); // Autogenerar documento para obtener ID
      final customId = 'pedido_${docRef.id}';
      final finalPedido = pedido.copyWith(id: customId);
      await _pedidos.doc(customId).set(finalPedido.toMap());
      return customId;
    } catch (e) {
      throw FirestoreException('Error al crear pedido: ${e.toString()}');
    }
  }

  // ── VERIFICACIONES ───────────────────────────────────────────────────────

  Future<String> guardarVerificacion(VerificacionModel verificacion) async {
    try {
      final docRef = await _verificaciones.add(verificacion.toMap());
      return docRef.id;
    } catch (e) {
      throw FirestoreException(
          'Error al guardar verificación: ${e.toString()}');
    }
  }

  /// Historial — sin orderBy para evitar índice, ordenamos en memoria
  Stream<List<VerificacionModel>> getVerificacionesStream() {
    return _verificaciones
        .limit(100)
        .snapshots()
        .map((snapshot) {
      final lista = snapshot.docs.map((doc) {
        return VerificacionModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      // Más recientes primero
      lista.sort((a, b) => b.fecha.compareTo(a.fecha));
      return lista;
    });
  }

  Stream<List<VerificacionModel>> getVerificacionesPorEmpleado(
      String empleadoEmail) {
    return _verificaciones
        .where('empleadoEmail', isEqualTo: empleadoEmail)
        .snapshots()
        .map((snapshot) {
      final lista = snapshot.docs.map((doc) {
        return VerificacionModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();

      lista.sort((a, b) => b.fecha.compareTo(a.fecha));
      return lista;
    });
  }
}
