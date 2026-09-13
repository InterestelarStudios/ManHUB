import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/user_progress.dart';

class UserProgressService extends ChangeNotifier {
  static final UserProgressService _instance = UserProgressService._internal();
  factory UserProgressService() => _instance;
  UserProgressService._internal() {
    _initAuthListener();
  }

  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _progressSubscription;

  final Map<String, UserProgress> _progressMap = {};

  void _initAuthListener() {
    try {
      final auth = _auth;
      if (auth == null) return;
      _authSubscription = auth.authStateChanges().listen((user) {
        _progressSubscription?.cancel();
        _progressSubscription = null;

        if (user != null) {
          _listenToUserProgress(user.uid);
        } else {
          _progressMap.clear();
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Firebase Auth listener indisponível: $e');
    }
  }

  void _listenToUserProgress(String uid) {
    try {
      final firestore = _firestore;
      if (firestore == null) return;
      _progressSubscription = firestore
          .collection('users')
          .doc(uid)
          .collection('progress')
          .snapshots()
          .listen((snapshot) {
        for (final doc in snapshot.docs) {
          _progressMap[doc.id] = UserProgress.fromMap(doc.data(), doc.id);
        }
        notifyListeners();
      }, onError: (e) {
        debugPrint('Erro ao sincronizar progresso do usuário: $e');
      });
    } catch (e) {
      debugPrint('Firestore progress listener indisponível: $e');
    }
  }

  UserProgress? getProgress(String trainingId) {
    return _progressMap[trainingId];
  }

  UserProgress? getLastActiveProgress() {
    if (_progressMap.isEmpty) return null;
    final list = _progressMap.values.toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list.first;
  }

  Future<void> saveCurrentPosition({
    required String trainingId,
    required String trainingTitle,
    required int moduleIndex,
    required String sessionId,
    required String sessionTitle,
    required int screenIndex,
  }) async {
    final existing = _progressMap[trainingId];
    final updated = existing != null
        ? existing.copyWith(
            trainingTitle: trainingTitle.isNotEmpty ? trainingTitle : existing.trainingTitle,
            lastModuleIndex: moduleIndex,
            lastSessionId: sessionId,
            lastSessionTitle: sessionTitle.isNotEmpty ? sessionTitle : existing.lastSessionTitle,
            lastScreenIndex: screenIndex,
            updatedAt: DateTime.now(),
          )
        : UserProgress(
            trainingId: trainingId,
            trainingTitle: trainingTitle,
            lastModuleIndex: moduleIndex,
            lastSessionId: sessionId,
            lastSessionTitle: sessionTitle,
            lastScreenIndex: screenIndex,
            updatedAt: DateTime.now(),
          );

    _progressMap[trainingId] = updated;
    notifyListeners();

    final user = _auth?.currentUser;
    final firestore = _firestore;
    if (user != null && firestore != null) {
      try {
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('progress')
            .doc(trainingId)
            .set(updated.toMap(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('Erro ao persistir posição de progresso: $e');
      }
    }
  }

  Future<void> markSessionCompleted({
    required String trainingId,
    required String trainingTitle,
    required String sessionId,
    required int moduleIndex,
    bool isModuleFullyCompleted = false,
  }) async {
    final existing = _progressMap[trainingId];
    final completedSessions = existing != null
        ? List<String>.from(existing.completedSessionIds)
        : <String>[];
    if (!completedSessions.contains(sessionId)) {
      completedSessions.add(sessionId);
    }

    final completedModules = existing != null
        ? List<int>.from(existing.completedModuleIndices)
        : <int>[];
    if (isModuleFullyCompleted && !completedModules.contains(moduleIndex)) {
      completedModules.add(moduleIndex);
    }

    final updated = existing != null
        ? existing.copyWith(
            completedSessionIds: completedSessions,
            completedModuleIndices: completedModules,
            updatedAt: DateTime.now(),
          )
        : UserProgress(
            trainingId: trainingId,
            trainingTitle: trainingTitle,
            lastModuleIndex: moduleIndex,
            lastSessionId: sessionId,
            completedSessionIds: completedSessions,
            completedModuleIndices: completedModules,
            updatedAt: DateTime.now(),
          );

    _progressMap[trainingId] = updated;
    notifyListeners();

    final user = _auth?.currentUser;
    final firestore = _firestore;
    if (user != null && firestore != null) {
      try {
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('progress')
            .doc(trainingId)
            .set(updated.toMap(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('Erro ao persistir conclusão de sessão: $e');
      }
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _progressSubscription?.cancel();
    super.dispose();
  }
}
