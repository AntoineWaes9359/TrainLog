import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:trainlog/models/trip.dart';
import '../services/firestore_service.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

// TODO: Replace with your App Group ID
const String appGroupId = 'group.com.antoinewaes.raillog'; // Add from here
const String iOSWidgetName = 'ProchainTrain';
const String androidWidgetName = 'NewsWidget'; // To here.

class TripProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Trip> _trips = [];
  List<Trip> _upcomingTrips = [];
  List<Trip> _pastTrips = [];
  List<Trip> _favoriteTrips = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = false;

  List<Trip> get trips => _trips;
  List<Trip> get upcomingTrips => _upcomingTrips;
  List<Trip> get pastTrips => _pastTrips;
  List<Trip> get favoriteTrips => _favoriteTrips;
  Map<String, dynamic> get stats => _stats;
  bool get isLoading => _isLoading;

  TripProvider() {
    _loadTrips();
  }

  void _loadTrips() {
    _firestoreService.getTrips().listen((trips) {
      _trips = trips;
      _upcomingTrips = trips
          .where((trip) => trip.departureTime.isAfter(DateTime.now()))
          .toList()
        ..sort((a, b) => a.departureTime.compareTo(b.departureTime));
      _pastTrips = trips
          .where((trip) => trip.departureTime.isBefore(DateTime.now()))
          .toList();
      _saveTripsForWidget();
      notifyListeners();
    });
  }

  Future<void> _saveTripsForWidget() async {
    try {
      final nextTrip = _upcomingTrips
          .where((trip) => trip.departureTime.isAfter(DateTime.now()))
          .toList()
        ..sort((a, b) => a.departureTime.compareTo(b.departureTime));

      if (nextTrip.isNotEmpty) {
        // Sauvegarder le JSON des prochains trajets
        final upcomingTripsJson = nextTrip
            .map((trip) => {
                  'id': trip.id,
                  'departureTime': trip.departureTime.toIso8601String(),
                  'departureStation': trip.departureStation,
                  'arrivalStation': trip.arrivalStation,
                  'trainNumber': trip.trainNumber,
                  'trainType': trip.trainType,
                  'distance': trip.distance,
                  'price': trip.price,
                })
            .toList();

        final jsonString = jsonEncode(upcomingTripsJson);
        await HomeWidget.saveWidgetData('nextTrips', jsonString);
        print('JSON sauvegardé: $jsonString');
      } else {
        // Si aucun trajet, envoyer des valeurs par défaut

        await HomeWidget.saveWidgetData('nextTrips', '[]');
      }

      await HomeWidget.updateWidget(
        iOSName: iOSWidgetName,
        androidName: androidWidgetName,
      );

      print('Widget mis à jour avec le prochain trajet');
    } catch (e) {
      print('Erreur lors de la mise à jour du widget: $e');
    }
  }

  Future<void> addTrip(Trip trip) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _firestoreService.addTrip(trip);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTrip(Trip trip) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _firestoreService.updateTrip(trip.id, trip);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _firestoreService.deleteTrip(tripId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(Trip trip) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _firestoreService.toggleFavorite(trip.id, !trip.isFavorite);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTrips() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Charger les voyages depuis Firestore
      // ...

      // Sauvegarder les voyages pour le widget
      await _saveTripsForWidget();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
