import 'package:flutter/material.dart';

class AppFonts {
  // Font family name
  static const String mansalva = 'Mansalva';
  
  // Font weights
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  
  // Predefined text styles for common use cases
  static const TextStyle titleStyle = TextStyle(
    fontFamily: mansalva,
    fontSize: 28,
    fontWeight: bold,
  );
  
  static const TextStyle subtitleStyle = TextStyle(
    fontFamily: mansalva,
    fontSize: 20,
    fontWeight: semiBold,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontFamily: mansalva,
    fontSize: 16,
    fontWeight: regular,
  );
  
  static const TextStyle captionStyle = TextStyle(
    fontFamily: mansalva,
    fontSize: 14,
    fontWeight: regular,
  );
}
