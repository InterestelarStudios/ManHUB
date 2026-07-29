import 'package:flutter/material.dart';
import '../../domain/models/training.dart';
import '../../domain/models/module.dart';
import '../../domain/models/session.dart';
import '../../data/repositories/training_repository.dart';
import '../../core/theme/app_colors.dart';
import 'session_player_screen.dart';

class CourseDashboardScreen extends StatefulWidget {
  const CourseDashboardScreen({super.key});

  @override
  State<CourseDashboardScreen> createState() => _CourseDashboardScreenState();
}

class _CourseDashboardScreenState extends State<CourseDashboardScreen> {
  final TrainingRepository _repository = TrainingRepository();
  Training? _training;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTraining();
  }

  Future<void> _loadTraining() async {
    try {
      final training = await _repository.getLocalTraining();
      setState(() {
        _training = training;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _openSession(Session session) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SessionPlayerScreen(session: session),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.neonPrimary)),
      );
    }

    if (_error != null || _training == null) {
      return Scaffold(
        body: Center(child: Text('Erro ao carregar curso:\n$_error')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Área Superior - Hero (Luxo/Mistério)
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.backgroundMain,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _training!.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.backgroundMain,
                      AppColors.backgroundSecondary,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.diamond_outlined, // Símbolo de valor/premium
                    size: 80,
                    color: AppColors.neonPrimary.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
          
          // Lista de Módulos e Aulas
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final module = _training!.modules[index];
                  return _buildModuleCard(module);
                },
                childCount: _training!.modules.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(Module module) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ExpansionTile(
        title: Text(
          module.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        iconColor: AppColors.neonPrimary,
        children: module.sessions.map((session) => _buildSessionItem(session)).toList(),
      ),
    );
  }

  Widget _buildSessionItem(Session session) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.neonPrimary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.play_arrow, color: AppColors.neonPrimary, size: 20),
      ),
      title: Text(session.title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: session.subtitle.isNotEmpty
          ? Text(session.subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))
          : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: () => _openSession(session),
    );
  }
}
