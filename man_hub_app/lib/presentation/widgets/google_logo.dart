import 'package:flutter/material.dart';

/// Um widget vetorial do logotipo oficial do Google com as 4 cores características
class GoogleLogo extends StatelessWidget {
  final double size;
  const GoogleLogo({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;
    final strokeWidth = w * 0.22;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    // Arco Azul
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.75, 1.5, false, paint);

    // Arco Amarelo
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.35, 1.55, false, paint);

    // Arco Verde
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.75, 1.6, false, paint);

    // Arco Vermelho
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -2.35, 1.6, false, paint);

    // Barra azul central
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTRB(w * 0.45, h * 0.39, w * 0.98, h * 0.61),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
