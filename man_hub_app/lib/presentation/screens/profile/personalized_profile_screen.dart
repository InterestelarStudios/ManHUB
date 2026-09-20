import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import 'face_scan_capture_screen.dart';

class PersonalizedProfileScreen extends StatefulWidget {
  final UserProfile? user;

  const PersonalizedProfileScreen({super.key, this.user});

  @override
  State<PersonalizedProfileScreen> createState() => _PersonalizedProfileScreenState();
}

class _PersonalizedProfileScreenState extends State<PersonalizedProfileScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 10;

  // Controllers para texto
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late final TextEditingController _ageController;

  // Estados selecionados
  String? _selectedBodyType;
  String? _selectedFaceShape;
  String? _selectedSkinTone;
  String? _selectedContrastLevel;
  String? _selectedHairType;
  String? _selectedBeardStyle;
  String? _selectedStylePreference;
  String? _selectedDressOccasion;
  String? _selectedFragrancePreference;
  final Set<String> _selectedGoals = {};

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final u = widget.user ?? AuthService().currentUser;
    _heightController = TextEditingController(text: u?.height ?? '');
    _weightController = TextEditingController(text: u?.weight ?? '');
    _ageController = TextEditingController(text: u?.age ?? '');

    _selectedBodyType = u?.bodyType;
    _selectedFaceShape = u?.faceShape;
    _selectedSkinTone = u?.skinTone;
    _selectedContrastLevel = u?.contrastLevel;
    _selectedHairType = u?.hairType;
    _selectedBeardStyle = u?.beardStyle;
    _selectedStylePreference = u?.stylePreference;
    _selectedDressOccasion = u?.dressOccasion;
    _selectedFragrancePreference = u?.fragrancePreference;

    if (u != null && u.goals.isNotEmpty) {
      _selectedGoals.addAll(u.goals);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    FocusScope.of(context).unfocus();
    if (_currentPage < _totalPages - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _savePersonalizedProfile();
    }
  }

  void _prevPage() {
    FocusScope.of(context).unfocus();
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _savePersonalizedProfile() async {
    setState(() => _isSaving = true);
    try {
      await AuthService().updatePersonalizedProfile(
        height: _heightController.text.trim().isNotEmpty ? _heightController.text.trim() : null,
        weight: _weightController.text.trim().isNotEmpty ? _weightController.text.trim() : null,
        age: _ageController.text.trim().isNotEmpty ? _ageController.text.trim() : null,
        bodyType: _selectedBodyType,
        faceShape: _selectedFaceShape,
        skinTone: _selectedSkinTone,
        contrastLevel: _selectedContrastLevel,
        hairType: _selectedHairType,
        beardStyle: _selectedBeardStyle,
        stylePreference: _selectedStylePreference,
        dressOccasion: _selectedDressOccasion,
        fragrancePreference: _selectedFragrancePreference,
        goals: _selectedGoals.toList(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.royalBlue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: Row(
              children: const [
                Icon(Icons.check_circle_rounded, color: AppColors.neonPrimary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Diagnóstico e características atualizadas com sucesso!',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(e.toString()),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentPage + 1) / _totalPages;

    return Scaffold(
      backgroundColor: AppColors.backgroundMain,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundMain,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          onPressed: _prevPage,
        ),
        title: Column(
          children: [
            Text(
              'ETAPA ${_currentPage + 1} DE $_totalPages',
              style: const TextStyle(
                color: AppColors.neonLight,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _getPageTitle(_currentPage),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.backgroundSecondary,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neonPrimary),
              minHeight: 3,
            ),
          ),
        ),
        actions: [
          if (_currentPage < _totalPages - 1)
            TextButton(
              onPressed: _nextPage,
              child: const Text(
                'Pular',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildStep1BodyType(),
                  _buildStep2FaceShape(),
                  _buildStep3SkinAndContrast(),
                  _buildStep4HairType(),
                  _buildStep5BeardStyle(),
                  _buildStep6StylePreference(),
                  _buildStep7DressOccasion(),
                  _buildStep8FragrancePreference(),
                  _buildStep9Goals(),
                  _buildStep10SummaryAndInsights(),
                ],
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  String _getPageTitle(int page) {
    switch (page) {
      case 0:
        return 'Medidas & Biotipo';
      case 1:
        return 'Formato do Rosto';
      case 2:
        return 'Contraste & Pele';
      case 3:
        return 'Tipo de Cabelo';
      case 4:
        return 'Estilo de Barba';
      case 5:
        return 'Identidade de Estilo';
      case 6:
        return 'Ocasião Frequente';
      case 7:
        return 'Família Olfativa';
      case 8:
        return 'Objetivos de Evolução';
      case 9:
        return 'Diagnóstico & Insights';
      default:
        return 'Perfil';
    }
  }

  // ==========================================
  // 1. MEDIDAS & BIOTIPO CORPORAL
  // ==========================================
  Widget _buildStep1BodyType() {
    final bodyTypes = [
      {
        'title': 'Ectomorfo / Magro',
        'subtitle': 'Estrutura óssea fina, membros longos e ombros estreitos.',
        'icon': Icons.accessibility_rounded,
      },
      {
        'title': 'Mesomorfo / Atlético',
        'subtitle': 'Estrutura em V, ombros largos e facilidade em ganhar massa.',
        'icon': Icons.fitness_center_rounded,
      },
      {
        'title': 'Endomorfo / Robusto',
        'subtitle': 'Estrutura óssea larga, caixa torácica ampla e porte forte.',
        'icon': Icons.shield_rounded,
      },
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderBlock(
            title: 'Suas Dimensões e Biotipo',
            subtitle: 'Conhecer suas proporções é a chave para o caimento perfeito de alfaiataria e peças casuais.',
          ),
          const SizedBox(height: 24),

          // Altura, Peso e Idade
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  controller: _heightController,
                  label: 'Altura',
                  hint: 'Ex: 1.82 m',
                  icon: Icons.height_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  controller: _weightController,
                  label: 'Peso',
                  hint: 'Ex: 80 kg',
                  icon: Icons.monitor_weight_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  controller: _ageController,
                  label: 'Idade',
                  hint: 'Ex: 28',
                  icon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          _buildSectionLabel('SELECIONE SUA SILHUETA CORPORAL'),
          const SizedBox(height: 12),

          ...bodyTypes.map((b) {
            final isSelected = _selectedBodyType == b['title'];
            return _buildOptionCard(
              title: b['title'] as String,
              subtitle: b['subtitle'] as String,
              icon: b['icon'] as IconData,
              isSelected: isSelected,
              onTap: () {
                setState(() => _selectedBodyType = b['title'] as String);
              },
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // 2. FORMATO DO ROSTO
  // ==========================================
  Widget _buildStep2FaceShape() {
    final faceShapes = [
      {
        'title': 'Oval',
        'subtitle': 'Harmônico & Equilibrado',
        'desc': 'Proporção áurea facial com queixo levemente afilado. O formato mais harmônico e versátil para quase todos os cortes de cabelo e armações de óculos.',
        'image': 'contents/images/face_formats/oval.png',
        'fallbackIcon': Icons.face_rounded,
      },
      {
        'title': 'Quadrado',
        'subtitle': 'Marcante & Angular',
        'desc': 'Linha da mandíbula forte e angular, testa e queixo com larguras similares. Transmite autoridade, imponência e masculinidade sólida.',
        'image': 'contents/images/face_formats/square.png',
        'fallbackIcon': Icons.crop_square_rounded,
      },
      {
        'title': 'Redondo',
        'subtitle': 'Suave & Proporcional',
        'desc': 'Comprimento e largura similares com maçãs do rosto proeminentes. Exige cortes com volume superior e barbas alinhadas para verticalizar a silhueta.',
        'image': 'contents/images/face_formats/round.png',
        'fallbackIcon': Icons.circle_outlined,
      },
      {
        'title': 'Retangular / Oblongo',
        'subtitle': 'Alongado & Definido',
        'desc': 'Estrutura facial longa e vertical com laterais retas. Harmoniza com cortes de volume lateral e barbas médias a cheias.',
        'image': 'contents/images/face_formats/rectangular.png',
        'fallbackIcon': Icons.view_headline_rounded,
      },
      {
        'title': 'Diamante',
        'subtitle': 'Maçãs Proeminentes',
        'desc': 'Maçãs do rosto largas com testa e queixo afilados. Favorecido por cortes texturizados com franja e barbas com volume na base.',
        'image': 'contents/images/face_formats/diamond.png',
        'fallbackIcon': Icons.diamond_outlined,
      },
      {
        'title': 'Triangular',
        'subtitle': 'Testa Ampla & Queixo Fino',
        'desc': 'Mandíbula estreita e testa mais larga (ou vice-versa). Demanda equilíbrio de volumes nas têmporas e barbas desenhadas.',
        'image': 'contents/images/face_formats/triangular.png',
        'fallbackIcon': Icons.change_history_rounded,
      },
    ];

    final selectedFace = faceShapes.firstWhere(
      (f) => f['title'] == _selectedFaceShape,
      orElse: () => faceShapes.first,
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderBlock(
            title: 'Formato do Rosto',
            subtitle: 'O formato ósseo do seu rosto determina a geometria ideal dos cortes de cabelo, desenho de barba e armações de óculos.',
          ),
          const SizedBox(height: 20),

          // Banner de Ação para o Scan Facial com IA
          _buildAiScanBanner(),
          const SizedBox(height: 24),

          _buildSectionLabel('OU SELECIONE O FORMATO MANUALMENTE'),
          const SizedBox(height: 14),

          // Grade 2 Colunas com os Ícones Personalizados
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: faceShapes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.88,
            ),
            itemBuilder: (context, index) {
              final f = faceShapes[index];
              final title = f['title'] as String;
              final isSelected = _selectedFaceShape == title;

              return _buildVisualGridCard(
                title: title,
                subtitle: f['subtitle'] as String,
                imagePath: f['image'] as String,
                fallbackIcon: f['fallbackIcon'] as IconData,
                isSelected: isSelected,
                onTap: () => setState(() => _selectedFaceShape = title),
              );
            },
          ),

          if (_selectedFaceShape != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.royalBlue.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.tips_and_updates_rounded,
                    color: AppColors.neonPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Visagismo para Rosto ${_selectedFaceShape!}:',
                          style: const TextStyle(
                            color: AppColors.neonLight,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedFace['desc'] as String,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openFaceScanner() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const FaceScanCaptureScreen(),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _selectedFaceShape = result;
      });
    }
  }

  Widget _buildAiScanBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.royalBlue.withValues(alpha: 0.35),
            AppColors.card,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neonPrimary.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonPrimary.withValues(alpha: 0.12),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openFaceScanner,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.royalBlue.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.neonPrimary,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonPrimary.withValues(alpha: 0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.face_retouching_natural_rounded,
                    color: AppColors.neonPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'SCAN FACIAL POR IA',
                            style: TextStyle(
                              color: AppColors.neonLight,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.neonPrimary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'RECOMENDADO',
                              style: TextStyle(
                                color: AppColors.neonPrimary,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Descubra seu formato exato por biometria e visagismo',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.neonPrimary,
                  size: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisualGridCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required IconData fallbackIcon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.royalBlue.withValues(alpha: 0.25)
              : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.neonPrimary
                : AppColors.neonPrimary.withValues(alpha: 0.25),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.neonPrimary.withValues(alpha: 0.25),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.radio_button_off,
                  color: isSelected ? AppColors.neonPrimary : AppColors.textSecondary.withValues(alpha: 0.3),
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.neonPrimary.withValues(alpha: 0.08)
                      : AppColors.backgroundSecondary.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        fallbackIcon,
                        color: isSelected ? AppColors.neonPrimary : AppColors.textSecondary,
                        size: 40,
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? AppColors.neonLight : AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 3. CONTRASTE & TOM DE PELE
  // ==========================================
  Widget _buildStep3SkinAndContrast() {
    final contrastLevels = [
      {
        'title': 'Alto Contraste',
        'desc': 'Pele clara acompanhada de cabelos, sobrancelhas e olhos muito escuros. Sustenta ternos escuros com camisa branca pura e gravata escura.',
        'icon': Icons.contrast_rounded,
      },
      {
        'title': 'Médio Contraste',
        'desc': 'Pele morena/clara com cabelos castanhos médios ou barba mesclada. Harmoniza perfeitamente com cinza-médio, azul-celeste e marinho.',
        'icon': Icons.tonality_rounded,
      },
      {
        'title': 'Baixo Contraste Claro',
        'desc': 'Pele clara com cabelos loiros, ruivos ou grisalhos. Beneficia-se de combinações suaves, cáqui, tons terrosos e azul-petróleo.',
        'icon': Icons.wb_sunny_outlined,
      },
      {
        'title': 'Baixo Contraste Escuro',
        'desc': 'Pele negra com cabelos e olhos no mesmo tom profundo. Excelente para paletas ricas monocromáticas e tons nobres saturados.',
        'icon': Icons.nightlight_round,
      },
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderBlock(
            title: 'Contraste Pessoal & Pele',
            subtitle: 'Respeitar seu nível de contraste garante que a roupa emoldure seu rosto com naturalidade, sem ofuscá-lo.',
          ),
          const SizedBox(height: 24),
          _buildSectionLabel('NÍVEL DE CONTRASTE PESSOAL'),
          const SizedBox(height: 12),
          ...contrastLevels.map((c) {
            final title = c['title'] as String;
            final isSelected = _selectedContrastLevel == title;
            return _buildOptionCard(
              title: title,
              subtitle: c['desc'] as String,
              icon: c['icon'] as IconData,
              isSelected: isSelected,
              onTap: () => setState(() => _selectedContrastLevel = title),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // 4. TIPO DE CABELO
  // ==========================================
  Widget _buildStep4HairType() {
    final hairTypes = [
      {
        'title': 'Liso',
        'desc': 'Fios retos sem ondulações. Excelente para cortes clássicos penteados (Side Part, Slick Back) ou texturizados com pomada fosca.',
        'icon': Icons.waves_rounded,
      },
      {
        'title': 'Ondulado',
        'desc': 'Fios em formato de "S" com volume natural e textura. Muito versátil para cortes médios despojados e pompadour.',
        'icon': Icons.water_rounded,
      },
      {
        'title': 'Cacheado',
        'desc': 'Cachos definidos e densidade marcante. Destaca-se com laterais em fade e topo volumoso bem hidratado.',
        'icon': Icons.all_inclusive_rounded,
      },
      {
        'title': 'Crespo',
        'desc': 'Curvatura fechada em ziguezague com alta estrutura. Brilha com High Top Fade, Drop Fade e alinhamentos geométricos.',
        'icon': Icons.grain_rounded,
      },
      {
        'title': 'Raspado / Calvície',
        'desc': 'Corte Buzz Cut ou cabeça raspada. Transmite autoridade, virilidade e praticidade máxima quando alinhado a uma barba cuidada.',
        'icon': Icons.sports_kabaddi_rounded,
      },
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderBlock(
            title: 'Tipo de Cabelo',
            subtitle: 'A textura e comportamento do seu cabelo definem os produtos de fixação e a manutenção do corte ideal.',
          ),
          const SizedBox(height: 24),
          _buildSectionLabel('SELECIONE A TEXTURA DO SEU CABELO'),
          const SizedBox(height: 12),
          ...hairTypes.map((h) {
            final title = h['title'] as String;
            final isSelected = _selectedHairType == title;
            return _buildOptionCard(
              title: title,
              subtitle: h['desc'] as String,
              icon: h['icon'] as IconData,
              isSelected: isSelected,
              onTap: () => setState(() => _selectedHairType = title),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // 5. ESTILO DE BARBA
  // ==========================================
  Widget _buildStep5BeardStyle() {
    final beardStyles = [
      {
        'title': 'Sem Barba / Lisa',
        'desc': 'Rosto barbeado e pele limpa. Visual clássico corporativo, formal e que evidencia mandíbulas bem definidas.',
        'icon': Icons.clean_hands_rounded,
      },
      {
        'title': 'Por Fazer / Stubble (1 a 3 dias)',
        'desc': 'Sombra facial rústica e elegante. Adiciona masculinidade e textura sem a necessidade de desenho pesado.',
        'icon': Icons.blur_on_rounded,
      },
      {
        'title': 'Média Desenhada',
        'desc': 'Comprimento calibrado com linhas do pescoço e bochechas alinhadas na navalha. O equilíbrio entre sofisticação e presença.',
        'icon': Icons.content_cut_rounded,
      },
      {
        'title': 'Cheia / Lenhador',
        'desc': 'Barba densa e volumosa com formato estruturado. Excelente para preencher queixos recuados ou alongar a face.',
        'icon': Icons.park_rounded,
      },
      {
        'title': 'Cavanhaque',
        'desc': 'Foco no bigode e queixo com laterais raspadas. Direciona a atenção para o centro do rosto e alonga o perfil.',
        'icon': Icons.filter_vintage_rounded,
      },
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderBlock(
            title: 'Estilo de Barba',
            subtitle: 'A barba atua como a maquiagem natural masculina, capaz de estruturar o maxilar e compensar assimetrias.',
          ),
          const SizedBox(height: 24),
          _buildSectionLabel('SELECIONE SEU ESTILO DE BARBA PREFERIDO'),
          const SizedBox(height: 12),
          ...beardStyles.map((b) {
            final title = b['title'] as String;
            final isSelected = _selectedBeardStyle == title;
            return _buildOptionCard(
              title: title,
              subtitle: b['desc'] as String,
              icon: b['icon'] as IconData,
              isSelected: isSelected,
              onTap: () => setState(() => _selectedBeardStyle = title),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // 6. IDENTIDADE DE ESTILO
  // ==========================================
  Widget _buildStep6StylePreference() {
    final styles = [
      {
        'title': 'Smart Casual',
        'subtitle': 'Elegância & Versatilidade',
        'desc': 'Blazers desestruturados, calças chino, polos de algodão mercerizado e mocassins de camurça. O equilíbrio perfeito entre autoridade e dinamismo.',
        'image': 'contents/images/style_identity/smart.png',
        'fallbackIcon': Icons.style_rounded,
      },
      {
        'title': 'Clássico / Executivo',
        'subtitle': 'Alfaiataria & Autoridade',
        'desc': 'Ternos de alfaiataria em lã fria, camisas de popeline premium, gravatas de seda e sapatos Oxford. Transmite liderança, rigor executivo e poder.',
        'image': 'contents/images/style_identity/classic.png',
        'fallbackIcon': Icons.business_center_rounded,
      },
      {
        'title': 'Casual Urbano',
        'subtitle': 'Moderno & Estruturado',
        'desc': 'Overshirts de sarja pesada, camisetas premium de alta gramatura, jeans escuro reto e botas Chelsea. Visual cosmopolita sofisticado.',
        'image': 'contents/images/style_identity/urban.png',
        'fallbackIcon': Icons.location_city_rounded,
      },
      {
        'title': 'Minimalista & Atemporal',
        'subtitle': 'Quiet Luxury & Linhas Secas',
        'desc': 'Paleta neutra sem estampas, golas altas (turtleneck), sobretudos de lã e ausência total de logotipos. Elegância silenciosa e atemporal.',
        'image': 'contents/images/style_identity/minimalist.png',
        'fallbackIcon': Icons.wb_twilight_rounded,
      },
      {
        'title': 'Old Money / Nobre',
        'subtitle': 'Linho, Herança & Tradição',
        'desc': 'Camisas de puro linho, suéteres de tricô jogados nos ombros, relógios mecânicos com pulseira de couro e estética aristocrática refinada.',
        'image': 'contents/images/style_identity/old-money.png',
        'fallbackIcon': Icons.diamond_outlined,
      },
      {
        'title': 'Tech & Sport Chic',
        'subtitle': 'Performance & Inovação',
        'desc': 'Jaquetas técnicas corta-vento sob medida, tecidos inteligentes de alta tecnologia e sneakers de luxo minimalistas.',
        'image': 'contents/images/style_identity/tech-sport.png',
        'fallbackIcon': Icons.directions_run_rounded,
      },
    ];

    final selectedStyle = styles.firstWhere(
      (s) => s['title'] == _selectedStylePreference,
      orElse: () => styles.first,
    );

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderBlock(
            title: 'Identidade de Estilo',
            subtitle: 'Como você deseja se expressar e ser percebido pelo mundo através da harmonia visual da sua vestimenta.',
          ),
          const SizedBox(height: 24),
          _buildSectionLabel('SELECIONE SEU ESTILO PREDOMINANTE'),
          const SizedBox(height: 14),

          // Grade 2 Colunas com os Ícones Personalizados
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: styles.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.88,
            ),
            itemBuilder: (context, index) {
              final s = styles[index];
              final title = s['title'] as String;
              final isSelected = _selectedStylePreference == title;

              return _buildVisualGridCard(
                title: title,
                subtitle: s['subtitle'] as String,
                imagePath: s['image'] as String,
                fallbackIcon: s['fallbackIcon'] as IconData,
                isSelected: isSelected,
                onTap: () => setState(() => _selectedStylePreference = title),
              );
            },
          ),

          if (_selectedStylePreference != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.neonPrimary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.style_rounded,
                    color: AppColors.neonPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Conceito do Estilo ${_selectedStylePreference!}:',
                          style: const TextStyle(
                            color: AppColors.neonLight,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedStyle['desc'] as String,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // 7. OCASIÃO MAIS FREQUENTE
  // ==========================================
  Widget _buildStep7DressOccasion() {
    final occasions = [
      {
        'title': 'Trabalho Corporativo / Escritório',
        'desc': 'Ambiente corporativo formal, escritórios de advocacia, consultoria e mercado financeiro.',
        'icon': Icons.corporate_fare_rounded,
      },
      {
        'title': 'Home Office & Dia a Dia Dinâmico',
        'desc': 'Flexibilidade diária, reuniões por vídeo e saídas casuais que exigem conforto e compostura.',
        'icon': Icons.laptop_mac_rounded,
      },
      {
        'title': 'Eventos Sociais & Noites Especiais',
        'desc': 'Jantares em restaurantes de alto padrão, festas sociais, encontros e celebrações noturnas.',
        'icon': Icons.local_bar_rounded,
      },
      {
        'title': 'Reuniões de Negócios & Liderança',
        'desc': 'Apresentações estratégicas, feiras de negócios, conselhos de administração e networking de alto nível.',
        'icon': Icons.handshake_rounded,
      },
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderBlock(
            title: 'Ocasião Frequente',
            subtitle: 'Entender seu ambiente principal permite calibrar o nível de formalidade e as peças coringas do armário.',
          ),
          const SizedBox(height: 24),
          _buildSectionLabel('SELECIONE SEU CENÁRIO DO DIA A DIA'),
          const SizedBox(height: 12),
          ...occasions.map((o) {
            final title = o['title'] as String;
            final isSelected = _selectedDressOccasion == title;
            return _buildOptionCard(
              title: title,
              subtitle: o['desc'] as String,
              icon: o['icon'] as IconData,
              isSelected: isSelected,
              onTap: () => setState(() => _selectedDressOccasion = title),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // 8. FAMÍLIA OLFATIVA (PERFUMES)
  // ==========================================
  Widget _buildStep8FragrancePreference() {
    final fragranceFamilies = [
      {
        'title': 'Amadeirado & Especiado',
        'desc': 'Notas de cedro, sândalo, cardamomo e noz-moscada. Imponência, maturidade e presença marcante para o trabalho e noites.',
        'icon': Icons.forest_rounded,
      },
      {
        'title': 'Cítrico & Fresco',
        'desc': 'Notas de bergamota, vetiver e limão siciliano. Energia revigorante, limpeza e excelente desempenho em clima quente.',
        'icon': Icons.wb_sunny_rounded,
      },
      {
        'title': 'Oriental & Quente',
        'desc': 'Notas de âmbar, baunilha negra e fava tonka. Sedução magnética, rastro envolvente e ideal para encontros especiais.',
        'icon': Icons.local_fire_department_rounded,
      },
      {
        'title': 'Couro & Tabaco',
        'desc': 'Notas nobres de couro toscano e tabaco macerado. Assinatura aristocrática de autoridade e luxo clássico.',
        'icon': Icons.shield_rounded,
      },
      {
        'title': 'Aquático & Aromático',
        'desc': 'Notas de brisa marinha, lavanda e sálvia. Frescor contemporâneo de extrema versatilidade do dia à noite.',
        'icon': Icons.water_drop_rounded,
      },
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderBlock(
            title: 'Família Olfativa',
            subtitle: 'O perfume é a sua assinatura invisível. Ele ancora a memória olfativa e a presença que você deixa no ambiente.',
          ),
          const SizedBox(height: 24),
          _buildSectionLabel('SELECIONE SUA FAMÍLIA OLFATIVA FAVORITA'),
          const SizedBox(height: 12),
          ...fragranceFamilies.map((f) {
            final title = f['title'] as String;
            final isSelected = _selectedFragrancePreference == title;
            return _buildOptionCard(
              title: title,
              subtitle: f['desc'] as String,
              icon: f['icon'] as IconData,
              isSelected: isSelected,
              onTap: () => setState(() => _selectedFragrancePreference = title),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // 9. OBJETIVOS DE EVOLUÇÃO
  // ==========================================
  Widget _buildStep9Goals() {
    final allGoals = [
      {
        'title': 'Dominar Caimento & Alfaiataria',
        'subtitle': 'Aprender proporções, tecidos nobres e como vestir peças impecáveis.',
        'icon': Icons.checkroom_rounded,
      },
      {
        'title': 'Visagismo de Cabelo & Barba',
        'subtitle': 'Encontrar o corte ideal para seu formato de rosto e harmonia facial.',
        'icon': Icons.face_retouching_natural_rounded,
      },
      {
        'title': 'Rotina de Skincare & Higiene',
        'subtitle': 'Cuidar da pele, barba e autocuidado masculino de alto nível.',
        'icon': Icons.spa_rounded,
      },
      {
        'title': 'Construir Assinatura Olfativa',
        'subtitle': 'Descobrir perfumes para cada ocasião, projeção e fixação.',
        'icon': Icons.bubble_chart_rounded,
      },
      {
        'title': 'Postura, Presença & Linguagem Corporal',
        'subtitle': 'Desenvolver presença física imponente, contato visual e caminhar.',
        'icon': Icons.directions_walk_rounded,
      },
      {
        'title': 'Comunicação & Oratória de Alto Impacto',
        'subtitle': 'Voz, firmeza, posicionamento social e networking profissional.',
        'icon': Icons.record_voice_over_rounded,
      },
      {
        'title': 'Disciplina & Código de Valor',
        'subtitle': 'Fortalecer a mente, responsabilidade e consistência diária.',
        'icon': Icons.shield_moon_rounded,
      },
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderBlock(
            title: 'Metas de Evolução Pessoal',
            subtitle: 'Selecione as áreas prioritárias que você deseja desenvolver no ecossistema Man Hub.',
          ),
          const SizedBox(height: 24),
          _buildSectionLabel('SELECIONE SEUS OBJETIVOS (MULTI-SELEÇÃO)'),
          const SizedBox(height: 12),
          ...allGoals.map((g) {
            final title = g['title'] as String;
            final isSelected = _selectedGoals.contains(title);
            return _buildOptionCard(
              title: title,
              subtitle: g['subtitle'] as String,
              icon: g['icon'] as IconData,
              isSelected: isSelected,
              isMultiSelect: true,
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedGoals.remove(title);
                  } else {
                    _selectedGoals.add(title);
                  }
                });
              },
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // 10. DIAGNÓSTICO & INSIGHTS PERSONALIZADOS
  // ==========================================
  Widget _buildStep10SummaryAndInsights() {
    final insights = _generatePersonalizedInsights();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderBlock(
            title: 'Seu Diagnóstico Personalizado',
            subtitle: 'Compilamos suas características para criar uma experiência e recomendações sob medida para você.',
          ),
          const SizedBox(height: 24),

          // Card Arquétipo
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.royalBlue.withValues(alpha: 0.35),
                  AppColors.card,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.neonPrimary.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonPrimary.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.neonPrimary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.neonPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'ARQUÉTIPO MAPEADO',
                        style: TextStyle(
                          color: AppColors.neonLight,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _selectedStylePreference ?? 'Evolução Integral',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_selectedBodyType ?? 'Biotipo Padrão'} • Rosto ${_selectedFaceShape ?? 'Equilibrado'} • ${_selectedContrastLevel ?? 'Contraste Neutro'}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          _buildSectionLabel('INSIGHTS & DIRETRIZES DE OURO'),
          const SizedBox(height: 12),

          ...insights.map((insight) {
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.neonPrimary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.royalBlue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      insight['icon'] as IconData,
                      color: AppColors.neonPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          insight['title'] as String,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          insight['desc'] as String,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generatePersonalizedInsights() {
    final list = <Map<String, dynamic>>[];

    // Insight de Visagismo / Cabelo
    if (_selectedFaceShape == 'Quadrado') {
      list.add({
        'title': 'Corte para Rosto Quadrado',
        'desc': 'Seus traços mandibulares transmitem alta autoridade. Prefira cortes com volume no topo (Pompadour, Quiff) e laterais com graduação sutil para equilibrar os ângulos retos.',
        'icon': Icons.face_rounded,
      });
    } else if (_selectedFaceShape == 'Redondo') {
      list.add({
        'title': 'Corte para Rosto Redondo',
        'desc': 'Evite volume nas laterais. Aposte em cortes com bastante topo angular e laterais curtas (High Fade / Undercut) acompanhados de barba desenhada no queixo para alongar a face.',
        'icon': Icons.face_rounded,
      });
    } else if (_selectedFaceShape == 'Oval') {
      list.add({
        'title': 'Harmonia para Rosto Oval',
        'desc': 'Seu formato é o mais versátil. Cortes clássicos com textura superior (Slick Back, Textured Crop) e barba por fazer evidenciam suas feições naturais.',
        'icon': Icons.face_rounded,
      });
    } else {
      list.add({
        'title': 'Proporção Facial de Visagismo',
        'desc': 'Mantenha o colarinho italiano em camisas para emoldurar o queixo com imponência e use barbatanas de metal para colarinho sempre impecável.',
        'icon': Icons.face_rounded,
      });
    }

    // Insight de Caimento / Biotipo
    if (_selectedBodyType?.contains('Ectomorfo') == true) {
      list.add({
        'title': 'Diretriz de Caimento (Ectomorfo)',
        'desc': 'Adicione massa visual com sobreposições (overshirts, suéteres de lã merino) e tecidos estruturados (sarja pesada, flanela). Evite peças coladas (skinny) e aposte no corte Slim Clássico.',
        'icon': Icons.checkroom_rounded,
      });
    } else if (_selectedBodyType?.contains('Mesomorfo') == true) {
      list.add({
        'title': 'Diretriz de Caimento (Mesomorfo)',
        'desc': 'Valorize a silhueta em V com paletós de drop estruturado e calças de alfaiataria com gancho médio. Evite camisas excessivamente apertadas que deformem na linha do tórax.',
        'icon': Icons.checkroom_rounded,
      });
    } else if (_selectedBodyType?.contains('Endomorfo') == true) {
      list.add({
        'title': 'Diretriz de Caimento (Endomorfo)',
        'desc': 'Crie colunas verticais com looks monocromáticos e calças de cintura média a alta assentadas na cintura real. Paletós estruturados em lã fria Super 120s alongam a postura.',
        'icon': Icons.checkroom_rounded,
      });
    }

    // Insight de Perfumaria
    if (_selectedFragrancePreference != null) {
      list.add({
        'title': 'Assinatura Olfativa Recomendada',
        'desc': 'Para a preferência $_selectedFragrancePreference, aplique nos 4 pontos pulsáteis (laterais do pescoço e pulsos) sobre pele bem hidratada para máxima fixação e rastro sofisticado.',
        'icon': Icons.bubble_chart_rounded,
      });
    }

    return list;
  }

  // ==========================================
  // WIDGETS AUXILIARES & DESIGN SYSTEM
  // ==========================================
  Widget _buildHeaderBlock({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.neonPrimary,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.neonPrimary, size: 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    bool isMultiSelect = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.royalBlue.withValues(alpha: 0.25)
                : AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.neonPrimary
                  : AppColors.neonPrimary.withValues(alpha: 0.25),
              width: isSelected ? 1.8 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.neonPrimary.withValues(alpha: 0.15),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.neonPrimary.withValues(alpha: 0.2)
                      : AppColors.backgroundSecondary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? AppColors.neonPrimary : AppColors.textSecondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? AppColors.neonLight : AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                isMultiSelect
                    ? (isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded)
                    : (isSelected ? Icons.radio_button_checked : Icons.radio_button_off),
                color: isSelected ? AppColors.neonPrimary : AppColors.textSecondary.withValues(alpha: 0.4),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final isLastPage = _currentPage == _totalPages - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundMain,
        border: Border(
          top: BorderSide(
            color: AppColors.textSecondary.withValues(alpha: 0.12),
          ),
        ),
      ),
      child: Row(
        children: [
          if (_currentPage > 0) ...[
            OutlinedButton(
              onPressed: _prevPage,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: BorderSide(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Voltar'),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _nextPage,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      isLastPage ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
              label: Text(
                _isSaving
                    ? 'Salvando Perfil...'
                    : (isLastPage ? 'Concluir & Salvar Diagnóstico' : 'Próxima Etapa'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.royalBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
