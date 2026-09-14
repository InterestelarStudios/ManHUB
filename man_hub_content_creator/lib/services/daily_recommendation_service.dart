import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../domain/models/daily_recommendation.dart';

class DailyRecommendationService {
  static final DailyRecommendationService _instance = DailyRecommendationService._internal();
  factory DailyRecommendationService() => _instance;
  DailyRecommendationService._internal();

  static const String collectionName = 'daily_recommendations';
  static const String activeDocId = 'active_featured';

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      debugPrint('Firestore não inicializado: $e');
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>>? get _collection {
    final fs = _firestore;
    if (fs == null) return null;
    return fs.collection(collectionName);
  }

  /// Stream em tempo real de todas as recomendações cadastradas
  Stream<List<DailyRecommendation>> streamRecommendations() {
    final col = _collection;
    if (col == null) return const Stream.empty();

    return col.snapshots().map((snapshot) {
      final list = <DailyRecommendation>[];
      for (final doc in snapshot.docs) {
        // Ignora o documento espelho 'active_featured'
        if (doc.id == activeDocId) continue;
        list.add(DailyRecommendation.fromFirestore(doc));
      }
      // Ordena pelas mais recentes
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Busca a lista atual de recomendações
  Future<List<DailyRecommendation>> fetchRecommendations() async {
    final col = _collection;
    if (col == null) return [];

    try {
      final snapshot = await col.get();
      final list = <DailyRecommendation>[];
      for (final doc in snapshot.docs) {
        if (doc.id == activeDocId) continue;
        list.add(DailyRecommendation.fromFirestore(doc));
      }
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (e) {
      debugPrint('Erro ao buscar recomendações do Firestore: $e');
      return [];
    }
  }

  /// Salva ou atualiza uma recomendação
  Future<bool> saveRecommendation(
    DailyRecommendation recommendation, {
    bool makeActive = true,
  }) async {
    final col = _collection;
    if (col == null) return false;

    try {
      final recId = recommendation.id.trim().isEmpty
          ? const Uuid().v4()
          : recommendation.id.trim();

      final toSave = recommendation.copyWith(
        id: recId,
        isActive: makeActive ? true : recommendation.isActive,
        updatedAt: DateTime.now().toIso8601String(),
      );

      final batch = _firestore!.batch();
      final docRef = col.doc(toSave.id);
      batch.set(docRef, toSave.toMap(), SetOptions(merge: true));

      if (makeActive) {
        // Atualiza o documento espelho 'active_featured'
        final activeRef = col.doc(activeDocId);
        batch.set(activeRef, toSave.toMap(), SetOptions(merge: true));
      }

      await batch.commit();
      debugPrint('Recomendação "${toSave.title}" salva com sucesso.');
      return true;
    } catch (e) {
      debugPrint('Erro ao salvar recomendação: $e');
      return false;
    }
  }

  /// Alterna o status de ativo/inativo de uma recomendação
  Future<bool> toggleActive(DailyRecommendation recommendation) async {
    final col = _collection;
    if (col == null) return false;

    try {
      final newStatus = !recommendation.isActive;
      await col.doc(recommendation.id).update({
        'isActive': newStatus,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('Erro ao alternar status da recomendação: $e');
      return false;
    }
  }

  /// Define uma recomendação existente como a ativa na Home
  Future<bool> setActiveRecommendation(DailyRecommendation recommendation) async {
    return toggleActive(recommendation);
  }

  /// Exclui uma recomendação
  Future<bool> deleteRecommendation(DailyRecommendation recommendation) async {
    final col = _collection;
    if (col == null) return false;

    try {
      final batch = _firestore!.batch();
      batch.delete(col.doc(recommendation.id));

      // Se for a que está ativa atualmente no active_featured, remove o destaque
      final activeDoc = await col.doc(activeDocId).get();
      if (activeDoc.exists && activeDoc.data()?['id'] == recommendation.id) {
        batch.delete(col.doc(activeDocId));
      }

      await batch.commit();
      debugPrint('Recomendação excluída com sucesso.');
      return true;
    } catch (e) {
      debugPrint('Erro ao excluir recomendação: $e');
      return false;
    }
  }
}
