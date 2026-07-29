import 'package:flutter/material.dart';
import 'presentation/controllers/creator_controller.dart';
import 'presentation/screens/creator_screen.dart';

void main() {
  runApp(const ManHubCreatorApp());
}

class ManHubCreatorApp extends StatelessWidget {
  const ManHubCreatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Man Hub Content Creator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: CreatorAppRoot(),
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CreatorScreen(controller: _controller);
  }
}
