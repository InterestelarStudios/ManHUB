import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum ScanDirection { none, left, right }

/// Widget de overlay com estética Dark Luxury / Cyber Biometria.
/// Renderiza a moldura oval, pontos de ancoragem biométricos e feixe de laser animado.
class FaceScannerOverlay extends StatefulWidget {
  final bool isScanning;
  final String statusText;
  final ScanDirection direction;

  const FaceScannerOverlay({
    super.key,
    this.isScanning = true,
    this.statusText = 'Mapeando proporções faciais...',
    this.direction = ScanDirection.none,
  });

  @override
  State<FaceScannerOverlay> createState() => _FaceScannerOverlayState();
}

class _FaceScannerOverlayState extends State<FaceScannerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _laserController;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final ovalWidth = constraints.maxWidth * 0.72;
        final ovalHeight = ovalWidth * 1.35;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Pintor da Máscara Escura e Moldura Oval
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _ScannerMaskPainter(
                ovalWidth: ovalWidth,
                ovalHeight: ovalHeight,
              ),
            ),

            // Feixe de Laser Animado (apenas se estiver escaneando)
            if (widget.isScanning)
              AnimatedBuilder(
                animation: _laserController,
                builder: (context, child) {
                  final topOffset =
                      (constraints.maxHeight - ovalHeight) / 2 +
                          (_laserController.value * ovalHeight);

                  return Positioned(
                    top: topOffset,
                    child: Container(
                      width: ovalWidth * 0.94,
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.neonPrimary.withValues(alpha: 0.8),
                            AppColors.neonLight,
                            AppColors.neonPrimary.withValues(alpha: 0.8),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonPrimary.withValues(alpha: 0.6),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            // Miras e Âncoras nos Cantos
            SizedBox(
              width: ovalWidth + 24,
              height: ovalHeight + 24,
              child: const _BiometricTargetCorners(),
            ),

            // Setas de direção
            if (widget.direction == ScanDirection.left)
              Positioned(
                left: constraints.maxWidth / 2 - ovalWidth / 2 - 40,
                child: const _DirectionArrow(isLeft: true),
              ),
            if (widget.direction == ScanDirection.right)
              Positioned(
                right: constraints.maxWidth / 2 - ovalWidth / 2 - 40,
                child: const _DirectionArrow(isLeft: false),
              ),

            // Indicador de Status Dinâmico Inferior
            Positioned(
              bottom: (constraints.maxHeight - ovalHeight) / 2 - 64,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.card.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.neonPrimary.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.neonPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.statusText,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Desenha o recorte escurecido exterior e a moldura oval neon
class _ScannerMaskPainter extends CustomPainter {
  final double ovalWidth;
  final double ovalHeight;

  _ScannerMaskPainter({
    required this.ovalWidth,
    required this.ovalHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ovalRect = Rect.fromCenter(
      center: center,
      width: ovalWidth,
      height: ovalHeight,
    );

    // 1. Fundo semitransparente escurecido fora do oval
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final ovalPath = Path()..addOval(ovalRect);
    final clipPath =
        Path.combine(PathOperation.difference, backgroundPath, ovalPath);

    final dimPaint = Paint()
      ..color = AppColors.backgroundMain.withValues(alpha: 0.72)
      ..style = PaintingStyle.fill;
    canvas.drawPath(clipPath, dimPaint);

    // 2. Borda externa suave do oval
    final borderPaint = Paint()
      ..color = AppColors.neonPrimary.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawOval(ovalRect, borderPaint);

    // 3. Glow sutil
    final glowPaint = Paint()
      ..color = AppColors.neonLight.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawOval(ovalRect, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _ScannerMaskPainter oldDelegate) {
    return oldDelegate.ovalWidth != ovalWidth ||
        oldDelegate.ovalHeight != ovalHeight;
  }
}

/// Quatro cantoneiras futuristas ao redor do oval
class _BiometricTargetCorners extends StatelessWidget {
  const _BiometricTargetCorners();

  @override
  Widget build(BuildContext context) {
    const cornerSize = 18.0;
    const cornerThickness = 2.5;
    const color = AppColors.neonPrimary;

    return Stack(
      children: [
        // Top-Left
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: cornerSize,
            height: cornerSize,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: color, width: cornerThickness),
                left: BorderSide(color: color, width: cornerThickness),
              ),
            ),
          ),
        ),
        // Top-Right
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: cornerSize,
            height: cornerSize,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: color, width: cornerThickness),
                right: BorderSide(color: color, width: cornerThickness),
              ),
            ),
          ),
        ),
        // Bottom-Left
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            width: cornerSize,
            height: cornerSize,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: color, width: cornerThickness),
                left: BorderSide(color: color, width: cornerThickness),
              ),
            ),
          ),
        ),
        // Bottom-Right
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: cornerSize,
            height: cornerSize,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: color, width: cornerThickness),
                right: BorderSide(color: color, width: cornerThickness),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DirectionArrow extends StatefulWidget {
  final bool isLeft;
  const _DirectionArrow({required this.isLeft});

  @override
  State<_DirectionArrow> createState() => _DirectionArrowState();
}

class _DirectionArrowState extends State<_DirectionArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(widget.isLeft ? -_animation.value : _animation.value, 0),
          child: Icon(
            widget.isLeft ? Icons.arrow_back_ios_new : Icons.arrow_forward_ios,
            color: AppColors.neonPrimary,
            size: 40,
          ),
        );
      },
    );
  }
}
