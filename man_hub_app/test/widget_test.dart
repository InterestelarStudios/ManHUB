import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:man_hub_app/core/theme/app_theme.dart';
import 'package:man_hub_app/core/theme/app_colors.dart';

void main() {
  testWidgets('App theme and basic widget smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: Center(
            child: Text(
              'Man Hub',
              style: TextStyle(color: AppColors.neonPrimary),
            ),
          ),
        ),
      ),
    );
    expect(find.text('Man Hub'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
