import 'package:flutter/material.dart';

import '../../app/theme/tokens.dart';

/// La marca de Lesen: un libro abierto sobre un cuadrado terracota, con el punto ocre de la web.
class LesenMark extends StatelessWidget {
  const LesenMark({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(size: Size.square(size), painter: _MarkPainter()),
  );
}

class _MarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final rect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(s * 0.26));
    canvas.drawRRect(rect, Paint()..color = LesenTokens.light.brand);
    final page = Paint()
      ..color = const Color(0xFFFFFDF8)
      ..style = PaintingStyle.fill;
    Path leaf(bool left) {
      final dir = left ? -1 : 1;
      final cx = s * 0.5;
      return Path()
        ..moveTo(cx, s * 0.34)
        ..quadraticBezierTo(cx + dir * s * 0.14, s * 0.27, cx + dir * s * 0.29, s * 0.31)
        ..lineTo(cx + dir * s * 0.29, s * 0.71)
        ..quadraticBezierTo(cx + dir * s * 0.14, s * 0.67, cx, s * 0.74)
        ..close();
    }

    canvas.drawPath(leaf(true), page);
    canvas.drawPath(leaf(false), page);
    canvas.drawCircle(Offset(s * 0.5, s * 0.2), s * 0.065, Paint()..color = const Color(0xFFE2A93B));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
