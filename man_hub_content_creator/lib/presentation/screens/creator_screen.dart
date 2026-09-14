import 'package:flutter/material.dart';
import '../../domain/models/content_block.dart';
import '../../domain/models/module.dart';
import '../../domain/models/screen_model.dart';
import '../../domain/models/session.dart';
import '../../services/export_service.dart';
import '../controllers/creator_controller.dart';
import '../widgets/training_details_dialog.dart';

class CreatorScreen extends StatefulWidget {
  final CreatorController controller;

  const CreatorScreen({super.key, required this.controller});

  @override
  State<CreatorScreen> createState() => _CreatorScreenState();
}

class _CreatorScreenState extends State<CreatorScreen> {
  final TextEditingController _trainingTitleController = TextEditingController();
  final TextEditingController _trainingSubtitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _trainingTitleController.text = widget.controller.training.title;
    _trainingSubtitleController.text = widget.controller.training.subtitle ?? '';
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _trainingTitleController.dispose();
    _trainingSubtitleController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      if (_trainingTitleController.text != widget.controller.training.title) {
        _trainingTitleController.text = widget.controller.training.title;
      }
      if (_trainingSubtitleController.text != (widget.controller.training.subtitle ?? '')) {
        _trainingSubtitleController.text = widget.controller.training.subtitle ?? '';
      }
      setState(() {});
    }
  }

  void _openTrainingDetailsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return TrainingDetailsDialog(
          training: widget.controller.training,
          isNew: false,
          onSave: ({
            required String title,
            String? subtitle,
            String? description,
            String? whatYouWillLearn,
            String? duration,
            String? coverImageUrl,
            String? requirements,
            double? price,
            String? category,
            List<String>? categories,
          }) {
            widget.controller.updateTrainingMetadata(
              title: title,
              subtitle: subtitle,
              description: description,
              whatYouWillLearn: whatYouWillLearn,
              duration: duration,
              coverImageUrl: coverImageUrl,
              requirements: requirements,
              price: price,
              category: category,
              categories: categories,
            );
          },
        );
      },
    );
  }

  Future<void> _saveToFirestore() async {
    final ok = await widget.controller.saveCurrentTraining();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? 'Treinamento "${widget.controller.training.title}" salvo com sucesso no Firestore!'
              : 'Erro ao salvar no Firestore: ${widget.controller.statusMessage}'),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _exportJson() async {
    try {
      await ExportService.exportTrainingToJson(widget.controller.training);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treinamento Exportado com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Man Hub Content Creator'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          tooltip: 'Voltar para Meus Treinamentos',
          onPressed: () async {
            // Salva automaticamente ao voltar para a lista
            await widget.controller.saveCurrentTraining();
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              onPressed: widget.controller.isSaving ? null : _saveToFirestore,
              icon: widget.controller.isSaving
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.cloud_upload_outlined, size: 18),
              label: Text(
                widget.controller.isSaving ? 'Salvando...' : 'Salvar no Firestore',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.tune_outlined),
            tooltip: 'Detalhes do Treinamento',
            onPressed: _openTrainingDetailsDialog,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Exportar JSON',
            onPressed: _exportJson,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Painel Esquerdo: Navegação de Módulos e Aulas
          Container(
            width: 350,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1.2),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _trainingTitleController,
                        decoration: const InputDecoration(
                          labelText: 'Nome do Treinamento',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) => widget.controller.updateTrainingTitle(val),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _trainingSubtitleController,
                        decoration: const InputDecoration(
                          labelText: 'Subtítulo (opcional)',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) => widget.controller.updateTrainingSubtitle(val),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: _openTrainingDetailsDialog,
                        icon: const Icon(Icons.tune_outlined, size: 16),
                        label: const Text('Detalhes do Treinamento', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(36),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton.icon(
                    onPressed: widget.controller.addModule,
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar Módulo'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.controller.training.modules.length,
                    itemBuilder: (context, index) {
                      final module = widget.controller.training.modules[index];
                      return _buildModuleItem(module);
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Painel Direito: Editor de Telas da Aula Selecionada
          Expanded(
            child: _buildRightPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleItem(Module module) {
    return ExpansionTile(
      key: ValueKey('module_tile_${module.id}'),
      title: TextFormField(
        key: ValueKey('module_title_${module.id}'),
        initialValue: module.title,
        decoration: const InputDecoration(border: InputBorder.none),
        onChanged: (val) => widget.controller.updateModuleTitle(module, val),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            tooltip: 'Adicionar Aula',
            onPressed: () => widget.controller.addSessionToModule(module),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
            tooltip: 'Remover Módulo',
            onPressed: () => widget.controller.removeModule(module),
          ),
        ],
      ),
      children: module.sessions.map((session) => _buildSessionItem(module, session)).toList(),
    );
  }

  Widget _buildSessionItem(Module module, Session session) {
    final isSelected = widget.controller.selectedSession == session;
    return ListTile(
      key: ValueKey('session_tile_${session.id}'),
      selected: isSelected,
      selectedTileColor: Colors.blue.withValues(alpha: 0.1),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            key: ValueKey('session_title_${session.id}'),
            initialValue: session.title,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              hintText: 'Título da Aula',
            ),
            onChanged: (val) => widget.controller.updateSessionTitle(session, val),
          ),
          TextFormField(
            key: ValueKey('session_sub_${session.id}'),
            initialValue: session.subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              hintText: 'Subtítulo da Aula (opcional)',
            ),
            onChanged: (val) => widget.controller.updateSessionSubtitle(session, val),
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete, size: 20, color: Colors.red),
        onPressed: () => widget.controller.removeSession(module, session),
      ),
      onTap: () => widget.controller.selectSession(session),
    );
  }

  Widget _buildRightPanel() {
    final selectedSession = widget.controller.selectedSession;

    if (selectedSession == null) {
      return const Center(
        child: Text('Selecione uma aula no menu lateral para editar.'),
      );
    }

    return KeyedSubtree(
      key: ValueKey('panel_session_${selectedSession.id}'),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          title: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...selectedSession.screens.map((screen) => _buildScreenTab(selectedSession, screen)),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => widget.controller.addScreenToSession(selectedSession),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Nova Tela'),
                ),
              ],
            ),
          ),
        ),
        body: _buildScreenEditor(selectedSession),
      ),
    );
  }

  Widget _buildScreenTab(Session session, ScreenModel screen) {
    final isSelected = widget.controller.selectedScreen == screen;
    return Padding(
      key: ValueKey('tab_chip_${screen.id}'),
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: InputChip(
        label: Text(screen.title),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) widget.controller.selectScreen(screen);
        },
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: () => widget.controller.removeScreen(session, screen),
      ),
    );
  }

  Widget _buildScreenEditor(Session session) {
    final selectedScreen = widget.controller.selectedScreen;

    if (selectedScreen == null) {
      return const Center(
        child: Text('Crie ou selecione uma tela na barra acima.'),
      );
    }

    return KeyedSubtree(
      key: ValueKey('screen_editor_${session.id}_${selectedScreen.id}'),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: selectedScreen.contents.isEmpty
                    ? const Center(child: Text('Nenhum bloco adicionado à esta tela.'))
                    : ReorderableListView.builder(
                        key: PageStorageKey('screen_list_${session.id}_${selectedScreen.id}'),
                        buildDefaultDragHandles: false,
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: selectedScreen.contents.length,
                        onReorder: (oldIndex, newIndex) {
                          widget.controller.reorderBlock(oldIndex, newIndex);
                        },
                        proxyDecorator: (child, index, animation) {
                          return AnimatedBuilder(
                            animation: animation,
                            builder: (context, child) {
                              return Material(
                                elevation: 8,
                                color: Colors.transparent,
                                shadowColor: const Color(0xFF00BFFF).withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                                child: child,
                              );
                            },
                            child: child,
                          );
                        },
                        itemBuilder: (context, index) {
                          final block = selectedScreen.contents[index];
                          return _buildBlockEditor(block, index, selectedScreen.contents.length);
                        },
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: PopupMenuButton<String>(
          tooltip: 'Adicionar Bloco',
          child: const FloatingActionButton(
            onPressed: null,
            child: Icon(Icons.add),
          ),
          onSelected: (type) {
            switch (type) {
              case 'title':
                widget.controller.addBlock(TitleBlock());
                break;
              case 'title2':
                widget.controller.addBlock(Title2Block());
                break;
              case 'description':
                widget.controller.addBlock(DescriptionBlock());
                break;
              case 'highlighted_description':
                widget.controller.addBlock(HighlightedDescriptionBlock());
                break;
              case 'image':
                widget.controller.addBlock(ImageBlock());
                break;
              case 'video':
                widget.controller.addBlock(VideoBlock());
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'title', child: Text('Título Principal (Azul)')),
            const PopupMenuItem(value: 'title2', child: Text('Título 2 (Branco)')),
            const PopupMenuItem(value: 'description', child: Text('Descrição')),
            const PopupMenuItem(value: 'highlighted_description', child: Text('Descrição Destacada (Card)')),
            const PopupMenuItem(value: 'image', child: Text('Imagem')),
            const PopupMenuItem(value: 'video', child: Text('Vídeo')),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockEditor(ContentBlock block, int index, int totalCount) {
    return BlockCardWidget(
      key: ValueKey('block_${block.id}'),
      block: block,
      index: index,
      canMoveUp: index > 0,
      canMoveDown: index < totalCount - 1,
      onMoveUp: () => widget.controller.moveBlockUp(index),
      onMoveDown: () => widget.controller.moveBlockDown(index),
      onDelete: () => widget.controller.removeBlock(block),
      onChanged: (val) {
        if (block is TitleBlock) {
          widget.controller.updateTitleBlock(block, val);
        } else if (block is Title2Block) {
          widget.controller.updateTitle2Block(block, val);
        } else if (block is DescriptionBlock) {
          widget.controller.updateDescriptionBlock(block, val);
        } else if (block is HighlightedDescriptionBlock) {
          widget.controller.updateHighlightedDescriptionBlock(block, val);
        } else if (block is ImageBlock) {
          widget.controller.updateImageBlock(block, val);
        } else if (block is VideoBlock) {
          widget.controller.updateVideoBlock(block, val);
        }
      },
    );
  }
}

/// Widget dedicado e com estado isolado para cada bloco de conteúdo
class BlockCardWidget extends StatefulWidget {
  final ContentBlock block;
  final int index;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onDelete;
  final Function(String) onChanged;

  const BlockCardWidget({
    required super.key,
    required this.block,
    required this.index,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  State<BlockCardWidget> createState() => _BlockCardWidgetState();
}

class _BlockCardWidgetState extends State<BlockCardWidget> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: _getBlockText(widget.block));
  }

  @override
  void didUpdateWidget(covariant BlockCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block.id != widget.block.id ||
        _getBlockText(widget.block) != _textController.text) {
      _textController.text = _getBlockText(widget.block);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  String _getBlockText(ContentBlock block) {
    if (block is TitleBlock) return block.text;
    if (block is Title2Block) return block.text;
    if (block is DescriptionBlock) return block.text;
    if (block is HighlightedDescriptionBlock) return block.text;
    if (block is ImageBlock) return block.imageUrl;
    if (block is VideoBlock) return block.videoUrl;
    return '';
  }

  String _getBlockTypeName(ContentBlock block) {
    if (block is TitleBlock) return 'Título Principal (Azul)';
    if (block is Title2Block) return 'Título 2 (Branco)';
    if (block is DescriptionBlock) return 'Descrição';
    if (block is HighlightedDescriptionBlock) return 'Descrição Destacada (Card)';
    if (block is ImageBlock) return 'Imagem';
    if (block is VideoBlock) return 'Vídeo';
    return 'Desconhecido';
  }

  String _getHintText(ContentBlock block) {
    if (block is TitleBlock) return 'Digite o título...';
    if (block is Title2Block) return 'Digite o Título 2...';
    if (block is DescriptionBlock) return 'Digite a descrição...';
    if (block is HighlightedDescriptionBlock) return 'Digite a descrição destacada...';
    if (block is ImageBlock) return 'URL da imagem...';
    if (block is VideoBlock) return 'URL do vídeo...';
    return '';
  }

  int _getMaxLines(ContentBlock block) {
    if (block is DescriptionBlock || block is HighlightedDescriptionBlock) {
      return 4;
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ReorderableDragStartListener(
                      index: widget.index,
                      child: Tooltip(
                        message: 'Clique e arraste para reordenar',
                        child: MouseRegion(
                          cursor: SystemMouseCursors.grab,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00BFFF).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFF00BFFF).withValues(alpha: 0.35),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.drag_indicator_rounded,
                                  color: Color(0xFF00BFFF),
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '#${widget.index + 1}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00BFFF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _getBlockTypeName(widget.block),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                      tooltip: 'Mover para cima',
                      color: widget.canMoveUp ? Colors.white70 : Colors.white24,
                      onPressed: widget.canMoveUp ? widget.onMoveUp : null,
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                      tooltip: 'Mover para baixo',
                      color: widget.canMoveDown ? Colors.white70 : Colors.white24,
                      onPressed: widget.canMoveDown ? widget.onMoveDown : null,
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                      tooltip: 'Excluir bloco',
                      onPressed: widget.onDelete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textController,
              maxLines: _getMaxLines(widget.block),
              decoration: InputDecoration(
                hintText: _getHintText(widget.block),
                border: const OutlineInputBorder(),
              ),
              onChanged: (val) {
                widget.onChanged(val);
                if (widget.block is ImageBlock) {
                  setState(() {});
                }
              },
            ),
            if (widget.block is ImageBlock && _textController.text.trim().startsWith('http')) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _textController.text.trim(),
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 60,
                    color: Colors.white.withValues(alpha: 0.05),
                    child: const Center(
                      child: Text('URL de imagem inválida ou inacessível', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
