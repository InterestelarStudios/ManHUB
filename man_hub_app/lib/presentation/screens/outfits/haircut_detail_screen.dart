import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/haircut_service.dart';
import '../../../domain/models/haircut.dart';
import '../../widgets/fullscreen_image_viewer.dart';

class HaircutDetailScreen extends StatefulWidget {
  final Haircut haircut;

  const HaircutDetailScreen({super.key, required this.haircut});

  @override
  State<HaircutDetailScreen> createState() => _HaircutDetailScreenState();
}

class _HaircutDetailScreenState extends State<HaircutDetailScreen> {
  final HaircutService _haircutService = HaircutService();
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openFullScreenImage(BuildContext context, int index) {
    final images = widget.haircut.imageUrls;
    if (images.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullscreenImageViewer(
          imageUrl: images[index],
          title: '${widget.haircut.title} (${index + 1}/${images.length})',
          heroTag: 'haircut_${widget.haircut.id}_$index',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSaved = _haircutService.isHaircutSaved(widget.haircut.id);
    final images = widget.haircut.imageUrls;

    return Scaffold(
      backgroundColor: AppColors.backgroundMain,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Galeria de Imagens / Carrossel
          SliverAppBar(
            expandedHeight: 400.0,
            pinned: true,
            backgroundColor: AppColors.backgroundMain,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.backgroundMain.withValues(alpha: 0.65),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.backgroundMain.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: isSaved ? AppColors.neonPrimary : Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _haircutService.toggleSaveHaircut(widget.haircut.id);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.card,
                        duration: const Duration(seconds: 2),
                        content: Text(
                          isSaved
                              ? 'Corte removido do seu Armário.'
                              : 'Corte salvo no seu Armário com sucesso!',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (images.isNotEmpty)
                    PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _openFullScreenImage(context, index),
                          child: Hero(
                            tag: 'haircut_${widget.haircut.id}_$index',
                            child: CachedNetworkImage(
                              imageUrl: images[index],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppColors.backgroundSecondary,
                                child: const Center(
                                  child: CircularProgressIndicator(color: AppColors.neonPrimary, strokeWidth: 2),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.backgroundSecondary,
                                child: const Center(
                                  child: Icon(Icons.broken_image_rounded, color: AppColors.textSecondary, size: 50),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      color: AppColors.backgroundSecondary,
                      child: const Center(
                        child: Icon(Icons.content_cut, color: AppColors.textSecondary, size: 64),
                      ),
                    ),

                  // Gradiente escuro para legibilidade
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.4),
                              Colors.transparent,
                              AppColors.backgroundMain.withValues(alpha: 0.85),
                              AppColors.backgroundMain,
                            ],
                            stops: const [0.0, 0.45, 0.85, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Indicador de fotos (bolinhas) e botão de zoom
                  if (images.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(images.length, (idx) {
                            final isActive = idx == _currentImageIndex;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: isActive ? 16 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isActive ? AppColors.neonPrimary : Colors.white.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),

                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.neonPrimary.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fullscreen_rounded, size: 16, color: AppColors.neonLight),
                          SizedBox(width: 5),
                          Text(
                            'Toque para expandir',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
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

          // Detalhes do Corte de Cabelo
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges de Tipo de Cabelo & Imagem
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.neonPrimary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.neonPrimary.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.texture_rounded, color: AppColors.neonLight, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'CABELO ${widget.haircut.hairType.toUpperCase()}',
                              style: const TextStyle(
                                color: AppColors.neonLight,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (images.length > 1) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.textSecondary.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '${images.length} Fotos de Ângulos',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Título do corte
                  Text(
                    widget.haircut.title.trim().isNotEmpty
                        ? widget.haircut.title
                        : 'Corte ${widget.haircut.hairType}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Card de Formatos de Rosto Harmonizados
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.neonPrimary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.face_retouching_natural_rounded, color: AppColors.neonPrimary, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Harmonização de Visagismo',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Formatos de rosto ideais para este corte:',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.haircut.faceShapes.map((face) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundMain,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.neonPrimary.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_outline, size: 13, color: AppColors.neonPrimary),
                                  const SizedBox(width: 5),
                                  Text(
                                    face,
                                    style: const TextStyle(
                                      color: AppColors.neonLight,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Descrição / Análise de Estilo
                  if (widget.haircut.description.isNotEmpty) ...[
                    const Text(
                      'Visão do Especialista & Proporções',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.haircut.description,
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.9),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Produto Recomendado de Finalização
                  if (widget.haircut.recommendedStylingProduct.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.neonPrimary.withValues(alpha: 0.08),
                            AppColors.card,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.neonPrimary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.neonPrimary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.auto_fix_high_rounded, color: AppColors.neonPrimary, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Produto Recomendado para Finalizar',
                                  style: TextStyle(
                                    color: AppColors.neonLight,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.haircut.recommendedStylingProduct,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Aplique nos fios úmidos ou secos para fixação, controle de frizz e definição da textura proposta.',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Tags
                  if (widget.haircut.tags.isNotEmpty) ...[
                    const Text(
                      'Tags Relacionadas',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.haircut.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Text(
                            '#$tag',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Botão Salvar no Armário
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSaved ? AppColors.card : AppColors.neonPrimary,
                        foregroundColor: isSaved ? AppColors.neonPrimary : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: isSaved
                              ? const BorderSide(color: AppColors.neonPrimary, width: 1.5)
                              : BorderSide.none,
                        ),
                        elevation: isSaved ? 0 : 3,
                      ),
                      icon: Icon(
                        isSaved ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
                        size: 20,
                      ),
                      label: Text(
                        isSaved ? 'Corte Salvo no Armário' : 'Salvar no Meu Armário',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isSaved ? AppColors.neonPrimary : Colors.black,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _haircutService.toggleSaveHaircut(widget.haircut.id);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.card,
                            duration: const Duration(seconds: 2),
                            content: Text(
                              isSaved
                                  ? 'Corte removido do seu Armário.'
                                  : 'Corte salvo no seu Armário com sucesso!',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
