import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Système de typographie pour TrainLog
/// Utilise Google Fonts avec des polices modernes et lisibles
class AppTypography {
  // ===== POLICES PRINCIPALES =====

  /// Police principale - Inter (moderne et lisible)
  static const String primaryFont = 'Inter';

  /// Police secondaire - Nunito (pour les titres)
  static const String secondaryFont = 'NiveauGrotesk';

  /// Police monospace - pour les codes et numéros
  static const String monoFont = 'JetBrains Mono';

  // ===== THÈME DE TEXTE PRINCIPAL =====

  /// Thème de texte basé sur Inter
  static TextTheme get textTheme => GoogleFonts.interTextTheme();

  /// Thème de texte pour les titres (Nunito)
  static TextTheme get displayTextTheme => GoogleFonts.nunitoTextTheme();

  // ===== STYLES PRÉDÉFINIS =====

  /// Style pour les grands titres
  static TextStyle get displayLarge => GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        height: 1.2,
      );

  /// Style pour les titres moyens
  static TextStyle get displayMedium => GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        height: 1.3,
      );

  /// Style pour les petits titres
  static TextStyle get displaySmall => GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
      );

  /// Style pour les titres de section
  static TextStyle get headlineLarge => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
      );

  /// Style pour les sous-titres
  static TextStyle get headlineMedium => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.5,
      );

  /// Style pour les petits sous-titres
  static TextStyle get headlineSmall => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        height: 1.5,
      );

  /// Style pour le corps de texte principal
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.6,
      );

  /// Style pour le corps de texte moyen
  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.6,
      );

  /// Style pour le petit corps de texte
  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.6,
      );

  /// Style pour les labels
  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
      );

  /// Style pour les labels moyens
  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.4,
      );

  /// Style pour les petits labels
  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.4,
      );

  /// Style pour le texte monospace (codes, numéros)
  static TextStyle get mono => GoogleFonts.robotoMono(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.6,
      );

  // ===== STYLES SPÉCIALISÉS =====

  /// Style pour les numéros de train
  static TextStyle get trainNumber => GoogleFonts.robotoMono(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.4,
      );

  /// Style pour les noms de gares
  static TextStyle get stationName => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.25,
        height: 1.4,
      );

  /// Style pour les heures
  static TextStyle get time => GoogleFonts.robotoMono(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.3,
      );

  /// Style pour les statistiques
  static TextStyle get stats => GoogleFonts.nunito(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        height: 1.1,
      );

  /// Style pour les boutons
  static TextStyle get button => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
      );

  /// Style pour les cartes
  static TextStyle get cardTitle => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.4,
      );

  /// Style pour les descriptions de cartes
  static TextStyle get cardDescription => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.5,
      );

  // ===== MÉTHODES UTILITAIRES =====

  /// Applique une couleur au style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Applique une taille au style
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }

  /// Applique un poids au style
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// Applique un espacement des lettres au style
  static TextStyle withLetterSpacing(TextStyle style, double spacing) {
    return style.copyWith(letterSpacing: spacing);
  }
}
