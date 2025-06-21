import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class DistanceCalculator {
  static double calculateDistance(GeoPoint point1, GeoPoint point2) {
    const double earthRadius = 6371; // Rayon de la Terre en kilomètres

    // Conversion des degrés en radians
    final lat1 = _degreesToRadians(point1.latitude);
    final lon1 = _degreesToRadians(point1.longitude);
    final lat2 = _degreesToRadians(point2.latitude);
    final lon2 = _degreesToRadians(point2.longitude);

    // Différences de latitude et longitude
    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    // Formule de Haversine
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadius * c;

    return distance;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}
