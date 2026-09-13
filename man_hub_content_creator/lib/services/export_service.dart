import 'dart:convert';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
import '../domain/models/training.dart';

class ExportService {
  static Future<void> exportTrainingToJson(Training training) async {
    // Atualiza a data da última modificação automaticamente no momento da exportação
    training.updatedAt = DateTime.now().toIso8601String();

    final jsonString = const JsonEncoder.withIndent('  ').convert(training.toJson());
    final bytes = Uint8List.fromList(utf8.encode(jsonString));
    
    // O file_saver cuida de mostrar o dialog no Desktop/Mobile e fazer o download automático na Web
    await FileSaver.instance.saveFile(
      name: 'curso_${training.title.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_').toLowerCase()}',
      bytes: bytes,
      fileExtension: 'json',
      mimeType: MimeType.json,
    );
  }
}
