import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/outfit_service.dart';
import '../../../domain/models/outfit.dart';
import '../../widgets/fullscreen_image_viewer.dart';

class OutfitDetailScreen extends StatefulWidget {
  final Outfit outfit;

  const OutfitDetailScreen({super.key, required this.outfit});

  @override
  State<OutfitDetailScreen> createState() => _OutfitDetailScreenState();
}

class _OutfitDetailScreenState extends State<OutfitDetailScreen> {
  final OutfitService _outfitService = OutfitService();

  Future<void> _openAffiliateUrl(String? url) async {
    if (url == null || url.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link de compra em atualização pelos curadores.')),
      );
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri != null) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Não foi possível abrir o link do parceiro.')),
          );
        }
      }
    }
  }

  void _openFullScreenImage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullscreenImageViewer(
          imageUrl: widget.outfit.imageUrl,
          title: widget.outfit.title,
          heroTag: 'outfit_img_${widget.outfit.id}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSaved = _outfitService.isOutfitSaved(widget.outfit.id);

    return Scaffold(
      backgroundColor: AppColors.backgroundMain,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Foto Principal do Outfit Completo
          SliverAppBar(
            expandedHeight: 380.0,
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
                      _outfitService.toggleSaveOutfit(widget.outfit.id);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.card,
                        duration: const Duration(seconds: 2),
                        content: Text(
                          isSaved
                              ? 'Look removido do seu Armário.'
                              : 'Look salvo no seu Armário com sucesso!',
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
              background: GestureDetector(
                onTap: () => _openFullScreenImage(context),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'outfit_img_${widget.outfit.id}',
                      child: CachedNetworkImage(
                        imageUrl: widget.outfit.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: AppColors.backgroundSecondary),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.backgroundSecondary,
                          child: const Center(
                            child: Icon(Icons.checkroom_rounded, color: AppColors.textSecondary, size: 60),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.4),
                              Colors.transparent,
                              AppColors.backgroundMain.withValues(alpha: 0.8),
                              AppColors.backgroundMain,
                            ],
                            stops: const [0.0, 0.4, 0.85, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Badge de Toque para Expandir Foto
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
          ),

          // Informações do Outfit & Cabeçalho
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges de Estilo & Ocasião
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
                        child: Text(
                          widget.outfit.styleCategory.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.neonLight,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.textSecondary.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.outfit.occasion,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.outfit.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: widget.outfit.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.royalBlue.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.neonPrimary.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.tag, size: 12, color: AppColors.neonLight),
                              const SizedBox(width: 4),
                              Text(
                                tag,
                                style: const TextStyle(
                                  color: AppColors.neonLight,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Título do Look
                  Text(
                    widget.outfit.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Descrição e Harmonização
                  Text(
                    widget.outfit.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botão de Ação Rápida para Salvar no Armário
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _outfitService.toggleSaveOutfit(widget.outfit.id);
                      });
                    },
                    icon: Icon(
                      isSaved ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
                      color: isSaved ? AppColors.neonPrimary : Colors.white,
                      size: 20,
                    ),
                    label: Text(
                      isSaved ? 'Look Salvo no Meu Armário' : 'Salvar Look no Meu Armário',
                      style: TextStyle(
                        color: isSaved ? AppColors.neonPrimary : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isSaved ? AppColors.neonPrimary : AppColors.neonPrimary.withValues(alpha: 0.3),
                        width: 1.2,
                      ),
                      backgroundColor: AppColors.card,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                  if (widget.outfit.pieces.isNotEmpty) ...[
                    const SizedBox(height: 32),

                    // Divisor & Título da Seção de Peças
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'PEÇAS DO LOOK & ONDE COMPRAR',
                          style: TextStyle(
                            color: AppColors.neonPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          '${widget.outfit.pieces.length} itens',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],
                ],
              ),
            ),
          ),

          // Lista de Peças com Links de Afiliados
          if (widget.outfit.pieces.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final piece = widget.outfit.pieces[index];
                    return _buildPieceCard(piece, index + 1);
                  },
                  childCount: widget.outfit.pieces.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }

  Widget _buildPieceCard(OutfitPiece piece, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.neonPrimary.withValues(alpha: 0.3),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonPrimary.withValues(alpha: 0.04),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categoria da Peça e Marca
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.neonPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  piece.category.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.neonLight,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              if (piece.brand != null && piece.brand!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  piece.brand!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const Spacer(),
              Text(
                piece.price,
                style: const TextStyle(
                  color: AppColors.neonLight,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Nome da Peça
          Text(
            piece.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),

          // Dica de estilo/caimento
          if (piece.notes != null && piece.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              piece.notes!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Botão Direto para Comprar Peça com Link de Afiliado
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openAffiliateUrl(piece.affiliateUrl),
              icon: const Icon(Icons.open_in_new_rounded, size: 16, color: Colors.black),
              label: const Text(
                'Comprar Peça no Parceiro',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.3,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
