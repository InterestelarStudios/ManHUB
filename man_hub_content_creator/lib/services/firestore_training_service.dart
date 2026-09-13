import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../domain/models/training.dart';

class FirestoreTrainingService {
  static final FirestoreTrainingService _instance = FirestoreTrainingService._internal();
  factory FirestoreTrainingService() => _instance;
  FirestoreTrainingService._internal();

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      debugPrint('Firestore não inicializado: $e');
      return null;
    }
  }

  bool get isAvailable => _firestore != null;

  CollectionReference<Map<String, dynamic>>? get _trainingsCollection {
    final fs = _firestore;
    if (fs == null) return null;
    return fs.collection('trainings');
  }

  /// Busca todos os treinamentos cadastrados no Firestore
  Future<List<Training>> fetchTrainings() async {
    final col = _trainingsCollection;
    if (col == null) return [];

    try {
      final snapshot = await col.get();
      final trainings = snapshot.docs.map((doc) {
        final data = doc.data();
        if (!data.containsKey('id') || data['id'] == null || (data['id'] as String).isEmpty) {
          data['id'] = doc.id;
        }
        return Training.fromJson(data);
      }).toList();

      // Ordena pelos mais recentemente atualizados primeiro
      trainings.sort((a, b) {
        final dateA = a.updatedAt != null ? DateTime.tryParse(a.updatedAt!) : null;
        final dateB = b.updatedAt != null ? DateTime.tryParse(b.updatedAt!) : null;
        if (dateA != null && dateB != null) {
          return dateB.compareTo(dateA);
        }
        return a.title.compareTo(b.title);
      });

      return trainings;
    } catch (e) {
      debugPrint('Erro ao buscar treinamentos do Firestore: $e');
      rethrow;
    }
  }

  /// Escuta alterações em tempo real na coleção de treinamentos
  Stream<List<Training>> streamTrainings() {
    final col = _trainingsCollection;
    if (col == null) {
      return const Stream.empty();
    }

    return col.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        if (!data.containsKey('id') || data['id'] == null || (data['id'] as String).isEmpty) {
          data['id'] = doc.id;
        }
        return Training.fromJson(data);
      }).toList();
    });
  }

  /// Salva ou atualiza um treinamento completo no Firestore
  Future<void> saveTraining(Training training) async {
    final col = _trainingsCollection;
    if (col == null) {
      throw StateError('Firebase Firestore não está disponível.');
    }

    // Atualiza a estampa de data e hora
    training.updatedAt = DateTime.now().toIso8601String();

    try {
      final data = training.toJson();
      await col.doc(training.id).set(data, SetOptions(merge: true));
      debugPrint('Treinamento "${training.title}" (${training.id}) salvo com sucesso no Firestore.');
    } catch (e) {
      debugPrint('Erro ao salvar treinamento no Firestore: $e');
      rethrow;
    }
  }

  /// Exclui um treinamento do Firestore
  Future<void> deleteTraining(String trainingId) async {
    final col = _trainingsCollection;
    if (col == null) {
      throw StateError('Firebase Firestore não está disponível.');
    }

    try {
      await col.doc(trainingId).delete();
      debugPrint('Treinamento $trainingId excluído do Firestore.');
    } catch (e) {
      debugPrint('Erro ao excluir treinamento no Firestore: $e');
      rethrow;
    }
  }
}
