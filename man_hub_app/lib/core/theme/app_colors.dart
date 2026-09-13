import 'package:flutter/material.dart';

class AppColors {
  // Construtor privado para evitar instanciação
  AppColors._();

  // Backgrounds
  static const Color backgroundMain = Color(0xFF040D1A);
  static const Color backgroundSecondary = Color(0xFF0A1E33);
  
  // Cards & Surfaces
  static const Color card = Color(0xFF071426);
  static const Color cardOpaque = Color(0xFF091A2E);
  static Color get cardBackground => backgroundSecondary.withValues(alpha: 0.5);
  static Color get cardBorder => neonPrimary.withValues(alpha: 0.3);
  static Color get cardBorderGlow => neonPrimary.withValues(alpha: 0.5);
  
  // Accents / Neon
  static const Color neonPrimary = Color(0xFF00BFFF);
  static const Color neonLight = Color(0xFF33CCFF);
  static const Color royalBlue = Color(0xFF005F9E);

  // Typography
  static const Color textPrimary = Color(0xFFE0E6EE);
  static const Color textSecondary = Color(0xFF8A9AAB); // Added a secondary text color for less important text
  
  // States & Actions
  static const Color error = Color(0xFFE57373);
  static const Color success = Color(0xFF81C784);
}
