import 'dart:ui';
import 'package:flutter/material.dart';
import '../../domain/models/session.dart';
import '../../domain/models/screen_model.dart';
import '../../domain/models/content_block.dart';
import '../../domain/models/training.dart';
import '../../domain/models/module.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/user_progress_service.dart';
import '../../core/services/bookmark_service.dart';
import '../../core/services/auth_service.dart';
import '../widgets/block_widgets.dart';
import '../widgets/purchase_bottom_sheet.dart';

class PlayableSessionItem {
  final Session session;
  final Module module;
  final int moduleIndex;
  final int sessionIndexInModule;
  final bool isFirstSessionOfModule;

  const PlayableSessionItem({
    required this.session,
    required this.module,
    required this.moduleIndex,
    required this.sessionIndexInModule,
    required this.isFirstSessionOfModule,
  });
}

class SessionPlayerScreen extends StatefulWidget {
  final Session session;
  final bool isFirstSessionOfModule;
  final String? backgroundImageUrl;
  final Training? training;
  final int initialScreenIndex;

  const SessionPlayerScreen({
    super.key,
    required this.session,
    this.isFirstSessionOfModule = false,
    this.backgroundImageUrl,
    this.training,
    this.initialScreenIndex = 0,
  });

  @override
  State<SessionPlayerScreen> createState() => _SessionPlayerScreenState();
}

class _SessionPlayerScreenState extends State<SessionPlayerScreen> {
  late Session _currentSession;
  late bool _isFirstSessionOfModule;
  late List<PlayableSessionItem> _playlist;
  int _playlistIndex = -1;
  int _currentIndex = 0;
  bool _isMovingForward = true;
  bool _isSessionFinished = false;
  final Map<int, GlobalKey<AnimatedScreenViewState>> _animKeys = {};
  final BookmarkService _bookmarkService = BookmarkService();
  final AuthService _authService = AuthService();

  bool get _hasFullAccess {
    if (widget.training == null) return true;
    return _authService.hasAccessToTraining(widget.training!.id);
  }

  bool _isSessionLocked(PlayableSessionItem? item) {
    if (item == null || widget.training == null) return false;
    return item.moduleIndex > 0 && !_hasFullAccess;
  }

