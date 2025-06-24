import 'package:home_widget/home_widget.dart';
import '../models/trip.dart';
import 'dart:convert';

class WidgetService {
  static const String _iOSWidgetName = 'ProchainTrain';
  static const String _androidWidgetName = 'NewsWidget';

  Future<void> updateWidgetWithTrips(List<Trip> trips) async {
    try {
      final nextTrips = trips
          .where((trip) => trip.departureTime.isAfter(DateTime.now()))
          .toList()
        ..sort((a, b) => a.departureTime.compareTo(b.departureTime));

      final upcomingTripsJson = nextTrips
          .map((trip) => {
                'id': trip.id,
                'departureTime': trip.departureTime.toIso8601String(),
                'departureStation': trip.departureStation,
                'arrivalStation': trip.arrivalStation,
                'trainNumber': trip.trainNumber,
                'trainType': trip.trainType,
                'distance': trip.distance,
                'price': trip.price,
                'departureCityName': trip.departureCityName,
                'arrivalCityName': trip.arrivalCityName,
              })
          .toList();

      final jsonString = jsonEncode(upcomingTripsJson);
      await HomeWidget.saveWidgetData('nextTrips', jsonString);

      await HomeWidget.updateWidget(
        iOSName: _iOSWidgetName,
        androidName: _androidWidgetName,
      );
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du widget: $e');
    }
  }

  Future<void> clearWidget() async {
    try {
      await HomeWidget.saveWidgetData('nextTrips', '[]');
      await HomeWidget.updateWidget(
        iOSName: _iOSWidgetName,
        androidName: _androidWidgetName,
      );
    } catch (e) {
      throw Exception('Erreur lors de la suppression du widget: $e');
    }
  }
}
