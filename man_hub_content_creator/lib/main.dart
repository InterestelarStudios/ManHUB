import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'presentation/controllers/creator_controller.dart';
import 'presentation/screens/course_list_screen.dart';
import 'core/theme/creator_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ManHubCreatorApp());
}

class ManHubCreatorApp extends StatelessWidget {
  const ManHubCreatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Man Hub Content Creator',
      theme: CreatorTheme.darkTheme,
      home: const CreatorAppRoot(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CreatorAppRoot extends StatefulWidget {
  const CreatorAppRoot({super.key});

  @override
  State<CreatorAppRoot> createState() => _CreatorAppRootState();
}

class _CreatorAppRootState extends State<CreatorAppRoot> {
  final CreatorController _controller = CreatorController();

  @override
  void initState() {
    super.initState();
    // Carrega os treinamentos do Firestore na inicialização
    _controller.loadTrainingsFromFirestore();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CourseListScreen(controller: _controller);
  }
}
