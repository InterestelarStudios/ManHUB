import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:man_hub_app/domain/models/face_scan_result.dart';
import 'package:man_hub_app/core/services/face_scan_service.dart';

void main() {
  group('FaceScanResult Model Tests', () {
    test('Deve validar os 6 formatos canônicos oficiais', () {
      final expectedShapes = [
        'Oval',
        'Quadrado',
        'Redondo',
        'Retangular / Oblongo',
        'Diamante',
        'Triangular',
      ];

      expect(FaceScanResult.canonicalFaceShapes, equals(expectedShapes));

      for (final shape in expectedShapes) {
        expect(FaceScanResult.isValidShape(shape), isTrue);
      }

      expect(FaceScanResult.isValidShape('Coração'), isFalse);
      expect(FaceScanResult.isValidShape('Inexistente'), isFalse);
    });

    test('Deve normalizar corretamente variações para formatos canônicos', () {
      expect(FaceScanResult.normalizeShape('quadrado'), equals('Quadrado'));
      expect(FaceScanResult.normalizeShape('square'), equals('Quadrado'));
      expect(FaceScanResult.normalizeShape('redondo'), equals('Redondo'));
      expect(FaceScanResult.normalizeShape('round'), equals('Redondo'));
      expect(FaceScanResult.normalizeShape('retangular'), equals('Retangular / Oblongo'));
      expect(FaceScanResult.normalizeShape('oblongo'), equals('Retangular / Oblongo'));
      expect(FaceScanResult.normalizeShape('diamante'), equals('Diamante'));
      expect(FaceScanResult.normalizeShape('diamond'), equals('Diamante'));
      expect(FaceScanResult.normalizeShape('triangular'), equals('Triangular'));
      expect(FaceScanResult.normalizeShape('coração'), equals('Triangular'));
      expect(FaceScanResult.normalizeShape('oval'), equals('Oval'));
      expect(FaceScanResult.normalizeShape(null), equals('Oval'));
    });
  });

  group('FaceScanService Tests', () {
    test('analyzeFace deve gerar diagnóstico estritamente dentro dos 6 formatos canônicos', () async {
      final service = FaceScanService();
      final dummyBytes = Uint8List.fromList(List.generate(200, (i) => (i * 7) % 256));

      final result = await service.analyzeFace(dummyBytes);

      expect(FaceScanResult.isValidShape(result.faceShape), isTrue);
      expect(result.confidenceScore, greaterThanOrEqualTo(85));
      expect(result.confidenceScore, lessThanOrEqualTo(100));
      expect(result.description, isNotEmpty);
      expect(result.proportions, isNotEmpty);
      expect(result.haircutTips, isNotEmpty);
      expect(result.beardTips, isNotEmpty);
      expect(result.glassesTips, isNotEmpty);
    });
  });
}
