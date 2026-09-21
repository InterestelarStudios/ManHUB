import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../domain/models/plan.dart';

class PlanCreatorService {
  static final PlanCreatorService _instance = PlanCreatorService._internal();
  factory PlanCreatorService() => _instance;
  PlanCreatorService._internal();

  static const String collectionName = 'plans';
  static const String defaultPassId = 'man_hub_pass';

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

  /// Escuta o plano principal (man_hub_pass) em tempo real
  Stream<Plan> streamMainPlan() {
    final col = _collection;
    if (col == null) {
      return Stream.value(_defaultPlan());
    }

    return col.doc(defaultPassId).snapshots().map((doc) {
      if (doc.exists) {
        return Plan.fromFirestore(doc);
      }
      return _defaultPlan();
    });
  }

  /// Busca o plano principal
  Future<Plan> fetchMainPlan() async {
    final col = _collection;
    if (col == null) return _defaultPlan();

    try {
      final doc = await col.doc(defaultPassId).get();
      if (doc.exists) {
        return Plan.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('Erro ao buscar plano $defaultPassId: $e');
    }
    return _defaultPlan();
  }

  /// Salva ou atualiza um plano no Firestore
  Future<bool> savePlan(Plan plan) async {
    final col = _collection;
    if (col == null) return false;

    try {
      await col.doc(plan.id).set(plan.toMap(), SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('Erro ao salvar plano ${plan.id} no Firestore: $e');
      return false;
    }
  }

  /// Atualiza especificamente o preço e descrição do plano principal
  Future<bool> updateMainPlanPrice({
    required double price,
    String? name,
    String? description,
  }) async {
    final col = _collection;
    if (col == null) return false;

    try {
      final updates = <String, dynamic>{
        'price': price,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (name != null && name.trim().isNotEmpty) {
        updates['name'] = name.trim();
      }
      if (description != null && description.trim().isNotEmpty) {
        updates['description'] = description.trim();
      }

      await col.doc(defaultPassId).set(updates, SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('Erro ao atualizar preço do plano $defaultPassId: $e');
      return false;
    }
  }

  Plan _defaultPlan() {
    return const Plan(
      id: defaultPassId,
      name: 'Man Hub Pass',
      description:
          'O Man Hub Pass desbloqueia todos os cursos, quizzes, looks recomendados e o armário virtual de estilo em uma única experiência contínua.',
      price: 49.90,
      currency: 'BRL',
      billingPeriod: 'monthly',
      features: [
        'Desbloqueio de todos os módulos de todos os cursos',
        'Visagismo, Perfumes, Estilo, Skincare, Presença e Postura',
        'Aulas imersivas estilo stories atualizadas com frequência',
        'Sincronização imediata entre seus dispositivos pelo seu e-mail',
      ],
      active: true,
    );
  }
}
