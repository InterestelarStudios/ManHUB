import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../domain/models/outfit.dart';

class OutfitCreatorService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<Outfit>> loadOutfitsFromFirestore() async {
    try {
      final snapshot = await _firestore
          .collection('outfits')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Outfit.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Erro ao carregar outfits: $e');
      return [];
    }
  }

  static Future<bool> saveOutfitToFirestore(Outfit outfit) async {
    try {
      final outfitId = outfit.id.trim().isEmpty ? const Uuid().v4() : outfit.id.trim();
      final toSave = outfit.copyWith(id: outfitId);

      await _firestore.collection('outfits').doc(outfitId).set(
        toSave.toMap(),
        SetOptions(merge: true),
      );
      return true;
    } catch (e) {
      debugPrint('Erro ao salvar outfit no Firestore: $e');
      return false;
    }
  }

  static Future<bool> deleteOutfitFromFirestore(String outfitId) async {
    try {
      await _firestore.collection('outfits').doc(outfitId).delete();
      return true;
    } catch (e) {
      debugPrint('Erro ao excluir outfit do Firestore: $e');
      return false;
    }
  }
}
