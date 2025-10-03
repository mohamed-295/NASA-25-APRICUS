import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class StarfieldBackground extends StatelessWidget {
  final int starCount;

  const StarfieldBackground({
    super.key,
    this.starCount = 50,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background,
            AppColors.background.withBlue(50),
            AppColors.surface,
          ],
        ),
      ),
      child: Stack(
        children: List.generate(starCount, (index) {
          return Positioned(
            left: (index * 37) % size.width,
            top: (index * 53) % size.height,
            child: Container(
              width: 2,
              height: 2,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
      ),
    );
  }
}
