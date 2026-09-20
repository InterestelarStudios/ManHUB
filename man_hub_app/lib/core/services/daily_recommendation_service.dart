import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/daily_recommendation.dart';

class DailyRecommendationService extends ChangeNotifier {
  static final DailyRecommendationService _instance =
      DailyRecommendationService._internal();
  factory DailyRecommendationService() => _instance;

  DailyRecommendationService._internal() {
    _startListening();
  }

  static const String collectionName = 'daily_recommendations';
  static const String activeDocId = 'active_featured';

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _collectionSubscription;

  List<DailyRecommendation> _recommendations = [];
  bool _isLoading = true;

  List<DailyRecommendation> get recommendations => _recommendations;
  DailyRecommendation? get currentRecommendation =>
      _recommendations.isNotEmpty ? _recommendations.first : null;
  bool get isLoading => _isLoading;

  void _startListening() {
    final fs = _firestore;
    if (fs == null) {
      _isLoading = false;
      return;
    }

    try {
      final col = fs
          .collection(collectionName)
          .orderBy('createdAt', descending: true)
          .limit(10);
      _collectionSubscription = col.snapshots().listen(
        (snapshot) {
          final list = <DailyRecommendation>[];
          for (final doc in snapshot.docs) {
            // Ignora o documento espelho legado
            if (doc.id == activeDocId) continue;
            final rec = DailyRecommendation.fromFirestore(doc);
            list.add(rec);
          }

          _recommendations = list;
          _isLoading = false;
          notifyListeners();
        },
        onError: (err) {
          debugPrint('Erro ao escutar recomendações do Firestore: $err');
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('Erro ao inicializar listener de recomendações: $e');
      _isLoading = false;
    }
  }

  Future<List<DailyRecommendation>> fetchRecommendations() async {
    final fs = _firestore;
    if (fs == null) return [];

    try {
      final snapshot = await fs.collection(collectionName).get();
      final list = <DailyRecommendation>[];
      for (final doc in snapshot.docs) {
        if (doc.id == activeDocId) continue;
        final rec = DailyRecommendation.fromFirestore(doc);
        list.add(rec);
      }
      _recommendations = list;
      notifyListeners();
      return _recommendations;
    } catch (e) {
      debugPrint('Erro ao buscar recomendações: $e');
      return [];
    }
  }

  @override
  void dispose() {
    _collectionSubscription?.cancel();
    super.dispose();
  }
}
