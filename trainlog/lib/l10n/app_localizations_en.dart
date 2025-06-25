// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TrainLog';

  @override
  String get navigationTrips => 'Trips';

  @override
  String get navigationHistory => 'History';

  @override
  String get navigationStats => 'Stats';

  @override
  String get navigationProfile => 'Profile';

  @override
  String get upcomingTitle => 'Upcoming';

  @override
  String get nextTripTitle => 'Next trip';

  @override
  String get timeUnitHours => 'HOURS';

  @override
  String get timeUnitDays => 'DAYS';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get editSeatTitle => 'Edit seat';

  @override
  String get seatNumberLabel => 'Seat number';

  @override
  String get seatNumberHint => 'Ex: 12A';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get saveButton => 'Save';

  @override
  String get deleteTripTitle => 'Delete trip';

  @override
  String get deleteTripConfirmation => 'Are you sure you want to delete this trip?';

  @override
  String get deleteButton => 'Delete';

  @override
  String get departureLabel => 'Departure';

  @override
  String get arrivalLabel => 'Arrival';

  @override
  String get distanceLabel => 'Distance';

  @override
  String get durationLabel => 'Duration';

  @override
  String get trainNumberLabel => 'Train number';

  @override
  String get ticketNumberLabel => 'Ticket number';

  @override
  String get seatLabel => 'Seat';

  @override
  String get dossierLabel => 'File';

  @override
  String get copyButton => 'COPY';

  @override
  String get pasteButton => 'PASTE';

  @override
  String get tapToEdit => 'Tap to Edit';

  @override
  String get classLabel => 'Class';

  @override
  String get carLabel => 'Car';

  @override
  String get informationTitle => 'Information';

  @override
  String get trainInfoLabel => 'Train';

  @override
  String get dateInfoLabel => 'Date';

  @override
  String get durationInfoLabel => 'Duration';

  @override
  String get distanceInfoLabel => 'Distance';

  @override
  String get myHistoryTitle => 'My history on this route';

  @override
  String get tripsLabel => 'Trips';

  @override
  String get travelTimeLabel => 'Travel time';

  @override
  String get dossierNumberHint => 'File number';

  @override
  String get seatNumberEditHint => 'Seat number (ex: 12A)';

  @override
  String get secondClass => 'Second';

  @override
  String get firstClass => 'First';

  @override
  String get businessClass => 'Business';

  @override
  String get saveChangesButton => 'Save';

  @override
  String get bookingDetailsTitle => 'Booking details';

  @override
  String get profileTitle => 'Profile';

  @override
  String get defaultUserName => 'User';

  @override
  String get logoutButton => 'Logout';

  @override
  String logoutError(String error) {
    return 'Error during logout: $error';
  }

  @override
  String get carbonFootprintTitle => 'Carbon footprint';

  @override
  String get trainEmissions => 'Train';

  @override
  String get carEmissions => 'Car';

  @override
  String get planeEmissions => 'Plane';

  @override
  String get carbonSavings => 'CO₂ savings';

  @override
  String get moderateImpact => 'Moderate carbon impact for this trip';

  @override
  String get historyTitle => 'History';

  @override
  String get noTripsInHistory => 'No trips in history';

  @override
  String get pastTripsWillAppearHere => 'Your past trips will appear here';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get allTime => 'ALL';

  @override
  String get trains => 'TRAINS';

  @override
  String get distance => 'DISTANCE';

  @override
  String get kilometers => 'km';

  @override
  String get time => 'TIME';

  @override
  String get stations => 'STATIONS';

  @override
  String get companies => 'COMPANIES';

  @override
  String get mostRiddenTrain => 'Most ridden train';

  @override
  String get trip => 'trip';

  @override
  String get trips => 'trips';

  @override
  String get allTrains => 'All trains';

  @override
  String get quickInfo => 'Quick information';

  @override
  String get totalDistance => 'Total distance';

  @override
  String get totalDistanceDescription => 'Sum of all your trips';

  @override
  String get timeInTrain => 'Time in train';

  @override
  String get timeInTrainDescription => 'Total duration of your journeys';

  @override
  String get visitedStations => 'Visited stations';

  @override
  String get visitedStationsDescription => 'Number of unique stations';

  @override
  String stationsCount(int count) {
    return '$count stations';
  }

  @override
  String get personalRecord => 'Personal record';

  @override
  String get longestTrip => 'Longest trip';

  @override
  String get personalRecordDescription => 'Discover your records';

  @override
  String get stationsList => 'List of visited stations';

  @override
  String get travelRecords => 'Your travel records';

  @override
  String get countdownTitle => 'Countdown';

  @override
  String get countdownDays => 'DAYS';

  @override
  String get countdownHours => 'HOURS';

  @override
  String get countdownMinutes => 'MINUTES';

  @override
  String get ticketInfoTitle => 'Ticket Info';

  @override
  String get notProvided => 'Not provided';

  @override
  String get deleteConfirmationTitle => 'Delete Confirmation';

  @override
  String get deleteConfirmationMessage => 'Are you sure you want to delete this trip? This action cannot be undone.';

  @override
  String get deleteTripButton => 'Delete Trip';
}
