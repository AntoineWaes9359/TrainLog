# Localisation de l'application TrainLog

Ce dossier contient les fichiers de traduction pour l'internationalisation de l'application.

## Fichiers de traduction

- `app_fr.arb` : Traductions françaises
- `app_en.arb` : Traductions anglaises

## Support multi-régions

L'application supporte maintenant **6 langues courantes en EU/US** avec leurs formats de date respectifs :

| Langue | Code | Format de date | Exemple |
|--------|------|----------------|---------|
| Français | `fr` | `dd/MM/yyyy` | `15/01/2024` |
| Anglais (US) | `en` | `MM/dd/yyyy` | `01/15/2024` |
| Allemand | `de` | `dd.MM.yyyy` | `15.01.2024` |
| Espagnol | `es` | `dd/MM/yyyy` | `15/01/2024` |
| Italien | `it` | `dd/MM/yyyy` | `15/01/2024` |
| Néerlandais | `nl` | `dd-MM-yyyy` | `15-01-2024` |

## Clés de traduction par écran

### Écran principal (home_screen)
- `homeTitle` : Titre de l'écran principal
- `upcomingTrips` : Onglet "Prochains trajets"
- `history` : Onglet "Historique"
- `stats` : Onglet "Statistiques"
- `profile` : Onglet "Profil"

### Écran des prochains trajets (upcoming_screen)
- `upcomingTitle` : Titre de l'écran
- `noUpcomingTrips` : Message quand il n'y a pas de trajets à venir
- `addYourFirstTrip` : Message d'aide pour ajouter le premier trajet
- `nextTrip` : Titre de la section "Prochain trajet"
- `departure` : Label "Départ"
- `arrival` : Label "Arrivée"
- `trainNumber` : Label "Numéro de train"
- `trainType` : Label "Type de train"
- `departureTime` : Label "Heure de départ"
- `arrivalTime` : Label "Heure d'arrivée"
- `departureStation` : Label "Gare de départ"
- `arrivalStation` : Label "Gare d'arrivée"
- `upcomingTripsList` : Titre de la section "Trajets à venir"

### Écran de détails du trajet (trip_detail_screen)
- `tripDetails` : Titre de l'écran
- `departure` : Label "Départ"
- `arrival` : Label "Arrivée"
- `trainNumber` : Label "Numéro de train"
- `trainType` : Label "Type de train"
- `departureTime` : Label "Heure de départ"
- `arrivalTime` : Label "Heure d'arrivée"
- `departureStation` : Label "Gare de départ"
- `arrivalStation` : Label "Gare d'arrivée"
- `deleteTrip` : Bouton "Supprimer le trajet"
- `deleteTripConfirmation` : Message de confirmation de suppression
- `cancel` : Bouton "Annuler"
- `confirm` : Bouton "Confirmer"
- `tripDeleted` : Message de succès après suppression
- `errorDeletingTrip` : Message d'erreur lors de la suppression

### Écran de profil (profile_screen)
- `profileTitle` : Titre de l'écran
- `account` : Section "Compte"
- `personalInfo` : Section "Informations personnelles"
- `settings` : Section "Paramètres"
- `logout` : Bouton "Se déconnecter"
- `logoutConfirmation` : Message de confirmation de déconnexion
- `cancel` : Bouton "Annuler"
- `confirm` : Bouton "Confirmer"

### Écran historique (history_screen)
- `historyTitle` : Titre de l'écran historique
- `noTripsInHistory` : Message quand il n'y a pas de trajets dans l'historique
- `pastTripsWillAppearHere` : Message d'aide pour l'historique vide

### Écran statistiques (stats_screen)
- `statsTitle` : Titre de l'écran statistiques
- `allTime` : Période "TOUT" (toutes les années)
- `trains` : Label "TRAINS"
- `distance` : Label "DISTANCE"
- `kilometers` : Unité "km"
- `time` : Label "TEMPS"
- `stations` : Label "GARES"
- `companies` : Label "COMPAGNIES"
- `mostRiddenTrain` : Titre "Train le plus fréquenté"
- `trip` : Singulier "trajet"
- `trips` : Pluriel "trajets"
- `allTrains` : Bouton "Tous les trains"
- `quickInfo` : Titre "Informations rapides"
- `totalDistance` : Titre "Distance totale"
- `totalDistanceDescription` : Description de la distance totale
- `timeInTrain` : Titre "Temps en train"
- `timeInTrainDescription` : Description du temps en train
- `visitedStations` : Titre "Gares visitées"
- `visitedStationsDescription` : Description des gares visitées
- `stationsCount` : Format "{count} gares" avec placeholder
- `personalRecord` : Titre "Record personnel"
- `longestTrip` : Sous-titre "Trajet le plus long"
- `personalRecordDescription` : Description des records personnels
- `stationsList` : Message "Liste des gares visitées"
- `travelRecords` : Message "Vos records de voyage"

### Impact carbone (carbon_footprint)
- `carbonFootprint` : Titre de la section impact carbone
- `co2Emissions` : Label "Émissions CO₂"
- `co2Saved` : Label "CO₂ économisé"
- `comparedToCar` : Texte "par rapport à la voiture"
- `comparedToPlane` : Texte "par rapport à l'avion"
- `lowImpact` : Message pour impact carbone faible
- `moderateImpact` : Message pour impact carbone modéré
- `highImpact` : Message pour impact carbone élevé

## Utilisation

Pour utiliser les traductions dans le code :

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Dans un widget
final l10n = AppLocalizations.of(context)!;
Text(l10n.homeTitle)
```

## Génération des fichiers

Après avoir modifié les fichiers ARB, exécutez :

```bash
flutter gen-l10n
```

## Formatage des dates

Utilisez la classe `DateFormatter` pour formater les dates selon la langue et la région :

```dart
import '../utils/date_formatter.dart';

// Format court selon la région : "15/01/2024" / "01/15/2024" / "15.01.2024"
DateFormatter.formatShortDateOnly(context, date)

// Format avec jour : "lun 15 jan" / "Mon Jan 15"
DateFormatter.formatShortDate(context, date)

// Format complet : "lundi 15 janvier 2024" / "Monday January 15, 2024"
DateFormatter.formatFullDate(context, date)

// Heure selon la région : "14:30" / "2:30 PM"
DateFormatter.formatTime(context, date)

// Date + heure : "15/01/2024 14:30" / "01/15/2024 2:30 PM"
DateFormatter.formatShortDateWithTime(context, date)
```

## Formats régionaux supportés

### Dates
- **Format européen standard** (`dd/MM/yyyy`) : France, Espagne, Italie
- **Format américain** (`MM/dd/yyyy`) : États-Unis
- **Format allemand** (`dd.MM.yyyy`) : Allemagne
- **Format néerlandais** (`dd-MM-yyyy`) : Pays-Bas

### Heures
- **Format 24h** : Tous les pays européens
- **Format 12h** : États-Unis (avec AM/PM)

## Extensibilité

Pour ajouter une nouvelle langue :

1. Ajouter le cas dans `DateFormatter._getLocaleCode()`
2. Définir le format de date approprié dans `formatShortDateOnly()`
3. Ajouter les traductions dans les fichiers ARB
4. Mettre à jour cette documentation

## Tests

Des tests sont disponibles dans `utils/date_formatter_test.dart` pour vérifier le bon fonctionnement des formats régionaux.