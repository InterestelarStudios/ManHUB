import 'package:flutter_test/flutter_test.dart';
import 'package:man_hub_app/domain/models/lesson_bookmark.dart';
import 'package:man_hub_app/domain/models/session.dart';
import 'package:man_hub_app/domain/models/module.dart';
import 'package:man_hub_app/domain/models/training.dart';
import 'package:man_hub_app/domain/models/screen_model.dart';
import 'package:man_hub_app/domain/models/content_block.dart';
import 'package:man_hub_app/core/services/bookmark_service.dart';

void main() {
  group('BookmarkService & LessonBookmark Unit Tests', () {
    late BookmarkService service;

    setUp(() {
      service = BookmarkService();
      service.clearForTesting();
    });

    test('LessonBookmark serialization and deserialization for screens', () {
      final now = DateTime.now();
      final bookmark = LessonBookmark(
        id: 'training_1_session_1_screen_2',
        trainingId: 'training_1',
        trainingTitle: 'Perfumaria Masculina',
        category: 'PERFUMES',
        moduleId: 'module_1',
        moduleTitle: 'Fundamentos',
        sessionId: 'session_1',
        sessionTitle: 'A Pirâmide Olfativa',
        sessionSubtitle: 'Saída, Coração e Fundo',
        screenId: 'screen_2',
        screenIndex: 1,
        screenTitle: 'Notas de Coração',
        screenPreviewText: 'O corpo do perfume que dura de 2 a 6 horas.',
        screenImageUrl: 'https://example.com/heart_notes.jpg',
        coverImageUrl: 'https://example.com/cover.jpg',
        createdAt: now,
      );

      final map = bookmark.toMap();
      expect(map['id'], 'training_1_session_1_screen_2');
      expect(map['trainingId'], 'training_1');
      expect(map['screenId'], 'screen_2');
      expect(map['screenIndex'], 1);
      expect(map['screenTitle'], 'Notas de Coração');
      expect(map['screenPreviewText'], 'O corpo do perfume que dura de 2 a 6 horas.');
      expect(map['screenImageUrl'], 'https://example.com/heart_notes.jpg');

      final fromMap = LessonBookmark.fromMap(map, 'training_1_session_1_screen_2');
      expect(fromMap.id, 'training_1_session_1_screen_2');
      expect(fromMap.trainingTitle, 'Perfumaria Masculina');
      expect(fromMap.sessionId, 'session_1');
      expect(fromMap.screenId, 'screen_2');
      expect(fromMap.screenIndex, 1);
      expect(fromMap.screenTitle, 'Notas de Coração');
    });

    test('Toggle bookmark adds and removes screen from favorites', () async {
      final screen0 = ScreenModel(
        id: 'scr_0',
        title: 'Introdução ao Caimento',
        contents: [DescriptionBlock(text: 'Primeira regra de alfaiataria.')],
      );
      final screen1 = ScreenModel(
        id: 'scr_1',
        title: 'Ombros e Mangas',
        contents: [HighlightedDescriptionBlock(text: 'A costura deve alinhar com o osso do ombro.')],
      );

      final session = Session(
        id: 'sess_123',
        title: 'Caimento Perfeito',
        screens: [screen0, screen1],
      );
      final module = Module(id: 'mod_1', title: 'Fundamentos', sessions: [session]);
      final training = Training(
        id: 'train_1',
        title: 'O Homem Bem-Vestido',
        category: 'ESTILO',
        modules: [module],
      );

      expect(
        service.isBookmarked(trainingId: 'train_1', sessionId: 'sess_123', screenId: 'scr_1'),
        isFalse,
      );
      expect(service.count, 0);

      // 1. Favorita apenas a tela 1 (ombros e mangas)
      final wasAdded = await service.toggleBookmark(
        training: training,
        module: module,
        session: session,
        screen: screen1,
        screenIndex: 1,
      );

      expect(wasAdded, isTrue);
      expect(
        service.isBookmarked(trainingId: 'train_1', sessionId: 'sess_123', screenId: 'scr_1'),
        isTrue,
      );
      // Tela 0 não deve estar marcada!
      expect(
        service.isBookmarked(trainingId: 'train_1', sessionId: 'sess_123', screenId: 'scr_0'),
        isFalse,
      );
      expect(service.count, 1);
      expect(service.bookmarks.first.screenTitle, 'Ombros e Mangas');
      expect(service.bookmarks.first.screenIndex, 1);
      expect(service.bookmarks.first.screenPreviewText, 'A costura deve alinhar com o osso do ombro.');

      // 2. Alterna novamente para remover a tela 1
      final wasRemoved = await service.toggleBookmark(
        training: training,
        module: module,
        session: session,
        screen: screen1,
        screenIndex: 1,
      );

      expect(wasRemoved, isFalse);
      expect(
        service.isBookmarked(trainingId: 'train_1', sessionId: 'sess_123', screenId: 'scr_1'),
        isFalse,
      );
      expect(service.count, 0);
    });

    test('Remove bookmark by ID removes specific screen entry', () async {
      final b1 = LessonBookmark(
        id: 't1_s1_scr1',
        trainingId: 't1',
        trainingTitle: 'T1',
        moduleId: 'm1',
        moduleTitle: 'M1',
        sessionId: 's1',
        sessionTitle: 'S1',
        screenId: 'scr1',
        screenTitle: 'Tela 1',
      );
      final b2 = LessonBookmark(
        id: 't1_s1_scr2',
        trainingId: 't1',
        trainingTitle: 'T1',
        moduleId: 'm1',
        moduleTitle: 'M1',
        sessionId: 's1',
        sessionTitle: 'S1',
        screenId: 'scr2',
        screenTitle: 'Tela 2',
      );

      service.addBookmarkForTesting(b1);
      service.addBookmarkForTesting(b2);

      expect(service.count, 2);
      expect(service.isBookmarked(trainingId: 't1', sessionId: 's1', screenId: 'scr1'), isTrue);
      expect(service.isBookmarked(trainingId: 't1', sessionId: 's1', screenId: 'scr2'), isTrue);

      await service.removeBookmark('t1_s1_scr1');

      expect(service.count, 1);
      expect(service.isBookmarked(trainingId: 't1', sessionId: 's1', screenId: 'scr1'), isFalse);
      expect(service.isBookmarked(trainingId: 't1', sessionId: 's1', screenId: 'scr2'), isTrue);
    });
  });
}
