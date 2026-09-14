import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/wardrobe_service.dart';
import '../../../core/services/outfit_service.dart';
import '../../../core/services/bookmark_service.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final int xp;
  final String category;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.xp,
    required this.category,
  });
}

class AchievementsProgressScreen extends StatefulWidget {
  final UserProfile? user;

  const AchievementsProgressScreen({super.key, this.user});

  @override
  State<AchievementsProgressScreen> createState() =>
      _AchievementsProgressScreenState();
}

class _AchievementsProgressScreenState
    extends State<AchievementsProgressScreen> {
  final AuthService _authService = AuthService();
  final WardrobeService _wardrobeService = WardrobeService();
  final OutfitService _outfitService = OutfitService();
  final BookmarkService _bookmarkService = BookmarkService();

  late List<String> _userGoals;
  bool _isSavingGoals = false;

  final List<String> _availableGoals = [
    'Dominar combinação de cores e contrastes',
    'Alinhar corte de cabelo com formato de rosto',
    'Construir um guarda-roupa cápsula inteligente',
    'Desenvolver postura e comunicação corporal',
    'Rotina de cuidados com a pele e barba',
    'Manter treinos e condicionamento físico',
    'Criar presença de impacto e magnetismo pessoal',
    'Desenvolver mentalidade de liderança e disciplina',
  ];

  @override
  void initState() {
    super.initState();
    final profile = widget.user ?? _authService.currentUser;
    _userGoals = List.from(profile?.goals ?? []);
  }

  Future<void> _toggleGoal(String goal) async {
    final profile = _authService.currentUser;
    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login para salvar suas metas.')),
      );
      return;
    }

    setState(() {
      if (_userGoals.contains(goal)) {
        _userGoals.remove(goal);
      } else {
        _userGoals.add(goal);
      }
    });

    try {
      setState(() => _isSavingGoals = true);
      await _authService.updateProfile(
        name: profile.name,
        goals: _userGoals,
      );
    } catch (_) {
      // Ignora falha de conexão silenciosamente
    } finally {
      if (mounted) {
        setState(() => _isSavingGoals = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser ?? widget.user;

    final savedOutfitsCount = _outfitService.savedOutfits.length;
    final savedHaircutsCount = _wardrobeService.savedHaircuts.length;
    final bookmarkedCount = _bookmarkService.count;
    final isSubscribed = _authService.isSubscribed;

    final hasFaceShape = user?.faceShape != null && user!.faceShape!.isNotEmpty;
    final hasBodyType = user?.bodyType != null && user!.bodyType!.isNotEmpty;
    final hasCustomPhoto =
        user?.profileImageUrl != null && user!.profileImageUrl!.isNotEmpty;
    final hasBio = user?.bio != null && user!.bio!.isNotEmpty;
    final hasGoals = _userGoals.isNotEmpty;

    // Lista dinâmica de Conquistas
    final achievements = [
      Achievement(
        id: 'alpha_member',
        title: 'Membro Alpha VIP',
        description: 'Assinatura ativa do Man Hub Pass',
        icon: Icons.workspace_premium_rounded,
        isUnlocked: isSubscribed,
        xp: 250,
        category: 'Exclusivo',
      ),
      Achievement(
        id: 'visagismo',
        title: 'Visagismo Mapeado',
        description: 'Formato de rosto definido no diagnóstico',
        icon: Icons.face_rounded,
        isUnlocked: hasFaceShape,
        xp: 120,
        category: 'Imagem',
      ),
      Achievement(
        id: 'biometria',
        title: 'Biotipo Registrado',
        description: 'Tipo físico e silhueta mapeados',
        icon: Icons.accessibility_new_rounded,
        isUnlocked: hasBodyType,
        xp: 100,
        category: 'Imagem',
      ),
      Achievement(
        id: 'first_outfit',
        title: 'Curador de Estilo',
        description: 'Salvou 1 ou mais looks no seu armário',
        icon: Icons.auto_awesome_mosaic_rounded,
        isUnlocked: savedOutfitsCount > 0,
        xp: 80,
        category: 'Estilo',
      ),
      Achievement(
        id: 'haircut_master',
        title: 'Corte Sob Medida',
        description: 'Favoritou um estilo de cabelo no armário',
        icon: Icons.content_cut_rounded,
        isUnlocked: savedHaircutsCount > 0,
        xp: 80,
        category: 'Visagismo',
      ),
      Achievement(
        id: 'knowledge_seeker',
        title: 'Mente Afiada',
        description: 'Salvou telas ou dicas nas favoritas',
        icon: Icons.bookmark_added_rounded,
        isUnlocked: bookmarkedCount > 0,
        xp: 60,
        category: 'Conhecimento',
      ),
      Achievement(
        id: 'identity_forged',
        title: 'Identidade Blindada',
        description: 'Personalizou foto e apresentação pessoal',
        icon: Icons.verified_user_rounded,
        isUnlocked: hasCustomPhoto && hasBio,
        xp: 90,
        category: 'Perfil',
      ),
      Achievement(
        id: 'purpose_driven',
        title: 'Homem com Metas',
        description: 'Definiu suas metas de evolução pessoal',
        icon: Icons.track_changes_rounded,
        isUnlocked: hasGoals,
        xp: 100,
        category: 'Mentalidade',
      ),
    ];

    // Cálculo total de XP e Nível
    int totalXp = 0;
    int unlockedCount = 0;
    for (final a in achievements) {
      if (a.isUnlocked) {
        totalXp += a.xp;
        unlockedCount++;
      }
    }

    // Nível atual baseado no total de XP
    final levelData = _calculateLevel(totalXp);

    return Scaffold(
      backgroundColor: AppColors.backgroundMain,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Conquistas & Progresso',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // CARD DE NÍVEL E XP
              _buildLevelCard(levelData, totalXp, unlockedCount, achievements.length),
              const SizedBox(height: 20),

              // RESUMO EM NÚMEROS
              _buildQuickStats(
                savedOutfitsCount: savedOutfitsCount,
                savedHaircutsCount: savedHaircutsCount,
                bookmarkedCount: bookmarkedCount,
                goalsCount: _userGoals.length,
              ),
              const SizedBox(height: 28),

              // SEÇÃO: BADGES E CONQUISTAS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'CONQUISTAS & MEDALHAS',
                    style: TextStyle(
                      color: AppColors.neonLight,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    '$unlockedCount/${achievements.length} Desbloqueadas',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: achievements.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  return _buildAchievementCard(achievements[index]);
                },
              ),
              const SizedBox(height: 28),

              // SEÇÃO: METAS DE EVOLUÇÃO
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'METAS DE EVOLUÇÃO PESSOAL',
                    style: TextStyle(
                      color: AppColors.neonLight,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (_isSavingGoals)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.neonPrimary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Selecione as áreas prioritárias para a sua transformação contínua:',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),

              _buildGoalsList(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  /// Card de Nível com barra de progresso de XP
  Widget _buildLevelCard(
    _LevelInfo level,
    int currentXp,
    int unlockedCount,
    int totalCount,
  ) {
    final progress = (currentXp - level.currentLevelMinXp) /
        (level.nextLevelXp - level.currentLevelMinXp);
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.royalBlue.withValues(alpha: 0.45),
            AppColors.card,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.neonPrimary.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonPrimary.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neonPrimary.withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppColors.neonPrimary.withValues(alpha: 0.5),
                  ),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: AppColors.neonPrimary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'NÍVEL ${level.level}',
                          style: const TextStyle(
                            color: AppColors.neonLight,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$currentXp XP',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Barra de progresso de XP
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Próximo nível: ${level.nextTitle}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                '$currentXp / ${level.nextLevelXp} XP',
                style: const TextStyle(
                  color: AppColors.neonPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: clampedProgress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.neonPrimary),
            ),
          ),
        ],
      ),
    );
  }

  /// Cards rápidos com contadores estatísticos
  Widget _buildQuickStats({
    required int savedOutfitsCount,
    required int savedHaircutsCount,
    required int bookmarkedCount,
    required int goalsCount,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.auto_awesome_mosaic_outlined,
            value: '$savedOutfitsCount',
            label: 'Looks',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatItem(
            icon: Icons.content_cut_outlined,
            value: '$savedHaircutsCount',
            label: 'Cortes',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatItem(
            icon: Icons.bookmark_outline_rounded,
            value: '$bookmarkedCount',
            label: 'Favoritos',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatItem(
            icon: Icons.track_changes_outlined,
            value: '$goalsCount',
            label: 'Metas',
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.neonPrimary, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  /// Card de cada conquista / medalha
  Widget _buildAchievementCard(Achievement item) {
    final unlocked = item.isUnlocked;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked
              ? AppColors.neonPrimary.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.06),
          width: 1.2,
        ),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: AppColors.neonPrimary.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: unlocked
                      ? const Color(0xFFFFB300).withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.05),
                  border: Border.all(
                    color: unlocked
                        ? const Color(0xFFFFB300).withValues(alpha: 0.6)
                        : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Icon(
                  item.icon,
                  color: unlocked
                      ? const Color(0xFFFFC107)
                      : Colors.white.withValues(alpha: 0.3),
                  size: 20,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: unlocked
                      ? AppColors.neonPrimary.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '+${item.xp} XP',
                  style: TextStyle(
                    color: unlocked
                        ? AppColors.neonPrimary
                        : AppColors.textSecondary.withValues(alpha: 0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: unlocked
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.45),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: unlocked
                  ? AppColors.textSecondary
                  : AppColors.textSecondary.withValues(alpha: 0.4),
              fontSize: 11,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                unlocked
                    ? Icons.check_circle_rounded
                    : Icons.lock_outline_rounded,
                size: 13,
                color: unlocked ? AppColors.neonPrimary : Colors.white24,
              ),
              const SizedBox(width: 4),
              Text(
                unlocked ? 'Conquistado' : 'Bloqueado',
                style: TextStyle(
                  color: unlocked ? AppColors.neonPrimary : Colors.white24,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Lista interativa de metas
  Widget _buildGoalsList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _availableGoals.length,
        separatorBuilder: (context, index) => Divider(
          color: Colors.white.withValues(alpha: 0.05),
          height: 1,
        ),
        itemBuilder: (context, index) {
          final goal = _availableGoals[index];
          final isChecked = _userGoals.contains(goal);

          return InkWell(
            onTap: () => _toggleGoal(goal),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isChecked
                          ? AppColors.neonPrimary
                          : Colors.transparent,
                      border: Border.all(
                        color: isChecked
                            ? AppColors.neonPrimary
                            : Colors.white.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: isChecked
                        ? const Icon(
                            Icons.check,
                            color: Colors.black,
                            size: 14,
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      goal,
                      style: TextStyle(
                        color: isChecked
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight:
                            isChecked ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13.5,
                      ),
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

  _LevelInfo _calculateLevel(int xp) {
    if (xp < 150) {
      return const _LevelInfo(
        level: 1,
        title: 'Iniciante do Estilo',
        nextTitle: 'Homem em Evolução',
        currentLevelMinXp: 0,
        nextLevelXp: 150,
      );
    } else if (xp < 300) {
      return const _LevelInfo(
        level: 2,
        title: 'Homem em Evolução',
        nextTitle: 'Presença Notável',
        currentLevelMinXp: 150,
        nextLevelXp: 300,
      );
    } else if (xp < 500) {
      return const _LevelInfo(
        level: 3,
        title: 'Presença Notável',
        nextTitle: 'Cavaleiro da Imagem',
        currentLevelMinXp: 300,
        nextLevelXp: 500,
      );
    } else if (xp < 750) {
      return const _LevelInfo(
        level: 4,
        title: 'Cavaleiro da Imagem',
        nextTitle: 'Lorde da Elegância',
        currentLevelMinXp: 500,
        nextLevelXp: 750,
      );
    } else if (xp < 1000) {
      return const _LevelInfo(
        level: 5,
        title: 'Lorde da Elegância',
        nextTitle: 'Mestre Alpha',
        currentLevelMinXp: 750,
        nextLevelXp: 1000,
      );
    } else {
      return const _LevelInfo(
        level: 6,
        title: 'Mestre Alpha & Autoridade',
        nextTitle: 'Lenda do Man Hub',
        currentLevelMinXp: 1000,
        nextLevelXp: 1500,
      );
    }
  }
}

class _LevelInfo {
  final int level;
  final String title;
  final String nextTitle;
  final int currentLevelMinXp;
  final int nextLevelXp;

  const _LevelInfo({
    required this.level,
    required this.title,
    required this.nextTitle,
    required this.currentLevelMinXp,
    required this.nextLevelXp,
  });
}
