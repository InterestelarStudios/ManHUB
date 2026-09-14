import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/creator_theme.dart';
import '../../../domain/models/outfit.dart';
import '../../../services/outfit_creator_service.dart';

class PieceInputItem {
  final TextEditingController nameController;
  final TextEditingController linkController;
  final TextEditingController priceController;
  final TextEditingController brandController;
  final TextEditingController notesController;
  String category;

  PieceInputItem({
    String? name,
    String? link,
    String? price,
    String? brand,
    String? notes,
    String? category,
  })  : nameController = TextEditingController(text: name ?? ''),
        linkController = TextEditingController(text: link ?? ''),
        priceController = TextEditingController(text: price ?? ''),
        brandController = TextEditingController(text: brand ?? ''),
        notesController = TextEditingController(text: notes ?? ''),
        category = category ?? 'Torso / Camisa';

  void dispose() {
    nameController.dispose();
    linkController.dispose();
    priceController.dispose();
    brandController.dispose();
    notesController.dispose();
  }
}

class CreateOutfitScreen extends StatefulWidget {
  final Outfit? outfitToEdit;

  const CreateOutfitScreen({super.key, this.outfitToEdit});

  @override
  State<CreateOutfitScreen> createState() => _CreateOutfitScreenState();
}

class _CreateOutfitScreenState extends State<CreateOutfitScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _tagInputController;
  late final TextEditingController _customCategoryController;

  String _selectedStyleCategory = 'Smart Casual';
  String _selectedOccasion = 'Trabalho / Corporativo';
  final List<String> _tags = [];
  final List<PieceInputItem> _pieceInputs = [];
  bool _isSaving = false;

  final List<String> _standardCategories = [
    'Smart Casual',
    'Old Money',
    'Minimalista',
    'Criativo',
    'Streetwear',
    'Casual Urbano',
    'Clássico',
    'Esportivo',
    'Outro',
  ];

  final List<String> _occasions = [
    'Trabalho / Corporativo',
    'Encontro Noturno',
    'Fim de Semana Casual',
    'Festa / Evento Social',
    'Casamento / Gala',
    'Viagem / Resort',
  ];

  final List<String> _pieceCategories = [
    'Torso / Camisa',
    'Torso / Camiseta',
    'Torso / Polo',
    'Casaco / Blazer',
    'Casaco / Jaqueta',
    'Casaco / Tricô',
    'Calça / Alfaiataria',
    'Calça / Jeans',
    'Calça / Chino',
    'Calçado / Sapato',
    'Calçado / Bota',
    'Calçado / Tênis',
    'Acessório / Relógio',
    'Acessório / Óculos',
    'Perfumaria / Assinatura',
    'Outro',
  ];

  @override
  void initState() {
    super.initState();
    final editing = widget.outfitToEdit;

    _titleController = TextEditingController(text: editing?.title ?? '');
    _imageUrlController = TextEditingController(text: editing?.imageUrl ?? '');
    _descriptionController = TextEditingController(text: editing?.description ?? '');
    _tagInputController = TextEditingController();
    _customCategoryController = TextEditingController();

    if (editing != null) {
      if (_standardCategories.contains(editing.styleCategory)) {
        _selectedStyleCategory = editing.styleCategory;
      } else {
        _selectedStyleCategory = 'Outro';
        _customCategoryController.text = editing.styleCategory;
      }

      if (_occasions.contains(editing.occasion)) {
        _selectedOccasion = editing.occasion;
      }

      _tags.addAll(editing.tags);

      for (final p in editing.pieces) {
        _pieceInputs.add(PieceInputItem(
          name: p.name,
          link: p.affiliateUrl,
          price: p.price,
          brand: p.brand,
          notes: p.notes,
          category: p.category,
        ));
      }
    }

    _imageUrlController.addListener(_onImageUrlChange);
  }

  void _onImageUrlChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _imageUrlController.removeListener(_onImageUrlChange);
    _titleController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _tagInputController.dispose();
    _customCategoryController.dispose();
    for (final p in _pieceInputs) {
      p.dispose();
    }
    super.dispose();
  }

  void _addTag() {
    final text = _tagInputController.text.trim().toLowerCase();
    if (text.isNotEmpty && !_tags.contains(text)) {
      setState(() {
        _tags.add(text);
        _tagInputController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _addPieceInput() {
    setState(() {
      _pieceInputs.add(PieceInputItem());
    });
  }

  void _removePieceInput(int index) {
    setState(() {
      final removed = _pieceInputs.removeAt(index);
      removed.dispose();
    });
  }

  Future<void> _saveOutfit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final finalCategory = _selectedStyleCategory == 'Outro'
        ? (_customCategoryController.text.trim().isNotEmpty
            ? _customCategoryController.text.trim()
            : 'Personalizado')
        : _selectedStyleCategory;

    final List<OutfitPiece> pieces = [];
    for (int i = 0; i < _pieceInputs.length; i++) {
      final p = _pieceInputs[i];
      final name = p.nameController.text.trim();
      final link = p.linkController.text.trim();

      if (name.isNotEmpty || link.isNotEmpty) {
        pieces.add(OutfitPiece(
          id: 'piece_${i + 1}_${const Uuid().v4().substring(0, 5)}',
          name: name.isNotEmpty ? name : 'Item ${i + 1}',
          category: p.category,
          price: p.priceController.text.trim(),
          brand: p.brandController.text.trim(),
          affiliateUrl: link,
          notes: p.notesController.text.trim(),
        ));
      }
    }

    final outfitId = widget.outfitToEdit?.id ?? const Uuid().v4();
    final outfit = Outfit(
      id: outfitId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      styleCategory: finalCategory,
      occasion: _selectedOccasion,
      imageUrl: _imageUrlController.text.trim(),
      pieces: pieces,
      tags: _tags,
      creatorName: 'Man Hub Curadoria',
      isFeatured: true,
      createdAt: widget.outfitToEdit?.createdAt ?? DateTime.now(),
    );

    final ok = await OutfitCreatorService.saveOutfitToFirestore(outfit);

    setState(() => _isSaving = false);

    if (mounted) {
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Outfit "${outfit.title}" publicado com sucesso no Man Hub!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao publicar outfit no Firestore. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.outfitToEdit != null;
    final previewUrl = _imageUrlController.text.trim();

    return Scaffold(
      backgroundColor: CreatorTheme.backgroundMain,
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Outfit' : 'Publicar Novo Outfit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline_rounded, color: CreatorTheme.neonPrimary, size: 26),
            tooltip: 'Salvar no Firestore',
            onPressed: _isSaving ? null : _saveOutfit,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isSaving
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: CreatorTheme.neonPrimary),
                  SizedBox(height: 16),
                  Text('Publicando no Cloud Firestore...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seção 1: Imagem do Look
                    _buildSectionHeader('1. FOTO DO LOOK / ESTILO', Icons.image_outlined),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL da Imagem de Alta Resolução',
                        hintText: 'https://exemplo.com/foto_look.jpg',
                        prefixIcon: Icon(Icons.link, color: CreatorTheme.neonPrimary),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Insira o link da imagem do look.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Preview da Imagem em Tempo Real
                    if (previewUrl.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: CreatorTheme.cardBg,
                            border: Border.all(color: CreatorTheme.neonPrimary.withValues(alpha: 0.3)),
                          ),
                          child: Image.network(
                            previewUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image, color: Colors.orangeAccent, size: 36),
                                  SizedBox(height: 6),
                                  Text('Não foi possível carregar a prévia do link.', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 16),

                    // Seção 2: Título e Categorização
                    _buildSectionHeader('2. INFORMAÇÕES DO ESTILO', Icons.tune_rounded),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título do Look / Estilo',
                        hintText: 'Ex: Smart Casual Riviera & Linho',
                        prefixIcon: Icon(Icons.title, color: CreatorTheme.neonPrimary),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Insira um título para o estilo.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Dropdown Categoria de Estilo
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedStyleCategory,
                            decoration: const InputDecoration(
                              labelText: 'Categoria de Estilo',
                              prefixIcon: Icon(Icons.category_outlined, color: CreatorTheme.neonPrimary),
                            ),
                            items: _standardCategories.map((cat) {
                              return DropdownMenuItem(value: cat, child: Text(cat));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedStyleCategory = val);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedOccasion,
                            decoration: const InputDecoration(
                              labelText: 'Ocasião Recomendada',
                              prefixIcon: Icon(Icons.event_seat_outlined, color: CreatorTheme.neonPrimary),
                            ),
                            items: _occasions.map((occ) {
                              return DropdownMenuItem(value: occ, child: Text(occ, overflow: TextOverflow.ellipsis));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedOccasion = val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    if (_selectedStyleCategory == 'Outro') ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _customCategoryController,
                        decoration: const InputDecoration(
                          labelText: 'Nome da Categoria Personalizada',
                          hintText: 'Ex: Streetwear Futurista',
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descrição & Dicas de Harmonização',
                        hintText: 'Explique a harmonia das peças, caimento recomendado e postura ao usar...',
                        alignLabelWithHint: true,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Seção 3: Tags Dinâmicas (ex: halloween, carnaval, casamento, etc.)
                    _buildSectionHeader('3. TAGS DINÂMICAS', Icons.tag),
                    const SizedBox(height: 4),
                    const Text(
                      'Defina tags para que os usuários possam encontrar facilmente o estilo (ex: halloween, carnaval, casamento, verão, minimalista, praia...).',
                      style: TextStyle(color: CreatorTheme.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _tagInputController,
                            decoration: const InputDecoration(
                              hintText: 'Digite o nome da tag (ex: carnaval)',
                              prefixIcon: Icon(Icons.tag, color: CreatorTheme.neonPrimary),
                            ),
                            onFieldSubmitted: (_) => _addTag(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _addTag,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Adicionar'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Chips de Tags Adicionadas
                    if (_tags.isEmpty)
                      const Text(
                        'Nenhuma tag adicionada ainda.',
                        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 13),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tags.map((tag) {
                          return Chip(
                            label: Text('#$tag', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            backgroundColor: CreatorTheme.neonPrimary.withValues(alpha: 0.2),
                            deleteIcon: const Icon(Icons.close, size: 16, color: Colors.white70),
                            onDeleted: () => _removeTag(tag),
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 28),

                    // Seção 4: Links Reais de Compra dos Produtos (Peças)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader('4. PEÇAS DO LOOK & ONDE COMPRAR (OPCIONAL)', Icons.shopping_bag_outlined),
                        ElevatedButton.icon(
                          onPressed: _addPieceInput,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Adicionar Peça'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CreatorTheme.cardBg,
                            foregroundColor: CreatorTheme.neonPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Opcional: você pode publicar o look sem produtos, ou adicionar as peças e links de compra caso deseje recomendar aos membros.',
                      style: TextStyle(color: CreatorTheme.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 14),

                    // Estado se nenhuma peça for adicionada
                    if (_pieceInputs.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CreatorTheme.cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.check_circle_outline, color: CreatorTheme.neonLight, size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Nenhuma peça adicionada. O look será publicado apenas como inspiração visual.',
                                style: TextStyle(color: CreatorTheme.textSecondary, fontSize: 12.5),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Lista de Inputs de Peças
                    ...List.generate(_pieceInputs.length, (index) {
                      final item = _pieceInputs[index];
                      return _buildPieceInputCard(item, index);
                    }),

                    const SizedBox(height: 32),

                    // Botão Final de Publicação
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveOutfit,
                        icon: const Icon(Icons.cloud_upload_rounded, size: 20),
                        label: Text(
                          isEditing ? 'Atualizar Outfit no Man Hub' : 'Publicar Outfit no Man Hub',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: CreatorTheme.neonPrimary, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: CreatorTheme.neonPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildPieceInputCard(PieceInputItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CreatorTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: CreatorTheme.neonPrimary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Peça #${index + 1}',
                style: const TextStyle(
                  color: CreatorTheme.neonLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                tooltip: 'Remover Peça',
                onPressed: () => _removePieceInput(index),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Nome do produto & Categoria
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: item.nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Produto / Peça (Opcional)',
                    hintText: 'Ex: Camisa Linho Puro Branco',
                    isDense: true,
                  ),
                  validator: (value) {
                    if ((item.linkController.text.trim().isNotEmpty || item.priceController.text.trim().isNotEmpty) &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Informe o nome da peça ou limpe o link.';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: item.category,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    isDense: true,
                  ),
                  items: _pieceCategories.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => item.category = val);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Link Real de Compra (URL)
          TextFormField(
            controller: item.linkController,
            decoration: const InputDecoration(
              labelText: 'Link Real de Compra (URL)',
              hintText: 'https://loja.com.br/produto/camisa-linho',
              prefixIcon: Icon(Icons.open_in_new, size: 18, color: CreatorTheme.neonPrimary),
              isDense: true,
            ),
          ),
          const SizedBox(height: 10),

          // Preço e Marca
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: item.priceController,
                  decoration: const InputDecoration(
                    labelText: 'Preço Estimado',
                    hintText: 'Ex: R\$ 289,90',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: item.brandController,
                  decoration: const InputDecoration(
                    labelText: 'Marca / Loja',
                    hintText: 'Ex: Zara, Reserva, Foxton',
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Dica / Caimento
          TextFormField(
            controller: item.notesController,
            decoration: const InputDecoration(
              labelText: 'Dica de Caimento / Comentário (opcional)',
              hintText: 'Ex: Usar com a barra italiana ou colarinho aberto',
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}
