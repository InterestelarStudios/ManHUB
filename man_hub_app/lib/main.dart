import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'core/services/auth_service.dart';
import 'presentation/screens/main_navigation_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializa o serviço de autenticação para monitorar a sessão do usuário
  AuthService().initialize();

  // Verifica se o usuário já completou o onboarding no dispositivo
  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;

  runApp(ManHubApp(seenOnboarding: seenOnboarding));
}

class ManHubApp extends StatelessWidget {
  final bool seenOnboarding;

  const ManHubApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Man Hub',
      theme: AppTheme.darkTheme,
      home: seenOnboarding
          ? const MainNavigationScreen()
          : const OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
