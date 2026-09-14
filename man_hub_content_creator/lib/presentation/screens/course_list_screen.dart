import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/models/training.dart';
import '../../services/export_service.dart';
import '../controllers/creator_controller.dart';
import '../widgets/training_details_dialog.dart';
import 'creator_screen.dart';
import 'outfits/outfit_manager_screen.dart';
import 'haircuts/haircut_manager_screen.dart';
import 'recommendations/manage_daily_recommendation_screen.dart';

class CourseListScreen extends StatefulWidget {
  final CreatorController controller;

  const CourseListScreen({super.key, required this.controller});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateState);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _syncToFirestore(Training t) async {
    final ok = await widget.controller.saveTrainingToFirestore(t);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok
              ? 'Treinamento "${t.title}" salvo com sucesso no Firestore!'
              : 'Erro ao salvar: ${widget.controller.statusMessage}'),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return TrainingDetailsDialog(
          isNew: true,
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
          }) async {
            widget.controller.addNewTraining(
              title,
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
            final current = widget.controller.training;
            _openEditor();
            await _syncToFirestore(current);
          },
        );
      },
    );
  }

  void _showEditDetailsDialog(Training training) {
    showDialog(
      context: context,
      builder: (context) {
        return TrainingDetailsDialog(
          training: training,
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
          }) async {
            widget.controller.selectTraining(training);
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
            await _syncToFirestore(training);
          },
        );
      },
    );
  }

  void _showImportOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Importar Treinamento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Escolha como deseja importar a estrutura do curso. Ele será automaticamente sincronizado com o Firestore:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _pickAndImportJsonFile();
                },
                icon: const Icon(Icons.folder_open_outlined),
                label: const Text('Subir Arquivo .json'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showPasteJsonDialog();
                },
                icon: const Icon(Icons.paste_outlined),
                label: const Text('Colar código JSON (Texto)'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _pickAndImportJsonFile() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (file != null) {
        final fileBytes = await file.readAsBytes();
        final rawJson = utf8.decode(fileBytes);
        final jsonMap = jsonDecode(rawJson) as Map<String, dynamic>;
        final imported = Training.fromJson(jsonMap);

        widget.controller.importTraining(imported);
        _openEditor();
        await _syncToFirestore(imported);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao importar arquivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPasteJsonDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Colar JSON do Treinamento'),
          content: SizedBox(
            width: 500,
            child: TextField(
              controller: textController,
              maxLines: 15,
              decoration: const InputDecoration(
                hintText: 'Cole aqui todo o código JSON...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final text = textController.text.trim();
                if (text.isEmpty) return;

                try {
                  final jsonMap = jsonDecode(text) as Map<String, dynamic>;
                  final imported = Training.fromJson(jsonMap);
                  widget.controller.importTraining(imported);
                  Navigator.pop(context);
                  _openEditor();
                  await _syncToFirestore(imported);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('JSON inválido: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Importar e Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _openEditor() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreatorScreen(controller: widget.controller),
      ),
    );
  }

  void _confirmDelete(Training training) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Curso?'),
          content: Text('Tem certeza que deseja excluir "${training.title}"? Esta ação removerá o curso localmente e do Cloud Firestore.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                await widget.controller.deleteTraining(training);
                messenger.showSnackBar(
                  SnackBar(content: Text('Treinamento "${training.title}" excluído.')),
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
    final trainings = widget.controller.trainings;
    final isLoading = widget.controller.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Man Hub - Meus Treinamentos'),
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HaircutManagerScreen()),
              );
            },
            icon: const Icon(Icons.content_cut_outlined, size: 16),
            label: const Text('Cortes de Cabelo'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.cyanAccent,
              side: const BorderSide(color: Colors.cyanAccent, width: 1.2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OutfitManagerScreen()),
              );
            },
            icon: const Icon(Icons.style_outlined, size: 16),
            label: const Text('Outfits & Estilos'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.cyanAccent,
              side: const BorderSide(color: Colors.cyanAccent, width: 1.2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ManageDailyRecommendationScreen()),
              );
            },
            icon: const Icon(Icons.auto_awesome, size: 16),
            label: const Text('Recomendação do Dia'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.amberAccent,
              side: const BorderSide(color: Colors.amberAccent, width: 1.2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.cloud_sync_outlined),
            tooltip: 'Sincronizar com Firestore',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await widget.controller.loadTrainingsFromFirestore();
              messenger.showSnackBar(
                const SnackBar(content: Text('Treinamentos sincronizados do Cloud Firestore.')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            tooltip: 'Importar JSON',
            onPressed: _showImportOptionsDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando treinamentos do Firestore...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : trainings.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_queue_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'Nenhum curso encontrado no Firestore.\nClique no botão "+" para criar ou importe um arquivo JSON.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _showImportOptionsDialog,
                          icon: const Icon(Icons.file_upload_outlined),
                          label: const Text('Importar Treinamento JSON'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: trainings.length,
                  itemBuilder: (context, index) {
                    final t = trainings[index];
                    final totalModules = t.modules.length;
                    final totalSessions = t.modules.fold(0, (sum, m) => sum + m.sessions.length);
                    final hasImage = t.coverImageUrl != null && t.coverImageUrl!.trim().isNotEmpty;

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: hasImage
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  t.coverImageUrl!,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                                    backgroundColor: Colors.blueAccent,
                                    child: Icon(Icons.school, color: Colors.white),
                                  ),
                                ),
                              )
                            : const CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                child: Icon(Icons.school, color: Colors.white),
                              ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                t.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.cloud_done_outlined, size: 12, color: Colors.greenAccent),
                                  SizedBox(width: 4),
                                  Text(
                                    'Firestore',
                                    style: TextStyle(fontSize: 10, color: Colors.greenAccent, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (t.subtitle != null && t.subtitle!.trim().isNotEmpty) ...[
                                Text(
                                  t.subtitle!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                const SizedBox(height: 2),
                              ],
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    '$totalModules Módulos • $totalSessions Aulas',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  if (t.duration != null && t.duration!.trim().isNotEmpty) ...[
                                    const Text('•', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    const Icon(Icons.timer_outlined, size: 12, color: Colors.blueAccent),
                                    Text(
                                      t.duration!,
                                      style: const TextStyle(fontSize: 12, color: Colors.blueAccent),
                                    ),
                                  ],
                                  if (t.price != null) ...[
                                    const Text('•', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'R\$ ${t.price!.toStringAsFixed(2).replaceAll('.', ',')}',
                                        style: const TextStyle(fontSize: 11, color: Colors.greenAccent, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                  if (t.category != null && t.category!.trim().isNotEmpty) ...[
                                    const Text('•', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        t.category!.toUpperCase(),
                                        style: const TextStyle(fontSize: 10, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.cloud_upload_outlined, color: Colors.cyanAccent),
                              tooltip: 'Salvar no Firestore',
                              onPressed: () => _syncToFirestore(t),
                            ),
                            IconButton(
                              icon: const Icon(Icons.tune_outlined, color: Colors.orangeAccent),
                              tooltip: 'Detalhes do Treinamento',
                              onPressed: () => _showEditDetailsDialog(t),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              tooltip: 'Editar Aulas/Conteúdo',
                              onPressed: () {
                                widget.controller.selectTraining(t);
                                _openEditor();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.file_download_outlined, color: Colors.green),
                              tooltip: 'Baixar JSON',
                              onPressed: () => ExportService.exportTrainingToJson(t),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              tooltip: 'Excluir',
                              onPressed: () => _confirmDelete(t),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        tooltip: 'Criar Novo Curso',
        child: const Icon(Icons.add),
      ),
    );
  }
}
