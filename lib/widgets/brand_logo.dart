import 'package:flutter/material.dart';

import '../theme/design_system.dart';

class BrandLogo extends StatelessWidget {
  final double size;
  final bool showLabel;
  final bool showGlow;

  const BrandLogo({
    super.key,
    this.size = 140,
    this.showLabel = true,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final archSize = size * 0.78;
    final strokeWidth = size * 0.09;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size * 1.05,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (showGlow) ...[
                _GlowCircle(
                  size: size * 0.96,
                  color: BirrTheme.primary.withValues(alpha: 0.08),
                  blurSigma: 34,
                ),
                _GlowCircle(
                  size: size * 0.74,
                  color: BirrTheme.secondaryContainer.withValues(alpha: 0.18),
                  blurSigma: 24,
                  offset: Offset(0, size * 0.03),
                ),
              ],
              CustomPaint(
                size: Size(archSize, archSize),
                painter: _ArchPainter(
                  color: BirrTheme.primaryContainer,
                  strokeWidth: strokeWidth,
                ),
              ),
              Positioned(
                bottom: size * 0.01,
                child: Container(
                  width: size * 0.42,
                  height: size * 0.16,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        BirrTheme.primaryContainer,
                        BirrTheme.primary.withValues(alpha: 0.92),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(size * 0.08),
                    boxShadow: [
                      BoxShadow(
                        color: BirrTheme.primary.withValues(alpha: 0.22),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 18),
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [BirrTheme.secondaryContainer, BirrTheme.secondary],
              ).createShader(bounds);
            },
            child: Text(
              'ብር Gebeya',
              textAlign: TextAlign.center,
              style: BirrTheme.getHeadlineLgMobile(context).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  final double blurSigma;
  final Offset offset;

  const _GlowCircle({
    required this.size,
    required this.color,
    required this.blurSigma,
    this.offset = Offset.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: blurSigma,
              spreadRadius: blurSigma / 6,
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _ArchPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final outer = RRect.fromRectAndCorners(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth * 0.2,
      ),
      topLeft: Radius.circular(size.width * 0.45),
      topRight: Radius.circular(size.width * 0.45),
      bottomLeft: Radius.circular(size.width * 0.16),
      bottomRight: Radius.circular(size.width * 0.16),
    );

    canvas.drawRRect(outer, paint);

    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.62
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final inner = RRect.fromRectAndCorners(
      Rect.fromLTWH(
        strokeWidth * 1.9,
        strokeWidth * 1.7,
        size.width - strokeWidth * 3.8,
        size.height - strokeWidth * 2.8,
      ),
      topLeft: Radius.circular(size.width * 0.34),
      topRight: Radius.circular(size.width * 0.34),
      bottomLeft: Radius.circular(size.width * 0.08),
      bottomRight: Radius.circular(size.width * 0.08),
    );

    canvas.drawRRect(inner, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _ArchPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
