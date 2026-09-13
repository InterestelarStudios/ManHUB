import 'package:flutter/material.dart';
import '../../domain/models/training.dart';

class TrainingDetailsDialog extends StatefulWidget {
  final Training? training;
  final bool isNew;
  final Function({
    required String title,
    String? subtitle,
    String? description,
    String? whatYouWillLearn,
    String? duration,
    String? coverImageUrl,
    String? requirements,
  }) onSave;

  const TrainingDetailsDialog({
    super.key,
    this.training,
    this.isNew = false,
    required this.onSave,
  });

  @override
  State<TrainingDetailsDialog> createState() => _TrainingDetailsDialogState();
}

class _TrainingDetailsDialogState extends State<TrainingDetailsDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _whatYouWillLearnController;
  late final TextEditingController _durationController;
  late final TextEditingController _coverImageUrlController;
  late final TextEditingController _requirementsController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.training?.title ?? '');
    _subtitleController = TextEditingController(text: widget.training?.subtitle ?? '');
    _descriptionController = TextEditingController(text: widget.training?.description ?? '');
    _whatYouWillLearnController = TextEditingController(text: widget.training?.whatYouWillLearn ?? '');
    _durationController = TextEditingController(text: widget.training?.duration ?? '');
    _coverImageUrlController = TextEditingController(text: widget.training?.coverImageUrl ?? '');
    _requirementsController = TextEditingController(text: widget.training?.requirements ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _whatYouWillLearnController.dispose();
    _durationController.dispose();
    _coverImageUrlController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O título do treinamento é obrigatório.')),
      );
      return;
    }

    widget.onSave(
      title: title,
      subtitle: _subtitleController.text.trim().isNotEmpty ? _subtitleController.text.trim() : null,
      description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
      whatYouWillLearn: _whatYouWillLearnController.text.trim().isNotEmpty ? _whatYouWillLearnController.text.trim() : null,
      duration: _durationController.text.trim().isNotEmpty ? _durationController.text.trim() : null,
      coverImageUrl: _coverImageUrlController.text.trim().isNotEmpty ? _coverImageUrlController.text.trim() : null,
      requirements: _requirementsController.text.trim().isNotEmpty ? _requirementsController.text.trim() : null,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 650,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tune_rounded, color: Colors.blueAccent),
                    const SizedBox(width: 10),
                    Text(
                      widget.isNew ? 'Criar Novo Treinamento' : 'Detalhes do Treinamento',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título e Subtítulo
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Título do Treinamento *',
                        hintText: 'Ex: O Homem Bem-Vestido',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      autofocus: widget.isNew,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _subtitleController,
                      decoration: const InputDecoration(
                        labelText: 'Subtítulo',
                        hintText: 'Ex: Guia Completo de Imagem e Estilo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.subtitles_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Duração e Imagem
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _durationController,
                            decoration: const InputDecoration(
                              labelText: 'Tempo Estimado de Duração',
                              hintText: 'Ex: 4 horas, 2h 30min',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.timer_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _coverImageUrlController,
                            decoration: const InputDecoration(
                              labelText: 'URL da Imagem Principal (Capa)',
                              hintText: 'https://...',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.image_outlined),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    if (_coverImageUrlController.text.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          _coverImageUrlController.text.trim(),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Text(
                              'URL da imagem inválida ou inacessível',
                              style: TextStyle(color: Colors.redAccent, fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Apresentação / Descrição Geral
                    TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Apresentação / Descrição Geral',
                        hintText: 'Visão geral e proposta completa deste treinamento...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // O que o usuário aprenderá
                    TextField(
                      controller: _whatYouWillLearnController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'O que o usuário aprenderá',
                        hintText: '• Princípios fundamentais de caimento\n• Como coordenar cores neutras\n• Tipos de lapelas e colarinhos...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Requisitos
                    TextField(
                      controller: _requirementsController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Requisitos / Pré-requisitos',
                        hintText: 'Ex: Nenhum pré-requisito necessário. Aberto a todos.',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check),
                  label: Text(widget.isNew ? 'Criar Treinamento' : 'Salvar Detalhes'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
