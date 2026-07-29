import 'dart:convert';
import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';
import '../domain/models/training.dart';

class ExportService {
  static Future<void> exportTrainingToJson(Training training) async {
    final jsonString = jsonEncode(training.toJson());
    final bytes = Uint8List.fromList(utf8.encode(jsonString));
    
    // O file_saver cuida de mostrar o dialog no Desktop/Mobile e fazer o download automático na Web
    await FileSaver.instance.saveFile(
      name: 'curso_${training.title.replaceAll(' ', '_').toLowerCase()}',
      bytes: bytes,
      fileExtension: 'json',
      mimeType: MimeType.json,
    );
  }
}
