import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:man_hub_app/core/services/auth_service.dart';
import 'package:man_hub_app/presentation/screens/profile/personalized_profile_screen.dart';

void main() {
  group('UserProfile Model Tests', () {
    test('toMap and fromMap serialize personalized profile attributes correctly', () {
      final user = UserProfile(
        uid: 'user_123',
        name: 'Walker',
        email: 'walker@manhub.com',
        height: '1.82 m',
        weight: '82 kg',
        age: '28',
        bodyType: 'Mesomorfo / Atlético',
        faceShape: 'Quadrado',
        skinTone: 'Claro / Médio',
        contrastLevel: 'Alto Contraste',
        hairType: 'Ondulado',
        beardStyle: 'Média Desenhada',
        stylePreference: 'Smart Casual',
        dressOccasion: 'Trabalho Corporativo / Escritório',
        fragrancePreference: 'Amadeirado & Especiado',
        goals: ['Dominar Caimento & Alfaiataria', 'Visagismo de Cabelo & Barba'],
      );

      final map = user.toMap();
      expect(map['uid'], 'user_123');
      expect(map['height'], '1.82 m');
      expect(map['age'], '28');
      expect(map['faceShape'], 'Quadrado');
      expect(map['contrastLevel'], 'Alto Contraste');
      expect(map['stylePreference'], 'Smart Casual');
      expect(map['goals'], contains('Dominar Caimento & Alfaiataria'));

      final parsed = UserProfile.fromMap(map, 'user_123');
      expect(parsed.height, '1.82 m');
      expect(parsed.bodyType, 'Mesomorfo / Atlético');
      expect(parsed.faceShape, 'Quadrado');
      expect(parsed.contrastLevel, 'Alto Contraste');
      expect(parsed.goals.length, 2);
    });

    test('copyWith updates personalized attributes properly', () {
      final original = UserProfile(
        uid: 'user_123',
        name: 'Walker',
        email: 'walker@manhub.com',
      );

      final updated = original.copyWith(
        faceShape: 'Oval',
        fragrancePreference: 'Cítrico & Fresco',
        goals: ['Construir Assinatura Olfativa'],
      );

      expect(updated.faceShape, 'Oval');
      expect(updated.fragrancePreference, 'Cítrico & Fresco');
      expect(updated.goals, contains('Construir Assinatura Olfativa'));
      expect(updated.name, 'Walker');
    });
  });

  group('PersonalizedProfileScreen Widget Tests', () {
    testWidgets('Renders Step 1 with dimensions and body types', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PersonalizedProfileScreen(),
        ),
      );

      expect(find.text('ETAPA 1 DE 10'), findsOneWidget);
      expect(find.text('Medidas & Biotipo'), findsOneWidget);
      expect(find.text('Suas Dimensões e Biotipo'), findsOneWidget);
      expect(find.text('Ectomorfo / Magro'), findsOneWidget);
      expect(find.text('Mesomorfo / Atlético'), findsOneWidget);
      expect(find.text('Endomorfo / Robusto'), findsOneWidget);
      expect(find.text('Próxima Etapa'), findsOneWidget);
    });

    testWidgets('Navigating to next step updates title and progress', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PersonalizedProfileScreen(),
        ),
      );

      await tester.tap(find.text('Próxima Etapa'));
      await tester.pumpAndSettle();

      expect(find.text('ETAPA 2 DE 10'), findsOneWidget);
      expect(find.text('Formato do Rosto'), findsNWidgets(2));
      expect(find.text('SELECIONE O FORMATO PREDOMINANTE'), findsOneWidget);
      expect(find.text('Oval'), findsOneWidget);
      expect(find.text('Quadrado'), findsOneWidget);
      expect(find.text('Diamante'), findsOneWidget);

      // Tap on 'Oval'
      await tester.ensureVisible(find.text('Oval'));
      await tester.tap(find.text('Oval'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Visagismo para Rosto Oval:'));
      expect(find.text('Visagismo para Rosto Oval:'), findsOneWidget);
    });

    testWidgets('Step 6 Style Preference renders style identity grid and interactive concept card', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PersonalizedProfileScreen(),
        ),
      );

      // Navigate to step 6 (index 5)
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text('Próxima Etapa'));
        await tester.pumpAndSettle();
      }

      expect(find.text('ETAPA 6 DE 10'), findsOneWidget);
      expect(find.text('Identidade de Estilo'), findsNWidgets(2));
      expect(find.text('SELECIONE SEU ESTILO PREDOMINANTE'), findsOneWidget);
      expect(find.text('Smart Casual'), findsOneWidget);
      expect(find.text('Clássico / Executivo'), findsOneWidget);
      expect(find.text('Old Money / Nobre'), findsOneWidget);
      expect(find.text('Tech & Sport Chic'), findsOneWidget);

      // Select 'Smart Casual'
      await tester.ensureVisible(find.text('Smart Casual'));
      await tester.tap(find.text('Smart Casual'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Conceito do Estilo Smart Casual:'));
      expect(find.text('Conceito do Estilo Smart Casual:'), findsOneWidget);
    });
  });
}
