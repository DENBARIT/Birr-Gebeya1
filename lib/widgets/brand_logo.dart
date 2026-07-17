import 'package:flutter/material.dart';

import '../theme/design_system.dart';

class BrandLogo extends StatefulWidget {
  final double size;
  final bool showLabel;
  final bool showGlow;

  /// Crops the mark into a circular badge with a drop shadow instead of the
  /// plain square/contain image.
  final bool circular;

  /// Animates a soft diagonal shine sweeping across the mark on a loop.
  /// Only meaningful when [circular] is true.
  final bool glimmer;

  const BrandLogo({
    super.key,
    this.size = 140,
    this.showLabel = true,
    this.showGlow = true,
    this.circular = false,
    this.glimmer = false,
  });

  @override
  State<BrandLogo> createState() => _BrandLogoState();
}

class _BrandLogoState extends State<BrandLogo>
    with SingleTickerProviderStateMixin {
  AnimationController? _shimmerController;

  @override
  void initState() {
    super.initState();
    if (widget.glimmer) {
      _shimmerController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2600),
      )..repeat();
    }
  }

  @override
  void dispose() {
    _shimmerController?.dispose();
    super.dispose();
  }

  Widget _buildMark() {
    final logoSize = widget.size * 0.92;

    if (!widget.circular) {
      return Image.asset(
        'lib/assets/Logo.png.jpeg',
        width: logoSize,
        height: logoSize,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      );
    }

    final badge = Container(
      width: logoSize,
      height: logoSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        image: const DecorationImage(
          image: AssetImage('lib/assets/Logo.png.jpeg'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: BirrTheme.primary.withValues(alpha: 0.30),
            blurRadius: 26,
            spreadRadius: 0,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    if (_shimmerController == null) return badge;

    return AnimatedBuilder(
      animation: _shimmerController!,
      builder: (context, child) {
        final t = _shimmerController!.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.8 + t * 3.6, -1),
              end: Alignment(-0.6 + t * 3.6, 1),
              colors: [
                Colors.white.withValues(alpha: 0.0),
                Colors.white.withValues(alpha: 0.65),
                Colors.white.withValues(alpha: 0.0),
              ],
              stops: const [0.35, 0.5, 0.65],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: badge,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.showGlow) ...[
                _GlowCircle(
                  size: widget.size * 0.96,
                  color: BirrTheme.primary.withValues(alpha: 0.08),
                  blurSigma: 34,
                ),
                _GlowCircle(
                  size: widget.size * 0.74,
                  color: BirrTheme.secondaryContainer.withValues(alpha: 0.18),
                  blurSigma: 24,
                  offset: Offset(0, widget.size * 0.03),
                ),
              ],
              _buildMark(),
            ],
          ),
        ),
        if (widget.showLabel) ...[
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
