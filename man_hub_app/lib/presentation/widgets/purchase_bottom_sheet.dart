import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/payment_service.dart';
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
    final coursePrice = training.price != null
        ? 'R\$ ${training.price!.toStringAsFixed(2).replaceAll('.', ',')}'
        : 'R\$ 97,00';

    return StatefulBuilder(
      builder: (context, setSheetState) {
        bool isProcessing = false;
        String? processingType;

        void handleSubscription() async {
          if (!authService.isLoggedIn) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Faça login ou cadastre-se para assinar o plano.'),
                backgroundColor: AppColors.card,
              ),
            );
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AuthScreen()),
            );
            return;
          }

          setSheetState(() {
            isProcessing = true;
            processingType = 'sub';
          });

          try {
            final launched = await PaymentService().startCheckout(
              itemType: 'pass',
              itemId: 'man_hub_pass',
              title: 'Man Hub Pass (Acesso Ilimitado)',
              price: 49.90,
              userId: authService.currentUser?.uid ?? '',
              userEmail: authService.currentUser?.email,
            );

            if (context.mounted) {
              Navigator.of(context).pop();
              if (launched) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppColors.card,
                    duration: Duration(seconds: 6),
                    content: Text(
                      'Checkout aberto no Mercado Pago! Assim que o pagamento (Pix, Cartão ou Boleto) for confirmado, o seu plano será ativado automaticamente.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }
            }
          } catch (e) {
            if (context.mounted) {
              setSheetState(() => isProcessing = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro ao abrir checkout: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }

        void handleLifetimePurchase() async {
          if (!authService.isLoggedIn) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Faça login ou cadastre-se para adquirir o treinamento.'),
                backgroundColor: AppColors.card,
              ),
            );
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AuthScreen()),
            );
            return;
          }

          setSheetState(() {
            isProcessing = true;
            processingType = 'lifetime';
          });

          final priceValue = training.price ?? 97.00;

          try {
            final launched = await PaymentService().startCheckout(
              itemType: 'training',
              itemId: training.id,
              title: 'Acesso Vitalício: ${training.title}',
              price: priceValue,
              userId: authService.currentUser?.uid ?? '',
              userEmail: authService.currentUser?.email,
            );

            if (context.mounted) {
              Navigator.of(context).pop();
              if (launched) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.card,
                    duration: const Duration(seconds: 6),
                    content: Text(
                      'Checkout aberto no Mercado Pago para "${training.title}"! Assim que aprovado, seu treinamento será desbloqueado.',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }
            }
          } catch (e) {
            if (context.mounted) {
              setSheetState(() => isProcessing = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erro ao abrir checkout: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }

        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
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
                              'DESBLOQUEIE SUA EVOLUÇÃO',
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
                        'Acesse Todos os Módulos de ${training.title}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'O Módulo 1 é gratuito para você conhecer a metodologia. Escolha a melhor opção para desbloquear o restante do curso:',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // OPÇÃO 1: ASSINATURA MENSAL (MAN HUB PASS)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.neonPrimary,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonPrimary.withValues(alpha: 0.12),
                              blurRadius: 16,
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
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.neonPrimary,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'MAIS POPULAR',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  'R\$ 49,90/mês',
                                  style: TextStyle(
                                    color: AppColors.neonLight,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Man Hub Pass (Todos os Cursos)',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Acesso imediato a TODOS os treinamentos atuais e futuros do aplicativo enquanto sua assinatura estiver ativa.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _benefitRow('Todos os módulos deste e dos demais cursos'),
                            _benefitRow('Atualizações de conteúdo e novos lançamentos'),
                            _benefitRow('Cancele quando quiser, sem fidelidade'),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isProcessing ? null : handleSubscription,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.neonPrimary,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: isProcessing && processingType == 'sub'
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.black,
                                        ),
                                      )
                                    : const Text(
                                        'Assinar Man Hub Pass',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // OPÇÃO 2: COMPRA VITALÍCIA INDIVIDUAL
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.textSecondary.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Acesso Vitalício',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  coursePrice,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Acesso exclusivo e vitalício apenas para o treinamento "${training.title}". Pagamento único.',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _benefitRow('Acesso para sempre a este treinamento específico'),
                            _benefitRow('Sem mensalidades ou cobranças recorrentes'),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: isProcessing ? null : handleLifetimePurchase,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textPrimary,
                                  side: BorderSide(
                                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: isProcessing && processingType == 'lifetime'
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.neonPrimary,
                                        ),
                                      )
                                    : Text(
                                        'Comprar Apenas Este Curso ($coursePrice)',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
