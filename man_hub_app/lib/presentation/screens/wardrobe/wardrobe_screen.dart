import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/wardrobe_service.dart';
import '../../../core/services/outfit_service.dart';
import '../../../core/services/auth_service.dart';
import '../outfits/outfit_detail_screen.dart';
import '../profile/personalized_profile_screen.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final WardrobeService _wardrobeService = WardrobeService();
  final OutfitService _outfitService = OutfitService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _launchAffiliateUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Não foi possível abrir o link do parceiro.')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao abrir link externo.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundMain,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundMain,
        elevation: 0,
        title: const Text(
          'Meu Armário',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.neonPrimary.withValues(alpha: 0.2),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    AppColors.neonPrimary.withValues(alpha: 0.3),
                    AppColors.royalBlue.withValues(alpha: 0.3),
                  ],
                ),
                border: Border.all(color: AppColors.neonPrimary),
              ),
              labelColor: AppColors.neonPrimary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              tabs: const [
                Tab(icon: Icon(Icons.auto_awesome_mosaic_outlined, size: 18), text: 'Outfits'),
                Tab(icon: Icon(Icons.content_cut_outlined, size: 18), text: 'Cortes & Visagismo'),
                Tab(icon: Icon(Icons.spa_outlined, size: 18), text: 'Perfumes'),
                Tab(icon: Icon(Icons.palette_outlined, size: 18), text: 'Paleta & Biometria'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSavedOutfitsTab(),
          _buildSavedHaircutsTab(),
          _buildSavedFragrancesTab(),
          _buildPaletteAndBiometricsTab(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: OUTFITS SALVOS
  // ---------------------------------------------------------------------------
  Widget _buildSavedOutfitsTab() {
    return ListenableBuilder(
      listenable: _outfitService,
      builder: (context, _) {
        final saved = _outfitService.savedOutfits;

        if (saved.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.card,
                      border: Border.all(
                        color: AppColors.neonPrimary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.bookmark_border_rounded,
                      size: 48,
                      color: AppColors.neonPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Nenhum look salvo ainda',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Explore a aba Outfits para salvar composições inspiradoras e comprar as peças.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: saved.length,
          itemBuilder: (context, index) {
            final outfit = saved[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.neonPrimary.withValues(alpha: 0.3),
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OutfitDetailScreen(outfit: outfit),
                    ),
                  );
                },
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                      child: Image.network(
                        outfit.imageUrl,
                        width: 110,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 110,
                          height: 120,
                          color: AppColors.backgroundMain,
                          child: const Icon(Icons.image_not_supported, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.neonPrimary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                outfit.styleCategory,
                                style: const TextStyle(
                                  color: AppColors.neonPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              outfit.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${outfit.pieces.length} peças combinadas',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.bookmark_remove, color: AppColors.neonPrimary),
                      tooltip: 'Remover do armário',
                      onPressed: () => _outfitService.toggleSaveOutfit(outfit.id),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: CORTES DE CABELO & VISAGISMO
  // ---------------------------------------------------------------------------
  Widget _buildSavedHaircutsTab() {
    return ListenableBuilder(
      listenable: _wardrobeService,
      builder: (context, _) {
        final haircuts = _wardrobeService.savedHaircuts;

        if (haircuts.isEmpty) {
          return const Center(
            child: Text(
              'Nenhum corte salvo no momento.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: haircuts.length,
          itemBuilder: (context, index) {
            final haircut = haircuts[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 18),
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
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Image.network(
                      haircut.imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 180,
                        color: AppColors.backgroundMain,
                        child: const Icon(Icons.content_cut, color: AppColors.textSecondary, size: 40),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                haircut.title,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.bookmark_remove, color: AppColors.neonPrimary),
                              onPressed: () => _wardrobeService.toggleSaveHaircut(haircut),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.face_retouching_natural, size: 16, color: AppColors.neonPrimary),
                            const SizedBox(width: 6),
                            Text(
                              'Ideal para: ${haircut.faceShape}',
                              style: const TextStyle(
                                color: AppColors.neonPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          haircut.description,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundMain,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.neonPrimary.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.brush_outlined, size: 18, color: AppColors.neonLight),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Fixador recomendado: ${haircut.recommendedStylingProduct}',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
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
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: PERFUMES & ASSINATURA OLFATIVA
  // ---------------------------------------------------------------------------
  Widget _buildSavedFragrancesTab() {
    return ListenableBuilder(
      listenable: _wardrobeService,
      builder: (context, _) {
        final fragrances = _wardrobeService.savedFragrances;

        if (fragrances.isEmpty) {
          return const Center(
            child: Text(
              'Nenhum perfume salvo no momento.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: fragrances.length,
          itemBuilder: (context, index) {
            final frag = fragrances[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.neonPrimary.withValues(alpha: 0.3),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            frag.imageUrl,
                            width: 80,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 80,
                              height: 90,
                              color: AppColors.backgroundMain,
                              child: const Icon(Icons.spa, color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                frag.brand.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.neonPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                frag.name,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                frag.family,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.bookmark_remove, color: AppColors.neonPrimary),
                          onPressed: () => _wardrobeService.toggleSaveFragrance(frag),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundMain,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.neonPrimary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.event_note, size: 14, color: AppColors.neonPrimary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Ocasião: ${frag.occasion}',
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.bubble_chart_outlined, size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Notas: ${frag.notes}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (frag.affiliateUrl != null && frag.affiliateUrl!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.neonPrimary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          onPressed: () => _launchAffiliateUrl(frag.affiliateUrl!),
                          icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.neonPrimary, size: 16),
                          label: const Text(
                            'Ver Oferta na Loja Parceira',
                            style: TextStyle(
                              color: AppColors.neonPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 4: PALETA & BIOMETRIA
  // ---------------------------------------------------------------------------
  Widget _buildPaletteAndBiometricsTab() {
    return ListenableBuilder(
      listenable: _authService,
      builder: (context, _) {
        final profile = _authService.currentUser;

        final skin = profile?.skinTone ?? 'Médio';
        final contrast = profile?.contrastLevel ?? 'Médio';
        final faceShape = profile?.faceShape ?? 'Oval';
        final bodyType = profile?.bodyType ?? 'Atlético';

        final paletteColors = _getRecommendedPalette(contrast);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resumo de Biometria Pessoal
              Container(
                padding: const EdgeInsets.all(18),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sua Assinatura Visual',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppColors.neonPrimary, size: 20),
                          tooltip: 'Editar Biometria',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PersonalizedProfileScreen(user: profile),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildBioBadge('Pele', skin),
                        _buildBioBadge('Contraste', contrast),
                        _buildBioBadge('Rosto', faceShape),
                        _buildBioBadge('Biotipo', bodyType),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Cartela de Cores Recomendadas
              Container(
                padding: const EdgeInsets.all(18),
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
                    Row(
                      children: [
                        const Icon(Icons.color_lens_outlined, color: AppColors.neonPrimary, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Cores Favoráveis ($contrast)',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tons que valorizam suas feições sem apagar sua presença:',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: paletteColors.map((item) {
                        return Column(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: item.color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: item.color.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.name,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Recomendações de Acessórios e Metais
              Container(
                padding: const EdgeInsets.all(18),
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
                    const Row(
                      children: [
                        Icon(Icons.watch_outlined, color: AppColors.neonLight, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Metais e Relógios',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      contrast.toLowerCase().contains('alto')
                          ? 'Para alto contraste, aço escovado, prata pura e mostradores pretos proporcionam a máxima imponência e autoridade.'
                          : 'Para contraste médio/baixo, ouro escovado, bronze, pulseiras em couro conhaque ou café valorizam tons de pele quentes e neutros.',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // CTA para editar perfil
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonPrimary,
                    foregroundColor: AppColors.backgroundMain,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PersonalizedProfileScreen(user: profile),
                      ),
                    );
                  },
                  icon: const Icon(Icons.tune),
                  label: const Text(
                    'Refinar Análise de Estilo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBioBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundMain,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.neonPrimary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.neonPrimary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<_PaletteItem> _getRecommendedPalette(String contrast) {
    final c = contrast.toLowerCase();
    if (c.contains('alto')) {
      return [
        const _PaletteItem('Preto Ônix', Color(0xFF101010)),
        const _PaletteItem('Branco Puro', Color(0xFFF5F5F5)),
        const _PaletteItem('Azul Real', Color(0xFF0F3D78)),
        const _PaletteItem('Borgonha', Color(0xFF58111A)),
        const _PaletteItem('Chumbo', Color(0xFF33383B)),
      ];
    } else if (c.contains('baixo')) {
      return [
        const _PaletteItem('Off-White', Color(0xFFEDE8D0)),
        const _PaletteItem('Areia', Color(0xFFC2B280)),
        const _PaletteItem('Verde Oliva', Color(0xFF556B2F)),
        const _PaletteItem('Caramelo', Color(0xFFA0522D)),
        const _PaletteItem('Azul Pastel', Color(0xFF6C8D9B)),
      ];
    } else {
      // Médio
      return [
        const _PaletteItem('Azul Marinho', Color(0xFF1B2A4A)),
        const _PaletteItem('Cinza Médio', Color(0xFF5A6265)),
        const _PaletteItem('Verde Floresta', Color(0xFF1E4620)),
        const _PaletteItem('Vinho Nobre', Color(0xFF6B1D2F)),
        const _PaletteItem('Bege Frio', Color(0xFFD8D2C2)),
      ];
    }
  }
}

class _PaletteItem {
  final String name;
  final Color color;
  const _PaletteItem(this.name, this.color);
}
