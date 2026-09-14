import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/outfit_service.dart';
import '../../../core/services/haircut_service.dart';
import '../../../domain/models/outfit.dart';
import '../../../domain/models/haircut.dart';
import 'outfit_detail_screen.dart';
import 'haircut_detail_screen.dart';

class OutfitsScreen extends StatefulWidget {
  const OutfitsScreen({super.key});

  @override
  State<OutfitsScreen> createState() => _OutfitsScreenState();
}

class _OutfitsScreenState extends State<OutfitsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Services
  final OutfitService _outfitService = OutfitService();
  final HaircutService _haircutService = HaircutService();

  // Outfits State
  String _selectedOutfitCategory = 'Todos';
  String _selectedOutfitTag = '';
  final TextEditingController _outfitSearchController = TextEditingController();

  final List<String> _outfitCategories = [
    'Todos',
    'Smart Casual',
    'Old Money',
    'Minimalista',
    'Criativo',
    'Streetwear',
    'Casual Urbano',
    'Clássico',
    'Esportivo',
  ];

  // Haircuts State
  String _selectedHairType = 'Todos';
  String _selectedFaceShape = 'Todos';
  String _selectedHaircutTag = '';
  final TextEditingController _haircutSearchController =
      TextEditingController();

  final List<String> _hairTypes = [
    'Todos',
    'Liso',
    'Ondulado',
    'Cacheado',
    'Crespo',
  ];

  final List<String> _faceShapes = [
    'Todos',
    'Quadrado',
    'Diamante',
    'Oval',
    'Redondo',
    'Triangular',
    'Coração',
    'Oblongo',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _outfitService.addListener(_onServiceUpdate);
    _haircutService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _outfitService.removeListener(_onServiceUpdate);
    _haircutService.removeListener(_onServiceUpdate);
    _outfitSearchController.dispose();
    _haircutSearchController.dispose();
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  bool get _hasActiveOutfitFilters =>
      _selectedOutfitCategory != 'Todos' ||
      _selectedOutfitTag.isNotEmpty ||
      _outfitSearchController.text.trim().isNotEmpty;

  bool get _hasActiveHaircutFilters =>
      _selectedHairType != 'Todos' ||
      _selectedFaceShape != 'Todos' ||
      _selectedHaircutTag.isNotEmpty ||
      _haircutSearchController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final isHaircutTab = _tabController.index == 1;

    return Scaffold(
      backgroundColor: AppColors.backgroundMain,
      appBar: AppBar(
        title: const Text(
          'Galeria de Estilos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
        backgroundColor: AppColors.backgroundMain,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (!isHaircutTab && _hasActiveOutfitFilters)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedOutfitCategory = 'Todos';
                  _selectedOutfitTag = '';
                  _outfitSearchController.clear();
                });
              },
              icon: const Icon(
                Icons.clear_all,
                size: 16,
                color: AppColors.neonPrimary,
              ),
              label: const Text(
                'Limpar',
                style: TextStyle(color: AppColors.neonPrimary, fontSize: 12),
              ),
            ),
          if (isHaircutTab && _hasActiveHaircutFilters)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedHairType = 'Todos';
                  _selectedFaceShape = 'Todos';
                  _selectedHaircutTag = '';
                  _haircutSearchController.clear();
                });
              },
              icon: const Icon(
                Icons.clear_all,
                size: 16,
                color: AppColors.neonPrimary,
              ),
              label: const Text(
                'Limpar',
                style: TextStyle(color: AppColors.neonPrimary, fontSize: 12),
              ),
            ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.neonPrimary.withValues(alpha: 0.2),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                dividerHeight: 0,
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
                  Tab(
                    icon: Icon(Icons.auto_awesome_mosaic_outlined, size: 17),
                    text: 'Outfits',
                  ),
                  Tab(
                    icon: Icon(Icons.content_cut_outlined, size: 17),
                    text: 'Cortes de Cabelo',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [_buildOutfitsTab(), _buildHaircutsTab()],
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 1: OUTFITS
  // ===========================================================================
  Widget _buildOutfitsTab() {
    final allOutfits = _outfitService.outfits;

    final Set<String> allTags = {};
    for (final o in allOutfits) {
      allTags.addAll(o.tags.map((t) => t.toLowerCase().trim()));
    }
    final sortedTags = allTags.where((t) => t.isNotEmpty).toList()..sort();

    final searchQuery = _outfitSearchController.text.trim().toLowerCase();
    final filteredOutfits = allOutfits.where((o) {
      if (_selectedOutfitCategory != 'Todos') {
        final matchCategory =
            o.styleCategory.toLowerCase().contains(
              _selectedOutfitCategory.toLowerCase(),
            ) ||
            _selectedOutfitCategory.toLowerCase().contains(
              o.styleCategory.toLowerCase(),
            );
        if (!matchCategory) return false;
      }

      if (_selectedOutfitTag.isNotEmpty) {
        final hasTag = o.tags.any(
          (t) => t.toLowerCase().trim() == _selectedOutfitTag.toLowerCase(),
        );
        if (!hasTag) return false;
      }

      if (searchQuery.isNotEmpty) {
        final inTitle = o.title.toLowerCase().contains(searchQuery);
        final inCategory = o.styleCategory.toLowerCase().contains(searchQuery);
        final inDescription = o.description.toLowerCase().contains(searchQuery);
        final inTags = o.tags.any((t) => t.toLowerCase().contains(searchQuery));
        final inPieces = o.pieces.any(
          (p) => p.name.toLowerCase().contains(searchQuery),
        );
        if (!inTitle && !inCategory && !inDescription && !inTags && !inPieces) {
          return false;
        }
      }

      return true;
    }).toList();

    return RefreshIndicator(
      onRefresh: _outfitService.refreshOutfits,
      color: AppColors.neonPrimary,
      backgroundColor: AppColors.card,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // Barra de Pesquisa de Estilos / Tags
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.neonPrimary.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _outfitSearchController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Buscar estilo, tag (ex: casual, linho, blazer)...',
                    hintStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                    suffixIcon: _outfitSearchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.textSecondary,
                              size: 16,
                            ),
                            onPressed: () {
                              _outfitSearchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ),

          // Chips de Categoria de Estilo (Horizontal)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _outfitCategories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _outfitCategories[index];
                  final isSelected = cat == _selectedOutfitCategory;

                  return InkWell(
                    onTap: () => setState(() => _selectedOutfitCategory = cat),
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.neonPrimary.withValues(alpha: 0.2)
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.neonPrimary
                              : AppColors.neonPrimary.withValues(alpha: 0.2),
                          width: isSelected ? 1.4 : 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.neonPrimary
                                : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Chips de Tags Disponíveis
          if (sortedTags.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 32,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: sortedTags.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final tag = sortedTags[index];
                    final isSelected =
                        _selectedOutfitTag.toLowerCase() == tag.toLowerCase();

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedOutfitTag = isSelected ? '' : tag;
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.royalBlue
                              : AppColors.card.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.cyanAccent
                                : AppColors.cardBorder,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.tag,
                              size: 11,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              tag,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 14)),

          // Grade de Outfits
          if (_outfitService.isLoading && allOutfits.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.neonPrimary),
                    SizedBox(height: 16),
                    Text(
                      'Carregando estilos...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (filteredOutfits.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.style_outlined,
                        size: 54,
                        color: AppColors.neonPrimary.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        allOutfits.isEmpty
                            ? 'Nenhum look publicado ainda.'
                            : 'Nenhum look encontrado para este filtro.',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        allOutfits.isEmpty
                            ? 'Os looks e composições curadas serão exibidos aqui assim que publicados.'
                            : 'Tente selecionar outro estilo ou limpar a busca.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.64,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final outfit = filteredOutfits[index];
                  return _buildOutfitGridCard(outfit);
                }, childCount: filteredOutfits.length),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildOutfitGridCard(Outfit outfit) {
    final isSaved = _outfitService.isOutfitSaved(outfit.id);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neonPrimary.withValues(alpha: 0.25),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => OutfitDetailScreen(outfit: outfit),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagem e Badges
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: outfit.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.backgroundSecondary,
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.neonPrimary,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.backgroundSecondary,
                          child: const Icon(
                            Icons.checkroom_rounded,
                            color: AppColors.textSecondary,
                            size: 36,
                          ),
                        ),
                      ),
                    ),

                    // Gradiente escuro para legibilidade
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.45),
                              Colors.transparent,
                              AppColors.card.withValues(alpha: 0.95),
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Badge de Estilo no topo esquerdo
                    Positioned(
                      top: 8,
                      left: 8,
                      right: 42,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundMain.withValues(
                              alpha: 0.85,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.neonPrimary.withValues(
                                alpha: 0.45,
                              ),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            outfit.styleCategory.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.neonLight,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Botão de Bookmark no topo direito
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            _outfitService.toggleSaveOutfit(outfit.id);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppColors.card,
                                duration: const Duration(seconds: 2),
                                content: Text(
                                  isSaved
                                      ? 'Removido do seu Armário.'
                                      : 'Look adicionado ao seu Armário!',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundMain.withValues(
                                alpha: 0.75,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSaved
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              color: isSaved
                                  ? AppColors.neonPrimary
                                  : Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Tags no rodapé da imagem
                    if (outfit.tags.isNotEmpty)
                      Positioned(
                        bottom: 6,
                        left: 8,
                        right: 8,
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: outfit.tags.take(2).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '#$tag',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ),
              ),

              // Informações do Outfit no rodapé do Card
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      outfit.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          size: 12,
                          color: AppColors.neonPrimary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${outfit.pieces.length} peças com link',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
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

  // ===========================================================================
  // TAB 2: CORTES DE CABELO
  // ===========================================================================
  Widget _buildHaircutsTab() {
    final allHaircuts = _haircutService.haircuts;

    // Extrair todas as tags de cortes
    final Set<String> allHaircutTags = {};
    for (final h in allHaircuts) {
      allHaircutTags.addAll(h.tags.map((t) => t.toLowerCase().trim()));
    }
    final sortedHaircutTags = allHaircutTags.where((t) => t.isNotEmpty).toList()
      ..sort();

    final searchQuery = _haircutSearchController.text.trim().toLowerCase();
    final filteredHaircuts = allHaircuts.where((h) {
      // Filtro de tipo de cabelo (single-select)
      if (_selectedHairType != 'Todos') {
        if (h.hairType.toLowerCase() != _selectedHairType.toLowerCase()) {
          return false;
        }
      }

      // Filtro de formato de rosto
      if (_selectedFaceShape != 'Todos') {
        final matchShape = h.faceShapes.any(
          (f) => f.toLowerCase() == _selectedFaceShape.toLowerCase(),
        );
        if (!matchShape) return false;
      }

      // Filtro de tag
      if (_selectedHaircutTag.isNotEmpty) {
        final hasTag = h.tags.any(
          (t) => t.toLowerCase().trim() == _selectedHaircutTag.toLowerCase(),
        );
        if (!hasTag) return false;
      }

      // Filtro de busca textual
      if (searchQuery.isNotEmpty) {
        final inTitle = h.title.toLowerCase().contains(searchQuery);
        final inHairType = h.hairType.toLowerCase().contains(searchQuery);
        final inDescription = h.description.toLowerCase().contains(searchQuery);
        final inProduct = h.recommendedStylingProduct.toLowerCase().contains(
          searchQuery,
        );
        final inFaces = h.faceShapes.any(
          (f) => f.toLowerCase().contains(searchQuery),
        );
        final inTags = h.tags.any((t) => t.toLowerCase().contains(searchQuery));
        if (!inTitle &&
            !inHairType &&
            !inDescription &&
            !inProduct &&
            !inFaces &&
            !inTags) {
          return false;
        }
      }

      return true;
    }).toList();

    return RefreshIndicator(
      onRefresh: _haircutService.refreshHaircuts,
      color: AppColors.neonPrimary,
      backgroundColor: AppColors.card,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // Barra de Pesquisa de Cortes / Visagismo
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.neonPrimary.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _haircutSearchController,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Buscar corte, produto, visagismo (ex: fade, quiff)...',
                    hintStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                    suffixIcon: _haircutSearchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.textSecondary,
                              size: 16,
                            ),
                            onPressed: () {
                              _haircutSearchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ),

          // Chips de Tipo de Cabelo (Single-Select)
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: Row(
                    children: [
                      Icon(
                        Icons.texture_rounded,
                        size: 13,
                        color: AppColors.neonLight,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'TIPO DE CABELO',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _hairTypes.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final hair = _hairTypes[index];
                      final isSelected = hair == _selectedHairType;

                      return InkWell(
                        onTap: () => setState(() => _selectedHairType = hair),
                        borderRadius: BorderRadius.circular(18),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.neonPrimary.withValues(alpha: 0.2)
                                : AppColors.card,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.neonPrimary
                                  : AppColors.neonPrimary.withValues(
                                      alpha: 0.2,
                                    ),
                              width: isSelected ? 1.4 : 1.0,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              hair,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.neonPrimary
                                    : AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // Chips de Formato de Rosto
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  child: Row(
                    children: [
                      Icon(
                        Icons.face_retouching_natural_rounded,
                        size: 13,
                        color: AppColors.neonLight,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'FORMATO DE ROSTO',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _faceShapes.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final face = _faceShapes[index];
                      final isSelected = face == _selectedFaceShape;

                      return InkWell(
                        onTap: () => setState(() => _selectedFaceShape = face),
                        borderRadius: BorderRadius.circular(18),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.royalBlue.withValues(alpha: 0.3)
                                : AppColors.card,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.cyanAccent
                                  : AppColors.neonPrimary.withValues(
                                      alpha: 0.2,
                                    ),
                              width: isSelected ? 1.4 : 1.0,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              face,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.cyanAccent
                                    : AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Chips de Tags
          if (sortedHaircutTags.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 30,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: sortedHaircutTags.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final tag = sortedHaircutTags[index];
                    final isSelected =
                        _selectedHaircutTag.toLowerCase() == tag.toLowerCase();

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedHaircutTag = isSelected ? '' : tag;
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.royalBlue
                              : AppColors.card.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.cyanAccent
                                : AppColors.cardBorder,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.tag,
                              size: 11,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              tag,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 14)),

          // Grade de Cortes de Cabelo
          if (_haircutService.isLoading && allHaircuts.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.neonPrimary),
                    SizedBox(height: 16),
                    Text(
                      'Carregando cortes & visagismo...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (filteredHaircuts.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.content_cut_rounded,
                        size: 54,
                        color: AppColors.neonPrimary.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        allHaircuts.isEmpty
                            ? 'Nenhum corte publicado ainda.'
                            : 'Nenhum corte encontrado para este filtro.',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        allHaircuts.isEmpty
                            ? 'Os cortes de cabelo e visagismo curados serão exibidos aqui assim que publicados.'
                            : 'Tente selecionar outro tipo de cabelo ou formato de rosto.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.64,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final haircut = filteredHaircuts[index];
                  return _buildHaircutGridCard(haircut);
                }, childCount: filteredHaircuts.length),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildHaircutGridCard(Haircut haircut) {
    final isSaved = _haircutService.isHaircutSaved(haircut.id);
    final hasImages = haircut.imageUrls.isNotEmpty;
    final primaryImage = hasImages ? haircut.imageUrls.first : '';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neonPrimary.withValues(alpha: 0.25),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => HaircutDetailScreen(haircut: haircut),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagem e Badges
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      child: hasImages
                          ? CachedNetworkImage(
                              imageUrl: primaryImage,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppColors.backgroundSecondary,
                                child: const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.neonPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppColors.backgroundSecondary,
                                child: const Icon(
                                  Icons.content_cut,
                                  color: AppColors.textSecondary,
                                  size: 36,
                                ),
                              ),
                            )
                          : Container(
                              color: AppColors.backgroundSecondary,
                              child: const Icon(
                                Icons.content_cut,
                                color: AppColors.textSecondary,
                                size: 36,
                              ),
                            ),
                    ),

                    // Gradiente escuro para legibilidade
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.45),
                              Colors.transparent,
                              AppColors.card.withValues(alpha: 0.95),
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Badge de Tipo de Cabelo no topo esquerdo
                    Positioned(
                      top: 8,
                      left: 8,
                      right: 42,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundMain.withValues(
                              alpha: 0.85,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.neonPrimary.withValues(
                                alpha: 0.45,
                              ),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            haircut.hairType.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.neonLight,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Botão de Bookmark no topo direito
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            _haircutService.toggleSaveHaircut(haircut.id);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundMain.withValues(
                                alpha: 0.75,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSaved
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              color: isSaved
                                  ? AppColors.neonPrimary
                                  : Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Badge de múltiplas fotos no canto inferior direito da imagem
                    if (haircut.imageUrls.length > 1)
                      Positioned(
                        bottom: 6,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 0.6,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.photo_library_rounded,
                                size: 10,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${haircut.imageUrls.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Formatos de rosto no rodapé da imagem
                    if (haircut.faceShapes.isNotEmpty)
                      Positioned(
                        bottom: 6,
                        left: 8,
                        right: haircut.imageUrls.length > 1 ? 40 : 8,
                        child: Text(
                          haircut.faceShapes.take(2).join(' • '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.neonLight.withValues(alpha: 0.9),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Informações do Corte no rodapé do Card
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      haircut.title.trim().isNotEmpty
                          ? haircut.title
                          : 'Corte ${haircut.hairType}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_fix_high_rounded,
                          size: 12,
                          color: AppColors.neonPrimary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            haircut.recommendedStylingProduct.isNotEmpty
                                ? haircut.recommendedStylingProduct
                                : '${haircut.faceShapes.length} formatos ideais',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
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
