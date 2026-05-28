import 'dart:convert';

/// Modelo que representa un producto (piso) de Cecentoni.
///
/// Este modelo cumple tres funciones:
/// 1. Representar datos de Firestore (fromFirestore)
/// 2. Parsear el contenido del QR (fromQrJson)
/// 3. Serializar para guardar en Firestore (toMap)
///
/// Al usar un solo modelo para ambas fuentes (QR + Firestore),
/// la comparación en la validación es directa y limpia.
class ProductoModel {
  final String? id;        // ID del documento Firestore (null si viene del QR)
  final String modelo;
  final String color;
  final String medida;
  final String lote;
  final String? cliente;
  final String? imagen;    // URL de Firebase Storage (opcional)
  final String? estatus;

  const ProductoModel({
    this.id,
    required this.modelo,
    required this.color,
    required this.medida,
    required this.lote,
    this.cliente,
    this.imagen,
    this.estatus,
  });

  // ── Constructores de fábrica ─────────────────────────────────────────────

  /// Crea un ProductoModel desde un documento de Firestore.
  factory ProductoModel.fromFirestore(Map<String, dynamic> map, String docId) {
    return ProductoModel(
      id: docId,
      modelo: map['modelo'] as String? ?? '',
      color: map['color'] as String? ?? '',
      medida: map['medida'] as String? ?? '',
      lote: map['lote'] as String? ?? '',
      cliente: map['cliente'] as String?,
      imagen: map['imagen'] as String?,
      estatus: map['estatus'] as String?,
    );
  }

  /// Crea un ProductoModel desde el JSON escaneado en un QR.
  ///
  /// El QR contiene un String JSON con este formato:
  /// {"modelo":"Marmol Beige","color":"Beige","medida":"60x60","lote":"LT2294"}
  ///
  /// Pasos del parseo:
  /// 1. jsonDecode convierte el String a Map<String, dynamic>
  /// 2. Extraemos cada campo con cast seguro
  /// 3. Si falta algún campo obligatorio → lanzamos FormatException
  factory ProductoModel.fromQrString(String qrData) {
    // Paso 1: Parsear el JSON crudo
    final Map<String, dynamic> map;
    try {
      map = jsonDecode(qrData) as Map<String, dynamic>;
    } catch (_) {
      throw FormatException('El QR no contiene JSON válido: $qrData');
    }

    // Paso 2: Validar campos obligatorios
    final requiredFields = ['modelo', 'color', 'medida', 'lote'];
    for (final field in requiredFields) {
      if (!map.containsKey(field) || (map[field] as String?)?.isEmpty == true) {
        throw FormatException('El QR no contiene el campo requerido: "$field"');
      }
    }

    // Paso 3: Construir el modelo
    return ProductoModel(
      modelo: map['modelo'] as String,
      color: map['color'] as String,
      medida: map['medida'] as String,
      lote: map['lote'] as String,
    );
  }

  // ── Serialización ────────────────────────────────────────────────────────

  /// Convierte el modelo a Map para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'modelo': modelo,
      'color': color,
      'medida': medida,
      'lote': lote,
      if (cliente != null) 'cliente': cliente,
      if (imagen != null) 'imagen': imagen,
      if (estatus != null) 'estatus': estatus,
    };
  }

  // ── Igualdad / Comparación ───────────────────────────────────────────────
  // Este es el corazón de la VALIDACIÓN.
  // Dos productos son iguales si coinciden modelo, color, medida y lote.
  // Usamos .toLowerCase().trim() para evitar falsos negativos por
  // diferencias de mayúsculas o espacios en los datos.

  /// Compara si este producto coincide con otro (para la validación del pedido).
  bool coincideCon(ProductoModel otro) {
    return _normalizar(modelo) == _normalizar(otro.modelo) &&
        _normalizar(color) == _normalizar(otro.color) &&
        _normalizar(medida) == _normalizar(otro.medida) &&
        _normalizar(lote) == _normalizar(otro.lote);
  }

  String _normalizar(String valor) => valor.toLowerCase().trim();

  // ── Overrides estándar ───────────────────────────────────────────────────
  @override
  bool operator ==(Object other) =>
      other is ProductoModel && coincideCon(other);

  @override
  int get hashCode =>
      _normalizar(modelo).hashCode ^
      _normalizar(color).hashCode ^
      _normalizar(medida).hashCode ^
      _normalizar(lote).hashCode;

  @override
  String toString() =>
      'Producto($modelo | $color | $medida | $lote)';

  /// Crea una copia con campos modificados (patrón copyWith)
  ProductoModel copyWith({
    String? id,
    String? modelo,
    String? color,
    String? medida,
    String? lote,
    String? cliente,
    String? imagen,
    String? estatus,
  }) {
    return ProductoModel(
      id: id ?? this.id,
      modelo: modelo ?? this.modelo,
      color: color ?? this.color,
      medida: medida ?? this.medida,
      lote: lote ?? this.lote,
      cliente: cliente ?? this.cliente,
      imagen: imagen ?? this.imagen,
      estatus: estatus ?? this.estatus,
    );
  }
}