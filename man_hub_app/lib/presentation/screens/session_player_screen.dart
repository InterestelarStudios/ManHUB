import 'package:flutter/material.dart';
import '../../domain/models/session.dart';
import '../../domain/models/screen_model.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/block_widgets.dart';

class SessionPlayerScreen extends StatefulWidget {
  final Session session;

  const SessionPlayerScreen({super.key, required this.session});

  @override
  State<SessionPlayerScreen> createState() => _SessionPlayerScreenState();
}

class _SessionPlayerScreenState extends State<SessionPlayerScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextScreen() {
    if (_currentIndex < widget.session.screens.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      // Aula terminou, voltar
      Navigator.of(context).pop();
    }
  }

  void _previousScreen() {
    if (_currentIndex > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.session.screens.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.session.title)),
        body: const Center(child: Text('Nenhum conteúdo nesta aula.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundMain,
      body: SafeArea(
        child: Stack(
          children: [
            // O PageView com os conteúdos
            PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Desabilita swipe para usar o toque nas bordas
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: widget.session.screens.length,
              itemBuilder: (context, index) {
                return _buildScreenContent(widget.session.screens[index]);
              },
            ),

            // O indicador de progresso (barrinhas no topo)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: _buildProgressIndicators(),
            ),

            // Tap Areas para avançar e voltar
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: _previousScreen,
                      behavior: HitTestBehavior.translucent,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _nextScreen,
                      behavior: HitTestBehavior.translucent,
                    ),
                  ),
                ],
              ),
            ),
            
            // Botão fechar
            Positioned(
              top: 32,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildScreenContent(ScreenModel screen) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 80, bottom: 40, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: screen.contents.map((block) {
          // Precisamos permitir que os toques passem para os widgets que precisam (ex: Vídeo)
          // mas sem bloquear o onTap da tela quando não for interativo.
          return ContentBlockRenderer(block: block);
        }).toList(),
      ),
    );
  }

  Widget _buildProgressIndicators() {
    return Row(
      children: List.generate(
        widget.session.screens.length,
        (index) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 4,
            decoration: BoxDecoration(
              color: index <= _currentIndex ? AppColors.neonPrimary : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
