# Utilitaires TrainLog

Ce dossier contient les utilitaires réutilisables de l'application.

## DateFormatter

Classe utilitaire pour formater les dates selon la langue et la région de l'utilisateur.

### Langues et régions supportées

L'application supporte 6 langues courantes en EU/US avec leurs formats de date respectifs :

| Langue | Code | Locale | Format de date | Exemple |
|--------|------|--------|----------------|---------|
| Français | `fr` | `fr_FR` | `dd/MM/yyyy` | `15/01/2024` |
| Anglais (US) | `en` | `en_US` | `MM/dd/yyyy` | `01/15/2024` |
| Allemand | `de` | `de_DE` | `dd.MM.yyyy` | `15.01.2024` |
| Espagnol | `es` | `es_ES` | `dd/MM/yyyy` | `15/01/2024` |
| Italien | `it` | `it_IT` | `dd/MM/yyyy` | `15/01/2024` |
| Néerlandais | `nl` | `nl_NL` | `dd-MM-yyyy` | `15-01-2024` |

### Méthodes disponibles

#### `formatShortDateOnly(context, date)`
Formate une date au format court selon la région.
```dart
// Français: "15/01/2024"
// Anglais US: "01/15/2024"
// Allemand: "15.01.2024"
// Néerlandais: "15-01-2024"
DateFormatter.formatShortDateOnly(context, date)
```

#### `formatShortDate(context, date)`
Formate une date avec le jour de la semaine.
```dart
// Français: "lun 15 jan"
// Anglais US: "Mon Jan 15"
DateFormatter.formatShortDate(context, date)
```

#### `formatShortDateTime(context, date)`
Formate une date avec l'heure.
```dart
// Français: "lun 15 jan, 14:30"
// Anglais US: "Mon Jan 15, 2:30 PM"
DateFormatter.formatShortDateTime(context, date)
```

#### `formatFullDate(context, date)`
Formate une date complète.
```dart
// Français: "lundi 15 janvier 2024"
// Anglais US: "Monday January 15, 2024"
DateFormatter.formatFullDate(context, date)
```

#### `formatFullDateTime(context, date)`
Formate une date complète avec l'heure.
```dart
// Français: "lundi 15 janvier 2024 14:30"
// Anglais US: "Monday January 15, 2024 2:30 PM"
DateFormatter.formatFullDateTime(context, date)
```

#### `formatTime(context, date)`
Formate l'heure selon la région.
```dart
// Européen: "14:30" (format 24h)
// US: "2:30 PM" (format 12h)
DateFormatter.formatTime(context, date)
```

#### `formatShortDateWithTime(context, date)`
Combine date courte et heure.
```dart
// Français: "15/01/2024 14:30"
// Anglais US: "01/15/2024 2:30 PM"
// Allemand: "15.01.2024 14:30"
DateFormatter.formatShortDateWithTime(context, date)
```

#### `formatMonth(context, date)`
Retourne le nom du mois.
```dart
// Français: "janvier"
// Anglais US: "January"
DateFormatter.formatMonth(context, date)
```

#### `formatDay(context, date)`
Retourne le nom complet du jour.
```dart
// Français: "lundi"
// Anglais US: "Monday"
DateFormatter.formatDay(context, date)
```

#### `formatShortDay(context, date)`
Retourne le nom court du jour.
```dart
// Français: "lun"
// Anglais US: "Mon"
DateFormatter.formatShortDay(context, date)
```

### Utilisation

```dart
import '../utils/date_formatter.dart';

// Dans un widget
final date = DateTime.now();
Text(DateFormatter.formatShortDateOnly(context, date))
```

### Extensibilité

Pour ajouter une nouvelle langue :

1. Ajouter le cas dans `_getLocaleCode()`
2. Définir le format de date approprié dans `formatShortDateOnly()`
3. Ajouter les traductions dans les fichiers ARB
4. Mettre à jour cette documentation

### Formats régionaux

- **Format européen standard** (`dd/MM/yyyy`) : France, Espagne, Italie
- **Format américain** (`MM/dd/yyyy`) : États-Unis
- **Format allemand** (`dd.MM.yyyy`) : Allemagne
- **Format néerlandais** (`dd-MM-yyyy`) : Pays-Bas

### Heures

- **Format 24h** : Tous les pays européens
- **Format 12h** : États-Unis (avec AM/PM) 