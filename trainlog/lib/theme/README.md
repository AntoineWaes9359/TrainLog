# Système de Design TrainLog

Ce dossier contient le système de design complet de l'application TrainLog, basé sur des couleurs HSL modernes et une typographie cohérente.

## Structure

- `colors.dart` : Système de couleurs HSL
- `typography.dart` : Système de typographie
- `app_theme.dart` : Thème Material 3 complet

## Système de Couleurs HSL

### Couleurs de Base

Le système utilise une palette verte naturelle et moderne basée sur HSL :

| Couleur | HSL | Hex | Usage |
|---------|-----|-----|-------|
| `text` | hsl(146, 47%, 3%) | `#040b07` | Texte principal |
| `background` | hsl(140, 60%, 99%) | `#fbfefc` | Fond principal |
| `primary` | hsl(143, 56%, 52%) | `#40c975` | Couleur primaire |
| `secondary` | hsl(143, 63%, 70%) | `#82e3a7` | Couleur secondaire |
| `accent` | hsl(143, 71%, 65%) | `#66e597` | Couleur d'accent |

### Couleurs Utilitaires

- `white` : Blanc pur (`#FFFFFF`)
- `black` : Noir pur (`#000000`)
- `light` : Gris très clair (`#F5F5F5`)
- `gray` : Gris moyen (`#9E9E9E`)
- `dark` : Gris foncé (`#424242`)
- `error` : Rouge d'erreur (`#B3261E`)

### Couleurs de Texte sur Fond

- `primaryFg` : Texte sur fond primaire
- `secondaryFg` : Texte sur fond secondaire
- `accentFg` : Texte sur fond accent

### Dégradés

Le système inclut des dégradés prédéfinis :

- `linearPrimarySecondary` : Dégradé linéaire primaire → secondaire
- `linearPrimaryAccent` : Dégradé linéaire primaire → accent
- `linearSecondaryAccent` : Dégradé linéaire secondaire → accent
- `radialPrimarySecondary` : Dégradé radial primaire → secondaire
- `radialPrimaryAccent` : Dégradé radial primaire → accent
- `radialSecondaryAccent` : Dégradé radial secondaire → accent

### Méthodes Utilitaires

```dart
// Appliquer une opacité
AppColors.withOpacity(AppColors.primary, 0.5)

// Éclaircir une couleur
AppColors.lighter(AppColors.primary, 0.1)

// Assombrir une couleur
AppColors.darker(AppColors.primary, 0.1)
```

## Système de Typographie

### Polices Principales

- **Inter** : Police principale (corps de texte, labels)
- **Nunito** : Police secondaire (titres, statistiques)
- **Roboto Mono** : Police monospace (numéros, codes)

### Styles Prédefinis

#### Titres
- `displayLarge` : Grands titres (32px, Nunito)
- `displayMedium` : Titres moyens (28px, Nunito)
- `displaySmall` : Petits titres (24px, Nunito)
- `headlineLarge` : Titres de section (22px, Inter)
- `headlineMedium` : Sous-titres (18px, Inter)
- `headlineSmall` : Petits sous-titres (16px, Inter)

#### Corps de Texte
- `bodyLarge` : Corps principal (16px, Inter)
- `bodyMedium` : Corps moyen (14px, Inter)
- `bodySmall` : Petit corps (12px, Inter)

#### Labels
- `labelLarge` : Labels grands (14px, Inter)
- `labelMedium` : Labels moyens (12px, Inter)
- `labelSmall` : Labels petits (10px, Inter)

#### Styles Spécialisés
- `trainNumber` : Numéros de train (12px, Roboto Mono)
- `stationName` : Noms de gares (16px, Inter)
- `time` : Heures (18px, Roboto Mono)
- `stats` : Statistiques (36px, Nunito)
- `button` : Boutons (14px, Inter)
- `cardTitle` : Titres de cartes (18px, Inter)
- `cardDescription` : Descriptions de cartes (14px, Inter)

### Méthodes Utilitaires

```dart
// Appliquer une couleur
AppTypography.withColor(AppTypography.headlineLarge, AppColors.primary)

// Modifier la taille
AppTypography.withSize(AppTypography.bodyMedium, 18)

// Modifier le poids
AppTypography.withWeight(AppTypography.bodyLarge, FontWeight.w600)

// Modifier l'espacement
AppTypography.withLetterSpacing(AppTypography.headlineMedium, 0.5)
```

## Thème Material 3

Le thème utilise Material 3 avec :

- **ColorScheme** : Basé sur les couleurs HSL
- **Typography** : Basé sur Inter et Nunito
- **Composants** : Cartes, boutons, champs de texte, etc.

### Composants Stylisés

#### Cartes
- Fond blanc avec ombre légère
- Coins arrondis (16px)
- Marges automatiques

#### Boutons
- **Elevated** : Fond primaire, texte primaireFg
- **Outlined** : Bordure primaire, texte primaire
- **Text** : Texte primaire uniquement

#### Champs de Texte
- Fond gris clair
- Bordure primaire au focus
- Coins arrondis (12px)

#### Navigation
- **AppBar** : Fond background, texte text
- **BottomNavigation** : Fond blanc, sélection primaire

## Utilisation

### Dans un Widget

```dart
import 'package:trainlog/theme/colors.dart';
import 'package:trainlog/theme/typography.dart';

class MonWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Text(
        'Mon texte',
        style: AppTypography.headlineMedium.copyWith(
          color: AppColors.text,
        ),
      ),
    );
  }
}
```

### Avec le Thème

```dart
import 'package:trainlog/theme/app_theme.dart';

MaterialApp(
  theme: AppTheme.lightTheme,
  // ...
)
```

## Avantages du Système

1. **Cohérence** : Couleurs et typographie uniformes
2. **Maintenabilité** : Centralisé et facile à modifier
3. **Accessibilité** : Contraste approprié
4. **Modernité** : Basé sur HSL et Material 3
5. **Extensibilité** : Facile d'ajouter de nouvelles couleurs/styles

## Extensibilité

### Ajouter une Couleur

```dart
// Dans colors.dart
static const Color newColor = Color(0xFF123456); // hsl(x, y%, z%)
```

### Ajouter un Style

```dart
// Dans typography.dart
static TextStyle get newStyle => GoogleFonts.inter(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  letterSpacing: 0.25,
  height: 1.5,
);
```

## Bonnes Pratiques

1. **Utiliser les couleurs prédéfinies** : Ne pas créer de nouvelles couleurs
2. **Utiliser les styles prédéfinis** : Ne pas créer de nouveaux styles
3. **Respecter la hiérarchie** : Utiliser les bons niveaux de titre
4. **Maintenir le contraste** : Vérifier l'accessibilité
5. **Documenter les changements** : Mettre à jour cette documentation 