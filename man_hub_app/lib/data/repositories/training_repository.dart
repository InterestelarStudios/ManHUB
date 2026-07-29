import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/models/training.dart';

class TrainingRepository {
  Future<Training> getLocalTraining() async {
    // Carrega o JSON da pasta contents
    final String jsonString = await rootBundle.loadString('contents/curso_jornada_do_homem_de_valor.json');
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    
    // Converte para o objeto Training
    return Training.fromJson(jsonMap);
  }
}
