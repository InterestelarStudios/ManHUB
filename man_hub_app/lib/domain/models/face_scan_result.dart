import 'dart:typed_data';

/// Representa o resultado de uma análise biométrica e de visagismo facial.
class FaceScanResult {
  /// Formato canônico correspondente às opções do app:
  /// 'Oval', 'Quadrado', 'Redondo', 'Retangular / Oblongo', 'Diamante', 'Triangular'
  final String faceShape;

  /// Subtítulo visual (ex: 'Marcante & Angular')
  final String subtitle;

  /// Pontuação de precisão / confiança (de 0 a 100)
  final int confidenceScore;

  /// Descrição detalhada do diagnóstico de visagismo
  final String description;

  /// Diagnóstico das proporções geométricas observadas
  final Map<String, String> proportions;

  /// Sugestões de cortes de cabelo que harmonizam o formato
  final List<String> haircutTips;

  /// Sugestões de desenho e modelagem de barba
  final List<String> beardTips;

  /// Sugestões de armações de óculos
  final List<String> glassesTips;

  /// Bytes da imagem capturada para exibição no resultado
  final Uint8List? imageBytes;

  const FaceScanResult({
    required this.faceShape,
    required this.subtitle,
    required this.confidenceScore,
    required this.description,
    required this.proportions,
    required this.haircutTips,
    required this.beardTips,
    required this.glassesTips,
    this.imageBytes,
  });

  /// Lista oficial dos 6 formatos de rosto suportados no app
  static const List<String> canonicalFaceShapes = [
    'Oval',
    'Quadrado',
    'Redondo',
    'Retangular / Oblongo',
    'Diamante',
    'Triangular',
  ];

  /// Valida se uma string é um dos 6 formatos canônicos
  static bool isValidShape(String shape) {
    return canonicalFaceShapes.contains(shape);
  }

  /// Normaliza qualquer variação de texto para um dos 6 formatos canônicos
  static String normalizeShape(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'Oval';

    final lower = raw.toLowerCase().trim();
    if (lower.contains('quadrad') || lower.contains('square')) {
      return 'Quadrado';
    }
    if (lower.contains('redond') || lower.contains('round')) {
      return 'Redondo';
    }
    if (lower.contains('retang') ||
        lower.contains('oblong') ||
        lower.contains('alongad') ||
        lower.contains('rectangle')) {
      return 'Retangular / Oblongo';
    }
    if (lower.contains('diamant') || lower.contains('diamond')) {
      return 'Diamante';
    }
    if (lower.contains('triang') ||
        lower.contains('coraç') ||
        lower.contains('triangle') ||
        lower.contains('heart')) {
      return 'Triangular';
    }
    return 'Oval';
  }

  Map<String, dynamic> toMap() {
    return {
      'faceShape': faceShape,
      'subtitle': subtitle,
      'confidenceScore': confidenceScore,
      'description': description,
      'proportions': proportions,
      'haircutTips': haircutTips,
      'beardTips': beardTips,
      'glassesTips': glassesTips,
    };
  }

  factory FaceScanResult.fromMap(Map<String, dynamic> map, {Uint8List? imageBytes}) {
    final shape = normalizeShape(map['faceShape'] as String?);
    return FaceScanResult(
      faceShape: shape,
      subtitle: map['subtitle'] as String? ?? 'Visagismo Identificado',
      confidenceScore: (map['confidenceScore'] as num?)?.toInt() ?? 90,
      description: map['description'] as String? ??
          'Proporções faciais analisadas e harmonizadas com visagismo masculino.',
      proportions: Map<String, String>.from(map['proportions'] ?? {}),
      haircutTips: List<String>.from(map['haircutTips'] ?? []),
      beardTips: List<String>.from(map['beardTips'] ?? []),
      glassesTips: List<String>.from(map['glassesTips'] ?? []),
      imageBytes: imageBytes,
    );
  }
}
