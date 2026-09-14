import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/user_progress_service.dart';
import '../../../domain/models/user_progress.dart';
import '../../../domain/models/training.dart';
import '../../../data/repositories/training_repository.dart';
import '../session_player_screen.dart';
import '../course_detail_screen.dart';
import '../course_dashboard_screen.dart';
import '../shopping/shopping_screen.dart';
import '../auth/auth_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../../widgets/subscription_upsell_card.dart';
import '../../widgets/subscription_bottom_sheet.dart';
import '../../../core/services/daily_recommendation_service.dart';
import '../../../domain/models/daily_recommendation.dart';
import '../../../domain/models/session.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final UserProgressService _progressService = UserProgressService();
  final TrainingRepository _trainingRepository = TrainingRepository();
  final DailyRecommendationService _recommendationService = DailyRecommendationService();

  List<Training> _trainings = [];
  double _scrollOpacity = 0.0;
  List<DailyRecommendation> _shuffledRecommendations = [];
  bool _hasShuffledRecommendations = false;

  @override
  void initState() {
    super.initState();
    _hasShuffledRecommendations = false;
    _authService.addListener(_onAuthChanged);
    _progressService.addListener(_onAuthChanged);
    _recommendationService.addListener(_onRecommendationChanged);
    _loadTrainings();
    _updateShuffledRecommendations();
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthChanged);
    _progressService.removeListener(_onAuthChanged);
    _recommendationService.removeListener(_onRecommendationChanged);
    super.dispose();
  }

  void _onRecommendationChanged() {
    if (mounted) {
      _updateShuffledRecommendations();
      setState(() {});
    }
  }

  void _updateShuffledRecommendations() {
    final all = _recommendationService.recommendations;
    if (all.isNotEmpty) {
      final currentIds = _shuffledRecommendations.map((r) => r.id).toSet();
      final allIds = all.map((r) => r.id).toSet();

      // Se ainda não embaralhou ou se houve alteração na lista de IDs disponíveis
      if (!_hasShuffledRecommendations ||
          _shuffledRecommendations.isEmpty ||
          currentIds.length != allIds.length ||
          !currentIds.containsAll(allIds)) {
        final list = List<DailyRecommendation>.from(all);
        list.shuffle();
        _shuffledRecommendations = list.take(10).toList();
        _hasShuffledRecommendations = true;
      } else {
        // Apenas atualiza o conteúdo dos itens existentes mantendo a ordem
        final updated = <DailyRecommendation>[];
        for (final r in _shuffledRecommendations) {
          final found = all.firstWhere((item) => item.id == r.id, orElse: () => r);
          updated.add(found);
        }
        _shuffledRecommendations = updated;
      }
    } else {
      _shuffledRecommendations = [];
      _hasShuffledRecommendations = false;
    }
  }

  Future<void> _loadTrainings() async {
    try {
      final list = await _trainingRepository.getAllTrainings();
      if (mounted) {
        setState(() {
          _trainings = list;
        });
      }
    } catch (_) {}
  }

  void _onAuthChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Bom dia,';
    } else if (hour >= 12 && hour < 18) {
      return 'Boa tarde,';
    } else {
      return 'Boa noite,';
    }
  }

  void _openLogin() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AuthScreen()));
  }

  void _openEditProfile(UserProfile user) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => EditProfileScreen(user: user)));
  }

  Widget _buildAvatarInitial(String name) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'U';
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: AppColors.neonPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = _authService.isLoggedIn;
    final user = _authService.currentUser;
    const appBarHeight = 85.0;

    final appBarBgColor =
        Color.lerp(
          AppColors.backgroundMain,
          AppColors.backgroundSecondary,
          _scrollOpacity,
        ) ??
        AppColors.backgroundMain;

    return Scaffold(
      backgroundColor: AppColors.backgroundMain,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        toolbarHeight: appBarHeight,
        centerTitle: false,
        backgroundColor: appBarBgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Image.asset(
              'contents/images/manhub_icon.png',
              width: 38,
              height: 38,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLoggedIn ? _getGreeting() : 'Bem-vindo ao',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isLoggedIn ? '${user?.name}.' : 'Man Hub',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              if (isLoggedIn && user != null) {
                _openEditProfile(user);
              } else {
                _openLogin();
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.card,
                border: Border.all(
                  color: AppColors.neonPrimary.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonPrimary.withValues(alpha: 0.18),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: isLoggedIn && user != null
                  ? (user.profileImageUrl != null &&
                            user.profileImageUrl!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              user.profileImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildAvatarInitial(user.name),
                            ),
                          )
                        : _buildAvatarInitial(user.name))
                  : const Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.neonPrimary,
                      size: 24,
                    ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification.depth == 0) {
              final offset = notification.metrics.pixels;
              final opacity = (offset / 80.0).clamp(0.0, 1.0);
              if (opacity != _scrollOpacity) {
                setState(() {
                  _scrollOpacity = opacity;
                });
              }
            }
            return false;
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProgressCard(isLoggedIn),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Continue de onde parou'),
                  const SizedBox(height: 16),
                  _buildContinueCard(),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Explorar Pilares'),
                  const SizedBox(height: 16),
                  _buildCategories(),
                  if (!_authService.isSubscribed) ...[
                    const SizedBox(height: 32),
                    const SubscriptionUpsellCard(),
                  ],
                  const SizedBox(height: 32),
                  _buildSectionTitle('Recomendações do Dia'),
                  const SizedBox(height: 16),
                  _buildRecommendationsSection(isLoggedIn),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openResumeSessionFromHome(Training training, UserProgress? progress) {
    if (progress != null && progress.lastSessionId.isNotEmpty) {
      for (int m = 0; m < training.modules.length; m++) {
        final mod = training.modules[m];
        for (int s = 0; s < mod.sessions.length; s++) {
          final sess = mod.sessions[s];
          if (sess.id == progress.lastSessionId) {
            if (m > 0 && !_authService.hasAccessToTraining(training.id)) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CourseDetailScreen(training: training),
                ),
              );
              return;
            }
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SessionPlayerScreen(
                  session: sess,
                  isFirstSessionOfModule: s == 0,
                  backgroundImageUrl: training.coverImageUrl,
                  training: training,
                  initialScreenIndex: progress.lastScreenIndex,
                ),
              ),
            );
            return;
          }
        }
      }
    }

    if (training.modules.isNotEmpty &&
        training.modules.first.sessions.isNotEmpty) {
      final firstSession = training.modules.first.sessions.first;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SessionPlayerScreen(
            session: firstSession,
            isFirstSessionOfModule: true,
            backgroundImageUrl: training.coverImageUrl,
            training: training,
            initialScreenIndex: 0,
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CourseDetailScreen(training: training),
        ),
      );
    }
  }

  Widget _buildProgressCard(bool isLoggedIn) {
    final lastProgress = _progressService.getLastActiveProgress();
    final Training activeTraining =
        (lastProgress != null && _trainings.isNotEmpty)
        ? _trainings.firstWhere(
            (t) => t.id == lastProgress.trainingId,
            orElse: () => _trainings.first,
          )
        : (_trainings.isNotEmpty
              ? _trainings.first
              : Training(title: 'A Jornada do Homem de Valor'));

    final totalSessions = activeTraining.modules.fold(
      0,
      (sum, m) => sum + m.sessions.length,
    );
    final progressVal = lastProgress != null
        ? lastProgress.getCompletionPercentage(totalSessions)
        : 0.0;
    final percentStr = '${(progressVal * 100).toInt()}%';

    final moduleTitle =
        (lastProgress != null &&
            activeTraining.modules.length > lastProgress.lastModuleIndex)
        ? 'Módulo ${lastProgress.lastModuleIndex + 1}: ${activeTraining.modules[lastProgress.lastModuleIndex].title}'
        : (activeTraining.modules.isNotEmpty
              ? 'Módulo 1: ${activeTraining.modules.first.title}'
              : 'Fundamentos');

    if (!isLoggedIn) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: InkWell(
          onTap: _openLogin,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.neonPrimary.withValues(alpha: 0.3),
                width: 1.2,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.card,
                  AppColors.backgroundSecondary.withValues(alpha: 0.65),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonPrimary.withValues(alpha: 0.08),
                  blurRadius: 16,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Coluna de Conteúdo e Ação
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge de Destaque
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.neonPrimary,
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'EVOLUÇÃO & IMAGEM',
                            style: TextStyle(
                              color: AppColors.neonPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Transforme Sua Imagem.',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Desenvolva seu estilo, visagismo e presença marcante.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Chips dos Pilares Principais
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _buildPillarChip(Icons.checkroom_rounded, 'Estilo'),
                          _buildPillarChip(Icons.face_retouching_natural_rounded, 'Visagismo'),
                          _buildPillarChip(Icons.spa_rounded, 'Perfumes'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Botão Começar / Entrar na Jornada
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.neonPrimary,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonPrimary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Começar Agora',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(width: 5),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.black,
                              size: 15,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Foto do Homem em Terno com moldura integrada ao tema
                Container(
                  width: 112,
                  height: 156,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.neonPrimary.withValues(alpha: 0.35),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    image: const DecorationImage(
                      image: AssetImage('contents/images/hero_man_suit.jpg'),
                      fit: BoxFit.cover,
                      alignment: Alignment(0, -0.35),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CourseDetailScreen(training: activeTraining),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.neonPrimary.withValues(alpha: 0.3),
              width: 1.2,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.card,
                AppColors.backgroundSecondary.withValues(alpha: 0.5),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.neonPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.neonPrimary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.diamond_outlined,
                          color: AppColors.neonPrimary,
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Sua Jornada',
                          style: TextStyle(
                            color: AppColors.neonPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    percentStr,
                    style: const TextStyle(
                      color: AppColors.neonLight,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                activeTraining.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                moduleTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              Stack(
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundMain,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: progressVal > 0 ? progressVal : 0.04,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.neonPrimary,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonPrimary.withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPillarChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.neonPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.neonPrimary.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.neonLight),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueCard() {
    final lastProgress = _progressService.getLastActiveProgress();

    Training? targetTraining;
    if (lastProgress != null && _trainings.isNotEmpty) {
      targetTraining = _trainings.firstWhere(
        (t) => t.id == lastProgress.trainingId,
        orElse: () => _trainings.first,
      );
    } else if (_trainings.isNotEmpty) {
      targetTraining = _trainings.first;
    }

    if (targetTraining == null) return const SizedBox.shrink();

    final hasStarted =
        lastProgress != null &&
        (lastProgress.lastSessionTitle.isNotEmpty ||
            lastProgress.completedSessionIds.isNotEmpty);

    final title = hasStarted && lastProgress.lastSessionTitle.isNotEmpty
        ? lastProgress.lastSessionTitle
        : (targetTraining.modules.isNotEmpty &&
                  targetTraining.modules.first.sessions.isNotEmpty
              ? targetTraining.modules.first.sessions.first.title
              : targetTraining.title);

    final subtitle = hasStarted
        ? targetTraining.title
        : 'Comece pelo Módulo 1 (Acesso Liberado)';

    final imageUrl =
        targetTraining.coverImageUrl ??
        'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?q=80&w=200&auto=format&fit=crop';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: InkWell(
        onTap: () => _openResumeSessionFromHome(targetTraining!, lastProgress),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.neonPrimary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                    opacity: 0.7,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    color: AppColors.neonPrimary,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.neonLight,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'name': 'Jornada', 'icon': Icons.explore_outlined},
      {'name': 'Estilo', 'icon': Icons.checkroom_outlined},
      {'name': 'Visagismo', 'icon': Icons.face_outlined},
      {'name': 'Perfumes', 'icon': Icons.water_drop_outlined},
      {'name': 'Skincare', 'icon': Icons.clean_hands_outlined},
      {'name': 'Corpo', 'icon': Icons.fitness_center_outlined},
      {'name': 'Comunicação', 'icon': Icons.record_voice_over_outlined},
      {'name': 'Shopping', 'icon': Icons.shopping_bag_outlined},
    ];

    void onCategoryTap(String categoryName) {
      if (categoryName == 'Shopping') {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ShoppingScreen()),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CourseDashboardScreen(initialCategory: categoryName),
          ),
        );
      }
    }

    return SizedBox(
      height: 96,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final catName = cat['name'] as String;
          final catIcon = cat['icon'] as IconData;

          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () => onCategoryTap(catName),
              borderRadius: BorderRadius.circular(30),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.neonPrimary.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neonPrimary.withValues(alpha: 0.08),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      catIcon,
                      color: AppColors.neonLight,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    catName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openDailyRecommendationLesson(DailyRecommendation? rec) async {
    if (!_authService.isLoggedIn) {
      _openLogin();
      return;
    }

    if (rec == null || rec.trainingId.isEmpty || rec.sessionId.isEmpty) {
      if (_trainings.isNotEmpty) {
        _openResumeSessionFromHome(
          _trainings.first,
          _progressService.getProgress(_trainings.first.id),
        );
      }
      return;
    }

    // 1. Localiza o treinamento correspondente
    Training? targetTraining;
    try {
      targetTraining = _trainings.firstWhere((t) => t.id == rec.trainingId);
    } catch (_) {
      try {
        final all = await _trainingRepository.getAllTrainings();
        targetTraining = all.firstWhere((t) => t.id == rec.trainingId);
      } catch (_) {}
    }

    if (targetTraining == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Treinamento vinculado não encontrado no catálogo.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    // 2. Localiza a sessão dentro dos módulos do curso
    Session? targetSession;
    int moduleIndex = 0;
    int sessionIndex = 0;
    bool found = false;

    for (int m = 0; m < targetTraining.modules.length; m++) {
      final module = targetTraining.modules[m];
      for (int s = 0; s < module.sessions.length; s++) {
        if (module.sessions[s].id == rec.sessionId) {
          targetSession = module.sessions[s];
          moduleIndex = m;
          sessionIndex = s;
          found = true;
          break;
        }
      }
      if (found) break;
    }

    // Fallback se o ID específico da sessão tiver sido alterado
    if (targetSession == null &&
        targetTraining.modules.isNotEmpty &&
        targetTraining.modules.first.sessions.isNotEmpty) {
      targetSession = targetTraining.modules.first.sessions.first;
      moduleIndex = 0;
      sessionIndex = 0;
    }

    if (targetSession == null) {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CourseDetailScreen(training: targetTraining!),
          ),
        );
      }
      return;
    }

    // 3. Verificação de acesso:
    // Se a aula for restrita (módulo > 0) e o usuário NÃO tiver acesso ao treinamento,
    // abre diretamente o bottom sheet de assinatura/aquisição!
    final hasAccess = _authService.hasAccessToTraining(targetTraining.id);
    if (!hasAccess && (moduleIndex > 0 || !targetTraining.isUnlocked)) {
      if (mounted) {
        SubscriptionBottomSheet.show(context);
      }
      return;
    }

    // 4. Progresso do usuário para continuar do ponto certo caso já tenha iniciado esta aula
    final progress = _progressService.getProgress(targetTraining.id);
    final initialIndex = (progress?.lastSessionId == targetSession.id)
        ? progress!.lastScreenIndex
        : 0;

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SessionPlayerScreen(
            session: targetSession!,
            isFirstSessionOfModule: sessionIndex == 0,
            backgroundImageUrl: targetTraining!.coverImageUrl,
            training: targetTraining,
            initialScreenIndex: initialIndex,
          ),
        ),
      );
    }
  }

  Widget _buildRecommendationsSection(bool isLoggedIn) {
    final recommendations = _shuffledRecommendations;

    if (recommendations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: _buildSingleRecommendationCard(null, isLoggedIn),
      );
    }

    if (recommendations.length == 1) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: _buildSingleRecommendationCard(recommendations.first, isLoggedIn),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth * 0.82).clamp(280.0, 360.0);

    return SizedBox(
      height: 320,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        itemCount: recommendations.length,
        separatorBuilder: (_, i) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final rec = recommendations[index];
          return SizedBox(
            width: cardWidth,
            child: _buildSingleRecommendationCard(rec, isLoggedIn),
          );
        },
      ),
    );
  }

  Widget _buildSingleRecommendationCard(
    DailyRecommendation? rec,
    bool isLoggedIn,
  ) {
    final title = (rec != null && rec.title.trim().isNotEmpty)
        ? rec.title
        : 'Guarda-Roupa Inteligente';

    final description = (rec != null && rec.description.trim().isNotEmpty)
        ? rec.description
        : (isLoggedIn
            ? 'Considerando seu objetivo e estilo atual, descubra as peças fundamentais para multiplicar suas combinações.'
            : 'Descubra a metodologia de estilo que otimiza seu visual usando o mínimo de peças com o máximo de impacto.');

    final imageUrl = (rec != null && rec.imageUrl.trim().isNotEmpty)
        ? rec.imageUrl
        : 'https://images.unsplash.com/photo-1593032465175-481ac7f401a0?q=80&w=600&auto=format&fit=crop';

    void onCardTapped() {
      _openDailyRecommendationLesson(rec);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onCardTapped,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.neonPrimary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: SizedBox(
                  height: 130,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.card,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.card.withValues(alpha: 0.9),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: AppColors.neonLight,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Recomendado',
                          style: TextStyle(
                            color: AppColors.neonLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 42,
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 36,
                      child: Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: onCardTapped,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isLoggedIn ? 'Descobrir' : 'Entrar e Descobrir',
                              style: const TextStyle(
                                color: AppColors.neonPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: AppColors.neonPrimary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
