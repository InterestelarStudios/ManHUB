import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../main_navigation_screen.dart';

class OnboardingItem {
  final String imagePath;
  final String title;
  final String subtitle;

  const OnboardingItem({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isFinishing = false;

  final List<OnboardingItem> _items = const [
    OnboardingItem(
      imagePath: 'contents/images/onboarding/0.jpg',
      title: 'Bem vindo ao Man HUB.',
      subtitle: 'O seu passaporte para se tornar um verdadeiro homem de valor.',
    ),
    OnboardingItem(
      imagePath: 'contents/images/onboarding/1.jpg',
      title: 'Mais do que estilo. Uma nova versão de você.',
      subtitle: 'O Man Hub é o ponto de partida para o homem que busca evolução.',
    ),
    OnboardingItem(
      imagePath: 'contents/images/onboarding/2.jpg',
      title: 'Domine sua imagem, comande sua presença.',
      subtitle:
          'Descubra seu tipo físico, formato de rosto, estilo pessoal e aprenda a usar a imagem como ferramenta de respeito, atração e autoridade.',
    ),
    OnboardingItem(
      imagePath: 'contents/images/onboarding/4.jpg',
      title: 'Estilo é só o começo.',
      subtitle:
          'Aprenda sobre comportamento, treinos, perfumes, cuidado pessoal e mentalidade.',
    ),
    OnboardingItem(
      imagePath: 'contents/images/onboarding/5.jpg',
      title: 'Sua transformação começa agora.',
      subtitle:
          'Dentro do Man Hub, você encontrará treinamentos, guias e recomendações personalizadas para se tornar a sua melhor versão.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (_isFinishing) return;
    setState(() => _isFinishing = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('seen_onboarding', true);
    } catch (_) {
      // Ignora erro no prefs e prossegue
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const MainNavigationScreen(),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // PageView com as telas de onboarding
            PageView.builder(
              controller: _pageController,
              itemCount: _items.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final item = _items[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Imagem de fundo
                    Image.asset(
                      item.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.backgroundMain,
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.white24,
                              size: 48,
                            ),
                          ),
                        );
                      },
                    ),

                    // Gradiente escuro para legibilidade do texto
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.35, 0.65, 0.95],
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.15),
                              Colors.black.withValues(alpha: 0.75),
                              Colors.black.withValues(alpha: 0.95),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Conteúdo de texto (Título e Subtítulo)
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                height: 1.25,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.subtitle,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.78),
                                fontSize: 13.5,
                                height: 1.45,
                                letterSpacing: 0.1,
                              ),
                            ),
                            // Espaço reservado para a barra inferior de botões
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Controles de navegação na parte inferior fixados
            Positioned(
              left: 24,
              right: 24,
              bottom: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: _currentPage == 0
                      ? _buildStartButton()
                      : _buildNavControls(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Botão "Começar" exibido apenas na primeira tela (índice 0)
  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: _nextPage,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: AppColors.neonPrimary,
            width: 1.5,
          ),
          backgroundColor: Colors.black.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          splashFactory: InkRipple.splashFactory,
        ),
        child: const Text(
          'Começar',
          style: TextStyle(
            color: AppColors.neonPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  /// Controles com Dots na esquerda e botões circulares (< e >) na direita
  Widget _buildNavControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Indicador de pontos (5 páginas)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_items.length, (index) {
            final isActive = _currentPage == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              height: 3.5,
              width: isActive ? 14 : 4,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.neonPrimary
                    : Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),

        // Botões de voltar e avançar (< e >)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botão Voltar (<)
            GestureDetector(
              onTap: _previousPage,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.45),
                  border: Border.all(
                    color: AppColors.neonPrimary.withValues(alpha: 0.7),
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.neonPrimary,
                    size: 26,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Botão Avançar / Concluir (>)
            GestureDetector(
              onTap: _nextPage,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.45),
                  border: Border.all(
                    color: AppColors.neonPrimary,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: _isFinishing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.neonPrimary,
                          ),
                        )
                      : const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.neonPrimary,
                          size: 26,
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
