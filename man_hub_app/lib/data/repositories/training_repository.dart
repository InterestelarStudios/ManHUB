import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../domain/models/training.dart';

class TrainingRepository {
  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  /// Busca todos os treinamentos disponíveis.
  /// Prioriza o Cloud Firestore para atualizações dinâmicas instantâneas.
  /// Caso o Firestore esteja indisponível ou vazio, recorre aos assets locais como fallback.
  Future<List<Training>> getAllTrainings() async {
    final fs = _firestore;
    if (fs != null) {
      try {
        final snapshot = await fs.collection('trainings').get();
        if (snapshot.docs.isNotEmpty) {
          final trainings = snapshot.docs.map((doc) {
            final data = doc.data();
            if (!data.containsKey('id') || data['id'] == null || (data['id'] as String).isEmpty) {
              data['id'] = doc.id;
            }
            final training = Training.fromJson(data);
            _applyDefaults(training, '');
            return training;
          }).toList();

          trainings.sort((a, b) {
            final dateA = a.updatedAt != null ? DateTime.tryParse(a.updatedAt!) : null;
            final dateB = b.updatedAt != null ? DateTime.tryParse(b.updatedAt!) : null;
            if (dateA != null && dateB != null) {
              return dateB.compareTo(dateA);
            }
            return a.title.compareTo(b.title);
          });

          return trainings;
        }
      } catch (e) {
        debugPrint('Aviso: Falha ao carregar treinamentos do Firestore, utilizando fallback de assets: $e');
      }
    }

    return getAllLocalTrainings();
  }

  /// Escuta alterações na coleção de treinamentos em tempo real
  Stream<List<Training>> streamTrainings() {
    final fs = _firestore;
    if (fs == null) {
      return Stream.fromFuture(getAllLocalTrainings());
    }

    return fs.collection('trainings').snapshots().asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) {
        return getAllLocalTrainings();
      }

      final trainings = snapshot.docs.map((doc) {
        final data = doc.data();
        if (!data.containsKey('id') || data['id'] == null || (data['id'] as String).isEmpty) {
          data['id'] = doc.id;
        }
        final training = Training.fromJson(data);
        _applyDefaults(training, '');
        return training;
      }).toList();

      trainings.sort((a, b) {
        final dateA = a.updatedAt != null ? DateTime.tryParse(a.updatedAt!) : null;
        final dateB = b.updatedAt != null ? DateTime.tryParse(b.updatedAt!) : null;
        if (dateA != null && dateB != null) {
          return dateB.compareTo(dateA);
        }
        return a.title.compareTo(b.title);
      });

      return trainings;
    });
  }

  /// Lê os treinamentos embutidos nos assets locais da aplicação (fallback)
  Future<List<Training>> getAllLocalTrainings() async {
    List<Training> trainings = [];

    try {
      final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final List<String> contentPaths = manifest
          .listAssets()
          .where((path) => path.startsWith('contents/') && path.endsWith('.json'))
          .toList();

      for (final path in contentPaths) {
        try {
          final String jsonString = await rootBundle.loadString(path);
          final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
          final training = Training.fromJson(jsonMap);
          _applyDefaults(training, path);
          trainings.add(training);
        } catch (_) {}
      }
    } catch (_) {
      final fallbackPaths = [
        'contents/curso_o_homem_bem_vestido.json',
        'contents/curso_pele_cabelo_barba.json',
        'contents/curso_perfumaria_masculina.json',
      ];
      for (final path in fallbackPaths) {
        try {
          final String jsonString = await rootBundle.loadString(path);
          final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
          final training = Training.fromJson(jsonMap);
          _applyDefaults(training, path);
          trainings.add(training);
        } catch (_) {}
      }
    }

    if (trainings.isEmpty) {
      final fallbackPaths = [
        'contents/curso_o_homem_bem_vestido.json',
        'contents/curso_pele_cabelo_barba.json',
        'contents/curso_perfumaria_masculina.json',
      ];
      for (final path in fallbackPaths) {
        try {
          final String jsonString = await rootBundle.loadString(path);
          final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
          final training = Training.fromJson(jsonMap);
          _applyDefaults(training, path);
          trainings.add(training);
        } catch (_) {}
      }
    }

    return trainings;
  }

  void _applyDefaults(Training training, String path) {
    if (training.coverImageUrl == null || training.coverImageUrl!.isEmpty) {
      final lower = (training.title + path).toLowerCase();
      if (lower.contains('jornada') || lower.contains('valor')) {
        training.coverImageUrl =
            'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=600&auto=format&fit=crop';
        training.category ??= 'DESENVOLVIMENTO';
      } else if (lower.contains('assinatura') || lower.contains('visual') || lower.contains('estilo') || lower.contains('vestido')) {
        training.coverImageUrl =
            'https://images.unsplash.com/photo-1593032465175-481ac7f401a0?q=80&w=600&auto=format&fit=crop';
        training.category ??= 'ESTILO';
      } else if (lower.contains('visagismo')) {
        training.coverImageUrl =
            'https://images.unsplash.com/photo-1621605815971-fbc98d665033?q=80&w=600&auto=format&fit=crop';
        training.category ??= 'APARÊNCIA';
      } else if (lower.contains('perfume') || lower.contains('olfativa')) {
        training.coverImageUrl =
            'https://images.unsplash.com/photo-1594035910387-fea47794261f?q=80&w=600&auto=format&fit=crop';
        training.category ??= 'PERFUMES';
      } else if (lower.contains('skincare') || lower.contains('pele')) {
        training.coverImageUrl =
            'https://images.unsplash.com/photo-1608248597279-f99d160bfcbc?q=80&w=600&auto=format&fit=crop';
        training.category ??= 'CUIDADO';
      } else {
        training.coverImageUrl =
            'https://images.unsplash.com/photo-1507679799987-c73779587ccf?q=80&w=600&auto=format&fit=crop';
        training.category ??= 'EVOLUÇÃO';
      }
    }

    training.isUnlocked = true;
  }

  Future<Training> getLocalTraining() async {
    final trainings = await getAllTrainings();
    if (trainings.isNotEmpty) {
      return trainings.first;
    }
    final String jsonString = await rootBundle.loadString('contents/curso_o_homem_bem_vestido.json');
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    final training = Training.fromJson(jsonMap);
    _applyDefaults(training, 'contents/curso_o_homem_bem_vestido.json');
    return training;
  }
}
