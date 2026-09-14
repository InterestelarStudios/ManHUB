import 'package:flutter/material.dart';
import '../../../core/theme/creator_theme.dart';
import '../../../domain/models/outfit.dart';
import '../../../services/outfit_creator_service.dart';
import 'create_outfit_screen.dart';

class OutfitManagerScreen extends StatefulWidget {
  const OutfitManagerScreen({super.key});

  @override
  State<OutfitManagerScreen> createState() => _OutfitManagerScreenState();
}

class _OutfitManagerScreenState extends State<OutfitManagerScreen> {
  List<Outfit> _outfits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOutfits();
  }

  Future<void> _loadOutfits() async {
    setState(() => _isLoading = true);
    final outfits = await OutfitCreatorService.loadOutfitsFromFirestore();
    if (mounted) {
      setState(() {
        _outfits = outfits;
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmDelete(Outfit outfit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Outfit?'),
        content: Text('Tem certeza que deseja excluir o outfit "${outfit.title}"? Esta ação removerá o look do app do usuário imediatamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final ok = await OutfitCreatorService.deleteOutfitFromFirestore(outfit.id);
      if (mounted) {
        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Outfit "${outfit.title}" removido com sucesso.'),
              backgroundColor: Colors.green,
            ),
          );
          _loadOutfits();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao excluir outfit.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CreatorTheme.backgroundMain,
      appBar: AppBar(
        title: const Text('Gerenciador de Outfits & Estilos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Recarregar do Firestore',
            onPressed: _loadOutfits,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: CreatorTheme.neonPrimary),
                  SizedBox(height: 16),
                  Text('Carregando outfits do Cloud Firestore...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : _outfits.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.style_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'Nenhum outfit publicado ainda no Firestore.',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Clique no botão "+" para publicar o primeiro look com foto, tags e links de compras.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final created = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(builder: (_) => const CreateOutfitScreen()),
                            );
                            if (created == true) _loadOutfits();
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Publicar Primeiro Outfit'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOutfits,
                  color: CreatorTheme.neonPrimary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _outfits.length,
                    itemBuilder: (context, index) {
                      final outfit = _outfits[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: CreatorTheme.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: CreatorTheme.neonPrimary.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Preview da Imagem
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  outfit.imageUrl,
                                  width: 90,
                                  height: 110,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 90,
                                    height: 110,
                                    color: CreatorTheme.backgroundSecondary,
                                    child: const Icon(Icons.broken_image, color: Colors.grey),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Informações do Outfit
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: CreatorTheme.neonPrimary.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            outfit.styleCategory.toUpperCase(),
                                            style: const TextStyle(
                                              color: CreatorTheme.neonLight,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            outfit.occasion,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      outfit.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${outfit.pieces.length} peças com links de compra',
                                      style: const TextStyle(
                                        color: CreatorTheme.neonLight,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (outfit.tags.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 4,
                                        runSpacing: 4,
                                        children: outfit.tags.take(4).map((tag) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.black38,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '#$tag',
                                              style: const TextStyle(color: Colors.white70, fontSize: 10),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Ações
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                                    tooltip: 'Editar Outfit',
                                    onPressed: () async {
                                      final updated = await Navigator.of(context).push<bool>(
                                        MaterialPageRoute(
                                          builder: (_) => CreateOutfitScreen(outfitToEdit: outfit),
                                        ),
                                      );
                                      if (updated == true) _loadOutfits();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                    tooltip: 'Excluir Outfit',
                                    onPressed: () => _confirmDelete(outfit),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const CreateOutfitScreen()),
          );
          if (created == true) _loadOutfits();
        },
        backgroundColor: CreatorTheme.neonPrimary,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          'Publicar Novo Outfit',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