  @override
  void initState() {
    super.initState();
    _currentSession = widget.session;
    _isFirstSessionOfModule = widget.isFirstSessionOfModule;
    _bookmarkService.addListener(_onStateChanged);
    _authService.addListener(_onStateChanged);
    _buildPlaylist();
    final maxIndex = _currentSession.screens.isNotEmpty ? _currentSession.screens.length - 1 : 0;
    _currentIndex = widget.initialScreenIndex.clamp(0, maxIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveCurrentProgress();
    });
  }

  @override
  void dispose() {
    _bookmarkService.removeListener(_onStateChanged);
    _authService.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  void _buildPlaylist() {
    _playlist = [];
    if (widget.training != null) {
      for (int m = 0; m < widget.training!.modules.length; m++) {
        final module = widget.training!.modules[m];
        for (int s = 0; s < module.sessions.length; s++) {
          final sess = module.sessions[s];
          _playlist.add(
            PlayableSessionItem(
              session: sess,
              module: module,
              moduleIndex: m,
              sessionIndexInModule: s,
              isFirstSessionOfModule: s == 0,
            ),
          );
        }
      }
      _playlistIndex =
          _playlist.indexWhere((item) => item.session.id == _currentSession.id);
    }
  }

  PlayableSessionItem? get _nextPlayableItem {
    if (_playlistIndex >= 0 && _playlistIndex < _playlist.length - 1) {
      return _playlist[_playlistIndex + 1];
    }
    return null;
  }

  bool get _isLastSessionOfCourse =>
      widget.training != null &&
      _playlist.isNotEmpty &&
      _playlistIndex == _playlist.length - 1;

  int get _currentModuleIndex {
    if (_playlistIndex >= 0 && _playlistIndex < _playlist.length) {
      return _playlist[_playlistIndex].moduleIndex;
    }
    return 0;
  }

  void _saveCurrentProgress() {
    if (widget.training == null) return;
    UserProgressService().saveCurrentPosition(
      trainingId: widget.training!.id,
      trainingTitle: widget.training!.title,
      moduleIndex: _currentModuleIndex,
      sessionId: _currentSession.id,
      sessionTitle: _currentSession.title,
      screenIndex: _currentIndex,
    );
  }

  void _startNextSession() {
    final nextItem = _nextPlayableItem;
    if (nextItem == null) return;

    if (_isSessionLocked(nextItem)) {
      if (widget.training != null) {
        PurchaseBottomSheet.show(context, training: widget.training!);
      }
      return;
    }

    setState(() {
      _currentSession = nextItem.session;
      _isFirstSessionOfModule = nextItem.isFirstSessionOfModule;
      _playlistIndex++;
      _currentIndex = 0;
      _isMovingForward = true;
      _isSessionFinished = false;
      _animKeys.clear();
    });
    _saveCurrentProgress();
  }

  GlobalKey<AnimatedScreenViewState> _getAnimKey(int index) =>
      _animKeys.putIfAbsent(index, () => GlobalKey<AnimatedScreenViewState>());

  void _nextScreen() {
    if (_isSessionFinished) return;
    if (_currentIndex < _currentSession.screens.length - 1) {
      setState(() {
        _isMovingForward = true;
        _currentIndex++;
      });
      _saveCurrentProgress();
    } else {
      // Aula concluída -> registrar no progresso e exibir tela de transição
      setState(() {
        _isSessionFinished = true;
      });
      if (widget.training != null) {
        final currentModIdx = _currentModuleIndex;
        final currentMod = widget.training!.modules.length > currentModIdx
            ? widget.training!.modules[currentModIdx]
            : null;
        final isModuleComplete = currentMod != null &&
            currentMod.sessions.every((s) =>
                s.id == _currentSession.id ||
                (UserProgressService().getProgress(widget.training!.id)?.isSessionCompleted(s.id) ?? false));

        UserProgressService().markSessionCompleted(
          trainingId: widget.training!.id,
          trainingTitle: widget.training!.title,
          sessionId: _currentSession.id,
          moduleIndex: currentModIdx,
          isModuleFullyCompleted: isModuleComplete,
        );
      }
    }
  }

  void _previousScreen() {
    if (_isSessionFinished) {
      setState(() {
        _isSessionFinished = false;
      });
      return;
    }
    if (_currentIndex > 0) {
      setState(() {
        _isMovingForward = false;
        _currentIndex--;
      });
      _saveCurrentProgress();
    }
  }

  void _handleRightTap() {
    if (_isSessionFinished) return;
    final currentAnimState = _getAnimKey(_currentIndex).currentState;
    if (currentAnimState?.isAnimating ?? false) {
      currentAnimState?.fastForward();
      return;
    }
    _nextScreen();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentSession.screens.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.backgroundMain,
        appBar: AppBar(title: Text(_currentSession.title)),
        body: const Center(
          child: Text(
            'Nenhum conteúdo nesta aula.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final isFirstSessionIntro =
        _isFirstSessionOfModule && _currentIndex == 0;

    return Scaffold(
      backgroundColor: AppColors.backgroundMain,
      body: Stack(
        children: [
          // 1. Fundo com Imagem Desfocada (Blur) + Opacidade ~30%
          Positioned.fill(
            child: Container(
              color: AppColors.backgroundMain,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Opacity(
                      opacity: 0.30,
                      child: Image.network(
                        widget.backgroundImageUrl ??
                            'https://images.unsplash.com/photo-1507679799987-c73779587ccf?q=80&w=1200&auto=format&fit=crop',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: AppColors.backgroundSecondary),
                      ),
                    ),
                  ),
                  // Gradiente escuro para garantir contraste e leitura impecável
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.backgroundMain.withValues(alpha: 0.70),
                          AppColors.backgroundMain.withValues(alpha: 0.35),
                          AppColors.backgroundMain.withValues(alpha: 0.85),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Transicionador de Telas Animado OU Tela de Conclusão/Próxima Aula
          Positioned.fill(
            child: SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeInOutCubic,
                switchOutCurve: Curves.easeInOutCubic,
                transitionBuilder:
                    (Widget child, Animation<double> animation) {
                  final slideOffset = _isMovingForward
                      ? const Offset(0.08, 0.0)
                      : const Offset(-0.08, 0.0);

                  final slideAnimation = Tween<Offset>(
                    begin: slideOffset,
                    end: Offset.zero,
                  ).animate(animation);

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: child,
                    ),
                  );
                },
                child: _isSessionFinished
                    ? KeyedSubtree(
                        key: ValueKey<String>('completion_${_currentSession.id}'),
                        child: _buildCompletionView(),
                      )
                    : KeyedSubtree(
                        key: ValueKey<String>('${_currentSession.id}_$_currentIndex'),
                        child: AnimatedScreenView(
                          key: _getAnimKey(_currentIndex),
                          screen: _currentSession.screens[_currentIndex],
                          isFirstSessionIntro: isFirstSessionIntro,
                        ),
                      ),
              ),
            ),
          ),

          // 3. Indicador de Progresso (Barrinhas no topo)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: SafeArea(
              child: _buildProgressIndicators(),
            ),
          ),

          // 4. Áreas de Toque para Navegação (somente quando a aula está em andamento)
          if (!_isSessionFinished)
            Positioned.fill(
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: _previousScreen,
                        behavior: HitTestBehavior.translucent,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: _handleRightTap,
                        behavior: HitTestBehavior.translucent,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 5. Botões de Ação Superiores (Bookmark & Fechar)
          Positioned(
            top: 28,
            right: 16,
            child: SafeArea(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildBookmarkButton(),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkButton() {
    final training = widget.training;
    if (training == null) return const SizedBox.shrink();
    if (_currentSession.screens.isEmpty || _currentIndex >= _currentSession.screens.length) {
      return const SizedBox.shrink();
    }

    final currentScreen = _currentSession.screens[_currentIndex];
    final isSaved = _bookmarkService.isBookmarked(
      trainingId: training.id,
      sessionId: _currentSession.id,
      screenId: currentScreen.id,
    );

    return IconButton(
      tooltip: isSaved ? 'Remover tela dos favoritos' : 'Salvar tela nos favoritos',
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSaved
              ? AppColors.neonPrimary.withValues(alpha: 0.22)
              : Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
          border: isSaved
              ? Border.all(color: AppColors.neonPrimary, width: 1.5)
              : null,
          boxShadow: isSaved
              ? [
                  BoxShadow(
                    color: AppColors.neonPrimary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Icon(
          isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          color: isSaved ? AppColors.neonPrimary : Colors.white,
          size: 22,
        ),
      ),
      onPressed: _toggleBookmark,
    );
  }

  Future<void> _toggleBookmark() async {
    final training = widget.training;
    if (training == null) return;
    if (_currentSession.screens.isEmpty || _currentIndex >= _currentSession.screens.length) {
      return;
    }

    Module? currentModule;
    if (_playlistIndex >= 0 && _playlistIndex < _playlist.length) {
      currentModule = _playlist[_playlistIndex].module;
    } else {
      for (final m in training.modules) {
        if (m.sessions.any((s) => s.id == _currentSession.id)) {
          currentModule = m;
          break;
        }
      }
    }
    currentModule ??= training.modules.isNotEmpty ? training.modules.first : Module(title: 'Geral');

    final currentScreen = _currentSession.screens[_currentIndex];
    final wasSaved = await _bookmarkService.toggleBookmark(
      training: training,
      module: currentModule,
      session: _currentSession,
      screen: currentScreen,
      screenIndex: _currentIndex,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.card,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              Icon(
                wasSaved ? Icons.bookmark_added_rounded : Icons.bookmark_remove_rounded,
                color: wasSaved ? AppColors.neonPrimary : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  wasSaved
                      ? 'Tela salva nos seus favoritos!'
                      : 'Tela removida dos favoritos.',
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildCompletionView() {
    final nextItem = _nextPlayableItem;
    final isLastOverall = _isLastSessionOfCourse;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: AppColors.card.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.neonPrimary.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonPrimary.withValues(alpha: 0.14),
                blurRadius: 30,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Ícone de Status Neon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neonPrimary.withValues(alpha: 0.12),
                  border: Border.all(
                    color: isLastOverall
                        ? Colors.amberAccent.withValues(alpha: 0.8)
                        : AppColors.neonPrimary.withValues(alpha: 0.7),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isLastOverall
                          ? Colors.amberAccent.withValues(alpha: 0.3)
                          : AppColors.neonPrimary.withValues(alpha: 0.35),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  isLastOverall
                      ? Icons.emoji_events_rounded
                      : Icons.check_circle_outline_rounded,
                  color: isLastOverall ? Colors.amberAccent : AppColors.neonPrimary,
                  size: 38,
                ),
              ),
              const SizedBox(height: 18),

              // 2. Badge de Conclusão
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.neonPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isLastOverall ? 'CURSO CONCLUÍDO' : 'AULA CONCLUÍDA',
                  style: const TextStyle(
                    color: AppColors.neonLight,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 3. Título da Aula Finalizada
              Text(
                _currentSession.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 10),

              // 4. Pergunta ou Orientação do Usuário
              Text(
                isLastOverall
                    ? 'Parabéns! Você completou todas as aulas deste treinamento!'
                    : _isSessionLocked(nextItem)
                        ? 'Você concluiu o módulo introdutório gratuito! Para avançar para o Módulo ${nextItem!.moduleIndex + 1} e dominar a metodologia prática, desbloqueie seu acesso.'
                        : 'Deseja prosseguir para a próxima aula ou sair?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // 5. Card da Próxima Aula
              if (nextItem != null) ...[
                if (_isSessionLocked(nextItem))
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundMain.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.45),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.lock_rounded,
                              size: 15,
                              color: Color(0xFFD4AF37),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'BLOQUEADO • MÓDULO ${nextItem.moduleIndex + 1}',
                              style: const TextStyle(
                                color: Color(0xFFD4AF37),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'PREMIUM',
                                style: TextStyle(
                                  color: Color(0xFFD4AF37),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          nextItem.session.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nextItem.module.title,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Row(
                          children: [
                            Icon(Icons.workspace_premium_rounded, size: 14, color: Color(0xFFD4AF37)),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Disponível no Man Hub Pass ou Acesso Vitalício',
                                style: TextStyle(
                                  color: Color(0xFFD4AF37),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundMain.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.neonPrimary.withValues(alpha: 0.25),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.play_circle_fill_rounded,
                              size: 15,
                              color: AppColors.neonPrimary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'A SEGUIR • MÓDULO ${nextItem.moduleIndex + 1}',
                              style: const TextStyle(
                                color: AppColors.neonPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${nextItem.session.screens.length} telas',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          nextItem.session.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nextItem.module.title,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
              ],

              // 6. Botão de Ação Principal
              if (nextItem != null && _isSessionLocked(nextItem))
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      elevation: 6,
                      shadowColor: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      if (widget.training != null) {
                        PurchaseBottomSheet.show(context, training: widget.training!);
                      }
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_open_rounded,
                          size: 22,
                          color: Colors.black,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Desbloquear Acesso Completo',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonPrimary,
                      foregroundColor: AppColors.backgroundMain,
                      elevation: 6,
                      shadowColor: AppColors.neonPrimary.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      if (nextItem != null) {
                        _startNextSession();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          nextItem != null
                              ? Icons.play_arrow_rounded
                              : Icons.check_rounded,
                          size: 24,
                          color: AppColors.backgroundMain,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          nextItem != null
                              ? 'Prosseguir para Próxima Aula'
                              : 'Concluir e Voltar ao Curso',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              // 7. Botão Secundário de Sair
              if (nextItem != null)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Sair para os Módulos',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
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

  Widget _buildProgressIndicators() {
    return Row(
      children: List.generate(
        _currentSession.screens.length,
        (index) => Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 4,
            decoration: BoxDecoration(
              color: (_isSessionFinished || index <= _currentIndex)
                  ? AppColors.neonPrimary
                  : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
              boxShadow: (_isSessionFinished || index == _currentIndex)
                  ? [
                      BoxShadow(
                        color: AppColors.neonPrimary.withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}


/// Widget responsável pela animação imersiva sequencial dos blocos de conteúdo da tela
class AnimatedScreenView extends StatefulWidget {
  final ScreenModel screen;
  final bool isFirstSessionIntro;

  const AnimatedScreenView({
    super.key,
    required this.screen,
    this.isFirstSessionIntro = false,
  });

  @override
  State<AnimatedScreenView> createState() => AnimatedScreenViewState();
}

class AnimatedScreenViewState extends State<AnimatedScreenView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _totalDurationMs;

  bool get isAnimating => _controller.isAnimating;

  void fastForward() {
    if (_controller.isAnimating) {
      _controller.forward(from: 1.0);
    }
  }

  @override
  void initState() {
    super.initState();

    final contents = widget.screen.contents;

    if (widget.isFirstSessionIntro) {
      final titleIndex = contents.indexWhere((b) => b is TitleBlock);
      final remainingCount =
          titleIndex != -1 ? (contents.length - 1) : contents.length;
      // 500ms (respiro inicial breve) + 700ms (fade-in centro) + 400ms (pausa) + 650ms (sobe ao topo) + (remaining * 900ms)
      _totalDurationMs = 2250 + (remainingCount * 900);
    } else {
      // Outras telas: respiro inicial de 400ms + cada item surge a cada ~900ms
      _totalDurationMs = 400 + (contents.length * 900);
    }

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _totalDurationMs),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contents = widget.screen.contents;

    if (contents.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum conteúdo nesta tela.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    if (widget.isFirstSessionIntro) {
      return _buildFirstSessionIntroLayout(contents);
    } else {
      return _buildStandardStaggeredLayout(contents);
    }
  }

  /// Layout da PRIMEIRA AULA: Respiro breve (500ms) -> Título surge no centro -> Sobe para o topo -> Elementos restantes surgem com intervalo
  Widget _buildFirstSessionIntroLayout(List<ContentBlock> contents) {
    final titleIndex = contents.indexWhere((b) => b is TitleBlock);

    // Se não houver TitleBlock explícito, cai no fluxo padrão escalonado
    if (titleIndex == -1) {
      return _buildStandardStaggeredLayout(contents);
    }

    final heroTitle = contents[titleIndex] as TitleBlock;
    final otherBlocks = List<ContentBlock>.from(contents)..removeAt(titleIndex);

    // Intervalos relativos dentro da timeline total
    final totalMs = _totalDurationMs.toDouble();
    // Inicia rapidamente após breve respiro de 500ms
    final titleFadeInterval = Interval(
      (500.0 / totalMs).clamp(0.0, 1.0),
      (1200.0 / totalMs).clamp(0.0, 1.0),
      curve: Curves.easeOutCubic,
    );
    // Após breve pausa de 400ms no centro, move-se até o topo
    final titleMoveInterval = Interval(
      (1600.0 / totalMs).clamp(0.0, 1.0),
      (2250.0 / totalMs).clamp(0.0, 1.0),
      curve: Curves.easeInOutCubic,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        // Distância vertical para colocar o título no centro exato da tela antes de subir
        final centerOffsetY = (screenHeight / 2.0) - 100.0;

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final titleFadeVal = titleFadeInterval.transform(_controller.value);
            final titleMoveVal = titleMoveInterval.transform(_controller.value);

            // Deslocamento que vai de centerOffsetY (no centro) até 0.0 (no topo)
            final currentTitleYOffset = (1.0 - titleMoveVal) * centerOffsetY;

            return SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 72,
                bottom: 40,
                left: 16,
                right: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // TÍTULO HERO ANIMADO
                  Transform.translate(
                    offset: Offset(0.0, currentTitleYOffset),
                    child: Opacity(
                      opacity: titleFadeVal,
                      child: Transform.scale(
                        scale: 0.94 + (0.06 * titleFadeVal),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            heroTitle.text,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: AppColors.neonPrimary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  shadows: [
                                    BoxShadow(
                                      color: AppColors.neonPrimary.withValues(
                                        alpha: 0.5 * titleFadeVal,
                                      ),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // DEMAIS ELEMENTOS (Surgem um a um com intervalo após o título chegar ao topo)
                  ...otherBlocks.asMap().entries.map((entry) {
                    final index = entry.key;
                    final block = entry.value;

                    final startMs = 2250.0 + (index * 900.0);
                    final endMs = (startMs + 750.0).clamp(0.0, totalMs);
                    final itemInterval = Interval(
                      (startMs / totalMs).clamp(0.0, 1.0),
                      (endMs / totalMs).clamp(0.0, 1.0),
                      curve: Curves.easeOutCubic,
                    );

                    final itemAnimVal = itemInterval.transform(_controller.value);

                    return Opacity(
                      opacity: itemAnimVal,
                      child: Transform.translate(
                        offset: Offset(0.0, (1.0 - itemAnimVal) * 20.0),
                        child: ContentBlockRenderer(block: block),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Layout PADRÃO das demais aulas: Elementos surgem sequencialmente com fade-in suave e intervalo de leitura
  Widget _buildStandardStaggeredLayout(List<ContentBlock> contents) {
    final totalMs = _totalDurationMs.toDouble();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: 72,
            bottom: 40,
            left: 16,
            right: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: contents.asMap().entries.map((entry) {
              final index = entry.key;
              final block = entry.value;

              final startMs = 400.0 + (index * 900.0);
              final endMs = (startMs + 750.0).clamp(0.0, totalMs);
              final itemInterval = Interval(
                (startMs / totalMs).clamp(0.0, 1.0),
                (endMs / totalMs).clamp(0.0, 1.0),
                curve: Curves.easeOutCubic,
              );

              final itemAnimVal = itemInterval.transform(_controller.value);

              return Opacity(
                opacity: itemAnimVal,
                child: Transform.translate(
                  offset: Offset(0.0, (1.0 - itemAnimVal) * 16.0),
                  child: ContentBlockRenderer(block: block),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
