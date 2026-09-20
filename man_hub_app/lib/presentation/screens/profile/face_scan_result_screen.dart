import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../domain/models/face_scan_result.dart';
import 'face_scan_capture_screen.dart';
import 'personalized_profile_screen.dart';

/// Tela de resultado do Scan Facial e Visagismo Masculino.
/// Apresenta o formato identificado (um dos 6 canônicos), proporções anatômicas
/// e consultoria personalizada de corte de cabelo, barba e óculos.
/// Pode ser aberta tanto logo após o scan quanto como resumo de visagismo do perfil.
class FaceScanResultScreen extends StatefulWidget {
  final FaceScanResult result;
  final bool isSummaryMode;

  const FaceScanResultScreen({
    super.key,
    required this.result,
    this.isSummaryMode = false,
  });

  @override
  State<FaceScanResultScreen> createState() => _FaceScanResultScreenState();
}

class _FaceScanResultScreenState extends State<FaceScanResultScreen> {
  bool _isSaving = false;

  Future<void> _applyToProfile() async {
    setState(() => _isSaving = true);
    try {
      await AuthService().updatePersonalizedProfile(
        faceShape: widget.result.faceShape,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.royalBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.neonLight, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Formato ${widget.result.faceShape} aplicado ao seu perfil!',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      // Retorna o formato aplicado para a tela anterior
      Navigator.of(context).pop(widget.result.faceShape);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent.shade700,
          content: Text('Erro ao atualizar perfil: $e'),
        ),
      );
    }
  }

  Future<void> _rescan() async {
    final newShape = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const FaceScanCaptureScreen(),
      ),
    );
    if (newShape != null && mounted) {
      Navigator.of(context).pop(newShape);
    }
  }

  Future<void> _editManually() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PersonalizedProfileScreen(),
      ),
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  IconData _getShapeIcon(String shape) {
    switch (shape) {
      case 'Quadrado':
        return Icons.crop_square_rounded;
      case 'Redondo':
        return Icons.circle_outlined;
      case 'Retangular / Oblongo':
        return Icons.view_headline_rounded;
      case 'Diamante':
        return Icons.diamond_outlined;
      case 'Triangular':
        return Icons.change_history_rounded;
      case 'Oval':
      default:
        return Icons.face_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;

    return Scaffold(
      backgroundColor: AppColors.backgroundMain,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundMain,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            widget.isSummaryMode
                ? Icons.arrow_back_ios_new_rounded
                : Icons.close_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.isSummaryMode ? 'MEU VISAGISMO & ROSTO' : 'DIAGNÓSTICO FACIAL',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Destaque Visual com Foto e Badge
              _buildFaceHeader(result),
              const SizedBox(height: 24),

              // 2. Card de Proporções Anatômicas
              _buildProportionsCard(result),
              const SizedBox(height: 20),

              // 3. Recomendações de Visagismo: Cortes de Cabelo
              _buildVisagismSection(
                icon: Icons.content_cut_rounded,
                title: 'Cortes de Cabelo Harmonizados',
                subtitle: 'Estilos que valorizam a geometria do formato ${result.faceShape}',
                items: result.haircutTips,
              ),
              const SizedBox(height: 16),

              // 4. Recomendações de Visagismo: Barba
              _buildVisagismSection(
                icon: Icons.face_retouching_natural_rounded,
                title: 'Desenho & Modelagem de Barba',
                subtitle: 'Linhas e comprimentos que equilibram a mandíbula',
                items: result.beardTips,
              ),
              const SizedBox(height: 16),

              // 5. Recomendações de Visagismo: Óculos & Armações
              _buildVisagismSection(
                icon: Icons.visibility_rounded,
                title: 'Armações de Óculos Ideais',
                subtitle: 'Modelos que contrastam ou harmonizam com o formato',
                items: result.glassesTips,
              ),
              const SizedBox(height: 32),

              // 6. Botões de Ação Condicionais ao Modo
              if (widget.isSummaryMode) ...[
                // Botão Primário no Modo Resumo: Refazer Scan com Câmera/IA
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _rescan,
                    icon: const Icon(Icons.camera_alt_rounded, size: 20),
                    label: const Text(
                      'REFAZER SCAN FACIAL COM IA',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonPrimary,
                      foregroundColor: AppColors.backgroundMain,
                      elevation: 4,
                      shadowColor: AppColors.neonPrimary.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Botão Secundário no Modo Resumo: Alterar Manualmente
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _editManually,
                    icon: const Icon(Icons.tune_rounded,
                        color: AppColors.textPrimary, size: 18),
                    label: const Text(
                      'Alterar Formato Manualmente',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.neonPrimary.withValues(alpha: 0.35),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Botão CTA Principal: Aplicar ao Perfil
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _applyToProfile,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(AppColors.backgroundMain),
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 20),
                    label: Text(
                      _isSaving ? 'SALVANDO NO PERFIL...' : 'APLICAR AO MEU PERFIL',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonPrimary,
                      foregroundColor: AppColors.backgroundMain,
                      elevation: 4,
                      shadowColor: AppColors.neonPrimary.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Botão Secundário: Escanear Novamente
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.refresh_rounded,
                        color: AppColors.textSecondary, size: 18),
                    label: const Text(
                      'Escanear Novamente com Outra Foto',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Cabeçalho com foto emoldurada, badge do formato e barra de confiança
  Widget _buildFaceHeader(FaceScanResult result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.neonPrimary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonPrimary.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Foto ou Ícone Centralizado com Glow Neon
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.neonPrimary,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonPrimary.withValues(alpha: 0.35),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: result.imageBytes != null
                    ? Image.memory(
                        result.imageBytes!,
                        fit: BoxFit.cover,
                        width: 96,
                        height: 96,
                      )
                    : (AuthService().currentUser?.profileImageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: AuthService().currentUser!.profileImageUrl!,
                            fit: BoxFit.cover,
                            width: 96,
                            height: 96,
                            placeholder: (context, url) => Container(
                              color: AppColors.backgroundSecondary,
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColors.neonPrimary,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.backgroundSecondary,
                              child: Icon(
                                _getShapeIcon(result.faceShape),
                                color: AppColors.neonPrimary,
                                size: 44,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.backgroundSecondary,
                            child: Icon(
                              _getShapeIcon(result.faceShape),
                              color: AppColors.neonPrimary,
                              size: 44,
                            ),
                          )),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Badge com Formato Canônico
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.royalBlue.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.neonPrimary.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getShapeIcon(result.faceShape),
                  color: AppColors.neonLight,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    widget.isSummaryMode
                        ? 'FORMATO ATIVO: ${result.faceShape.toUpperCase()}'
                        : 'FORMATO: ${result.faceShape.toUpperCase()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.neonLight,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Subtítulo do Formato
          Text(
            result.subtitle,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Descrição Visagista
          Text(
            result.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),

          // Barra de Confiança / Match
          Row(
            children: [
              const Text(
                'Compatibilidade Biométrica:',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${result.confidenceScore}%',
                style: const TextStyle(
                  color: AppColors.neonPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: result.confidenceScore / 100.0,
              backgroundColor: AppColors.backgroundSecondary,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neonPrimary),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  /// Card de Proporções Anatômicas (Testa, Maçãs, Mandíbula, Proporção Vertical)
  Widget _buildProportionsCard(FaceScanResult result) {
    if (result.proportions.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neonPrimary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics_outlined,
                color: AppColors.neonPrimary,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                'ANÁLISE DE PROPORÇÕES',
                style: TextStyle(
                  color: AppColors.neonPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...result.proportions.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 115,
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Seção de Recomendações de Visagismo
  Widget _buildVisagismSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<String> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neonPrimary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.royalBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.neonPrimary, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 5.0, right: 8.0),
                    child: Icon(
                      Icons.circle,
                      size: 5,
                      color: AppColors.neonPrimary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
