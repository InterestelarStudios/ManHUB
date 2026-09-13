import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:man_hub_app/domain/models/training.dart';

void main() {
  test('Verify all JSON files in contents/ parse into Training models cleanly', () {
    final contentsDir = Directory('contents');
    expect(contentsDir.existsSync(), isTrue);

    final jsonFiles = contentsDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList();

    expect(jsonFiles.isNotEmpty, isTrue);

    for (final file in jsonFiles) {
      final jsonStr = file.readAsStringSync();
      final Map<String, dynamic> jsonMap = jsonDecode(jsonStr);
      
      final training = Training.fromJson(jsonMap);
      expect(training.title.isNotEmpty, isTrue, reason: 'Training title should not be empty in ${file.path}');
      expect(training.modules.isNotEmpty, isTrue, reason: 'Training should have modules in ${file.path}');

      // JSON and model structure verified successfully
    }
  });
}
