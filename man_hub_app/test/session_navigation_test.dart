import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:man_hub_app/domain/models/training.dart';
import 'package:man_hub_app/domain/models/module.dart';
import 'package:man_hub_app/domain/models/session.dart';
import 'package:man_hub_app/domain/models/screen_model.dart';
import 'package:man_hub_app/domain/models/content_block.dart';
import 'package:man_hub_app/presentation/screens/session_player_screen.dart';

void main() {
  Training createTestTraining() {
    final session1 = Session(
      id: 'sess_1',
      title: 'Aula 1: Introdução ao Estilo',
      screens: [
        ScreenModel(
          id: 's1_1',
          contents: [
            TitleBlock(id: 'b1', text: 'Bem-vindo ao Treinamento'),
            DescriptionBlock(id: 'b2', text: 'Esta é a primeira tela da aula 1.'),
          ],
        ),
      ],
    );

    final session2 = Session(
      id: 'sess_2',
      title: 'Aula 2: Paleta de Cores Essenciais',
      screens: [
        ScreenModel(
          id: 's2_1',
          contents: [
            TitleBlock(id: 'b3', text: 'Cores Neutras e Vivas'),
            DescriptionBlock(id: 'b4', text: 'Tela inicial da aula 2.'),
          ],
        ),
      ],
    );

    final module1 = Module(
      id: 'mod_1',
      title: 'Módulo 1: Fundamentos',
      sessions: [session1, session2],
    );

    return Training(
      id: 'train_1',
      title: 'Treinamento de Moda Masculina',
      modules: [module1],
    );
  }

  testWidgets('Navigating to the end of a session displays the completion prompt with next lesson title', (WidgetTester tester) async {
    final training = createTestTraining();
    final session1 = training.modules.first.sessions.first;

    await tester.pumpWidget(
      MaterialApp(
        home: SessionPlayerScreen(
          session: session1,
          training: training,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 1. First screen is visible
    expect(find.text('Bem-vindo ao Treinamento'), findsOneWidget);
    expect(find.text('AULA CONCLUÍDA'), findsNothing);

    // 2. Tap right to complete the screen/session
    // Find the right gesture area (flex 3)
    final rightTapFinder = find.byWidgetPredicate(
      (widget) => widget is GestureDetector && widget.behavior == HitTestBehavior.translucent,
    );
    // Tap the right detector (index 1)
    await tester.tap(rightTapFinder.last);
    await tester.pumpAndSettle();

    // 3. Verify completion view is displayed with requested details
    expect(find.text('AULA CONCLUÍDA'), findsOneWidget);
    expect(find.text('Aula 1: Introdução ao Estilo'), findsOneWidget);
    expect(find.text('Deseja prosseguir para a próxima aula ou sair?'), findsOneWidget);
    expect(find.text('Aula 2: Paleta de Cores Essenciais'), findsOneWidget);
    expect(find.text('Prosseguir para Próxima Aula'), findsOneWidget);
    expect(find.text('Sair para os Módulos'), findsOneWidget);

    // 4. Tap "Prosseguir para Próxima Aula"
    await tester.tap(find.text('Prosseguir para Próxima Aula'));
    await tester.pumpAndSettle();

    // 5. Session 2 screen is now active
    expect(find.text('Cores Neutras e Vivas'), findsOneWidget);
    expect(find.text('Tela inicial da aula 2.'), findsOneWidget);
    expect(find.text('AULA CONCLUÍDA'), findsNothing);
  });

  testWidgets('Last session of the training shows course completed message', (WidgetTester tester) async {
    final training = createTestTraining();
    final session2 = training.modules.first.sessions.last;

    await tester.pumpWidget(
      MaterialApp(
        home: SessionPlayerScreen(
          session: session2,
          training: training,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap to advance to completion
    final rightTapFinder = find.byWidgetPredicate(
      (widget) => widget is GestureDetector && widget.behavior == HitTestBehavior.translucent,
    );
    await tester.tap(rightTapFinder.last);
    await tester.pumpAndSettle();

    // Verify course completion UI
    expect(find.text('CURSO CONCLUÍDO'), findsOneWidget);
    expect(find.text('Concluir e Voltar ao Curso'), findsOneWidget);
  });
}
