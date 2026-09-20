import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/outfit.dart';
import 'auth_service.dart';

class OutfitService extends ChangeNotifier {
  static final OutfitService _instance = OutfitService._internal();
  factory OutfitService() => _instance;

  StreamSubscription<QuerySnapshot>? _outfitsSubscription;
  StreamSubscription<DocumentSnapshot>? _savedSubscription;

  OutfitService._internal() {
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

  final List<Outfit> _outfits = [];
  final Set<String> _savedOutfitIds = {};
  bool _isLoading = true;

  List<Outfit> get outfits => List.unmodifiable(_outfits);
  Set<String> get savedOutfitIds => Set.unmodifiable(_savedOutfitIds);
  bool get isLoading => _isLoading;

  List<Outfit> get savedOutfits {
    return _outfits.where((o) => _savedOutfitIds.contains(o.id)).toList();
  }

  bool isOutfitSaved(String outfitId) => _savedOutfitIds.contains(outfitId);

  void toggleSaveOutfit(String outfitId) {
    if (_savedOutfitIds.contains(outfitId)) {
      _savedOutfitIds.remove(outfitId);
    } else {
      _savedOutfitIds.add(outfitId);
    }
    notifyListeners();
    _persistSavedOutfits();
  }

  void _initAuthListener() {
    AuthService().addListener(() {
      _loadSavedOutfits();
    });
    _loadSavedOutfits();
  }

  Future<void> _loadSavedOutfits() async {
    final user = AuthService().currentUser;
    final fs = _firestore;
    if (user == null || fs == null) {
      _savedOutfitIds.clear();
      notifyListeners();
      return;
    }

    try {
      _savedSubscription?.cancel();
      _savedSubscription = fs.collection('users').doc(user.uid).snapshots().listen((doc) {
        if (doc.exists) {
          final data = doc.data();
          final rawSaved = data?['savedOutfitIds'];
          if (rawSaved is List) {
            _savedOutfitIds.clear();
            _savedOutfitIds.addAll(rawSaved.map((e) => e.toString()));
            notifyListeners();
          }
        }
      }, onError: (e) {
        debugPrint('Erro ao ouvir savedOutfitIds: $e');
      });
    } catch (e) {
      debugPrint('Erro ao carregar outfits salvos do usuário: $e');
    }
  }

  Future<void> _persistSavedOutfits() async {
    final user = AuthService().currentUser;
    final fs = _firestore;
    if (user != null && fs != null) {
      try {
        await fs.collection('users').doc(user.uid).set({
          'savedOutfitIds': _savedOutfitIds.toList(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Erro ao persistir outfits salvos: $e');
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
      _outfitsSubscription?.cancel();
      _outfitsSubscription = fs
          .collection('outfits')
          .orderBy('createdAt', descending: true)
          .limit(40)
          .snapshots()
          .listen((snapshot) {
        _outfits.clear();
        for (final doc in snapshot.docs) {
          try {
            _outfits.add(Outfit.fromFirestore(doc));
          } catch (e) {
            debugPrint('Erro ao parsear outfit ${doc.id}: $e');
          }
        }
        _isLoading = false;
        notifyListeners();
      }, onError: (e) {
        debugPrint('Erro no stream de outfits: $e');
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Erro ao inicializar listener de outfits: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> publishOutfit(Outfit outfit) async {
    final fs = _firestore;
    final outfitId = outfit.id.isEmpty ? const Uuid().v4() : outfit.id;
    final newOutfit = outfit.copyWith(id: outfitId);

    if (fs != null) {
      try {
        await fs.collection('outfits').doc(outfitId).set(newOutfit.toMap());
      } catch (e) {
        debugPrint('Erro ao publicar outfit no Firestore: $e');
      }
    }
  }

  Future<void> refreshOutfits() async {
    _initFirestoreListener();
    _loadSavedOutfits();
  }

  @override
  void dispose() {
    _outfitsSubscription?.cancel();
    _savedSubscription?.cancel();
    super.dispose();
  }
}

