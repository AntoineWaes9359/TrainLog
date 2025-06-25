import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'TrainLog'**
  String get appTitle;

  /// Navigation label for trips
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get navigationTrips;

  /// Navigation label for history
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navigationHistory;

  /// Navigation label for statistics
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navigationStats;

  /// Navigation label for profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navigationProfile;

  /// Title of the upcoming trips screen
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcomingTitle;

  /// Title of the next trip card
  ///
  /// In en, this message translates to:
  /// **'Next trip'**
  String get nextTripTitle;

  /// Time unit for hours
  ///
  /// In en, this message translates to:
  /// **'HOURS'**
  String get timeUnitHours;

  /// Time unit for days
  ///
  /// In en, this message translates to:
  /// **'DAYS'**
  String get timeUnitDays;

  /// Copy confirmation message
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// Title of the seat editing dialog
  ///
  /// In en, this message translates to:
  /// **'Edit seat'**
  String get editSeatTitle;

  /// Label for seat number field
  ///
  /// In en, this message translates to:
  /// **'Seat number'**
  String get seatNumberLabel;

  /// Help text for seat number
  ///
  /// In en, this message translates to:
  /// **'Ex: 12A'**
  String get seatNumberHint;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// Title of the delete dialog
  ///
  /// In en, this message translates to:
  /// **'Delete trip'**
  String get deleteTripTitle;

  /// Delete confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this trip?'**
  String get deleteTripConfirmation;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// Label for departure
  ///
  /// In en, this message translates to:
  /// **'Departure'**
  String get departureLabel;

  /// Label for arrival
  ///
  /// In en, this message translates to:
  /// **'Arrival'**
  String get arrivalLabel;

  /// Label for distance
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distanceLabel;

  /// Label for duration
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// Label for train number
  ///
  /// In en, this message translates to:
  /// **'Train number'**
  String get trainNumberLabel;

  /// Label for ticket number
  ///
  /// In en, this message translates to:
  /// **'Ticket number'**
  String get ticketNumberLabel;

  /// Label for seat
  ///
  /// In en, this message translates to:
  /// **'Seat'**
  String get seatLabel;

  /// Label for file
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get dossierLabel;

  /// Copy button
  ///
  /// In en, this message translates to:
  /// **'COPY'**
  String get copyButton;

  /// Paste button
  ///
  /// In en, this message translates to:
  /// **'PASTE'**
  String get pasteButton;

  /// Help text for editing
  ///
  /// In en, this message translates to:
  /// **'Tap to Edit'**
  String get tapToEdit;

  /// Label for class
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get classLabel;

  /// Label for car
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get carLabel;

  /// Title of the information section
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get informationTitle;

  /// Label for train information
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get trainInfoLabel;

  /// Label for date
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateInfoLabel;

  /// Label for duration
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationInfoLabel;

  /// Label for distance
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distanceInfoLabel;

  /// Title of the history section
  ///
  /// In en, this message translates to:
  /// **'My history on this route'**
  String get myHistoryTitle;

  /// Label for number of trips
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get tripsLabel;

  /// Label for travel time
  ///
  /// In en, this message translates to:
  /// **'Travel time'**
  String get travelTimeLabel;

  /// Help text for file number
  ///
  /// In en, this message translates to:
  /// **'File number'**
  String get dossierNumberHint;

  /// Help text for seat number editing
  ///
  /// In en, this message translates to:
  /// **'Seat number (ex: 12A)'**
  String get seatNumberEditHint;

  /// Second class
  ///
  /// In en, this message translates to:
  /// **'Second'**
  String get secondClass;

  /// First class
  ///
  /// In en, this message translates to:
  /// **'First'**
  String get firstClass;

  /// Business class
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get businessClass;

  /// Save changes button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveChangesButton;

  /// Title of the booking details dialog
  ///
  /// In en, this message translates to:
  /// **'Booking details'**
  String get bookingDetailsTitle;

  /// Title of the profile screen
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Default username
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get defaultUserName;

  /// Logout button
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutButton;

  /// Error message during logout
  ///
  /// In en, this message translates to:
  /// **'Error during logout: {error}'**
  String logoutError(String error);

  /// Title of the carbon footprint section
  ///
  /// In en, this message translates to:
  /// **'Carbon footprint'**
  String get carbonFootprintTitle;

  /// Label for train emissions
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get trainEmissions;

  /// Label for car emissions
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get carEmissions;

  /// Label for plane emissions
  ///
  /// In en, this message translates to:
  /// **'Plane'**
  String get planeEmissions;

  /// Label for CO2 savings
  ///
  /// In en, this message translates to:
  /// **'CO₂ savings'**
  String get carbonSavings;

  /// Message for moderate carbon impact
  ///
  /// In en, this message translates to:
  /// **'Moderate carbon impact for this trip'**
  String get moderateImpact;

  /// History screen title
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// Message when there are no trips in history
  ///
  /// In en, this message translates to:
  /// **'No trips in history'**
  String get noTripsInHistory;

  /// Help message for empty history
  ///
  /// In en, this message translates to:
  /// **'Your past trips will appear here'**
  String get pastTripsWillAppearHere;

  /// Statistics screen title
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// All time period
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get allTime;

  /// Label for number of trains
  ///
  /// In en, this message translates to:
  /// **'TRAINS'**
  String get trains;

  /// Label for distance
  ///
  /// In en, this message translates to:
  /// **'DISTANCE'**
  String get distance;

  /// Kilometers unit
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get kilometers;

  /// Label for time
  ///
  /// In en, this message translates to:
  /// **'TIME'**
  String get time;

  /// Label for number of stations
  ///
  /// In en, this message translates to:
  /// **'STATIONS'**
  String get stations;

  /// Label for number of companies
  ///
  /// In en, this message translates to:
  /// **'COMPANIES'**
  String get companies;

  /// Title for most ridden train section
  ///
  /// In en, this message translates to:
  /// **'Most ridden train'**
  String get mostRiddenTrain;

  /// Singular of trip
  ///
  /// In en, this message translates to:
  /// **'trip'**
  String get trip;

  /// Plural of trips
  ///
  /// In en, this message translates to:
  /// **'trips'**
  String get trips;

  /// Button to see all trains
  ///
  /// In en, this message translates to:
  /// **'All trains'**
  String get allTrains;

  /// Title for quick information section
  ///
  /// In en, this message translates to:
  /// **'Quick information'**
  String get quickInfo;

  /// Title for total distance
  ///
  /// In en, this message translates to:
  /// **'Total distance'**
  String get totalDistance;

  /// Description of total distance
  ///
  /// In en, this message translates to:
  /// **'Sum of all your trips'**
  String get totalDistanceDescription;

  /// Title for time spent in train
  ///
  /// In en, this message translates to:
  /// **'Time in train'**
  String get timeInTrain;

  /// Description of time in train
  ///
  /// In en, this message translates to:
  /// **'Total duration of your journeys'**
  String get timeInTrainDescription;

  /// Title for visited stations
  ///
  /// In en, this message translates to:
  /// **'Visited stations'**
  String get visitedStations;

  /// Description of visited stations
  ///
  /// In en, this message translates to:
  /// **'Number of unique stations'**
  String get visitedStationsDescription;

  /// Number of stations with unit
  ///
  /// In en, this message translates to:
  /// **'{count} stations'**
  String stationsCount(int count);

  /// Title for personal records
  ///
  /// In en, this message translates to:
  /// **'Personal record'**
  String get personalRecord;

  /// Subtitle for longest trip
  ///
  /// In en, this message translates to:
  /// **'Longest trip'**
  String get longestTrip;

  /// Description of personal records
  ///
  /// In en, this message translates to:
  /// **'Discover your records'**
  String get personalRecordDescription;

  /// Message for stations list
  ///
  /// In en, this message translates to:
  /// **'List of visited stations'**
  String get stationsList;

  /// Message for travel records
  ///
  /// In en, this message translates to:
  /// **'Your travel records'**
  String get travelRecords;

  /// Title for the countdown section before departure
  ///
  /// In en, this message translates to:
  /// **'Countdown'**
  String get countdownTitle;

  /// Label for days in the countdown
  ///
  /// In en, this message translates to:
  /// **'DAYS'**
  String get countdownDays;

  /// Label for hours in the countdown
  ///
  /// In en, this message translates to:
  /// **'HOURS'**
  String get countdownHours;

  /// Label for minutes in the countdown
  ///
  /// In en, this message translates to:
  /// **'MINUTES'**
  String get countdownMinutes;

  /// Title for the ticket information section
  ///
  /// In en, this message translates to:
  /// **'Ticket Info'**
  String get ticketInfoTitle;

  /// Text displayed when information is not available
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get notProvided;

  /// Title of the delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Confirmation'**
  String get deleteConfirmationTitle;

  /// Message of the delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this trip? This action cannot be undone.'**
  String get deleteConfirmationMessage;

  /// Label for the delete trip button
  ///
  /// In en, this message translates to:
  /// **'Delete Trip'**
  String get deleteTripButton;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
