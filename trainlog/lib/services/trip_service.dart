import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trip.dart';

class TripService {
  static const String _tripsKey = 'trips';
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<Trip>> getTrips() async {
    final tripsJson = _prefs.getStringList(_tripsKey) ?? [];
    return tripsJson.map((json) => Trip.fromJson(jsonDecode(json))).toList();
  }

  Future<void> saveTrip(Trip trip) async {
    final trips = await getTrips();
    final existingIndex = trips.indexWhere((t) => t.id == trip.id);

    if (existingIndex != -1) {
      trips[existingIndex] = trip;
    } else {
      trips.add(trip);
    }

    final tripsJson = trips.map((t) => jsonEncode(t.toJson())).toList();
    await _prefs.setStringList(_tripsKey, tripsJson);
  }

  Future<void> deleteTrip(String id) async {
    final trips = await getTrips();
    trips.removeWhere((trip) => trip.id == id);
    final tripsJson = trips.map((t) => jsonEncode(t.toJson())).toList();
    await _prefs.setStringList(_tripsKey, tripsJson);
  }

  Future<List<Trip>> getUpcomingTrips() async {
    final now = DateTime.now();
    final trips = await getTrips();
    return trips.where((trip) => trip.departureTime.isAfter(now)).toList()
      ..sort((a, b) => a.departureTime.compareTo(b.departureTime));
  }

  Future<List<Trip>> getPastTrips() async {
    final now = DateTime.now();
    final trips = await getTrips();
    return trips.where((trip) => trip.departureTime.isBefore(now)).toList()
      ..sort((a, b) => b.departureTime.compareTo(a.departureTime));
  }

  Future<List<Trip>> getFavoriteTrips() async {
    final trips = await getTrips();
    return trips.where((trip) => trip.isFavorite).toList()
      ..sort((a, b) => b.departureTime.compareTo(a.departureTime));
  }

  Future<Map<String, dynamic>> getStats() async {
    final trips = await getTrips();
    final now = DateTime.now();
    final pastTrips =
        trips.where((trip) => trip.departureTime.isBefore(now)).toList();

    return {
      'totalTrips': pastTrips.length,
      'totalDistance': pastTrips.fold(0.0, (sum, trip) => sum + trip.distance),
      'totalDuration': pastTrips.fold(
        Duration.zero,
        (sum, trip) => sum + trip.duration,
      ),
      'totalPrice': pastTrips.fold(0.0, (sum, trip) => sum + trip.price),
    };
  }
}
