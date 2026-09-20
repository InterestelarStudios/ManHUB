import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/bookmark_service.dart';
import '../../../domain/models/lesson_bookmark.dart';
import '../../../domain/models/training.dart';
import '../../../domain/models/session.dart';
import '../../../data/repositories/training_repository.dart';
import '../../../core/services/auth_service.dart';
import '../../widgets/purchase_bottom_sheet.dart';
import '../session_player_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final BookmarkService _bookmarkService = BookmarkService();
  final TrainingRepository _trainingRepository = TrainingRepository();

  List<Training> _loadedTrainings = [];
  bool _isLoadingTrainings = true;

  @override
  void initState() {
    super.initState();
    _bookmarkService.addListener(_onBookmarksChanged);
    _loadTrainings();
  }

  @override
  void dispose() {
    _bookmarkService.removeListener(_onBookmarksChanged);
    super.dispose();
  }

  void _onBookmarksChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadTrainings() async {
    try {
      final list = await _trainingRepository.getAllTrainings();
      if (mounted) {
        setState(() {
          _loadedTrainings = list;
          _isLoadingTrainings = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingTrainings = false;
        });
      }
    }
  }

  void _openLesson(LessonBookmark bookmark) {
    // Procura o treinamento completo na memória/repositório
    Training? matchingTraining;
    for (final t in _loadedTrainings) {
      if (t.id == bookmark.trainingId) {
        matchingTraining = t;
        break;
      }
    }

    Session? matchingSession;
    bool isFirst = false;

    if (matchingTraining != null) {
      for (final m in matchingTraining.modules) {
        for (int s = 0; s < m.sessions.length; s++) {
          if (m.sessions[s].id == bookmark.sessionId) {
            matchingSession = m.sessions[s];
            isFirst = s == 0;
            break;
          }
        }
        if (matchingSession != null) break;
      }
    }

    if (matchingSession != null) {
      if (matchingTraining != null) {
        int modIdx = 0;
        for (int m = 0; m < matchingTraining.modules.length; m++) {
          if (matchingTraining.modules[m].sessions.any((s) => s.id == matchingSession!.id)) {
            modIdx = m;
            break;
          }
        }
        if (modIdx > 0 && !AuthService().hasAccessToTraining(matchingTraining.id)) {
          PurchaseBottomSheet.show(context, training: matchingTraining);
          return;
        }
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SessionPlayerScreen(
            session: matchingSession!,
            training: matchingTraining,
            isFirstSessionOfModule: isFirst,
            initialScreenIndex: bookmark.screenIndex,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Carregando conteúdo da aula...'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _confirmDelete(LessonBookmark bookmark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remover Tela Salva', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Deseja remover "${bookmark.screenTitle}" dos seus favoritos?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _bookmarkService.removeBookmark(bookmark.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tela removida dos favoritos.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Remover', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookmarks = _bookmarkService.bookmarks;

    return Scaffold(
      backgroundColor: AppColors.backgroundMain,
      appBar: AppBar(
        title: const Text('Telas Salvas'),
        centerTitle: false,
        actions: [
          if (bookmarks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.neonPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.neonPrimary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${bookmarks.length} ${bookmarks.length == 1 ? 'tela' : 'telas'}',
                    style: const TextStyle(
                      color: AppColors.neonPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoadingTrainings && _loadedTrainings.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.neonPrimary),
            )
          : bookmarks.isEmpty
              ? _buildEmptyState()
              : _buildList(bookmarks),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonPrimary.withValues(alpha: 0.05),
                border: Border.all(
                  color: AppColors.neonPrimary.withValues(alpha: 0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonPrimary.withValues(alpha: 0.08),
                    blurRadius: 24,
                    spreadRadius: 4,
                  )
                ],
              ),
              child: Icon(
                Icons.bookmark_border_rounded,
                size: 64,
                color: AppColors.neonPrimary.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nenhuma Tela Salva Ainda',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Ao assistir a qualquer aula, quando encontrar uma dica, perfume, visual ou tela importante, toque no ícone de marcador para guardá-la aqui e consultá-la rapidamente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Voltar aos Treinamentos'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.neonPrimary,
                side: const BorderSide(color: AppColors.neonPrimary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<LessonBookmark> bookmarks) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) {
        final bookmark = bookmarks[index];
        return _buildBookmarkCard(bookmark);
      },
    );
  }

  Widget _buildBookmarkCard(LessonBookmark bookmark) {
    final effectiveImage = (bookmark.screenImageUrl != null && bookmark.screenImageUrl!.isNotEmpty)
        ? bookmark.screenImageUrl!
        : (bookmark.coverImageUrl != null && bookmark.coverImageUrl!.isNotEmpty)
            ? bookmark.coverImageUrl!
            : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14.0),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: AppColors.neonPrimary.withValues(alpha: 0.18),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: () => _openLesson(bookmark),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Miniatura da tela ou ícone com Glow
                if (effectiveImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: SizedBox(
                      width: 68,
                      height: 80,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: effectiveImage,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(
                              color: AppColors.backgroundSecondary,
                              child: const Center(
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: AppColors.neonPrimary,
                                    strokeWidth: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (_, _, _) => _buildFallbackIcon(),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.4),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  _buildFallbackIcon(),
                const SizedBox(width: 14),

                // Textos e Detalhes
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges: Treinamento e Tela
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.royalBlue.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              bookmark.trainingTitle.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.neonLight,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.neonPrimary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.neonPrimary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              'TELA ${bookmark.screenIndex + 1}',
                              style: const TextStyle(
                                color: AppColors.neonPrimary,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Título da Tela Salva
                      Text(
                        bookmark.screenTitle,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                        ),
                      ),

                      // Aula / Módulo
                      const SizedBox(height: 2),
                      Text(
                        '${bookmark.sessionTitle} • ${bookmark.moduleTitle}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.75),
                          fontSize: 12,
                        ),
                      ),

                      // Trecho de conteúdo da tela (preview)
                      if (bookmark.screenPreviewText != null &&
                          bookmark.screenPreviewText!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          bookmark.screenPreviewText!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.textSecondary.withValues(alpha: 0.9),
                            fontSize: 12,
                            height: 1.3,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Botão Acessar Tela
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const [
                          Text(
                            'Abrir tela',
                            style: TextStyle(
                              color: AppColors.neonPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.play_arrow_rounded,
                            color: AppColors.neonPrimary,
                            size: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Botão de Excluir
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                    size: 20,
                  ),
                  tooltip: 'Remover dos favoritos',
                  onPressed: () => _confirmDelete(bookmark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.neonPrimary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.neonPrimary.withValues(alpha: 0.3),
        ),
      ),
      child: const Icon(
        Icons.bookmark_rounded,
        color: AppColors.neonPrimary,
        size: 22,
      ),
    );
  }
}
