import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/haircut.dart';
import 'auth_service.dart';

class HaircutService extends ChangeNotifier {
  static final HaircutService _instance = HaircutService._internal();
  factory HaircutService() => _instance;

  StreamSubscription<QuerySnapshot>? _haircutsSubscription;
  StreamSubscription<DocumentSnapshot>? _savedSubscription;

  HaircutService._internal() {
    _initFirestoreListener();
    _initAuthListener();
  }

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  final List<Haircut> _haircuts = [];
  final Set<String> _savedHaircutIds = {};
  bool _isLoading = true;

  List<Haircut> get haircuts => List.unmodifiable(_haircuts);
  Set<String> get savedHaircutIds => Set.unmodifiable(_savedHaircutIds);
  bool get isLoading => _isLoading;

  List<Haircut> get savedHaircuts {
    return _haircuts.where((h) => _savedHaircutIds.contains(h.id)).toList();
  }

  bool isHaircutSaved(String haircutId) => _savedHaircutIds.contains(haircutId);

  void toggleSaveHaircut(String haircutId) {
    if (_savedHaircutIds.contains(haircutId)) {
      _savedHaircutIds.remove(haircutId);
    } else {
      _savedHaircutIds.add(haircutId);
    }
    notifyListeners();
    _persistSavedHaircuts();
  }

  void _initAuthListener() {
    AuthService().addListener(() {
      _loadSavedHaircuts();
    });
    _loadSavedHaircuts();
  }

  Future<void> _loadSavedHaircuts() async {
    final user = AuthService().currentUser;
    final fs = _firestore;
    if (user == null || fs == null) {
      _savedHaircutIds.clear();
      notifyListeners();
      return;
    }

    try {
      _savedSubscription?.cancel();
      _savedSubscription = fs.collection('users').doc(user.uid).snapshots().listen((doc) {
        if (doc.exists) {
          final data = doc.data();
          final rawSaved = data?['savedHaircutIds'];
          if (rawSaved is List) {
            _savedHaircutIds.clear();
            _savedHaircutIds.addAll(rawSaved.map((e) => e.toString()));
            notifyListeners();
          }
        }
      }, onError: (e) {
        debugPrint('Erro ao ouvir savedHaircutIds: $e');
      });
    } catch (e) {
      debugPrint('Erro ao carregar haircuts salvos do usuário: $e');
    }
  }

  Future<void> _persistSavedHaircuts() async {
    final user = AuthService().currentUser;
    final fs = _firestore;
    if (user != null && fs != null) {
      try {
        await fs.collection('users').doc(user.uid).set({
          'savedHaircutIds': _savedHaircutIds.toList(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Erro ao persistir haircuts salvos: $e');
      }
    }
  }

  void _initFirestoreListener() {
    final fs = _firestore;
    if (fs == null) {
      _isLoading = false;
      return;
    }

    try {
      _haircutsSubscription?.cancel();
      _haircutsSubscription = fs
          .collection('haircuts')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((snapshot) {
        _haircuts.clear();
        for (final doc in snapshot.docs) {
          try {
            final data = doc.data();
            _haircuts.add(Haircut.fromMap(data, doc.id));
          } catch (e) {
            debugPrint('Erro ao converter haircut ${doc.id}: $e');
          }
        }
        _isLoading = false;
        notifyListeners();
      }, onError: (err) {
        debugPrint('Erro no stream de haircuts: $err');
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Erro ao inicializar listener de haircuts: $e');
      _isLoading = false;
    }
  }

  Future<void> refreshHaircuts() async {
    final fs = _firestore;
    if (fs == null) return;
    try {
      final snap = await fs.collection('haircuts').orderBy('createdAt', descending: true).get();
      _haircuts.clear();
      for (final doc in snap.docs) {
        _haircuts.add(Haircut.fromMap(doc.data(), doc.id));
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao atualizar haircuts: $e');
    }
  }

  @override
  void dispose() {
    _haircutsSubscription?.cancel();
    _savedSubscription?.cancel();
    super.dispose();
  }
}
