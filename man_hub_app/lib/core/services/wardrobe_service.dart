import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class SavedHaircut {
  final String id;
  final String title;
  final String faceShape;
  final String description;
  final String imageUrl;
  final String recommendedStylingProduct;

  const SavedHaircut({
    required this.id,
    required this.title,
    required this.faceShape,
    required this.description,
    required this.imageUrl,
    required this.recommendedStylingProduct,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'faceShape': faceShape,
        'description': description,
        'imageUrl': imageUrl,
        'recommendedStylingProduct': recommendedStylingProduct,
      };

  factory SavedHaircut.fromMap(Map<String, dynamic> map) => SavedHaircut(
        id: map['id'] as String? ?? '',
        title: map['title'] as String? ?? '',
        faceShape: map['faceShape'] as String? ?? '',
        description: map['description'] as String? ?? '',
        imageUrl: map['imageUrl'] as String? ?? '',
        recommendedStylingProduct: map['recommendedStylingProduct'] as String? ?? '',
      );
}

class SavedFragrance {
  final String id;
  final String name;
  final String brand;
  final String family; // Amadeirado, Cítrico, Oriental, etc.
  final String occasion;
  final String notes;
  final String imageUrl;
  final String? affiliateUrl;

  const SavedFragrance({
    required this.id,
    required this.name,
    required this.brand,
    required this.family,
    required this.occasion,
    required this.notes,
    required this.imageUrl,
    this.affiliateUrl,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'brand': brand,
        'family': family,
        'occasion': occasion,
        'notes': notes,
        'imageUrl': imageUrl,
        'affiliateUrl': affiliateUrl,
      };

  factory SavedFragrance.fromMap(Map<String, dynamic> map) => SavedFragrance(
        id: map['id'] as String? ?? '',
        name: map['name'] as String? ?? '',
        brand: map['brand'] as String? ?? '',
        family: map['family'] as String? ?? '',
        occasion: map['occasion'] as String? ?? '',
        notes: map['notes'] as String? ?? '',
        imageUrl: map['imageUrl'] as String? ?? '',
        affiliateUrl: map['affiliateUrl'] as String?,
      );
}

class WardrobeService extends ChangeNotifier {
  static final WardrobeService _instance = WardrobeService._internal();
  factory WardrobeService() => _instance;
  WardrobeService._internal() {
    _loadDefaultSavedItems();
  }

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  final List<SavedHaircut> _savedHaircuts = [];
  final List<SavedFragrance> _savedFragrances = [];

  List<SavedHaircut> get savedHaircuts => List.unmodifiable(_savedHaircuts);
  List<SavedFragrance> get savedFragrances => List.unmodifiable(_savedFragrances);

  void toggleSaveHaircut(SavedHaircut haircut) {
    final index = _savedHaircuts.indexWhere((h) => h.id == haircut.id);
    if (index >= 0) {
      _savedHaircuts.removeAt(index);
    } else {
      _savedHaircuts.add(haircut);
    }
    notifyListeners();
    _persistWardrobe();
  }

  void toggleSaveFragrance(SavedFragrance fragrance) {
    final index = _savedFragrances.indexWhere((f) => f.id == fragrance.id);
    if (index >= 0) {
      _savedFragrances.removeAt(index);
    } else {
      _savedFragrances.add(fragrance);
    }
    notifyListeners();
    _persistWardrobe();
  }

  bool isHaircutSaved(String id) => _savedHaircuts.any((h) => h.id == id);
  bool isFragranceSaved(String id) => _savedFragrances.any((f) => f.id == id);

  Future<void> _persistWardrobe() async {
    final user = AuthService().currentUser;
    final fs = _firestore;
    if (user != null && fs != null) {
      try {
        await fs.collection('users').doc(user.uid).collection('wardrobe').doc('items').set({
          'savedHaircuts': _savedHaircuts.map((h) => h.toMap()).toList(),
          'savedFragrances': _savedFragrances.map((f) => f.toMap()).toList(),
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Erro ao persistir wardrobe: $e');
      }
    }
  }

  void _loadDefaultSavedItems() {
    // Fake haircuts removed in favor of real HaircutService from Firestore.
    _savedHaircuts.clear();

    if (_savedFragrances.isEmpty) {
      _savedFragrances.addAll([
        const SavedFragrance(
          id: 'frag_1',
          name: 'Bleu de Chanel Eau de Parfum',
          brand: 'Chanel',
          family: 'Amadeirado Aromático',
          occasion: 'Versátil / Reuniões & Encontros',
          notes: 'Toranja, Incenso, Gengibre, Âmbar e Cedro.',
          imageUrl: 'https://images.unsplash.com/photo-1523293182086-7651a899d37f?q=80&w=600&auto=format&fit=crop',
          affiliateUrl: 'https://www.sephora.com.br',
        ),
        const SavedFragrance(
          id: 'frag_2',
          name: 'Terre d’Hermès Parfum',
          brand: 'Hermès',
          family: 'Amadeirado Terroso / Cítrico',
          occasion: 'Ambiente Corporativo & Liderança',
          notes: 'Laranja amarga, Pimenta preta, Vetiver e Benjoim.',
          imageUrl: 'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?q=80&w=600&auto=format&fit=crop',
          affiliateUrl: 'https://www.sephora.com.br',
        ),
      ]);
    }
  }
}
