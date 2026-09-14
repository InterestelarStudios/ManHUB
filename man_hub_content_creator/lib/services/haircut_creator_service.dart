import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../domain/models/haircut.dart';

class HaircutCreatorService {
  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  /// Stream em tempo real da coleção 'haircuts'
  static Stream<List<Haircut>> streamHaircuts() {
    return _firestore
        .collection('haircuts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Haircut.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Faz upload de bytes brutos de imagem para o Firebase Storage.
  /// No Web, utiliza diretamente a REST API oficial do Firebase Storage
  /// para evitar o erro de serialização Int64 do Pigeon no dart2js.
  static Future<String> uploadHaircutImageBytes({
    required String haircutId,
    required Uint8List bytes,
  }) async {
    final fileId = const Uuid().v4();
    final filename = '$fileId.jpg';
    const bucket = 'man-hub-c0bef.firebasestorage.app';
    final pathName = 'haircuts/$haircutId/$filename';
    final encodedName = Uri.encodeComponent(pathName);

    // No Flutter Web, o SDK do Storage via Pigeon causa o erro 'Int64 accessor not supported by dart2js'.
    // A REST API oficial é 100% suportada no browser.
    if (kIsWeb) {
      return _uploadViaRestApi(bucket, encodedName, bytes);
    }

    // Em plataformas nativas, tenta o SDK primeiro:
    try {
      final storageRef = FirebaseStorage.instance
          .ref('haircuts/$haircutId/$filename');
      final uploadTask = await storageRef.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      if (downloadUrl.isNotEmpty) {
        return downloadUrl;
      }
    } catch (e) {
      debugPrint('Aviso: Falha no SDK do Storage nativo, usando REST: $e');
    }

    return _uploadViaRestApi(bucket, encodedName, bytes);
  }

  static Future<String> _uploadViaRestApi(
    String bucket,
    String encodedName,
    Uint8List bytes,
  ) async {
    try {
      final url = Uri.parse(
          'https://firebasestorage.googleapis.com/v0/b/$bucket/o?uploadType=media&name=$encodedName');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'image/jpeg'},
        body: bytes,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rawTokens = (data['downloadTokens'] ?? '').toString();
        final token = rawTokens.split(',').first.trim();
        return 'https://firebasestorage.googleapis.com/v0/b/$bucket/o/$encodedName?alt=media&token=$token';
      } else {
        throw 'Erro HTTP ${response.statusCode}: ${response.body}';
      }
    } catch (e) {
      throw 'Não foi possível fazer upload da foto: $e';
    }
  }

  /// Salva ou atualiza um corte no Cloud Firestore
  static Future<bool> saveHaircutToFirestore(Haircut haircut) async {
    try {
      await _firestore
          .collection('haircuts')
          .doc(haircut.id)
          .set(haircut.toMap(), SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('Erro ao salvar corte no Firestore: $e');
      return false;
    }
  }

  /// Exclui um corte do Firestore
  static Future<bool> deleteHaircutFromFirestore(String id) async {
    try {
      await _firestore.collection('haircuts').doc(id).delete();
      return true;
    } catch (e) {
      debugPrint('Erro ao excluir corte: $e');
      return false;
    }
  }
}
