import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/outfit_service.dart';
import '../../../domain/models/outfit.dart';

class CreateOutfitScreen extends StatefulWidget {
  const CreateOutfitScreen({super.key});

  @override
  State<CreateOutfitScreen> createState() => _CreateOutfitScreenState();
}

class _CreateOutfitScreenState extends State<CreateOutfitScreen> {
  final OutfitService _outfitService = OutfitService();
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _selectedStyle = 'Smart Casual';
  String _selectedOccasion = 'Trabalho / Almoço de Negócios';

  // Peças selecionadas com IA
  String _selectedTorso = 'Camisa de Linho Francês';
  String _selectedJacket = 'Blazer Desestruturado em Linho';
  String _selectedPants = 'Calça de Alfaiataria Chino Areia';
  String _selectedShoes = 'Mocassim Penny Loafer Camurça';
  String _selectedAccessory = 'Relógio Cronógrafo Pulseira de Couro';

  // Controladores de peças
  final List<OutfitPieceInput> _pieceInputs = [];
  bool _isGeneratingWithAI = false;
  bool _isPublishing = false;

  final List<String> _styles = [
    'Smart Casual',
    'Old Money',
    'Casual Urbano',
    'Minimalista & Atemporal',
    'Clássico / Executivo',
    'Tech & Sport Chic',
  ];

  final List<String> _occasions = [
    'Trabalho / Almoço de Negócios',
    'Encontro Noturno / Bar',
    'Fim de Semana / Resort',
    'Jantar Executivo / Evento Social',
    'Viagem / Aeroporto',
  ];

  // Opções para geração com IA
  final List<String> _torsoOptions = [
    'Camisa de Linho Francês',
    'Camisa Oxford Clássica',
    'Polo Algodão Mercerizado',
    'T-Shirt Heavyweight 240g',
    'Turtleneck Gola Alta Lã',
  ];

  final List<String> _jacketOptions = [
    'Blazer Desestruturado em Linho',
    'Overshirt de Sarja Pesada',
    'Casaco Overcoat em Lã Batida',
    'Jaqueta Harrington Minimalista',
    'Suéter Tricô Gola Redonda',
    'Sem Casaco (Verão)',
  ];

  final List<String> _pantsOptions = [
    'Calça de Alfaiataria Chino Areia',
    'Calça Alfaiataria Lã com Pregas',
    'Jeans Selvedge Denim Escuro',
    'Calça de Linho Puro Bege',
    'Bermuda Chino Alfaiatada',
  ];

  final List<String> _shoesOptions = [
    'Mocassim Penny Loafer Camurça',
    'Sapato Oxford Couro Nobre',
    'Bota Chelsea em Couro Preto',
    'Sneaker Branco em Couro Minimalista',
    'Sapato Derby Nobuck Café',
  ];

  final List<String> _accessoryOptions = [
    'Relógio Cronógrafo Pulseira de Couro',
    'Óculos de Sol Acetato Tartaruga',
    'Perfume Amadeirado & Especiado',
    'Cinto de Couro com Fivela Prata Fosca',
  ];

  @override
  void initState() {
    super.initState();
    _populateDefaultPieces();
  }

  void _populateDefaultPieces() {
    _titleController.text = 'Smart Casual Riviera';
    _descriptionController.text =
        'Look harmonizado com blazer desestruturado, camisa polo premium e calça de alfaiataria chino.';
    _imageUrlController.text =
        'https://images.unsplash.com/photo-1507679799987-c73779587ccf?q=80&w=1200&auto=format&fit=crop';

    _pieceInputs.clear();
    _pieceInputs.addAll([
      OutfitPieceInput(
        category: 'Torso / Camisa',
        nameController: TextEditingController(text: _selectedTorso),
        brandController: TextEditingController(text: 'Reserva Premium'),
        priceController: TextEditingController(text: 'R\$ 289,90'),
        affiliateUrlController: TextEditingController(text: 'https://www.usereserva.com'),
      ),
      OutfitPieceInput(
        category: 'Casaco / Sobreposição',
        nameController: TextEditingController(text: _selectedJacket),
        brandController: TextEditingController(text: 'Massimo Dutti'),
        priceController: TextEditingController(text: 'R\$ 690,00'),
        affiliateUrlController: TextEditingController(text: 'https://www.massimodutti.com'),
      ),
      OutfitPieceInput(
        category: 'Calça / Alfaiataria',
        nameController: TextEditingController(text: _selectedPants),
        brandController: TextEditingController(text: 'Zara Men Studio'),
        priceController: TextEditingController(text: 'R\$ 349,90'),
        affiliateUrlController: TextEditingController(text: 'https://www.zara.com'),
      ),
      OutfitPieceInput(
        category: 'Calçado / Sapato',
        nameController: TextEditingController(text: _selectedShoes),
        brandController: TextEditingController(text: 'Democrata'),
        priceController: TextEditingController(text: 'R\$ 489,90'),
        affiliateUrlController: TextEditingController(text: 'https://www.democrata.com.br'),
      ),
      OutfitPieceInput(
        category: 'Acessório / Relógio',
        nameController: TextEditingController(text: _selectedAccessory),
        brandController: TextEditingController(text: 'Tissot Classic'),
        priceController: TextEditingController(text: 'R\$ 950,00'),
        affiliateUrlController: TextEditingController(text: 'https://www.tissotwatches.com'),
      ),
    ]);
  }

