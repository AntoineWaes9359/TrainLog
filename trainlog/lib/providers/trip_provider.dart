import 'package:flutter/foundation.dart';
import 'package:trainlog/models/trip.dart';
import '../services/firestore_service.dart';
import '../services/widget_service.dart';

class TripProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final WidgetService _widgetService = WidgetService();
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
      _updateWidget();
      notifyListeners();
    });
  }

  Future<void> _updateWidget() async {
    try {
      await _widgetService.updateWidgetWithTrips(_upcomingTrips);
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour du widget: $e');
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
      await _updateWidget();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
