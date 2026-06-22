import 'package:flutter/material.dart';

/// Dark neumorphism color palette — dark gray base with soft directional shadows.
/// Nothing red accent retained; ~80% AMOLED benefit vs pure black.
class AppColors {
  AppColors._();

  // Background colors — dark gray base (neumorphic surface)
  static const background = Color(0xFF1C1C2C);
  static const surface = Color(0xFF222233);
  static const surfaceLight = Color(0xFF292940);
  static const card = Color(0xFF1C1C2C);

  // Neumorphic shadows
  static const shadowLight = Color(0xFF2E2E40); // top-left highlight
  static const shadowDark = Color(0xFF0A0A14);  // bottom-right depth

  // Accent colors — Nothing red, unchanged
  static const accent = Color(0xFFD72638);
  static const accentLight = Color(0xFFE8485A);
  static const primary = Color(0xFF292940);
  static const primaryLight = Color(0xFF333348);

  // Text colors
  static const textPrimary = Color(0xFFEDEDED);
  static const textSecondary = Color(0xFF8C8C8C);
  static const textMuted = Color(0xFF555555);

  // Status colors
  static const success = Color(0xFF4CAF7D);
  static const danger = Color(0xFFD72638);
  static const warning = Color(0xFFD4A843);
  static const info = Color(0xFF5B9BD5);

  // Category colors (muted/desaturated)
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
