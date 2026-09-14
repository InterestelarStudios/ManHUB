import 'package:flutter/material.dart';
import '../../domain/models/training.dart';
import '../../domain/models/module.dart';
import '../../domain/models/session.dart';
import '../../domain/models/user_progress.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/user_progress_service.dart';
import '../widgets/purchase_bottom_sheet.dart';
import 'session_player_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final Training training;

  const CourseDetailScreen({super.key, required this.training});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final AuthService _authService = AuthService();
  final UserProgressService _progressService = UserProgressService();
  int get _totalSessions => widget.training.modules.fold(0, (sum, m) => sum + m.sessions.length);
  bool _isPopping = false;

  @override
  void initState() {
    super.initState();
    _authService.addListener(_onStateChanged);
    _progressService.addListener(_onStateChanged);
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

  void _handlePop() {
    if (_isPopping) return;
    if (!mounted) return;
    _isPopping = true;
    Navigator.of(context).maybePop();
  }

  bool get _hasFullAccess => _authService.hasAccessToTraining(widget.training.id);

  UserProgress? get _currentProgress => _progressService.getProgress(widget.training.id);

  void _openResumeSession() {
    final progress = _currentProgress;

    // Se temos um progresso salvo com aula válida
    if (progress != null && progress.lastSessionId.isNotEmpty) {
      for (int m = 0; m < widget.training.modules.length; m++) {
        final mod = widget.training.modules[m];
        for (int s = 0; s < mod.sessions.length; s++) {
          final sess = mod.sessions[s];
          if (sess.id == progress.lastSessionId) {
            // Módulos além do 1º exigem acesso completo
            if (m > 0 && !_hasFullAccess) {
              _showPurchaseBottomSheet();
              return;
            }
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SessionPlayerScreen(
                  session: sess,
                  isFirstSessionOfModule: s == 0,
                  backgroundImageUrl: widget.training.coverImageUrl,
                  training: widget.training,
                  initialScreenIndex: progress.lastScreenIndex,
                ),
              ),
            );
            return;
          }
        }
      }
    }

    // Caso não tenha começado ainda, abre a primeira aula do primeiro módulo
    if (widget.training.modules.isNotEmpty && widget.training.modules.first.sessions.isNotEmpty) {
      final firstSession = widget.training.modules.first.sessions.first;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SessionPlayerScreen(
            session: firstSession,
            isFirstSessionOfModule: true,
            backgroundImageUrl: widget.training.coverImageUrl,
            training: widget.training,
            initialScreenIndex: 0,
          ),
        ),
      );
    }
  }

  void _openSession(Session session, int moduleIndex, {bool isFirstSessionOfModule = false}) {
    if (moduleIndex > 0 && !_hasFullAccess) {
      _showPurchaseBottomSheet();
      return;
    }

    final progress = _currentProgress;
    final initialScreen = (progress != null && progress.lastSessionId == session.id)
        ? progress.lastScreenIndex
        : 0;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SessionPlayerScreen(
          session: session,
          isFirstSessionOfModule: isFirstSessionOfModule,
          backgroundImageUrl: widget.training.coverImageUrl,
          training: widget.training,
          initialScreenIndex: initialScreen,
        ),
      ),
    );
  }

  void _showPurchaseBottomSheet() {
    PurchaseBottomSheet.show(context, training: widget.training);
  }

  String? _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.trim().isEmpty) return null;
    try {
      final dt = DateTime.parse(isoDate);
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year;
      return '$day/$month/$year';
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasCover = widget.training.coverImageUrl != null && widget.training.coverImageUrl!.trim().isNotEmpty;
    final formattedDate = _formatDate(widget.training.updatedAt);
    final progress = _currentProgress;
    final hasFullAccess = _hasFullAccess;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _isPopping = true;
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundMain,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Área Superior - Foto Principal Limpa e Cinematográfica
            SliverAppBar(
              expandedHeight: 230.0,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.backgroundMain,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.backgroundMain.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: Colors.white),
                  onPressed: _handlePop,
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (hasCover)
                      Image.network(
                        widget.training.coverImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.backgroundSecondary,
                                AppColors.backgroundMain,
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.school_outlined, size: 60, color: AppColors.neonPrimary),
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.backgroundSecondary,
                              AppColors.backgroundMain,
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.school_outlined, size: 60, color: AppColors.neonPrimary),
                        ),
                      ),

                    // Gradiente escuro suave na base
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.25),
                              Colors.transparent,
                              AppColors.backgroundMain.withValues(alpha: 0.7),
                              AppColors.backgroundMain,
                            ],
                            stops: const [0.0, 0.4, 0.8, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Seção de Título, Subtítulo, Badges e Botão de Play Principal
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TÍTULO DO TREINAMENTO
                    Text(
                      widget.training.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.3,
                        height: 1.2,
                      ),
                    ),

                    // SUBTÍTULO
                    if (widget.training.subtitle != null && widget.training.subtitle!.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.training.subtitle!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),

                    // BADGES DE METADADOS
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Badge Módulos & Aulas
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.neonPrimary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.neonPrimary.withValues(alpha: 0.35),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.layers_outlined, size: 14, color: AppColors.neonPrimary),
                              const SizedBox(width: 6),
                              Text(
                                "${widget.training.modules.length} MÓDULOS • $_totalSessions AULAS",
                                style: const TextStyle(
                                  color: AppColors.neonPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Badge Acesso / Status
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: hasFullAccess
                                ? AppColors.success.withValues(alpha: 0.12)
                                : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: hasFullAccess
                                  ? AppColors.success.withValues(alpha: 0.4)
                                  : Colors.white.withValues(alpha: 0.12),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                hasFullAccess ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                                size: 14,
                                color: hasFullAccess ? AppColors.success : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                hasFullAccess ? 'ACESSO TOTAL' : 'MÓDULO 1 GRÁTIS',
                                style: TextStyle(
                                  color: hasFullAccess ? AppColors.success : AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // BOTÃO PRINCIPAL (PLAY/CONTINUAR OU ADQUIRIR TREINAMENTO)
                    hasFullAccess
                        ? _buildPlayResumeButton(progress)
                        : _buildPurchaseCourseButton(),

                    const SizedBox(height: 24),

                    // SOBRE O TREINAMENTO
                    if (widget.training.description != null && widget.training.description!.trim().isNotEmpty) ...[
                      const Text(
                        'SOBRE O TREINAMENTO',
                        style: TextStyle(
                          color: AppColors.neonPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.training.description!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // O QUE VOCÊ APRENDERÁ
                    if (widget.training.whatYouWillLearn != null && widget.training.whatYouWillLearn!.trim().isNotEmpty) ...[
                      _buildNeonCard(
                        title: 'O que você aprenderá',
                        icon: Icons.auto_awesome_outlined,
                        content: Text(
                          widget.training.whatYouWillLearn!,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // REQUISITOS
                    if (widget.training.requirements != null && widget.training.requirements!.trim().isNotEmpty) ...[
                      _buildNeonCard(
                        title: 'Requisitos',
                        icon: Icons.checklist_rtl_rounded,
                        content: Text(
                          widget.training.requirements!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 8),

                    // TÍTULO DA SEÇÃO DE MÓDULOS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'CONTEÚDO DO CURSO',
                          style: TextStyle(
                            color: AppColors.neonPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        if (!hasFullAccess)
                          GestureDetector(
                            onTap: _showPurchaseBottomSheet,
                            child: const Text(
                              'Desbloquear Tudo',
                              style: TextStyle(
                                color: AppColors.neonLight,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 3. Lista de Módulos e Aulas
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final module = widget.training.modules[index];
                    final isModuleLocked = index > 0 && !hasFullAccess;

                    return PremiumModuleCard(
                      module: module,
                      moduleIndex: index,
                      isLocked: isModuleLocked,
                      userProgress: progress,
                      onSessionTap: (session, isFirst) => _openSession(
                        session,
                        index,
                        isFirstSessionOfModule: isFirst,
                      ),
                      onLockedTap: _showPurchaseBottomSheet,
                    );
                  },
                  childCount: widget.training.modules.length,
                ),
              ),
            ),

            // 4. Indicador de Última Atualização no Final da Tela
            if (formattedDate != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 40.0),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.history_rounded, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          'Última atualização: $formattedDate',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseCourseButton() {
    final originalPriceStr = widget.training.price != null
        ? 'R\$ ${widget.training.price!.toStringAsFixed(2).replaceAll('.', ',')}'
        : 'R\$ 97,00';

    return InkWell(
      onTap: _showPurchaseBottomSheet,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.neonPrimary.withValues(alpha: 0.16),
              AppColors.card,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.neonPrimary.withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonPrimary.withValues(alpha: 0.18),
              blurRadius: 18,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.neonPrimary, AppColors.neonLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonPrimary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_open_rounded,
                    color: Colors.black,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Adquirir Treinamento',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.neonPrimary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.neonPrimary.withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              originalPriceStr,
                              style: const TextStyle(
                                color: AppColors.neonLight,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Acesso vitalício por $originalPriceStr ou tudo no Pass (R\$ 49,90/mês)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.neonLight,
                  size: 14,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.remove_red_eye_outlined,
                    size: 13,
                    color: AppColors.neonPrimary,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Módulo 1 liberado para degustação gratuita logo abaixo',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
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

  Widget _buildPlayResumeButton(UserProgress? progress) {
    final bool hasStarted = progress != null &&
        (progress.completedSessionIds.isNotEmpty || progress.lastSessionTitle.isNotEmpty);

    final title = hasStarted ? 'Continuar Treinamento' : 'Iniciar Treinamento';
    final subtitle = hasStarted && progress.lastSessionTitle.isNotEmpty
        ? 'Parou em: ${progress.lastSessionTitle}'
        : 'Comece pelo Módulo 1 (Acesso Liberado)';

    return InkWell(
      onTap: _openResumeSession,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.neonPrimary.withValues(alpha: 0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonPrimary.withValues(alpha: 0.12),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.neonPrimary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonPrimary.withValues(alpha: 0.4),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.black,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
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
    );
  }

  Widget _buildNeonCard({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.neonPrimary.withValues(alpha: 0.45),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonPrimary.withValues(alpha: 0.08),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.neonPrimary, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}

class PremiumModuleCard extends StatefulWidget {
  final Module module;
  final int moduleIndex;
  final bool isLocked;
  final UserProgress? userProgress;
  final Function(Session session, bool isFirstSession) onSessionTap;
  final VoidCallback onLockedTap;

  const PremiumModuleCard({
    super.key,
    required this.module,
    required this.moduleIndex,
    required this.isLocked,
    this.userProgress,
    required this.onSessionTap,
    required this.onLockedTap,
  });

  @override
  State<PremiumModuleCard> createState() => _PremiumModuleCardState();
}

class _PremiumModuleCardState extends State<PremiumModuleCard> with SingleTickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
    // Abre automaticamente o primeiro módulo por ser livre
    if (widget.moduleIndex == 0) {
      _isExpanded = true;
      _expandController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    if (widget.isLocked) {
      widget.onLockedTap();
      return;
    }

    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final indexStr = (widget.moduleIndex + 1).toString().padLeft(2, '0');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 14.0),
      decoration: BoxDecoration(
        color: widget.isLocked
            ? AppColors.card.withValues(alpha: 0.3)
            : AppColors.card.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.isLocked
              ? Colors.white.withValues(alpha: 0.08)
              : (_isExpanded
                  ? AppColors.neonPrimary.withValues(alpha: 0.6)
                  : AppColors.neonPrimary.withValues(alpha: 0.35)),
          width: 1.3,
        ),
        boxShadow: widget.isLocked
            ? null
            : [
                BoxShadow(
                  color: AppColors.neonPrimary.withValues(alpha: _isExpanded ? 0.12 : 0.05),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: Column(
        children: [
          // Área de Clique do Cabeçalho
          InkWell(
            onTap: _toggleExpand,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                children: [
                  // Indicador do Número do Módulo
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.isLocked
                          ? Colors.white.withValues(alpha: 0.05)
                          : AppColors.neonPrimary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: widget.isLocked
                            ? Colors.white.withValues(alpha: 0.1)
                            : AppColors.neonPrimary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      indexStr,
                      style: TextStyle(
                        color: widget.isLocked ? AppColors.textSecondary : AppColors.neonPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Título do Módulo
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'MÓDULO $indexStr',
                              style: TextStyle(
                                color: widget.isLocked
                                    ? AppColors.textSecondary
                                    : AppColors.neonPrimary.withValues(alpha: 0.75),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            if (widget.isLocked) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'PREMIUM',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.module.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: widget.isLocked
                                ? AppColors.textPrimary.withValues(alpha: 0.6)
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Chevron ou Cadeado
                  if (widget.isLocked)
                    const Icon(
                      Icons.lock_outline_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    )
                  else
                    RotationTransition(
                      turns: Tween<double>(begin: 0.0, end: 0.5).animate(_expandAnimation),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.neonPrimary,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Corpo Expansível (Aulas)
          if (!widget.isLocked)
            SizeTransition(
              sizeFactor: _expandAnimation,
              axisAlignment: 1.0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Divider(
                        color: Colors.white.withValues(alpha: 0.06),
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...widget.module.sessions.map((session) => _buildSessionItem(session)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSessionItem(Session session) {
    final bool isCompleted = widget.userProgress?.isSessionCompleted(session.id) ?? false;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
      leading: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.success.withValues(alpha: 0.15)
              : AppColors.neonPrimary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: isCompleted
                ? AppColors.success.withValues(alpha: 0.4)
                : AppColors.neonPrimary.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Icon(
          isCompleted ? Icons.check_rounded : Icons.play_arrow_rounded,
          color: isCompleted ? AppColors.success : AppColors.neonPrimary,
          size: 16,
        ),
      ),
      title: Text(
        session.title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: isCompleted
              ? AppColors.textPrimary.withValues(alpha: 0.85)
              : AppColors.textPrimary,
        ),
      ),
      subtitle: session.subtitle.isNotEmpty
          ? Text(
              session.subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: isCompleted
          ? const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 16,
            )
          : const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white24,
              size: 12,
            ),
      onTap: () => widget.onSessionTap(
        session,
        widget.module.sessions.indexOf(session) == 0,
      ),
    );
  }
}
