import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/course_dashboard_screen.dart';

void main() {
  runApp(const ManHubApp());
}

class ManHubApp extends StatelessWidget {
  const ManHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Man Hub',
      theme: AppTheme.darkTheme,
      home: const CourseDashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
