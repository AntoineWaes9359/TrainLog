// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'TrainLog';

  @override
  String get navigationTrips => 'Trajets';

  @override
  String get navigationHistory => 'Historique';

  @override
  String get navigationStats => 'Stats';

  @override
  String get navigationProfile => 'Profil';

  @override
  String get upcomingTitle => 'À venir';

  @override
  String get nextTripTitle => 'Prochain trajet';

  @override
  String get timeUnitHours => 'HEURES';

  @override
  String get timeUnitDays => 'JOURS';

  @override
  String get copiedToClipboard => 'Copié dans le presse-papier';

  @override
  String get editSeatTitle => 'Modifier le siège';

  @override
  String get seatNumberLabel => 'Numéro de siège';

  @override
  String get seatNumberHint => 'Ex: 12A';

  @override
  String get cancelButton => 'Annuler';

  @override
  String get saveButton => 'Enregistrer';

  @override
  String get deleteTripTitle => 'Supprimer le trajet';

  @override
  String get deleteTripConfirmation => 'Êtes-vous sûr de vouloir supprimer ce trajet ?';

  @override
  String get deleteButton => 'Supprimer';

  @override
  String get departureLabel => 'Départ';

  @override
  String get arrivalLabel => 'Arrivée';

  @override
  String get distanceLabel => 'Distance';

  @override
  String get durationLabel => 'Durée';

  @override
  String get trainNumberLabel => 'Numéro de train';

  @override
  String get ticketNumberLabel => 'Numéro de billet';

  @override
  String get seatLabel => 'Siège';

  @override
  String get dossierLabel => 'Dossier';

  @override
  String get copyButton => 'COPIER';

  @override
  String get pasteButton => 'COLLER';

  @override
  String get tapToEdit => 'Tap to Edit';

  @override
  String get classLabel => 'Classe';

  @override
  String get carLabel => 'Voiture';

  @override
  String get informationTitle => 'Informations';

  @override
  String get trainInfoLabel => 'Train';

  @override
  String get dateInfoLabel => 'Date';

  @override
  String get durationInfoLabel => 'Durée';

  @override
  String get distanceInfoLabel => 'Distance';

  @override
  String get myHistoryTitle => 'Mon historique sur ce trajet';

  @override
  String get tripsLabel => 'Trajets';

  @override
  String get travelTimeLabel => 'Temps de trajet';

  @override
  String get dossierNumberHint => 'Numéro de dossier';

  @override
  String get seatNumberEditHint => 'Numéro de siège (ex: 12A)';

  @override
  String get secondClass => 'Seconde';

  @override
  String get firstClass => 'Première';

  @override
  String get businessClass => 'Business';

  @override
  String get saveChangesButton => 'Sauvegarder';

  @override
  String get bookingDetailsTitle => 'Détails de réservation';

  @override
  String get profileTitle => 'Profil';

  @override
  String get defaultUserName => 'Utilisateur';

  @override
  String get logoutButton => 'Déconnexion';

  @override
  String logoutError(String error) {
    return 'Erreur lors de la déconnexion: $error';
  }

  @override
  String get carbonFootprintTitle => 'Impact carbone';

  @override
  String get trainEmissions => 'Train';

  @override
  String get carEmissions => 'Voiture';

  @override
  String get planeEmissions => 'Avion';

  @override
  String get carbonSavings => 'Économies CO₂';

  @override
  String get moderateImpact => 'Impact carbone modéré pour ce trajet';

  @override
  String get historyTitle => 'Historique';

  @override
  String get noTripsInHistory => 'Aucun trajet dans l\'historique';

  @override
  String get pastTripsWillAppearHere => 'Vos trajets passés apparaîtront ici';

  @override
  String get statsTitle => 'Statistiques';

  @override
  String get allTime => 'TOUT';

  @override
  String get trains => 'TRAINS';

  @override
  String get distance => 'DISTANCE';

  @override
  String get kilometers => 'km';

  @override
  String get time => 'TEMPS';

  @override
  String get stations => 'GARES';

  @override
  String get companies => 'COMPAGNIES';

  @override
  String get mostRiddenTrain => 'Train le plus fréquenté';

  @override
  String get trip => 'trajet';

  @override
  String get trips => 'trajets';

  @override
  String get allTrains => 'Tous les trains';

  @override
  String get quickInfo => 'Informations rapides';

  @override
  String get totalDistance => 'Distance totale';

  @override
  String get totalDistanceDescription => 'Cumul de tous vos trajets';

  @override
  String get timeInTrain => 'Temps en train';

  @override
  String get timeInTrainDescription => 'Durée totale de vos voyages';

  @override
  String get visitedStations => 'Gares visitées';

  @override
  String get visitedStationsDescription => 'Nombre de gares uniques';

  @override
  String stationsCount(int count) {
    return '$count gares';
  }

  @override
  String get personalRecord => 'Record personnel';

  @override
  String get longestTrip => 'Trajet le plus long';

  @override
  String get personalRecordDescription => 'Découvrez vos records';

  @override
  String get stationsList => 'Liste des gares visitées';

  @override
  String get travelRecords => 'Vos records de voyage';

  @override
  String get countdownTitle => 'Compte à rebours';

  @override
  String get countdownDays => 'JOURS';

  @override
  String get countdownHours => 'HEURES';

  @override
  String get countdownMinutes => 'MINUTES';

  @override
  String get ticketInfoTitle => 'Infos billet';

  @override
  String get notProvided => 'Non fourni';

  @override
  String get deleteConfirmationTitle => 'Confirmation de suppression';

  @override
  String get deleteConfirmationMessage => 'Êtes-vous sûr de vouloir supprimer ce trajet ? Cette action est irréversible.';

  @override
  String get deleteTripButton => 'Supprimer le trajet';
}