  void _generateOutfitCompositionWithAI() async {
    setState(() => _isGeneratingWithAI = true);
    await Future.delayed(const Duration(milliseconds: 700));

    setState(() {
      _titleController.text = '$_selectedStyle: $_selectedOccasion';
      _descriptionController.text =
          'Look arquitetado por IA unindo $_selectedTorso, $_selectedJacket e $_selectedPants com calçado $_selectedShoes.';

      // Atualiza os inputs das peças
      if (_pieceInputs.length >= 4) {
        _pieceInputs[0].nameController.text = _selectedTorso;
        _pieceInputs[1].nameController.text = _selectedJacket;
        _pieceInputs[2].nameController.text = _selectedPants;
        _pieceInputs[3].nameController.text = _selectedShoes;
      }
      _isGeneratingWithAI = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.royalBlue,
          content: Text('Composição e diretrizes de look geradas pela IA!'),
        ),
      );
    }
  }

  void _publishOutfit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPublishing = true);

    final pieces = _pieceInputs.map((input) {
      return OutfitPiece(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: input.category,
        name: input.nameController.text.trim(),
        brand: input.brandController.text.trim(),
        price: input.priceController.text.trim(),
        affiliateUrl: input.affiliateUrlController.text.trim(),
      );
    }).toList();

    final newOutfit = Outfit(
      id: '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      styleCategory: _selectedStyle,
      occasion: _selectedOccasion,
      imageUrl: _imageUrlController.text.trim().isNotEmpty
          ? _imageUrlController.text.trim()
          : 'https://images.unsplash.com/photo-1507679799987-c73779587ccf?q=80&w=1200&auto=format&fit=crop',
      pieces: pieces,
      creatorName: 'Curadoria IA',
      likesCount: 1,
      isFeatured: true,
      createdAt: DateTime.now(),
    );

    await _outfitService.publishOutfit(newOutfit);

    if (mounted) {
      setState(() => _isPublishing = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.royalBlue,
          content: Text('Outfit completo publicado com sucesso para todos os usuários!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundMain,
      appBar: AppBar(
        title: const Text('Criar Outfit com IA', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Inteligente
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.neonPrimary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: AppColors.neonPrimary, size: 24),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'ARQUITETURA DE LOOK COM IA',
                              style: TextStyle(
                                color: AppColors.neonLight,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Selecione as peças e gere a harmonia do look com links de compra para a comunidade.',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 1. Estilo e Ocasião
                const Text(
                  '1. DEFINA O ESTILO & OCASIÃO',
                  style: TextStyle(
                    color: AppColors.neonPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedStyle,
                  dropdownColor: AppColors.card,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: 'Identidade de Estilo',
                    prefixIcon: Icon(Icons.style_outlined, color: AppColors.neonPrimary),
                  ),
                  items: _styles.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedStyle = val);
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _selectedOccasion,
                  dropdownColor: AppColors.card,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: 'Ocasião Recomendada',
                    prefixIcon: Icon(Icons.event_outlined, color: AppColors.neonPrimary),
                  ),
                  items: _occasions.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedOccasion = val);
                  },
                ),
                const SizedBox(height: 28),

                // 2. Seletor de Peças com IA
                const Text(
                  '2. COMPOSIÇÃO DAS PEÇAS (SELEÇÃO DA IA)',
                  style: TextStyle(
                    color: AppColors.neonPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                _buildPieceDropdown('Torso / Camisa', _selectedTorso, _torsoOptions, (v) => setState(() => _selectedTorso = v)),
                const SizedBox(height: 10),
                _buildPieceDropdown('Casaco / Sobreposição', _selectedJacket, _jacketOptions, (v) => setState(() => _selectedJacket = v)),
                const SizedBox(height: 10),
                _buildPieceDropdown('Calça / Pernas', _selectedPants, _pantsOptions, (v) => setState(() => _selectedPants = v)),
                const SizedBox(height: 10),
                _buildPieceDropdown('Calçado / Sapato', _selectedShoes, _shoesOptions, (v) => setState(() => _selectedShoes = v)),
                const SizedBox(height: 10),
                _buildPieceDropdown('Acessório / Detalhe', _selectedAccessory, _accessoryOptions, (v) => setState(() => _selectedAccessory = v)),
                const SizedBox(height: 14),

                // Botão de Gerar Harmonização com IA
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isGeneratingWithAI ? null : _generateOutfitCompositionWithAI,
                    icon: _isGeneratingWithAI
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.neonPrimary))
                        : const Icon(Icons.auto_awesome_rounded, color: AppColors.neonPrimary, size: 18),
                    label: Text(
                      _isGeneratingWithAI ? 'Harmonizando Peças...' : 'Harmonizar Composição com IA',
                      style: const TextStyle(color: AppColors.neonPrimary, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.neonPrimary.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // 3. Informações do Outfit Completo
                const Text(
                  '3. TÍTULO & FOTO DO OUTFIT COMPLETO',
                  style: TextStyle(
                    color: AppColors.neonPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Título do Look',
                    prefixIcon: Icon(Icons.title_rounded, color: AppColors.neonPrimary),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Insira um título' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Harmonização / Descrição',
                    prefixIcon: Icon(Icons.description_outlined, color: AppColors.neonPrimary),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _imageUrlController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'URL da Foto Completa do Look',
                    hintText: 'https://...',
                    prefixIcon: Icon(Icons.image_outlined, color: AppColors.neonPrimary),
                  ),
                ),
                const SizedBox(height: 28),

                // 4. Cadastro de Links de Afiliados e Preço por Peça
                const Text(
                  '4. LINKS DE AFILIADO & PREÇOS DAS PEÇAS',
                  style: TextStyle(
                    color: AppColors.neonPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Insira os links e preços de cada item para que os usuários possam comprá-los diretamente.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 14),

                ..._pieceInputs.map((input) => _buildPieceInputCard(input)),

                const SizedBox(height: 32),

                // Botão de Publicação
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isPublishing ? null : _publishOutfit,
                    icon: _isPublishing
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.publish_rounded, color: Colors.white),
                    label: Text(
                      _isPublishing ? 'Publicando Outfit...' : 'Publicar Outfit para a Comunidade',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.royalBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPieceDropdown(String label, String value, List<String> options, ValueChanged<String> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: options.contains(value) ? value : options.first,
      dropdownColor: AppColors.card,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }

  Widget _buildPieceInputCard(OutfitPieceInput input) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neonPrimary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            input.category.toUpperCase(),
            style: const TextStyle(color: AppColors.neonLight, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: input.nameController,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            decoration: const InputDecoration(labelText: 'Nome da Peça', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: input.brandController,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  decoration: const InputDecoration(labelText: 'Marca', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: input.priceController,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  decoration: const InputDecoration(labelText: 'Preço (Ex: R\$ 299)', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: input.affiliateUrlController,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            decoration: const InputDecoration(
              labelText: 'Link de Afiliado para Compra',
              hintText: 'https://...',
              prefixIcon: Icon(Icons.link, color: AppColors.neonPrimary, size: 16),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}

class OutfitPieceInput {
  final String category;
  final TextEditingController nameController;
  final TextEditingController brandController;
  final TextEditingController priceController;
  final TextEditingController affiliateUrlController;

  OutfitPieceInput({
    required this.category,
    required this.nameController,
    required this.brandController,
    required this.priceController,
    required this.affiliateUrlController,
  });
}
