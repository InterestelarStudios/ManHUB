import 'package:flutter/material.dart';
import '../../domain/models/training.dart';
import '../../data/repositories/training_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/user_progress_service.dart';
import 'course_detail_screen.dart';
import '../widgets/subscription_bottom_sheet.dart';

class CourseDashboardScreen extends StatefulWidget {
  final String? initialCategory;

  const CourseDashboardScreen({super.key, this.initialCategory});

  @override
  State<CourseDashboardScreen> createState() => _CourseDashboardScreenState();
}

class _CourseDashboardScreenState extends State<CourseDashboardScreen> {
  final TrainingRepository _repository = TrainingRepository();
  final AuthService _authService = AuthService();
  final UserProgressService _progressService = UserProgressService();

  List<Training> _allTrainings = [];
  bool _isLoading = true;
  String? _error;
  String _selectedCategory = 'Todos';

  static const List<String> _standardCategories = [
    'Todos',
    'Jornada',
    'Estilo',
    'Visagismo',
    'Perfumes',
    'Skincare',
    'Corpo',
    'Comunicação',
  ];

  List<String> get _categories {
    final categoriesSet = <String>{..._standardCategories};
    for (final t in _allTrainings) {
      if (t.category != null && t.category!.trim().isNotEmpty) {
        categoriesSet.add(t.category!.trim());
      }
      for (final c in t.categories) {
        if (c.trim().isNotEmpty) {
          categoriesSet.add(c.trim());
        }
      }
    }
    return categoriesSet.toList();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null && widget.initialCategory!.trim().isNotEmpty) {
      _selectedCategory = widget.initialCategory!.trim();
    }
    _authService.addListener(_onStateChanged);
    _progressService.addListener(_onStateChanged);
    _loadTrainings();
  }

  @override
  void dispose() {
    _authService.removeListener(_onStateChanged);
    _progressService.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadTrainings() async {
    try {
      final trainings = await _repository.getAllTrainings();
      if (mounted) {
        setState(() {
          _allTrainings = trainings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  List<Training> get _filteredTrainings {
    if (_selectedCategory.toUpperCase() == 'TODOS') return _allTrainings;
    final sel = _selectedCategory.toUpperCase();
    return _allTrainings.where((t) {
      if ((t.category ?? '').toUpperCase() == sel) return true;
      if (t.categories.any((c) => c.toUpperCase() == sel)) return true;

      // Fallback semântico inteligente caso a categoria tenha pequenas variações de grafia
      final titleLower = '${t.title} ${t.subtitle ?? ''} ${t.description ?? ''}'.toLowerCase();
      if (sel == 'PERFUMES' && (titleLower.contains('perfum') || titleLower.contains('olfat'))) return true;
      if (sel == 'ESTILO' && (titleLower.contains('vestido') || titleLower.contains('estilo') || titleLower.contains('roupa') || titleLower.contains('alfaiataria'))) return true;
      if (sel == 'VISAGISMO' && (titleLower.contains('visagismo') || titleLower.contains('rosto') || titleLower.contains('barba') || titleLower.contains('cabelo'))) return true;
      if (sel == 'SKINCARE' && (titleLower.contains('pele') || titleLower.contains('skincare'))) return true;
      if (sel == 'JORNADA' && (titleLower.contains('jornada') || titleLower.contains('valor'))) return true;
      if (sel == 'CORPO' && (titleLower.contains('corpo') || titleLower.contains('postura') || titleLower.contains('treino'))) return true;
      if (sel == 'COMUNICAÇÃO' && (titleLower.contains('comunicação') || titleLower.contains('voz') || titleLower.contains('oratória'))) return true;
      return false;
    }).toList();
  }

  void _openCourse(Training training) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CourseDetailScreen(training: training),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundMain,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.neonPrimary),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundMain,
        body: Center(child: Text('Erro ao carregar treinamentos:\n$_error')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundMain,
      appBar: AppBar(title: const Text('Treinamentos'), centerTitle: false),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadTrainings,
          color: AppColors.neonPrimary,
          backgroundColor: AppColors.card,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
            // Subtítulo e Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Marketplace de Evolução',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Expanda seus conhecimentos nos pilares essenciais.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Banner / Botão de Desbloqueio Total (Man Hub Pass)
            if (!_authService.isSubscribed)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 4.0),
                  child: _buildUnlockAllBanner(),
                ),
              ),

            // Barra de Filtros
            SliverToBoxAdapter(
              child: Container(
                height: 50,
                margin: const EdgeInsets.symmetric(vertical: 16.0),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = cat.toUpperCase() == _selectedCategory.toUpperCase();
                    return Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: FilterChip(
                        label: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = cat;
                          });
                        },
                        backgroundColor: AppColors.card,
                        selectedColor: AppColors.neonPrimary.withValues(
                          alpha: 0.15,
                        ),
                        checkmarkColor: AppColors.neonPrimary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.neonPrimary
                              : AppColors.textSecondary,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.neonPrimary.withValues(alpha: 0.5)
                                : AppColors.neonPrimary.withValues(alpha: 0.25),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Grade de Cursos ou Estado Vazio
            if (_filteredTrainings.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 48,
                          color: AppColors.textSecondary.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Nenhum treinamento encontrado nesta categoria.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final training = _filteredTrainings[index];
                    return _buildCourseGridItem(training);
                  }, childCount: _filteredTrainings.length),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildUnlockAllBanner() {
    return InkWell(
      onTap: () => SubscriptionBottomSheet.show(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.neonPrimary.withValues(alpha: 0.16),
              AppColors.card,
              AppColors.backgroundSecondary.withValues(alpha: 0.7),
            ],
          ),
          border: Border.all(
            color: AppColors.neonPrimary.withValues(alpha: 0.45),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonPrimary.withValues(alpha: 0.08),
              blurRadius: 14,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Linha Superior: Ícone, Badges e Botão de Ação
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.neonPrimary, AppColors.neonLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonPrimary.withValues(alpha: 0.35),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'MAN HUB PASS',
                  style: TextStyle(
                    color: AppColors.neonLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.neonPrimary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'ACESSO TOTAL',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.neonPrimary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonPrimary.withValues(alpha: 0.3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_open_rounded,
                        size: 13,
                        color: Colors.black,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Desbloquear',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Título Principal com largura total (sem cortes)
            const Text(
              'Desbloqueie tudo por apenas R\$ 49,90/mês',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),

            const SizedBox(height: 4),

            // Subtítulo descritivo
            const Text(
              'Acesso ilimitado e imediato a todos os treinamentos do aplicativo.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseGridItem(Training training) {
    return GestureDetector(
      onTap: () => _openCourse(training),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.neonPrimary.withValues(alpha: 0.3),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonPrimary.withValues(alpha: 0.06),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Capa com imagem Unsplash
              Expanded(
                flex: 1,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        training.coverImageUrl ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.backgroundSecondary,
                                AppColors.card,
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.school_outlined,
                              color: AppColors.neonPrimary,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Gradiente de leitura escuro
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.card.withValues(alpha: 0.95),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Badge de Categoria Neon no topo
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundMain.withValues(
                            alpha: 0.8,
                          ),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.neonPrimary.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          (training.categories.isNotEmpty
                                  ? training.categories.first
                                  : (training.category ?? 'JORNADA'))
                              .toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.neonLight,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Informações do Curso
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            training.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              height: 1.15,
                            ),
                          ),
                          if (training.subtitle != null &&
                              training.subtitle!.trim().isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              training.subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textSecondary.withValues(alpha: 0.8),
                                fontSize: 10,
                              ),
                            ),
                          ],
                          if (training.duration != null &&
                              training.duration!.trim().isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.timer_outlined, size: 10, color: AppColors.neonPrimary),
                                const SizedBox(width: 3),
                                Text(
                                  training.duration!,
                                  style: const TextStyle(
                                    color: AppColors.neonPrimary,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),

                      // Status no rodapé
                      Builder(
                        builder: (context) {
                          final hasAccess = _authService.hasAccessToTraining(training.id);
                          final progress = _progressService.getProgress(training.id);
                          final totalSessions = training.modules.fold(0, (sum, m) => sum + m.sessions.length);
                          final progressVal = progress != null ? progress.getCompletionPercentage(totalSessions) : 0.0;

                          if (hasAccess) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      progressVal > 0
                                          ? '${(progressVal * 100).toInt()}% completo'
                                          : 'Acesso Total',
                                      style: const TextStyle(
                                        color: AppColors.neonPrimary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.play_circle_fill_rounded,
                                      color: AppColors.neonPrimary,
                                      size: 16,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: progressVal > 0 ? progressVal : 0.05,
                                    backgroundColor: AppColors.backgroundMain,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      AppColors.neonPrimary,
                                    ),
                                    minHeight: 3.5,
                                  ),
                                ),
                              ],
                            );
                          } else {
                            final priceDisplay = training.price != null
                                ? 'R\$ ${training.price!.toStringAsFixed(2).replaceAll('.', ',')}'
                                : 'R\$ 97,00';
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      priceDisplay,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'Módulo 1 Grátis',
                                      style: TextStyle(
                                        color: AppColors.neonLight,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.play_circle_outline_rounded,
                                  color: AppColors.neonPrimary.withValues(alpha: 0.8),
                                  size: 18,
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
