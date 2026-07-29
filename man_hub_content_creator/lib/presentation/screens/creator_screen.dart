import 'package:flutter/material.dart';
import '../../domain/models/content_block.dart';
import '../../domain/models/module.dart';
import '../../domain/models/screen_model.dart';
import '../../domain/models/session.dart';
import '../../services/export_service.dart';
import '../controllers/creator_controller.dart';

class CreatorScreen extends StatefulWidget {
  final CreatorController controller;

  const CreatorScreen({super.key, required this.controller});

  @override
  State<CreatorScreen> createState() => _CreatorScreenState();
}

class _CreatorScreenState extends State<CreatorScreen> {
  final TextEditingController _trainingTitleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _trainingTitleController.text = widget.controller.training.title;
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _trainingTitleController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
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
        actions: [
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
                right: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _trainingTitleController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Treinamento',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => widget.controller.updateTrainingTitle(val),
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
      title: TextFormField(
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
      selected: isSelected,
      selectedTileColor: Colors.blue.withValues(alpha: 0.1),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            initialValue: session.title,
            decoration: const InputDecoration(border: InputBorder.none, isDense: true, hintText: 'Título da Aula'),
            onChanged: (val) => widget.controller.updateSessionTitle(session, val),
          ),
          TextFormField(
            initialValue: session.subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            decoration: const InputDecoration(border: InputBorder.none, isDense: true, hintText: 'Subtítulo da Aula (opcional)'),
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

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Colors.white,
        elevation: 1,
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
      body: _buildScreenEditor(),
    );
  }

  Widget _buildScreenTab(Session session, ScreenModel screen) {
    final isSelected = widget.controller.selectedScreen == screen;
    return Padding(
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

  Widget _buildScreenEditor() {
    final selectedScreen = widget.controller.selectedScreen;

    if (selectedScreen == null) {
      return const Center(
        child: Text('Crie ou selecione uma tela na barra acima.'),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: selectedScreen.contents.isEmpty
                  ? const Center(child: Text('Nenhum bloco adicionado à esta tela.'))
                  : ListView.builder(
                      itemCount: selectedScreen.contents.length,
                      itemBuilder: (context, index) {
                        return _buildBlockEditor(selectedScreen.contents[index]);
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
    );
  }

  Widget _buildBlockEditor(ContentBlock block) {
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
                Text(
                  _getBlockTypeName(block),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => widget.controller.removeBlock(block),
                )
              ],
            ),
            const SizedBox(height: 12),
            _buildBlockFields(block),
          ],
        ),
      ),
    );
  }

  String _getBlockTypeName(ContentBlock block) {
    if (block is TitleBlock) return 'Título Principal';
    if (block is Title2Block) return 'Título 2';
    if (block is DescriptionBlock) return 'Descrição';
    if (block is HighlightedDescriptionBlock) return 'Descrição Destacada';
    if (block is ImageBlock) return 'Imagem';
    if (block is VideoBlock) return 'Vídeo';
    return 'Desconhecido';
  }

  Widget _buildBlockFields(ContentBlock block) {
    if (block is TitleBlock) {
      return TextFormField(
        initialValue: block.text,
        decoration: const InputDecoration(hintText: 'Digite o título...', border: OutlineInputBorder()),
        onChanged: (val) => widget.controller.updateTitleBlock(block, val),
      );
    }
    if (block is Title2Block) {
      return TextFormField(
        initialValue: block.text,
        decoration: const InputDecoration(hintText: 'Digite o Título 2...', border: OutlineInputBorder()),
        onChanged: (val) => widget.controller.updateTitle2Block(block, val),
      );
    }
    if (block is DescriptionBlock) {
      return TextFormField(
        initialValue: block.text,
        maxLines: 4,
        decoration: const InputDecoration(hintText: 'Digite a descrição...', border: OutlineInputBorder()),
        onChanged: (val) => widget.controller.updateDescriptionBlock(block, val),
      );
    }
    if (block is HighlightedDescriptionBlock) {
      return TextFormField(
        initialValue: block.text,
        maxLines: 4,
        decoration: const InputDecoration(hintText: 'Digite a descrição destacada...', border: OutlineInputBorder()),
        onChanged: (val) => widget.controller.updateHighlightedDescriptionBlock(block, val),
      );
    }
    if (block is ImageBlock) {
      return TextFormField(
        initialValue: block.imageUrl,
        decoration: const InputDecoration(hintText: 'URL da imagem...', border: OutlineInputBorder()),
        onChanged: (val) => widget.controller.updateImageBlock(block, val),
      );
    }
    if (block is VideoBlock) {
      return TextFormField(
        initialValue: block.videoUrl,
        decoration: const InputDecoration(hintText: 'URL do vídeo...', border: OutlineInputBorder()),
        onChanged: (val) => widget.controller.updateVideoBlock(block, val),
      );
    }
    return const SizedBox();
  }
}
