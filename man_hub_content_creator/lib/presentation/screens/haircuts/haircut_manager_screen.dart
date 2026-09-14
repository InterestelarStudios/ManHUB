import 'package:flutter/material.dart';
import '../../../core/theme/creator_theme.dart';
import '../../../domain/models/haircut.dart';
import '../../../services/haircut_creator_service.dart';
import 'create_haircut_screen.dart';

class HaircutManagerScreen extends StatefulWidget {
  const HaircutManagerScreen({super.key});

  @override
  State<HaircutManagerScreen> createState() => _HaircutManagerScreenState();
}

class _HaircutManagerScreenState extends State<HaircutManagerScreen> {
  String _searchQuery = '';
  String _selectedHairType = 'Todos';

  final List<String> _hairTypes = [
    'Todos',
    'Liso',
    'Ondulado',
    'Cacheado',
    'Crespo',
  ];

  void _openCreateHaircut([Haircut? haircut]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateHaircutScreen(haircutToEdit: haircut),
      ),
    );
  }

  void _confirmDelete(Haircut haircut) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: CreatorTheme.cardBg,
          title: const Text('Excluir Corte de Cabelo?',
              style: TextStyle(color: Colors.white)),
          content: Text(
            'Tem certeza que deseja excluir "${haircut.title}" do catálogo do Man Hub?',
            style: const TextStyle(color: CreatorTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar',
                  style: TextStyle(color: CreatorTheme.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                final ok = await HaircutCreatorService.deleteHaircutFromFirestore(
                    haircut.id);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(ok
                        ? 'Corte "${haircut.title}" excluído com sucesso!'
                        : 'Erro ao excluir corte.'),
                    backgroundColor: ok ? Colors.green : Colors.red,
                  ),
                );
              },
              child: const Text('Excluir', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CreatorTheme.backgroundMain,
      appBar: AppBar(
        title: const Text('Catálogo de Cortes & Visagismo'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: () => _openCreateHaircut(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Novo Corte'),
              style: ElevatedButton.styleFrom(
                backgroundColor: CreatorTheme.neonPrimary,
                foregroundColor: Colors.black,
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Haircut>>(
        stream: HaircutCreatorService.streamHaircuts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                  color: CreatorTheme.neonPrimary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar cortes: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final allHaircuts = snapshot.data ?? [];

          // Filtragem
          final filtered = allHaircuts.where((h) {
            if (_selectedHairType != 'Todos') {
              if (h.hairType.toLowerCase() != _selectedHairType.toLowerCase()) {
                return false;
              }
            }
            if (_searchQuery.isNotEmpty) {
              final inTitle =
                  h.title.toLowerCase().contains(_searchQuery.toLowerCase());
              final inDesc = h.description
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
              final inFaces = h.faceShapes.any((f) =>
                  f.toLowerCase().contains(_searchQuery.toLowerCase()));
              final inTags = h.tags.any((t) =>
                  t.toLowerCase().contains(_searchQuery.toLowerCase()));
              if (!inTitle && !inDesc && !inFaces && !inTags) {
                return false;
              }
            }
            return true;
          }).toList();

          return Column(
            children: [
              // Barra de Pesquisa e Filtros
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                color: CreatorTheme.cardBg,
                child: Column(
                  children: [
                    TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText:
                            'Buscar por nome, formato de rosto, tag ou estilo...',
                        prefixIcon: const Icon(Icons.search,
                            color: CreatorTheme.neonPrimary),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () =>
                                    setState(() => _searchQuery = ''),
                              )
                            : null,
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _hairTypes.map((type) {
                          final isSelected = _selectedHairType == type;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(type),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _selectedHairType = type);
                                }
                              },
                              selectedColor: CreatorTheme.neonPrimary
                                  .withValues(alpha: 0.25),
                              side: BorderSide(
                                color: isSelected
                                    ? CreatorTheme.neonPrimary
                                    : Colors.white.withValues(alpha: 0.1),
                              ),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? CreatorTheme.neonPrimary
                                    : Colors.white70,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Contador
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filtered.length} corte(s) cadastrado(s)',
                      style: const TextStyle(
                        color: CreatorTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Grid de Cortes
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.content_cut,
                                size: 56, color: Colors.white24),
                            const SizedBox(height: 16),
                            const Text(
                              'Nenhum corte de cabelo encontrado.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Clique no botão abaixo para cadastrar o primeiro estilo!',
                              style: TextStyle(
                                  color: CreatorTheme.textSecondary,
                                  fontSize: 13),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => _openCreateHaircut(),
                              icon: const Icon(Icons.add),
                              label: const Text('Novo Corte'),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(24),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 360,
                          mainAxisExtent: 380,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final haircut = filtered[index];
                          return _buildHaircutCard(haircut);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHaircutCard(Haircut haircut) {
    final hasImages = haircut.imageUrls.isNotEmpty;
    final coverUrl = hasImages ? haircut.imageUrls.first : '';

    return Container(
      decoration: BoxDecoration(
        color: CreatorTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CreatorTheme.neonPrimary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto de Capa
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: hasImages
                    ? Image.network(
                        coverUrl,
                        height: 170,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 170,
                          color: Colors.black26,
                          child: const Icon(Icons.broken_image,
                              color: Colors.white24, size: 40),
                        ),
                      )
                    : Container(
                        height: 170,
                        color: Colors.black26,
                        child: const Icon(Icons.content_cut,
                            color: Colors.white24, size: 40),
                      ),
              ),
              // Badge de Tipo de Cabelo
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: CreatorTheme.neonPrimary.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    haircut.hairType.toUpperCase(),
                    style: const TextStyle(
                      color: CreatorTheme.neonLight,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              // Badge de Quantidade de Fotos
              if (haircut.imageUrls.length > 1)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.photo_library_rounded,
                            color: Colors.white70, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '${haircut.imageUrls.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Informações do corte
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  haircut.title.trim().isNotEmpty
                      ? haircut.title
                      : 'Corte ${haircut.hairType}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Harmoniza com: ${haircut.faceShapes.join(', ')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CreatorTheme.neonLight,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (haircut.description.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    haircut.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: CreatorTheme.textSecondary,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
                const SizedBox(height: 14),

                // Ações
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          color: CreatorTheme.neonPrimary, size: 20),
                      tooltip: 'Editar Corte',
                      onPressed: () => _openCreateHaircut(haircut),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.redAccent, size: 20),
                      tooltip: 'Excluir Corte',
                      onPressed: () => _confirmDelete(haircut),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
