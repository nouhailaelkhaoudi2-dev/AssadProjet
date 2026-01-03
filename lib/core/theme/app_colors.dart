import 'package:flutter/material.dart';

/// Palette de couleurs de l'application CAN 2025 Morocco
/// Inspirée des couleurs du drapeau marocain et de l'identité visuelle de la CAN
class AppColors {
  AppColors._();

  // Couleurs principales
  static const Color primary = Color(0xFFC8102E); // Rouge Maroc
  static const Color primaryDark = Color(0xFF8B0000); // Rouge foncé
  static const Color primaryLight = Color(0xFFE63946); // Rouge clair

  // Couleurs secondaires
  static const Color secondary = Color(0xFF006233); // Vert Maroc
  static const Color secondaryDark = Color(0xFF004D26);
  static const Color secondaryLight = Color(0xFF00875A);

  // Couleur d'accent (Or)
  static const Color accent = Color(0xFFC9A227); // Or/Jaune
  static const Color accentLight = Color(0xFFFFD700);

  // Couleurs de fond
  static const Color background = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF1A1F25);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2D3239);

  // Couleurs de texte
  static const Color textPrimary = Color(0xFF1A1F25);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Couleurs sémantiques
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
  static const Color info = Color(0xFF17A2B8);

  // Couleurs pour les équipes (sentiment)
  static const Color positive = Color(0xFF4CAF50);
  static const Color neutral = Color(0xFF9E9E9E);
  static const Color negative = Color(0xFFF44336);

  // Couleurs de cartes et bordures
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFE0E0E0);

  // Dégradés
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryDark],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundDark, Color(0xFF0D1117)],
  );
}
