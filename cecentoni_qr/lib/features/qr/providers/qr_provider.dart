import 'package:cecentoni_qr/models/producto_model.dart';
import 'package:cecentoni_qr/services/qr_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final qrServiceProvider = Provider<QrService>((ref) => const QrService());

// ── Estado ───────────────────────────────────────────────────────────────────

class QrScannerState {
  final bool isScanning;
  final bool scanned;
  final ProductoModel? producto;
  final String? errorMessage;

  const QrScannerState({
    this.isScanning = true,
    this.scanned = false,
    this.producto,
    this.errorMessage,
  });

  QrScannerState copyWith({
    bool? isScanning,
    bool? scanned,
    ProductoModel? producto,
    String? errorMessage,
  }) {
    return QrScannerState(
      isScanning: isScanning ?? this.isScanning,
      scanned: scanned ?? this.scanned,
      producto: producto ?? this.producto,
      errorMessage: errorMessage,
    );
  }
}

// FIX: migrado de StateNotifier → Notifier (API moderna Riverpod 2.x)
class QrScannerNotifier extends Notifier<QrScannerState> {
  @override
  QrScannerState build() => const QrScannerState();

  void procesarQr(String rawData) {
    if (state.scanned) return;
    try {
      final producto = ref.read(qrServiceProvider).parsearQr(rawData);
      state = state.copyWith(
        isScanning: false,
        scanned: true,
        producto: producto,
      );
    } catch (e) {
      state = state.copyWith(
        isScanning: false,
        scanned: true,
        errorMessage: e.toString(),
      );
    }
  }

  void reiniciar() => state = const QrScannerState();
}

final qrScannerProvider = NotifierProvider<QrScannerNotifier, QrScannerState>(
  QrScannerNotifier.new,
);