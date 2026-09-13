import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:man_hub_app/domain/models/content_block.dart';
import 'package:man_hub_app/presentation/widgets/block_widgets.dart';

void main() {
  group('buildMarkdownTextSpan', () {
    test('parses plain text without markdown', () {
      const text = 'Texto simples sem marcadores';
      const baseStyle = TextStyle(color: Colors.white, fontSize: 14);

      final span = buildMarkdownTextSpan(text: text, baseStyle: baseStyle);
      expect(span.text, equals(text));
      expect(span.children, isNull);
    });

    test('parses **Palavra:** into bold span and removes asterisks', () {
      const text = 'Aqui está uma **Dica Importante:** use sempre cinto.';
      const baseStyle = TextStyle(color: Colors.white, fontSize: 14);

      final span = buildMarkdownTextSpan(text: text, baseStyle: baseStyle);
      expect(span.children, isNotNull);
      expect(span.children!.length, equals(3));

      // 1. Plain prefix
      final firstSpan = span.children![0] as TextSpan;
      expect(firstSpan.text, equals('Aqui está uma '));

      // 2. Bold span
      final boldSpan = span.children![1] as TextSpan;
      expect(boldSpan.text, equals('Dica Importante:'));
      expect(boldSpan.style?.fontWeight, equals(FontWeight.bold));

      // 3. Plain suffix
      final thirdSpan = span.children![2] as TextSpan;
      expect(thirdSpan.text, equals(' use sempre cinto.'));
    });

    test('parses multiple bold and italic spans correctly', () {
      const text = '• **Regra 1:** Conforto.\n• **Regra 2:** *Elegância*.';
      const baseStyle = TextStyle(color: Colors.white, fontSize: 14);

      final span = buildMarkdownTextSpan(text: text, baseStyle: baseStyle);
      expect(span.children, isNotNull);

      final combinedPlainText = span.toPlainText();
      expect(combinedPlainText.contains('**'), isFalse);
      expect(combinedPlainText.contains('*'), isFalse);
      expect(combinedPlainText, equals('• Regra 1: Conforto.\n• Regra 2: Elegância.'));
    });
  });

  group('ContentBlockRenderer with Markdown', () {
    testWidgets('DescriptionBlockWidget renders markdown without visible asterisks', (WidgetTester tester) async {
      final block = DescriptionBlock(
        id: '1',
        text: 'Atenção especial: **Destaque:** o ajuste é o rei do estilo.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DescriptionBlockWidget(block: block),
          ),
        ),
      );

      // Verify the full plain text is rendered without **
      expect(find.textContaining('**'), findsNothing);
      expect(find.textContaining('Atenção especial: Destaque: o ajuste é o rei do estilo.'), findsOneWidget);
    });

    testWidgets('HighlightedDescriptionBlockWidget renders markdown highlight container', (WidgetTester tester) async {
      final block = HighlightedDescriptionBlock(
        id: '2',
        text: '**Importante:** Menos é mais no guarda-roupa masculino.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HighlightedDescriptionBlockWidget(block: block),
          ),
        ),
      );

      expect(find.textContaining('**'), findsNothing);
      expect(find.textContaining('Importante: Menos é mais no guarda-roupa masculino.'), findsOneWidget);
    });
  });
}
