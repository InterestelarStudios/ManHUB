import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/plan_service.dart';
import '../screens/auth/auth_screen.dart';

class SubscriptionBottomSheet extends StatefulWidget {
  const SubscriptionBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SubscriptionBottomSheet(),
    );
  }

  @override
  State<SubscriptionBottomSheet> createState() => _SubscriptionBottomSheetState();
}

class _SubscriptionBottomSheetState extends State<SubscriptionBottomSheet> {
  final AuthService _authService = AuthService();
  final PlanService _planService = PlanService();
  bool _isSyncing = false;
  String? _syncFeedback;
  bool _syncNotFound = false;

  @override
  void initState() {
    super.initState();
    _planService.addListener(_onPlanChanged);
  }

  @override
  void dispose() {
    _planService.removeListener(_onPlanChanged);
    super.dispose();
  }

  void _onPlanChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _openPortal() async {
    final uri = Uri.parse('https://manhub.app');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Erro ao abrir portal: $e');
    }
  }

  void _handleLogin() {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  Future<void> _handleSync() async {
    if (_isSyncing) return;
    setState(() {
      _isSyncing = true;
      _syncFeedback = null;
      _syncNotFound = false;
    });

    try {
      final success = await _authService.syncEntitlements();
      if (!mounted) return;

      final isSubscribed = _authService.isSubscribed;
      if (isSubscribed) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.neonPrimary,
            content: Text(
              'Man Hub Pass ATIVO! Todos os cursos e recursos foram liberados.',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        );
      } else {
        setState(() {
          _isSyncing = false;
          _syncNotFound = true;
          _syncFeedback = success
              ? 'Nenhuma assinatura ativa encontrada para ${_authService.currentUser?.email}.'
              : 'Não foi possível verificar no momento. Verifique sua conexão à internet.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _syncNotFound = true;
          _syncFeedback = 'Erro ao verificar assinatura: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = _authService.isLoggedIn;
    final isSubscribed = _authService.isSubscribed;
    final userEmail = _authService.currentUser?.email ?? '';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundMain,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra de arraste
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Cabeçalho com botão fechar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.neonPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.neonPrimary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'contents/images/manhub_icon.png',
                          width: 18,
                          height: 18,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'MAN HUB PASS',
                          style: TextStyle(
                            color: AppColors.neonLight,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Card Principal de Destaque
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.neonPrimary.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonPrimary.withValues(alpha: 0.12),
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSubscribed ? Colors.green : AppColors.neonPrimary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isSubscribed ? 'PLANO ATIVO' : 'ACESSO TOTAL',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          isSubscribed ? 'Membro Ativo' : _planService.formattedMonthlyPrice,
                          style: const TextStyle(
                            color: AppColors.neonLight,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Acesso Ilimitado a Todos os Treinamentos',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'O Man Hub Pass desbloqueia todos os cursos, quizzes, looks recomendados e o armário virtual de estilo em uma única experiência contínua.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _benefitRow('Desbloqueio de todos os módulos de todos os cursos'),
                    _benefitRow('Visagismo, Perfumes, Estilo, Skincare, Presença e Postura'),
                    _benefitRow('Aulas imersivas estilo stories atualizadas com frequência'),
                    _benefitRow('Sincronização imediata entre seus dispositivos pelo seu e-mail'),

                    // Feedback inline caso não localize assinatura
                    if (_syncFeedback != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _syncNotFound ? const Color(0xFF261919) : AppColors.backgroundMain,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _syncNotFound ? Colors.redAccent.withValues(alpha: 0.5) : AppColors.neonPrimary,
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _syncNotFound ? Icons.info_outline_rounded : Icons.check_circle_outline_rounded,
                                  color: _syncNotFound ? Colors.redAccent : AppColors.neonLight,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _syncNotFound ? 'Nenhuma Assinatura Localizada' : 'Status da Verificação',
                                  style: TextStyle(
                                    color: _syncNotFound ? Colors.redAccent : AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _syncFeedback!,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    if (!isLoggedIn) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.neonPrimary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                          ),
                          child: const Text(
                            'Entrar com Minha Conta',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _openPortal,
                          icon: const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.neonLight),
                          label: const Text(
                            'Acessar Portal Oficial (manhub.app)',
                            style: TextStyle(color: AppColors.neonLight, fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.neonPrimary, width: 1.2),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundMain,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.neonPrimary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person_outline, size: 18, color: AppColors.neonLight),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                userEmail,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSyncing ? null : _handleSync,
                          icon: _isSyncing
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                )
                              : const Icon(Icons.sync_rounded, color: Colors.black, size: 18),
                          label: Text(
                            _isSyncing ? 'Verificando assinatura...' : 'Sincronizar Minha Assinatura',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.neonPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _openPortal,
                          icon: const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.neonLight),
                          label: const Text(
                            'Acessar Portal Oficial (manhub.app)',
                            style: TextStyle(color: AppColors.neonLight, fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.neonPrimary.withValues(alpha: 0.6), width: 1.2),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: _handleLogin,
                          child: const Text(
                            'Entrar com outro e-mail',
                            style: TextStyle(color: AppColors.neonLight, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Selo informativo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 14,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Assinaturas realizadas no portal manhub.app sincronizam automaticamente.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  static Widget _benefitRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: AppColors.neonPrimary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 11, color: Colors.black),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
