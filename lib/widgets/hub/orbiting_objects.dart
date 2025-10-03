import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/constants/app_colors.dart';

class OrbitingObjects extends StatelessWidget {
  final Animation<double> orbitAnimation;

  const OrbitingObjects({
    super.key,
    required this.orbitAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: orbitAnimation,
      builder: (context, child) {
        // Define orbit radii so the drawn paths match the animated bodies
        const double rx1 = 120; // wider x-radius (further from Sunny)
        const double ry1 = 85;  // y-radius
        const double rx2 = 95;  // inner orbit further than before
        const double ry2 = 65;

        return SizedBox.expand(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Orbit paths (light lines)
              Positioned.fill(
                child: CustomPaint(
                  painter: _OrbitPathsPainter(
                    rx1: rx1,
                    ry1: ry1,
                    rx2: rx2,
                    ry2: ry2,
                  ),
                ),
              ),

              // Elliptical orbit 1 (further from sun)
              Transform.translate(
                offset: Offset(
                  math.cos(orbitAnimation.value * 2 * math.pi) * rx1,
                  math.sin(orbitAnimation.value * 2 * math.pi) * ry1,
                ),
                child: _buildOrbitObject(
                  size: 12,
                  color: AppColors.accent,
                ),
              ),
              // Elliptical orbit 2 (phase-shifted, smaller radius)
              Transform.translate(
                offset: Offset(
                  math.cos((orbitAnimation.value + 0.35) * 2 * math.pi) * rx2,
                  math.sin((orbitAnimation.value + 0.35) * 2 * math.pi) * ry2,
                ),
                child: _buildOrbitObject(
                  size: 9,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrbitObject({
    required double size,
    required Color color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: size / 2,
            spreadRadius: size / 10,
          ),
        ],
      ),
    );
  }
}

class _OrbitPathsPainter extends CustomPainter {
  final double rx1;
  final double ry1;
  final double rx2;
  final double ry2;

  _OrbitPathsPainter({
    required this.rx1,
    required this.ry1,
    required this.rx2,
    required this.ry2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =AppColors.accent.withOpacity(0.22) 
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // First ellipse path (match rx1/ry1)
    final rect1 = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: rx1 * 2,
      height: ry1 * 2,
    );
    canvas.drawOval(rect1, paint);

    // Second ellipse path (smaller)
    final paint2 = Paint()
      ..color = AppColors.primary.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final rect2 = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: rx2 * 2,
      height: ry2 * 2,
    );
    canvas.drawOval(rect2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
