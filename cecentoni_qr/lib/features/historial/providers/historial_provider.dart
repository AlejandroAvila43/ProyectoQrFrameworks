import 'package:cecentoni_qr/features/pedidos/providers/pedidos_provider.dart';
import 'package:cecentoni_qr/models/verificacion_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// Stream del historial de verificaciones
final historialProvider = StreamProvider<List<VerificacionModel>>((ref) {
  return ref.watch(firestoreServiceProvider).getVerificacionesStream();
});