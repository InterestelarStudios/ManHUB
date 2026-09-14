import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/creator_theme.dart';
import '../../../domain/models/haircut.dart';
import '../../../services/haircut_creator_service.dart';

class CreateHaircutScreen extends StatefulWidget {
  final Haircut? haircutToEdit;

  const CreateHaircutScreen({super.key, this.haircutToEdit});

  @override
  State<CreateHaircutScreen> createState() => _CreateHaircutScreenState();
}

class _CreateHaircutScreenState extends State<CreateHaircutScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _productController;
  late final TextEditingController _tagInputController;

  // Imagens
  final List<Uint8List> _newPastedImages = [];
  final List<String> _existingImageUrls = [];

  // Categorias de Formato de Rosto (Multi-Select)
  final List<String> _availableFaceShapes = [
    'Quadrado',
    'Diamante',
    'Oval',
    'Redondo',
    'Triangular',
    'Coração',
    'Oblongo',
  ];
  final Set<String> _selectedFaceShapes = {};

  // Tipo de Cabelo (Single-Select)
  final List<String> _availableHairTypes = [
    'Liso',
    'Ondulado',
    'Cacheado',
    'Crespo',
  ];
  String _selectedHairType = 'Liso';

  final List<String> _tags = [];
  bool _isSaving = false;
  String _saveProgressMessage = '';

  @override
  void initState() {
    super.initState();
    final editing = widget.haircutToEdit;

    _titleController = TextEditingController(text: editing?.title ?? '');
    _descriptionController =
        TextEditingController(text: editing?.description ?? '');
    _productController = TextEditingController(
        text: editing?.recommendedStylingProduct ?? '');
    _tagInputController = TextEditingController();

    if (editing != null) {
      _existingImageUrls.addAll(editing.imageUrls);
      _selectedFaceShapes.addAll(editing.faceShapes);
      if (_availableHairTypes.contains(editing.hairType)) {
        _selectedHairType = editing.hairType;
      }
      _tags.addAll(editing.tags);
    } else {
      // Default de formato de rosto
      _selectedFaceShapes.add('Quadrado');
      _selectedFaceShapes.add('Oval');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _productController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  /// Cola imagem diretamente dos bytes da área de transferência (Ctrl + V)
  Future<void> _pasteImageFromClipboard() async {
    try {
      final imageBytes = await Pasteboard.image;
      if (imageBytes != null && imageBytes.isNotEmpty) {
        setState(() {
          _newPastedImages.add(imageBytes);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: CreatorTheme.neonPrimary,
              content: Text(
                'Foto colada com sucesso! (${_newPastedImages.length + _existingImageUrls.length} no total)',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Nenhuma imagem encontrada na área de transferência. Copie uma foto (Ctrl+C) e tente novamente.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao colar imagem: $e')),
        );
      }
    }
  }

  /// Permite selecionar arquivo do computador como alternativa opcional
  Future<void> _pickImageFromFile() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.image,
      );

      if (files.isNotEmpty) {
        int added = 0;
        for (final file in files) {
          final bytes = await file.readAsBytes();
          if (bytes.isNotEmpty) {
            _newPastedImages.add(bytes);
            added++;
          }
        }
        if (added > 0) {
          setState(() {});
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$added foto(s) carregada(s) do arquivo.'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar arquivo: $e')),
        );
      }
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _newPastedImages.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
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

  Future<void> _saveHaircut() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFaceShapes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos um formato de rosto recomendado.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final totalImages = _existingImageUrls.length + _newPastedImages.length;
    if (totalImages == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Adicione pelo menos 1 foto do corte de cabelo colando com Ctrl + V.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _saveProgressMessage = 'Iniciando upload das fotos...';
    });

    final haircutId = widget.haircutToEdit?.id ?? const Uuid().v4();
    final List<String> finalImageUrls = List.from(_existingImageUrls);

    // Upload das novas imagens coladas via bytes brutos
    try {
      for (int i = 0; i < _newPastedImages.length; i++) {
        setState(() {
          _saveProgressMessage =
              'Fazendo upload da foto ${i + 1} de ${_newPastedImages.length}...';
        });
        final bytes = _newPastedImages[i];
        final uploadedUrl =
            await HaircutCreatorService.uploadHaircutImageBytes(
          haircutId: haircutId,
          bytes: bytes,
        );
        finalImageUrls.add(uploadedUrl);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro no upload das imagens: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _saveProgressMessage = 'Salvando dados no Cloud Firestore...';
    });

    final haircut = Haircut(
      id: haircutId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrls: finalImageUrls,
      faceShapes: _selectedFaceShapes.toList(),
      hairType: _selectedHairType,
      recommendedStylingProduct: _productController.text.trim(),
      tags: _tags,
      createdAt: widget.haircutToEdit?.createdAt ?? DateTime.now(),
      creatorName: 'Man Hub Curadoria',
    );

    final ok = await HaircutCreatorService.saveHaircutToFirestore(haircut);

    setState(() => _isSaving = false);

    if (mounted) {
      if (ok) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: CreatorTheme.neonPrimary,
            content: Text(
              widget.haircutToEdit != null
                  ? 'Corte atualizado com sucesso!'
                  : 'Corte publicado no Man Hub com sucesso!',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar no Firestore. Verifique sua conexão.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.haircutToEdit != null;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyV, control: true):
            _pasteImageFromClipboard,
      },
      child: Scaffold(
        backgroundColor: CreatorTheme.backgroundMain,
        appBar: AppBar(
          title: Text(isEditing
              ? 'Editar Corte de Cabelo'
              : 'Publicar Novo Corte de Cabelo'),
          actions: [
            if (!_isSaving)
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: ElevatedButton.icon(
                  onPressed: _saveHaircut,
                  icon: const Icon(Icons.cloud_upload_rounded, size: 18),
                  label: Text(isEditing ? 'Atualizar' : 'Publicar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CreatorTheme.neonPrimary,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
          ],
        ),
        body: _isSaving
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: CreatorTheme.neonPrimary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _saveProgressMessage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SEÇÃO 1: UPLOAD BRUTO DE IMAGENS (CTRL + V)
                      _buildSectionHeader(
                          '1. FOTOS DO CORTE (COLE COM CTRL + V)',
                          Icons.photo_library_outlined),
                      const SizedBox(height: 6),
                      const Text(
                        'Copie qualquer imagem (Ctrl + C) e clique no quadro abaixo ou aperte Ctrl + V para colar os bytes da foto diretamente. Você pode adicionar quantas fotos desejar.',
                        style: TextStyle(
                            color: CreatorTheme.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 14),

                      _buildImagePasteArea(),
                      const SizedBox(height: 16),

                      _buildImagesPreviewList(),
                      const SizedBox(height: 28),

                      // SEÇÃO 2: DADOS PRINCIPAIS DO CORTE
                      _buildSectionHeader('2. INFORMAÇÕES DO ESTILO',
                          Icons.content_cut_rounded),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Nome / Título do Corte (Opcional)',
                          hintText: 'Ex: Textured Quiff com Fade Graduado',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Descrição & Orientações (Opcional)',
                          hintText:
                              'Explique a proposta do corte, altura no topo, caimento e para quem transmite autoridade e estilo...',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _productController,
                        decoration: const InputDecoration(
                          labelText: 'Fixador / Finalizador Recomendado',
                          hintText:
                              'Ex: Pomada matte efeito seco, Cera em pó, Óleo capilar',
                          prefixIcon: Icon(Icons.brush_outlined),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // SEÇÃO 3: TIPO DE CABELO (SINGLE SELECT)
                      _buildSectionHeader('3. TIPO DE CABELO (ESCOLHA 1)',
                          Icons.category_rounded),
                      const SizedBox(height: 6),
                      const Text(
                        'Selecione o tipo de cabelo ideal para este estilo:',
                        style: TextStyle(
                            color: CreatorTheme.textSecondary, fontSize: 12.5),
                      ),
                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: _availableHairTypes.map((type) {
                          final isSelected = _selectedHairType == type;
                          return ChoiceChip(
                            label: Text(type),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedHairType = type);
                              }
                            },
                            selectedColor:
                                CreatorTheme.neonPrimary.withValues(alpha: 0.25),
                            side: BorderSide(
                              color: isSelected
                                  ? CreatorTheme.neonPrimary
                                  : Colors.white.withValues(alpha: 0.15),
                              width: 1.2,
                            ),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? CreatorTheme.neonPrimary
                                  : Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 28),

                      // SEÇÃO 4: FORMATO DE ROSTO (MULTI SELECT)
                      _buildSectionHeader(
                          '4. FORMATO DE ROSTO RECOMENDADO (MULTI-ESCOLHA)',
                          Icons.face_retouching_natural_rounded),
                      const SizedBox(height: 6),
                      const Text(
                        'Marque todos os formatos de rosto que harmonizam com este corte (Visagismo):',
                        style: TextStyle(
                            color: CreatorTheme.textSecondary, fontSize: 12.5),
                      ),
                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableFaceShapes.map((shape) {
                          final isSelected = _selectedFaceShapes.contains(shape);
                          return FilterChip(
                            label: Text(shape),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedFaceShapes.add(shape);
                                } else {
                                  _selectedFaceShapes.remove(shape);
                                }
                              });
                            },
                            selectedColor:
                                CreatorTheme.neonPrimary.withValues(alpha: 0.25),
                            checkmarkColor: CreatorTheme.neonPrimary,
                            side: BorderSide(
                              color: isSelected
                                  ? CreatorTheme.neonPrimary
                                  : Colors.white.withValues(alpha: 0.15),
                              width: 1.2,
                            ),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? CreatorTheme.neonPrimary
                                  : Colors.white,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 28),

                      // SEÇÃO 5: TAGS DINÂMICAS
                      _buildSectionHeader('5. TAGS & PALAVRAS-CHAVE',
                          Icons.tag_rounded),
                      const SizedBox(height: 6),
                      const Text(
                        'Adicione tags para ajudar os usuários na busca (ex: degradê, social, militar, quiff, taper fade, pompadour):',
                        style: TextStyle(
                            color: CreatorTheme.textSecondary, fontSize: 12.5),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _tagInputController,
                              decoration: const InputDecoration(
                                hintText: 'Digite uma tag e clique em Adicionar',
                                isDense: true,
                              ),
                              onFieldSubmitted: (_) => _addTag(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: _addTag,
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Adicionar'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (_tags.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _tags.map((tag) {
                            return Chip(
                              label: Text('#$tag'),
                              deleteIcon: const Icon(Icons.close, size: 14),
                              onDeleted: () => _removeTag(tag),
                              backgroundColor: CreatorTheme.cardBg,
                              side: BorderSide(
                                color: CreatorTheme.neonPrimary
                                    .withValues(alpha: 0.3),
                              ),
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 40),

                      // BOTÃO SALVAR / PUBLICAR
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveHaircut,
                          icon: const Icon(Icons.cloud_upload_rounded,
                              size: 20),
                          label: Text(
                            isEditing
                                ? 'Atualizar Corte no Man Hub'
                                : 'Publicar Corte no Man Hub',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
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

  /// Área interativa para colar a imagem
  Widget _buildImagePasteArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: CreatorTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CreatorTheme.neonPrimary.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CreatorTheme.neonPrimary.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.content_paste_rounded,
              color: CreatorTheme.neonPrimary,
              size: 36,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Área de Transferência de Imagens',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pressione Ctrl + V em qualquer lugar desta tela ou clique no botão abaixo para colar a imagem copiada.',
            textAlign: TextAlign.center,
            style: TextStyle(color: CreatorTheme.textSecondary, fontSize: 12.5),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _pasteImageFromClipboard,
                icon: const Icon(Icons.paste_rounded, size: 18),
                label: const Text('Colar Imagem (Ctrl + V)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CreatorTheme.neonPrimary,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _pickImageFromFile,
                icon: const Icon(Icons.file_upload_outlined, size: 18),
                label: const Text('Selecionar do Computador'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Lista de miniaturas das imagens adicionadas
  Widget _buildImagesPreviewList() {
    final total = _existingImageUrls.length + _newPastedImages.length;
    if (total == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fotos Prontas para Upload ($total)',
          style: const TextStyle(
            color: CreatorTheme.neonLight,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 130,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Imagens existentes (se editando)
              ...List.generate(_existingImageUrls.length, (index) {
                final url = _existingImageUrls[index];
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 130,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: CreatorTheme.neonPrimary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 16,
                      child: GestureDetector(
                        onTap: () => _removeExistingImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              color: Colors.redAccent, size: 14),
                        ),
                      ),
                    ),
                  ],
                );
              }),

              // Novas imagens coladas (bytes brutos)
              ...List.generate(_newPastedImages.length, (index) {
                final bytes = _newPastedImages[index];
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 130,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: CreatorTheme.neonPrimary,
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.memory(
                          bytes,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 16,
                      child: GestureDetector(
                        onTap: () => _removeNewImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              color: Colors.redAccent, size: 14),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#${_existingImageUrls.length + index + 1}',
                          style: const TextStyle(
                              color: CreatorTheme.neonLight,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
