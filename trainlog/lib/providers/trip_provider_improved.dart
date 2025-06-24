import 'package:flutter/foundation.dart';
import 'package:trainlog/models/trip.dart';
import '../services/firestore_service.dart';
import '../services/widget_service.dart';

class TripProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final WidgetService _widgetService = WidgetService();

  List<Trip> _trips = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Trip> get trips => _trips;
  List<Trip> get upcomingTrips => _getUpcomingTrips();
  List<Trip> get pastTrips => _getPastTrips();
  List<Trip> get favoriteTrips => _getFavoriteTrips();
  bool get isLoading => _isLoading;
  String? get error => _error;

  TripProvider() {
    _initializeTrips();
  }

  void _initializeTrips() {
    _firestoreService.getTrips().listen(
      (trips) {
        _trips = trips;
        _updateWidget();
        _clearError();
        notifyListeners();
      },
      onError: (error) {
        _setError('Erreur lors du chargement des trajets: $error');
      },
    );
  }

  List<Trip> _getUpcomingTrips() {
    final now = DateTime.now();
    return _trips.where((trip) {
      // Garder les trajets futurs ET ceux partis il y a moins de 6h
      // Cela permet de garder les informations en temps réel même après le départ
      final sixHoursAfterDeparture =
          trip.departureTime.add(const Duration(hours: 6));
      return now.isBefore(sixHoursAfterDeparture);
    }).toList()
      ..sort((a, b) => a.departureTime.compareTo(b.departureTime));
  }

  List<Trip> _getPastTrips() {
    final now = DateTime.now();
    return _trips.where((trip) {
      // Trajets partis il y a plus de 6h
      // Ces trajets sont considérés comme "terminés" et vont dans l'historique
      final sixHoursAfterDeparture =
          trip.departureTime.add(const Duration(hours: 6));
      return now.isAfter(sixHoursAfterDeparture);
    }).toList()
      ..sort((a, b) => b.departureTime.compareTo(a.departureTime));
  }

  List<Trip> _getFavoriteTrips() {
    return _trips.where((trip) => trip.isFavorite).toList();
  }

  Future<void> _updateWidget() async {
    try {
      await _widgetService.updateWidgetWithTrips(upcomingTrips);
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour du widget: $e');
    }
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  // CRUD Operations
  Future<void> addTrip(Trip trip) async {
    try {
      _setLoading(true);
      await _firestoreService.addTrip(trip);
    } catch (e) {
      _setError('Erreur lors de l\'ajout du trajet: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateTrip(Trip trip) async {
    try {
      _setLoading(true);
      await _firestoreService.updateTrip(trip.id, trip);
    } catch (e) {
      _setError('Erreur lors de la mise à jour du trajet: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteTrip(String tripId) async {
    try {
      _setLoading(true);
      await _firestoreService.deleteTrip(tripId);
    } catch (e) {
      _setError('Erreur lors de la suppression du trajet: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleFavorite(Trip trip) async {
    try {
      _setLoading(true);
      await _firestoreService.toggleFavorite(trip.id, !trip.isFavorite);
    } catch (e) {
      _setError('Erreur lors de la mise à jour du favori: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Méthodes utilitaires
  Trip? getNextTrip() {
    final upcoming = upcomingTrips;
    return upcoming.isNotEmpty ? upcoming.first : null;
  }

  List<Trip> getTripsByDate(DateTime date) {
    return _trips.where((trip) {
      final tripDate = DateTime(
        trip.departureTime.year,
        trip.departureTime.month,
        trip.departureTime.day,
      );
      final targetDate = DateTime(
        date.year,
        date.month,
        date.day,
      );
      return tripDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  void clearError() {
    _clearError();
  }
}
