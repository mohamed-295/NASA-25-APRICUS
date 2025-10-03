import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SunnyCharacter extends StatelessWidget {
  final Animation<double> pulseAnimation;

  const SunnyCharacter({
    super.key,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        final scale = 1.0 + (pulseAnimation.value * 0.1);
        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow
                Container(
                  width: 95,
                  height: 95,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.45),
                        blurRadius: 40,
                        spreadRadius: 12,
                      ),
                    ],
                  ),
                ),
                // Sunny asset
                Image.asset(
                  'assets/images/characters/sunny.png',
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
