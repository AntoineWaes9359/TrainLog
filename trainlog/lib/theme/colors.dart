import 'package:flutter/material.dart';

/// Système de couleurs HSL moderne pour TrainLog
/// Basé sur une palette verte naturelle et moderne
class AppColors {
  // ===== COULEURS DE BASE HSL =====

  /// Couleur de texte principale - Vert très foncé
  static const Color text = Color(0xFF040b07); // hsl(146, 47%, 3%)

  /// Couleur de fond principale - Vert très clair
  static const Color background = Color(0xFFfbfefc); // hsl(140, 60%, 99%)

  /// Couleur primaire - Vert vif
  static const Color primary = Color(0xFF40c975); // hsl(143, 56%, 52%)

  /// Couleur secondaire - Vert clair
  static const Color secondary = Color(0xFF82e3a7); // hsl(143, 63%, 70%)

  /// Couleur d'accent - Vert lumineux
  static const Color accent = Color(0xFF66e597); // hsl(143, 71%, 65%)

  // ===== COULEURS DE TEXTE SUR FOND =====

  /// Couleur de texte sur fond primaire
  static const Color primaryFg = Color(0xFF040b07); // hsl(146, 47%, 3%)

  /// Couleur de texte sur fond secondaire
  static const Color secondaryFg = Color(0xFF040b07); // hsl(146, 47%, 3%)

  /// Couleur de texte sur fond accent
  static const Color accentFg = Color(0xFF040b07); // hsl(146, 47%, 3%)

  // ===== COULEURS UTILITAIRES =====

  /// Blanc pur
  static const Color white = Color(0xFFFFFFFF);

  /// Noir pur
  static const Color black = Color(0xFF000000);

  /// Gris très clair
  static const Color light = Color(0xFFF5F5F5);

  /// Gris moyen
  static const Color gray = Color(0xFF9E9E9E);

  /// Gris foncé
  static const Color dark = Color(0xFF424242);

  /// Rouge d'erreur
  static const Color error = Color(0xFFB3261E);

  /// Rouge d'erreur clair
  static const Color errorLight = Color(0xFFF2B8B5);

  // ===== COULEURS SPÉCIFIQUES AUX TRAINS =====

  /// Couleur pour TGV (basée sur la primaire)
  static const Color tgv = Color(0xFF40c975);

  /// Couleur pour Ouigo (basée sur la secondaire)
  static const Color ouigo = Color(0xFF82e3a7);

  /// Couleur pour TER (basée sur l'accent)
  static const Color ter = Color(0xFF66e597);

  /// Couleur pour autres types de train
  static const Color other = Color(0xFF9E9E9E);

  // ===== DÉGRADÉS =====

  /// Dégradé linéaire primaire vers secondaire
  static const LinearGradient linearPrimarySecondary = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dégradé linéaire primaire vers accent
  static const LinearGradient linearPrimaryAccent = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dégradé linéaire secondaire vers accent
  static const LinearGradient linearSecondaryAccent = LinearGradient(
    colors: [secondary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dégradé radial primaire vers secondaire
  static const RadialGradient radialPrimarySecondary = RadialGradient(
    colors: [primary, secondary],
    center: Alignment.center,
    radius: 1.0,
  );

  /// Dégradé radial primaire vers accent
  static const RadialGradient radialPrimaryAccent = RadialGradient(
    colors: [primary, accent],
    center: Alignment.center,
    radius: 1.0,
  );

  /// Dégradé radial secondaire vers accent
  static const RadialGradient radialSecondaryAccent = RadialGradient(
    colors: [secondary, accent],
    center: Alignment.center,
    radius: 1.0,
  );

  // ===== SCHEMAS DE COULEURS MATERIAL 3 =====

  /// Schéma de couleurs Material 3 pour le thème clair
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: white,
    secondary: secondary,
    onSecondary: white,
    tertiary: accent,
    onTertiary: white,
    error: error,
    onError: white,
    background: background,
    onBackground: text,
    surface: white,
    onSurface: text,
    surfaceVariant: light,
    onSurfaceVariant: dark,
    outline: gray,
    outlineVariant: light,
    shadow: black,
    scrim: black,
    inverseSurface: dark,
    onInverseSurface: white,
    inversePrimary: accent,
    surfaceDim: light,
    surfaceBright: white,
    surfaceContainerLowest: white,
    surfaceContainerLow: light,
    surfaceContainer: light,
    surfaceContainerHigh: gray,
    surfaceContainerHighest: dark,
  );

  /// Schéma de couleurs Material 3 pour le thème sombre
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primary,
    onPrimary: white,
    secondary: secondary,
    onSecondary: white,
    tertiary: accent,
    onTertiary: white,
    error: error,
    onError: white,
    background: Color(0xFF121212),
    onBackground: white,
    surface: Color(0xFF1E1E1E),
    onSurface: white,
    surfaceVariant: Color(0xFF2A2A2A),
    onSurfaceVariant: Color(0xFFCCCCCC),
    outline: Color(0xFF666666),
    outlineVariant: Color(0xFF444444),
    shadow: black,
    scrim: black,
    inverseSurface: white,
    onInverseSurface: black,
    inversePrimary: accent,
    surfaceDim: Color(0xFF121212),
    surfaceBright: Color(0xFF2A2A2A),
    surfaceContainerLowest: Color(0xFF0A0A0A),
    surfaceContainerLow: Color(0xFF1A1A1A),
    surfaceContainer: Color(0xFF1E1E1E),
    surfaceContainerHigh: Color(0xFF2A2A2A),
    surfaceContainerHighest: Color(0xFF333333),
  );

  // ===== MÉTHODES UTILITAIRES =====

  /// Retourne une couleur avec opacité
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// Retourne une couleur plus claire
  static Color lighter(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  /// Retourne une couleur plus foncée
  static Color darker(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}
