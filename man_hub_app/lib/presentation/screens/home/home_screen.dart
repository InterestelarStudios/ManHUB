import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/user_progress_service.dart';
import '../../../domain/models/user_progress.dart';
import '../../../domain/models/training.dart';
import '../../../data/repositories/training_repository.dart';
import '../session_player_screen.dart';
import '../course_detail_screen.dart';
import '../auth/auth_screen.dart';
import '../profile/edit_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final UserProgressService _progressService = UserProgressService();
  final TrainingRepository _trainingRepository = TrainingRepository();

  List<Training> _trainings = [];
  double _scrollOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _authService.addListener(_onAuthChanged);
    _progressService.addListener(_onAuthChanged);
    _loadTrainings();
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthChanged);
    _progressService.removeListener(_onAuthChanged);
    super.dispose();
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isLoggedIn ? _getGreeting() : 'Bem-vindo ao',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isLoggedIn ? '${user?.name}.' : 'Man Hub',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
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
                  const SizedBox(height: 32),
                  _buildSectionTitle('Recomendação do Dia'),
                  const SizedBox(height: 16),
                  _buildRecommendationCard(isLoggedIn),
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
                children: [
                  const Icon(
                    Icons.diamond_outlined,
                    color: AppColors.neonPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    activeTraining.title.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.neonPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Inicie Sua Evolução',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Crie seu plano personalizado de estilo, visagismo e mentalidade.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _openLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.royalBlue,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Entrar na Jornada',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
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

    return SizedBox(
      height: 90,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == 0;
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.neonPrimary.withValues(alpha: 0.1)
                        : AppColors.card,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.neonPrimary
                          : AppColors.neonPrimary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Icon(
                    categories[index]['icon'] as IconData,
                    color: isSelected
                        ? AppColors.neonPrimary
                        : AppColors.textSecondary,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  categories[index]['name'] as String,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendationCard(bool isLoggedIn) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 140,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1593032465175-481ac7f401a0?q=80&w=600&auto=format&fit=crop',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
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
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: AppColors.neonLight,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
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
                  const Text(
                    'Guarda-Roupa Inteligente',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isLoggedIn
                        ? 'Considerando seu objetivo e estilo atual, descubra as peças fundamentais para multiplicar suas combinações.'
                        : 'Descubra a metodologia de estilo que otimiza seu visual usando o mínimo de peças com o máximo de impacto.',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isLoggedIn ? () {} : _openLogin,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLoggedIn ? 'Descobrir' : 'Entrar e Descobrir',
                            style: const TextStyle(
                              color: AppColors.neonPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
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
    );
  }
}
