import 'dart:math';
import 'package:flutter/material.dart';

/// Мини‑виджет кнопка «На главную» + дождь сердечек и закрытие экрана
class HeartOverlayClose extends StatefulWidget {
  const HeartOverlayClose({super.key});

  @override
  State<HeartOverlayClose> createState() => _HeartOverlayCloseState();
}

class _HeartOverlayCloseState extends State<HeartOverlayClose>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final _rnd = Random();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onPressed() async {
    _ctrl.forward();                               // запускаем сердечки
    await Future.delayed(const Duration(milliseconds: 650));
    if (mounted) Navigator.pop(context);           // закрываем страницу
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Кнопка
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFCC255B),
            foregroundColor: Colors.white,
            padding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            textStyle:
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _onPressed,
          child: const Text('На главную'),
        ),
        // Слой сердечек; IgnorePointer пропускает клики к кнопке
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) =>
                CustomPaint(painter: _HeartPainter(_ctrl.value, _rnd)),
          ),
        ),
      ],
    );
  }
}

/// Painter = рисуем n сердечек, падающих вниз по мере роста t (0‑1)
class _HeartPainter extends CustomPainter {
  final double t;
  final Random rnd;
  static const int n = 40;
  static const double fall = 500;

  _HeartPainter(this.t, this.rnd);

  @override
  void paint(Canvas c, Size s) {
    if (t == 0) return;
    final p = Paint()..color = const Color(0xFFFF4F79);
    for (int i = 0; i < n; i++) {
      final x = rnd.nextDouble() * s.width;
      final y = s.height / 3 - t * fall * (0.6 + rnd.nextDouble() * .4);
      final k = 0.3 + rnd.nextDouble() * 0.7;
      _drawHeart(c, Offset(x, y), 12 * k, p);
    }
  }

  void _drawHeart(Canvas c, Offset o, double s, Paint p) {
    final Path path = Path()
      ..moveTo(o.dx, o.dy + s / 4)
      ..cubicTo(o.dx + s, o.dy - s / 2, o.dx + 1.5 * s, o.dy + s,
          o.dx, o.dy + 1.5 * s)
      ..cubicTo(o.dx - 1.5 * s, o.dy + s, o.dx - s, o.dy - s / 2,
          o.dx, o.dy + s / 4)
      ..close();
    c.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _HeartPainter old) => old.t != t;
}
