import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color brandGreen = Color(0xFF00ED64);
  static const Color brandGreenDark = Color(0xFF00684A);
  static const Color brandTealDeep = Color(0xFF001E2B); // Deep Navy Hero
  static const Color brandTealMid = Color(0xFF00684A);
  static const Color brandTealLight = Color(0xFFE3FCF7);

  // Surface Colors
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color canvasDark = Color(0xFF001E2B);
  static const Color surface = Color(0xFFF9FBFA);
  static const Color surfaceSoft = Color(0xFFE8EDEB);
  static const Color surfaceFeature = Color(0xFFE3FCF7); // Mint highlight

  // Neutral Colors
  static const Color ink = Color(0xFF001E2B);
  static const Color charcoal = Color(0xFF3D4F58);
  static const Color slate = Color(0xFF5D6C74);
  static const Color steel = Color(0xFF889397);
  static const Color hairline = Color(0xFFE8EDEB);

  // Status Colors
  static const Color success = Color(0xFF00ED64);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(
    0xFFFFC107,
  ); // Light yellow for "Selecting" - matches theme
  static const Color booked = Color(
    0xFFEF5350,
  ); // Light coral red for "Booked" - soft and complements green
  static const Color available = Color(0xFF00ED64); // Seat available (Green)
}
