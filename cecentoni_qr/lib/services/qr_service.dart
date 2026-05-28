import '../models/producto_model.dart';
import '../core/errors/app_exceptions.dart';

/// Servicio que maneja el procesamiento de datos QR.
///
/// Separa la lógica de parseo del QR de la lógica de la cámara.
/// La pantalla QrScannerScreen solo captura el string raw del QR;
/// este servicio lo convierte en un ProductoModel.
class QrService {
  const QrService();

  /// Parsea el string raw escaneado del QR y retorna un ProductoModel.
  ///
  /// FLUJO COMPLETO DEL PARSEO:
  ///
  /// 1. El scanner de cámara devuelve un String (el contenido del QR).
  ///    Ejemplo: '{"modelo":"Marmol Beige","color":"Beige","medida":"60x60","lote":"LT2294"}'
  ///
  /// 2. Este método llama a ProductoModel.fromQrString(raw):
  ///    - jsonDecode() convierte el String a Map<String,dynamic>
  ///    - Se validan los campos obligatorios
  ///    - Se construye y retorna el ProductoModel
  ///
  /// 3. Si algo falla, lanzamos QrException con un mensaje útil.
  ///
  /// Lanza [QrException] si el QR es inválido o incompleto.
  ProductoModel parsearQr(String rawQrData) {
    if (rawQrData.trim().isEmpty) {
      throw QrException.invalidFormat();
    }

    try {
      return ProductoModel.fromQrString(rawQrData);
    } on FormatException catch (e) {
      // FormatException viene de ProductoModel.fromQrString
      if (e.message.contains('campo requerido')) {
        throw QrException.missingFields();
      }
      throw QrException.invalidFormat();
    } catch (e) {
      throw QrException('Error al procesar QR: ${e.toString()}');
    }
  }

  /// Valida si un string tiene estructura de JSON de producto
  bool esQrValido(String rawQrData) {
    try {
      parsearQr(rawQrData);
      return true;
    } catch (_) {
      return false;
    }
  }
}