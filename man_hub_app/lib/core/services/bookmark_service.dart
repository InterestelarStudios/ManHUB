import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/lesson_bookmark.dart';
import '../../domain/models/session.dart';
import '../../domain/models/module.dart';
import '../../domain/models/training.dart';
import '../../domain/models/screen_model.dart';
import '../../domain/models/content_block.dart';

class BookmarkService extends ChangeNotifier {
  static final BookmarkService _instance = BookmarkService._internal();
  factory BookmarkService() => _instance;
  BookmarkService._internal() {
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
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _bookmarksSubscription;

  final Map<String, LessonBookmark> _bookmarksMap = {};

  List<LessonBookmark> get bookmarks {
    final list = _bookmarksMap.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  int get count => _bookmarksMap.length;

  void _initAuthListener() {
    try {
      final auth = _auth;
      if (auth == null) return;
      _authSubscription = auth.authStateChanges().listen((user) {
        _bookmarksSubscription?.cancel();
        _bookmarksSubscription = null;

        if (user != null) {
          _listenToUserBookmarks(user.uid);
        } else {
          _bookmarksMap.clear();
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Firebase Auth listener indisponível no BookmarkService: $e');
    }
  }

  void _listenToUserBookmarks(String uid) {
    try {
      final firestore = _firestore;
      if (firestore == null) return;

      _bookmarksSubscription = firestore
          .collection('users')
          .doc(uid)
          .collection('bookmarks')
          .snapshots()
          .listen((snapshot) {
        _bookmarksMap.clear();
        for (final doc in snapshot.docs) {
          _bookmarksMap[doc.id] = LessonBookmark.fromMap(doc.data(), doc.id);
        }
        notifyListeners();
      }, onError: (e) {
        debugPrint('Erro ao sincronizar bookmarks do Firestore: $e');
      });
    } catch (e) {
      debugPrint('Firestore bookmarks listener indisponível: $e');
    }
  }

  /// Verifica se uma tela de uma sessão está marcada nos favoritos
  bool isBookmarked({
    required String trainingId,
    required String sessionId,
    required String screenId,
  }) {
    final key = '${trainingId}_${sessionId}_$screenId';
    return _bookmarksMap.containsKey(key);
  }

  /// Alterna o estado de favorito de uma tela específica.
  /// Retorna true se a tela foi salva, false se foi removida.
  Future<bool> toggleBookmark({
    required Training training,
    required Module module,
    required Session session,
    required ScreenModel screen,
    required int screenIndex,
  }) async {
    final bookmarkId = '${training.id}_${session.id}_${screen.id}';

    if (_bookmarksMap.containsKey(bookmarkId)) {
      await removeBookmark(bookmarkId);
      return false;
    } else {
      String screenTitle = screen.title.trim();
      if (screenTitle.isEmpty) {
        for (final block in screen.contents) {
          if (block is TitleBlock && block.text.trim().isNotEmpty) {
            screenTitle = block.text.trim();
            break;
          }
        }
      }
      if (screenTitle.isEmpty) {
        screenTitle = 'Destaque - Tela ${screenIndex + 1}';
      }

      final previewText = LessonBookmark.extractPreviewText(screen);
      final screenImg = LessonBookmark.extractImageUrl(screen);

      final newBookmark = LessonBookmark(
        id: bookmarkId,
        trainingId: training.id,
        trainingTitle: training.title,
        category: training.category,
        moduleId: module.id,
        moduleTitle: module.title,
        sessionId: session.id,
        sessionTitle: session.title,
        sessionSubtitle: session.subtitle.isNotEmpty ? session.subtitle : null,
        screenId: screen.id,
        screenIndex: screenIndex,
        screenTitle: screenTitle,
        screenPreviewText: previewText.isNotEmpty ? previewText : null,
        screenImageUrl: screenImg,
        coverImageUrl: training.coverImageUrl,
        createdAt: DateTime.now(),
      );

      _bookmarksMap[bookmarkId] = newBookmark;
      notifyListeners();

      final user = _auth?.currentUser;
      final firestore = _firestore;
      if (user != null && firestore != null) {
        try {
          await firestore
              .collection('users')
              .doc(user.uid)
              .collection('bookmarks')
              .doc(bookmarkId)
              .set(newBookmark.toMap(), SetOptions(merge: true));
        } catch (e) {
          debugPrint('Erro ao persistir bookmark no Firestore: $e');
        }
      }

      return true;
    }
  }

  /// Remove um bookmark pelo seu id
  Future<void> removeBookmark(String bookmarkId) async {
    _bookmarksMap.remove(bookmarkId);
    notifyListeners();

    final user = _auth?.currentUser;
    final firestore = _firestore;
    if (user != null && firestore != null) {
      try {
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('bookmarks')
            .doc(bookmarkId)
            .delete();
      } catch (e) {
        debugPrint('Erro ao remover bookmark do Firestore: $e');
      }
    }
  }

  @visibleForTesting
  void addBookmarkForTesting(LessonBookmark bookmark) {
    _bookmarksMap[bookmark.id] = bookmark;
    notifyListeners();
  }

  @visibleForTesting
  void clearForTesting() {
    _bookmarksMap.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _bookmarksSubscription?.cancel();
    super.dispose();
  }
}
