import 'package:flutter/material.dart';

/// Nothing OS-inspired monochrome + red accent color palette.
class AppColors {
  AppColors._();

  // Background colors
  static const background = Color(0xFF000000);
  static const surface = Color(0xFF0D0D0D);
  static const surfaceLight = Color(0xFF1A1A1A);
  static const card = Color(0xFF0D0D0D);

  // Accent colors
  static const accent = Color(0xFFD72638);
  static const accentLight = Color(0xFFE8485A);
  static const primary = Color(0xFF1A1A1A);
  static const primaryLight = Color(0xFF2A2A2A);

  // Text colors
  static const textPrimary = Color(0xFFEDEDED);
  static const textSecondary = Color(0xFF8C8C8C);
  static const textMuted = Color(0xFF555555);

  // Status colors
  static const success = Color(0xFF4CAF7D);
  static const danger = Color(0xFFD72638);
  static const warning = Color(0xFFD4A843);
  static const info = Color(0xFF5B9BD5);

  // Category colors (muted/desaturated for AMOLED black)
  static const categoryColors = [
    Color(0xFFD72638),
    Color(0xFF4CAF7D),
    Color(0xFFD4A843),
    Color(0xFF5B9BD5),
    Color(0xFFCC5A5A),
    Color(0xFF3DAA6D),
    Color(0xFF8A7FBF),
    Color(0xFFCC7A3D),
  ];
}
