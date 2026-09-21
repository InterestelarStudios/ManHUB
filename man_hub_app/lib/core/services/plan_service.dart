import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class PlanService extends ChangeNotifier {
  static final PlanService _instance = PlanService._internal();
  factory PlanService() => _instance;

  static const String collectionName = 'plans';
  static const String defaultPassId = 'man_hub_pass';

  double _price = 49.90;
  String _name = 'Man Hub Pass';
  String _description =
      'O Man Hub Pass desbloqueia todos os cursos, quizzes, looks recomendados e o armário virtual de estilo em uma única experiência contínua.';
  bool _initialized = false;

  double get price => _price;
  String get name => _name;
  String get description => _description;

  String get formattedPrice =>
      'R\$ ${_price.toStringAsFixed(2).replaceAll('.', ',')}';

  String get formattedMonthlyPrice => '$formattedPrice/mês';

  PlanService._internal() {
    _initListener();
  }

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      debugPrint('Firestore não inicializado no PlanService: $e');
      return null;
    }
  }

  void _initListener() {
    if (_initialized) return;
    _initialized = true;

    final fs = _firestore;
    if (fs == null) return;

    try {
      fs.collection(collectionName).doc(defaultPassId).snapshots().listen(
        (doc) {
          if (doc.exists) {
            final data = doc.data();
            if (data != null) {
              final rawPrice = data['price'];
              if (rawPrice is num) {
                _price = rawPrice.toDouble();
              } else if (rawPrice != null) {
                final parsed = double.tryParse(
                  rawPrice.toString().replaceAll(',', '.'),
                );
                if (parsed != null && parsed > 0) {
                  _price = parsed;
                }
              }

              if (data['name'] is String && (data['name'] as String).isNotEmpty) {
                _name = data['name'] as String;
              }

              if (data['description'] is String &&
                  (data['description'] as String).isNotEmpty) {
                _description = data['description'] as String;
              }

              notifyListeners();
            }
          }
        },
        onError: (err) {
          debugPrint('Aviso ao escutar plans/$defaultPassId no Firestore: $err');
        },
      );
    } catch (e) {
      debugPrint('Erro ao inicializar listener de planos: $e');
    }
  }

  /// Força a busca do valor atualizado
  Future<double> fetchCurrentPrice() async {
    final fs = _firestore;
    if (fs == null) return _price;

    try {
      final doc = await fs.collection(collectionName).doc(defaultPassId).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          final rawPrice = data['price'];
          if (rawPrice is num) {
            _price = rawPrice.toDouble();
          } else if (rawPrice != null) {
            final parsed = double.tryParse(
              rawPrice.toString().replaceAll(',', '.'),
            );
            if (parsed != null && parsed > 0) {
              _price = parsed;
            }
          }
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar plano no Firestore: $e');
    }
    return _price;
  }
}
