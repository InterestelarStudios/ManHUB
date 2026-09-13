import 'package:flutter_test/flutter_test.dart';
import 'package:man_hub_content_creator/domain/models/content_block.dart';
import 'package:man_hub_content_creator/domain/models/module.dart';
import 'package:man_hub_content_creator/domain/models/screen_model.dart';
import 'package:man_hub_content_creator/domain/models/session.dart';
import 'package:man_hub_content_creator/domain/models/training.dart';
import 'package:man_hub_content_creator/presentation/controllers/creator_controller.dart';

void main() {
  group('Training Model and CreatorController Tests', () {
    test('Training toJson and fromJson serializes complex course structures', () {
      final training = Training(
        id: 'course_123',
        title: 'Domínio de Imagem e Postura',
        subtitle: 'Da teoria ao guarda-roupa real',
        description: 'Curso completo de estilo e autoridade masculina.',
        whatYouWillLearn: '• Caimento\n• Visagismo\n• Alfaiataria',
        duration: '4 horas',
        coverImageUrl: 'https://example.com/cover.jpg',
        requirements: 'Nenhum requisito prévio.',
        updatedAt: '2026-09-13T10:00:00.000',
        modules: [
          Module(
            id: 'mod_1',
            title: 'Módulo 1: Fundamentos',
            sessions: [
              Session(
                id: 'sess_1',
                title: 'Aula 1: O Caimento Perfeito',
                subtitle: 'Linhas verticais e horizontais',
                screens: [
                  ScreenModel(
                    id: 'scr_1',
                    title: 'Tela 1',
                    contents: [
                      TitleBlock(id: 'blk_1', text: 'Princípios do Caimento'),
                      DescriptionBlock(id: 'blk_2', text: 'Ajuste nos ombros é o ponto mais crítico.'),
                      HighlightedDescriptionBlock(id: 'blk_3', text: 'Destaque: nunca compre terno sem provar o ombro.'),
                      ImageBlock(id: 'blk_4', imageUrl: 'https://example.com/ombro.jpg'),
                      VideoBlock(id: 'blk_5', videoUrl: 'https://example.com/aula.mp4'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      );

      final json = training.toJson();
      expect(json['id'], 'course_123');
      expect(json['title'], 'Domínio de Imagem e Postura');
      expect(json['modules'], isA<List>());
      expect((json['modules'] as List).length, 1);

      final parsed = Training.fromJson(json);
      expect(parsed.id, 'course_123');
      expect(parsed.title, 'Domínio de Imagem e Postura');
      expect(parsed.modules.length, 1);
      expect(parsed.modules.first.sessions.length, 1);
      expect(parsed.modules.first.sessions.first.screens.length, 1);
      expect(parsed.modules.first.sessions.first.screens.first.contents.length, 5);

      final firstBlock = parsed.modules.first.sessions.first.screens.first.contents.first;
      expect(firstBlock, isA<TitleBlock>());
      expect((firstBlock as TitleBlock).text, 'Princípios do Caimento');
    });

    test('CreatorController handles training management correctly', () {
      final controller = CreatorController();
      expect(controller.trainings.isNotEmpty, isTrue);

      controller.addNewTraining(
        'Novo Curso de Teste',
        subtitle: 'Subtítulo',
        duration: '2h',
      );

      expect(controller.trainings.length, 2);
      expect(controller.training.title, 'Novo Curso de Teste');

      controller.updateTrainingTitle('Título Atualizado');
      expect(controller.training.title, 'Título Atualizado');

      controller.addModule();
      expect(controller.training.modules.isNotEmpty, isTrue);
    });
  });
}
