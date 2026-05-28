import 'package:cecentoni_qr/models/pedido_model.dart';
import 'package:cecentoni_qr/services/firestore_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Providers de servicio ────────────────────────────────────────────────────

final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(),
);

// ── Streams de pedidos ───────────────────────────────────────────────────────

final pedidosPendientesProvider = StreamProvider<List<PedidoModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getPedidosPendientesStream();
});

final todosPedidosProvider = StreamProvider<List<PedidoModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getPedidosStream();
});

// ── Pedido seleccionado ──────────────────────────────────────────────────────

final pedidoSeleccionadoProvider = StateProvider<PedidoModel?>((ref) => null);
