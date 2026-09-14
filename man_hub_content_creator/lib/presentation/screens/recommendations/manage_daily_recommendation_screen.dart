import 'package:flutter/material.dart';
import '../../../domain/models/daily_recommendation.dart';
import '../../../domain/models/training.dart';
import '../../../domain/models/module.dart';
import '../../../domain/models/session.dart';
import '../../../services/daily_recommendation_service.dart';
import '../../../services/firestore_training_service.dart';
import 'package:uuid/uuid.dart';

class ManageDailyRecommendationScreen extends StatefulWidget {
  const ManageDailyRecommendationScreen({super.key});

  @override
  State<ManageDailyRecommendationScreen> createState() =>
      _ManageDailyRecommendationScreenState();
}

class _ManageDailyRecommendationScreenState
    extends State<ManageDailyRecommendationScreen> {
  final _service = DailyRecommendationService();
  final _trainingService = FirestoreTrainingService();

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  List<Training> _trainings = [];
  bool _isLoadingTrainings = true;
  Training? _selectedTraining;
  Session? _selectedSession;
  Module? _selectedModule;

  bool _setActive = true;
  bool _isSaving = false;
  String? _editingId;

  @override
  void initState() {
    super.initState();
    _loadTrainings();
    _imageUrlController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadTrainings() async {
    setState(() => _isLoadingTrainings = true);
    try {
      final list = await _trainingService.fetchTrainings();
      if (mounted) {
        setState(() {
          _trainings = list;
          _isLoadingTrainings = false;
          if (_trainings.isNotEmpty && _selectedTraining == null) {
            _onTrainingSelected(_trainings.first);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingTrainings = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar treinamentos: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _onTrainingSelected(Training? training) {
    setState(() {
      _selectedTraining = training;
      _selectedSession = null;
      _selectedModule = null;

      if (training != null && training.modules.isNotEmpty) {
        for (final mod in training.modules) {
          if (mod.sessions.isNotEmpty) {
            _selectedModule = mod;
            _selectedSession = mod.sessions.first;
            break;
          }
        }
      }
    });
  }

  void _resetForm() {
    setState(() {
      _editingId = null;
      _titleController.clear();
      _descriptionController.clear();
      _imageUrlController.clear();
      _setActive = true;
      if (_trainings.isNotEmpty) {
        _onTrainingSelected(_trainings.first);
      }
    });
  }

  void _editRecommendation(DailyRecommendation rec) {
    setState(() {
      _editingId = rec.id;
      _titleController.text = rec.title;
      _descriptionController.text = rec.description;
      _imageUrlController.text = rec.imageUrl;
      _setActive = rec.isActive;

      // Localiza o treinamento correspondente
      try {
        _selectedTraining = _trainings.firstWhere((t) => t.id == rec.trainingId);
      } catch (_) {
        _selectedTraining = null;
      }

      // Localiza a sessão correspondente
      _selectedSession = null;
      _selectedModule = null;
      if (_selectedTraining != null) {
        for (final mod in _selectedTraining!.modules) {
          for (final sess in mod.sessions) {
            if (sess.id == rec.sessionId) {
              _selectedModule = mod;
              _selectedSession = sess;
              break;
            }
          }
          if (_selectedSession != null) break;
        }
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTraining == null || _selectedSession == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um treinamento e uma aula válida.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final recId = (_editingId != null && _editingId!.trim().isNotEmpty)
          ? _editingId!
          : const Uuid().v4();

      final rec = DailyRecommendation(
        id: recId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        trainingId: _selectedTraining!.id,
        trainingTitle: _selectedTraining!.title,
        sessionId: _selectedSession!.id,
        sessionTitle: _selectedSession!.title,
        moduleId: _selectedModule?.id,
        isActive: _setActive,
        createdAt: DateTime.now().toIso8601String(),
      );

      final ok = await _service.saveRecommendation(rec, makeActive: _setActive);

      if (mounted) {
        setState(() => _isSaving = false);
        if (ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _editingId != null
                    ? 'Recomendação atualizada com sucesso!'
                    : 'Recomendação cadastrada e publicada!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          _resetForm();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao salvar no Firestore.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(DailyRecommendation rec) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Excluir Recomendação?'),
        content: Text(
          'Deseja excluir "${rec.title}"? Ela será removida da lista e da Home.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final ok = await _service.deleteRecommendation(rec);
      if (mounted && ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recomendação excluída com sucesso.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _activateRecommendation(DailyRecommendation rec) async {
    final ok = await _service.toggleActive(rec);
    if (mounted && ok) {
      final willBeActive = !rec.isActive;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            willBeActive
                ? '"${rec.title}" foi ativada nas Recomendações da Home!'
                : '"${rec.title}" foi desativada da Home.',
          ),
          backgroundColor: willBeActive ? Colors.green : Colors.grey[800],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editingId != null;

    // Lista de sessões agrupadas pelo módulo para o dropdown
    final List<Map<String, dynamic>> sessionOptions = [];
    if (_selectedTraining != null) {
      for (final mod in _selectedTraining!.modules) {
        for (final sess in mod.sessions) {
          sessionOptions.add({
            'module': mod,
            'session': sess,
            'label': '${mod.title.trim().isNotEmpty ? mod.title : "Módulo"} • ${sess.title.trim().isNotEmpty ? sess.title : "Aula sem título"}',
          });
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 22),
            SizedBox(width: 10),
            Text(
              'Recomendações do Dia (Home)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          if (isEditing)
            TextButton.icon(
              onPressed: _resetForm,
              icon: const Icon(Icons.close, color: Colors.white70, size: 18),
              label: const Text(
                'Cancelar Edição',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recarregar Treinamentos',
            onPressed: _loadTrainings,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoadingTrainings
          ? const Center(
              child: CircularProgressIndicator(color: Colors.amberAccent),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Coluna Esquerda: Formulário de Criação/Edição
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isEditing
                              ? Colors.amberAccent.withValues(alpha: 0.6)
                              : Colors.white12,
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isEditing ? Icons.edit_note : Icons.add_circle_outline,
                                  color: Colors.amberAccent,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isEditing
                                      ? 'Editar Chamada em Destaque'
                                      : 'Criar Nova Chamada da Home',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Defina o título, descrição persuasiva, imagem e a aula exata para onde o usuário será redirecionado ao clicar em "Descobrir".',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Campo: Título
                            const Text(
                              'Título da Chamada *',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _titleController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText:
                                    'Ex: Impressione qualquer mulher com um jantar romântico',
                                hintStyle: const TextStyle(color: Colors.white30),
                                filled: true,
                                fillColor: const Color(0xFF242424),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: const Icon(
                                  Icons.title,
                                  color: Colors.white38,
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'O título é obrigatório.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            // Campo: Descrição
                            const Text(
                              'Descrição da Chamada *',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 3,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText:
                                    'Ex: Aprenda a como montar uma mesa de jantar romântica e impressionar aquela mulher.',
                                hintStyle: const TextStyle(color: Colors.white30),
                                filled: true,
                                fillColor: const Color(0xFF242424),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'A descrição é obrigatória.';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            // Campo: Imagem URL
                            const Text(
                              'URL da Imagem de Capa *',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _imageUrlController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'https://images.unsplash.com/...',
                                hintStyle: const TextStyle(color: Colors.white30),
                                filled: true,
                                fillColor: const Color(0xFF242424),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: const Icon(
                                  Icons.image_outlined,
                                  color: Colors.white38,
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'A URL da imagem é obrigatória.';
                                }
                                if (!val.startsWith('http://') &&
                                    !val.startsWith('https://')) {
                                  return 'Insira uma URL válida (http/https).';
                                }
                                return null;
                              },
                            ),

                            // Preview da imagem
                            if (_imageUrlController.text.trim().isNotEmpty) ...[
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
                                  height: 140,
                                  width: double.infinity,
                                  child: Image.network(
                                    _imageUrlController.text.trim(),
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, stack) => Container(
                                      color: Colors.black45,
                                      alignment: Alignment.center,
                                      child: const Text(
                                        'URL de imagem inválida ou inacessível.',
                                        style: TextStyle(color: Colors.redAccent),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),

                            const Divider(color: Colors.white12),
                            const SizedBox(height: 16),

                            // Seleção de Treinamento e Aula
                            const Text(
                              'Vincular à Aula / Sessão de Treinamento',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Dropdown de Treinamento
                            const Text(
                              'Selecione o Treinamento:',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF242424),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<Training>(
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF2A2A2A),
                                  value: _selectedTraining,
                                  items: _trainings.map((t) {
                                    return DropdownMenuItem<Training>(
                                      value: t,
                                      child: Text(
                                        t.title.trim().isNotEmpty
                                            ? t.title
                                            : 'Sem título (${t.id})',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: _onTrainingSelected,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Dropdown de Aula / Sessão
                            const Text(
                              'Selecione a Aula / Sessão Alvo:',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (sessionOptions.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orangeAccent.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.orangeAccent.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.orangeAccent,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Este treinamento ainda não possui aulas cadastradas. Selecione outro treinamento.',
                                        style: TextStyle(
                                          color: Colors.orangeAccent,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF242424),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<Session>(
                                    isExpanded: true,
                                    dropdownColor: const Color(0xFF2A2A2A),
                                    value: _selectedSession,
                                    items: sessionOptions.map((opt) {
                                      final sess = opt['session'] as Session;
                                      final label = opt['label'] as String;
                                      return DropdownMenuItem<Session>(
                                        value: sess,
                                        child: Text(
                                          label,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (sess) {
                                      if (sess != null) {
                                        setState(() {
                                          _selectedSession = sess;
                                          // Encontra o módulo pai
                                          for (final opt in sessionOptions) {
                                            if (opt['session'] == sess) {
                                              _selectedModule = opt['module'] as Module;
                                              break;
                                            }
                                          }
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),

                            // Toggle Ativo na Home
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Definir como Recomendação Ativa na Home',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: const Text(
                                'Se ativado, esta chamada aparecerá imediatamente para os usuários.',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                              activeThumbColor: Colors.amberAccent,
                              activeTrackColor: Colors.amberAccent.withValues(alpha: 0.5),
                              value: _setActive,
                              onChanged: (val) => setState(() => _setActive = val),
                            ),
                            const SizedBox(height: 24),

                            // Botão Salvar
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amberAccent,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: _isSaving ? null : _submit,
                                icon: _isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.black,
                                        ),
                                      )
                                    : Icon(
                                        isEditing
                                            ? Icons.save_outlined
                                            : Icons.cloud_upload_outlined,
                                      ),
                                label: Text(
                                  _isSaving
                                      ? 'Salvando...'
                                      : (isEditing
                                          ? 'Atualizar Recomendação'
                                          : 'Salvar e Publicar na Home'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Divisória vertical
                Container(width: 1, color: Colors.white12),

                // Coluna Direita: Lista de Recomendações Cadastradas
                Expanded(
                  flex: 5,
                  child: StreamBuilder<List<DailyRecommendation>>(
                    stream: _service.streamRecommendations(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.amberAccent,
                          ),
                        );
                      }

                      final recommendations = snapshot.data ?? [];

                      if (recommendations.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome_motion_outlined,
                                  size: 64,
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Nenhuma recomendação cadastrada ainda',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Preencha o formulário ao lado para criar o primeiro atalho em destaque na Home.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.all(24.0),
                        itemCount: recommendations.length,
                        separatorBuilder: (_, i) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final rec = recommendations[index];
                          final isActive = rec.isActive;

                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isActive
                                    ? Colors.amberAccent.withValues(alpha: 0.7)
                                    : Colors.white10,
                                width: isActive ? 1.8 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Imagem e Status
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(13),
                                        topRight: Radius.circular(13),
                                      ),
                                      child: SizedBox(
                                        height: 130,
                                        width: double.infinity,
                                        child: Image.network(
                                          rec.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            color: Colors.white10,
                                            alignment: Alignment.center,
                                            child: const Icon(
                                              Icons.broken_image_outlined,
                                              color: Colors.white38,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? Colors.amberAccent
                                              : Colors.black87,
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black54,
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isActive
                                                  ? Icons.check_circle_rounded
                                                  : Icons.pause_circle_outline,
                                              size: 14,
                                              color: isActive
                                                  ? Colors.black
                                                  : Colors.white70,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              isActive
                                                  ? 'ATIVO NA HOME'
                                                  : 'Inativo',
                                              style: TextStyle(
                                                color: isActive
                                                    ? Colors.black
                                                    : Colors.white70,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Conteúdo
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        rec.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        rec.description,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 12),

                                      // Tag da Aula / Treinamento
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.white12,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.play_circle_fill_rounded,
                                              size: 16,
                                              color: Colors.cyanAccent,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                '${rec.trainingTitle} > ${rec.sessionTitle}',
                                                style: const TextStyle(
                                                  color: Colors.cyanAccent,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Ações
                                      Row(
                                        children: [
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isActive
                                                  ? Colors.white12
                                                  : Colors.amberAccent,
                                              foregroundColor: isActive
                                                  ? Colors.white70
                                                  : Colors.black,
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                            ),
                                            onPressed: () =>
                                                _activateRecommendation(rec),
                                            icon: Icon(
                                              isActive
                                                  ? Icons.pause_circle_outline
                                                  : Icons.star_rounded,
                                              size: 16,
                                            ),
                                            label: Text(
                                              isActive
                                                  ? 'Desativar'
                                                  : 'Ativar na Home',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: isActive
                                                    ? Colors.white70
                                                    : Colors.black,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.white70,
                                              side: const BorderSide(
                                                color: Colors.white24,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                            ),
                                            onPressed: () =>
                                                _editRecommendation(rec),
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              size: 16,
                                            ),
                                            label: const Text(
                                              'Editar',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.redAccent,
                                              size: 20,
                                            ),
                                            tooltip: 'Excluir',
                                            onPressed: () =>
                                                _confirmDelete(rec),
                                          ),
                                        ],
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
                  ),
                ),
              ],
            ),
    );
  }
}
