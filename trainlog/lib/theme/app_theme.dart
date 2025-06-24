import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';

/// Thème principal de l'application TrainLog
/// Utilise le système de couleurs HSL et la typographie moderne
class AppTheme {
  /// Thème clair principal
  static ThemeData get lightTheme {
    return ThemeData(
      // ===== SCHÉMA DE COULEURS =====
      colorScheme: AppColors.lightColorScheme,
      useMaterial3: true,

      // ===== TYPOGRAPHIE =====
      textTheme: AppTypography.textTheme,
      primaryTextTheme: AppTypography.displayTextTheme,

      // ===== CARTES =====
      cardTheme: CardTheme(
        elevation: 2,
        shadowColor: AppColors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ===== BARRE D'APPLICATION =====
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.headlineMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(size: 24),
      ),

      // ===== NAVIGATION INFÉRIEURE =====
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AppTypography.labelMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),

      // ===== BOUTONS =====
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTypography.button,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTypography.button,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: AppTypography.button,
        ),
      ),

      // ===== CHAMPS DE TEXTE =====
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: AppTypography.labelLarge,
        hintStyle: AppTypography.bodyMedium,
        errorStyle: AppTypography.bodySmall,
      ),

      // ===== FLOATING ACTION BUTTON =====
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 6,
        shape: CircleBorder(),
      ),

      // ===== SNACKBAR =====
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: AppTypography.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ===== DIALOG =====
      dialogTheme: DialogTheme(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: AppTypography.headlineMedium,
        contentTextStyle: AppTypography.bodyMedium,
      ),

      // ===== DIVIDER =====
      dividerTheme: const DividerThemeData(
        thickness: 1,
        space: 1,
      ),

      // ===== ICONS =====
      iconTheme: const IconThemeData(size: 24),

      // ===== PROGRESS INDICATOR =====
      progressIndicatorTheme: const ProgressIndicatorThemeData(),

      // ===== CHIP =====
      chipTheme: ChipThemeData(
        labelStyle: AppTypography.labelMedium,
        secondaryLabelStyle: AppTypography.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // ===== LIST TILE =====
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        titleTextStyle: AppTypography.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        subtitleTextStyle: AppTypography.bodyMedium,
        leadingAndTrailingTextStyle: AppTypography.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Thème sombre
  static ThemeData get darkTheme {
    return ThemeData(
      // ===== SCHÉMA DE COULEURS =====
      colorScheme: AppColors.darkColorScheme,
      useMaterial3: true,

      // ===== TYPOGRAPHIE =====
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColors.white,
        displayColor: AppColors.white,
      ),
      primaryTextTheme: AppTypography.displayTextTheme.apply(
        bodyColor: AppColors.white,
        displayColor: AppColors.white,
      ),

      // ===== CARTES =====
      cardTheme: CardTheme(
        elevation: 2,
        shadowColor: AppColors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ===== BARRE D'APPLICATION =====
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.headlineMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(size: 24),
      ),

      // ===== NAVIGATION INFÉRIEURE =====
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AppTypography.labelMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),

      // ===== BOUTONS =====
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTypography.button,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTypography.button,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: AppTypography.button,
        ),
      ),

      // ===== CHAMPS DE TEXTE =====
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: AppTypography.labelLarge,
        hintStyle: AppTypography.bodyMedium,
        errorStyle: AppTypography.bodySmall,
      ),

      // ===== FLOATING ACTION BUTTON =====
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 6,
        shape: CircleBorder(),
      ),

      // ===== SNACKBAR =====
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: AppTypography.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ===== DIALOG =====
      dialogTheme: DialogTheme(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: AppTypography.headlineMedium,
        contentTextStyle: AppTypography.bodyMedium,
      ),

      // ===== DIVIDER =====
      dividerTheme: const DividerThemeData(
        thickness: 1,
        space: 1,
      ),

      // ===== ICONS =====
      iconTheme: const IconThemeData(size: 24),

      // ===== PROGRESS INDICATOR =====
      progressIndicatorTheme: const ProgressIndicatorThemeData(),

      // ===== CHIP =====
      chipTheme: ChipThemeData(
        labelStyle: AppTypography.labelMedium,
        secondaryLabelStyle: AppTypography.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // ===== LIST TILE =====
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        titleTextStyle: AppTypography.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        subtitleTextStyle: AppTypography.bodyMedium,
        leadingAndTrailingTextStyle: AppTypography.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
