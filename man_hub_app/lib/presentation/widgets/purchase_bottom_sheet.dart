import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../domain/models/training.dart';
import '../screens/auth/auth_screen.dart';

class PurchaseBottomSheet extends StatelessWidget {
  final Training training;

  const PurchaseBottomSheet({super.key, required this.training});

  static Future<void> show(BuildContext context, {required Training training}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PurchaseBottomSheet(training: training),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StatefulBuilder(
      builder: (context, setSheetState) {
        bool isSyncing = false;

        void handleLogin() {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AuthScreen()),
          );
        }

        void handleSync() async {
          setSheetState(() => isSyncing = true);
          final success = await authService.syncEntitlements();
          if (context.mounted) {
            setSheetState(() => isSyncing = false);
            final hasAccess = authService.hasAccessToTraining(training.id);
            if (hasAccess) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.neonPrimary,
                  content: Text(
                    'Acesso confirmado para "${training.title}"! Bons estudos.',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.card,
                  duration: const Duration(seconds: 5),
                  content: Text(
                    success
                        ? 'Nenhuma matrícula ativa localizada para ${authService.currentUser?.email}. Se você adquiriu recentemente pelo site, aguarde alguns instantes e tente novamente.'
                        : 'Não foi possível verificar no momento. Verifique sua conexão.',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
          }
        }

        final isLoggedIn = authService.isLoggedIn;
        final userEmail = authService.currentUser?.email ?? '';

        return Container(
          height: MediaQuery.of(context).size.height * 0.78,
          decoration: const BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Barra de arraste
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.neonPrimary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.neonPrimary.withValues(alpha: 0.3)),
                            ),
                            child: const Text(
                              'CONTEÚDO EXCLUSIVO',
                              style: TextStyle(
                                color: AppColors.neonLight,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: AppColors.textSecondary),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Acesso de Membro: ${training.title}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'O Módulo 1 está liberado para degustação. Os módulos seguintes e quizzes são exclusivos para membros matriculados ou assinantes do Man Hub Pass.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Card Informativo de Acesso
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.neonPrimary.withValues(alpha: 0.4),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonPrimary.withValues(alpha: 0.08),
                              blurRadius: 16,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.workspace_premium_rounded, color: AppColors.neonLight, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Como acessar este treinamento?',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'As matrículas de cursos e assinaturas do ecossistema Man Hub são gerenciadas no portal oficial e sincronizadas automaticamente com o aplicativo.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _benefitRow('Liberação instantânea pelo e-mail cadastrado'),
                            _benefitRow('Acesso a todos os módulos, cards e quizzes'),
                            _benefitRow('Sincronização em tempo real entre seus dispositivos'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Bloco de Ação conforme estado de Login
                      if (!isLoggedIn) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundMain,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.15)),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Já possui uma conta ou realizou matrícula no site?',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Faça login com o mesmo e-mail para carregar seus acessos.',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.neonPrimary,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Entrar na Minha Conta',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundMain,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.neonPrimary.withValues(alpha: 0.25)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.account_circle_outlined, color: AppColors.neonLight, size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Conectado como:',
                                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                    ),
                                    Text(
                                      userEmail,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isSyncing ? null : handleSync,
                            icon: isSyncing
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                  )
                                : const Icon(Icons.sync_rounded, color: Colors.black, size: 20),
                            label: Text(
                              isSyncing ? 'Verificando...' : 'Sincronizar Meus Acessos',
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
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: TextButton(
                            onPressed: handleLogin,
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
            ],
          ),
        );
      },
    );
  }

  static Widget _benefitRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.neonLight, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
