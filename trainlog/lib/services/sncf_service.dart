import 'dart:convert';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'base_train_service.dart';

class SncfService extends BaseTrainService {
  @override
  String get baseUrl => 'https://api.navitia.io/v1';

  @override
  String get apiKey => _apiKey;

  @override
  Map<String, String> get defaultHeaders => {
        'Authorization': 'Basic ${base64Encode(utf8.encode('$_apiKey:'))}',
      };

  final String _apiKey;

  SncfService(this._apiKey);

  @override
  Future<List<Map<String, dynamic>>> searchStations(String query) async {
    try {
      final response = await get(
        '/coverage/sncf/places',
        queryParameters: {
          'q': query,
          'type[]': 'stop_area',
          'disable_geojson': 'true',
        },
      );

      final data = response.data as Map<String, dynamic>;
      final places = data['places'] as List<dynamic>?;

      if (places == null || places.isEmpty) {
        return [];
      }

      return places.map((place) {
        final Map<String, dynamic> station = {
          'id': place['id'] as String,
          'name': place['name'] as String,
          'type': place['embedded_type'] as String,
        };

        if (place['administrative_regions'] != null &&
            (place['administrative_regions'] as List).isNotEmpty) {
          final adminRegion =
              place['administrative_regions'][0] as Map<String, dynamic>;
          station['address'] = adminRegion['name'] as String;
        }

        return station;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchTrips({
    required String departureStation,
    required String arrivalStation,
    required DateTime date,
  }) async {
    validateSearchParams(
      departureStation: departureStation,
      arrivalStation: arrivalStation,
      date: date,
    );

    try {
      final dateStr = DateFormat('yyyyMMdd').format(date);
      final timeStr = DateFormat('HHmmss').format(date);

      final response = await get(
        '/coverage/sncf/journeys',
        queryParameters: {
          'from': departureStation,
          'to': arrivalStation,
          'datetime': '$dateStr$timeStr',
          'datetime_represents': 'departure',
          'count': '50',
          'max_nb_transfers': '0',
          'timeframe_duration': '1',
        },
      );

      final data = response.data as Map<String, dynamic>;
      final journeys = data['journeys'] as List? ?? [];
      final List<Map<String, dynamic>> allJourneys = [];

      for (final journey in journeys) {
        try {
          // Trouver la section de transport public (train)
          final publicTransportSection =
              (journey['sections'] as List).firstWhere(
            (section) => section['type'] == 'public_transport',
            orElse: () => null,
          );

          if (publicTransportSection == null) continue;

          final displayInfo = publicTransportSection['display_informations'];
          final stopDateTimes =
              publicTransportSection['stop_date_times'] as List;
          final firstStop = stopDateTimes.first;
          final lastStop = stopDateTimes.last;

          // Calculer la distance
          final firstCoords = firstStop['stop_point']['coord'];
          final lastCoords = lastStop['stop_point']['coord'];
          final distance = _calculateDistance(
            double.parse(firstCoords['lat']),
            double.parse(firstCoords['lon']),
            double.parse(lastCoords['lat']),
            double.parse(lastCoords['lon']),
          );

          final journeyInfo = {
            'id':
                '${displayInfo['headsign']}_${firstStop['departure_date_time']}',
            'departure_time': firstStop['departure_date_time'],
            'arrival_time': lastStop['arrival_date_time'],
            'duration': journey['duration'],
            'type': displayInfo['commercial_mode'],
            'train_number': displayInfo['headsign'],
            'network_name': displayInfo['network'] as String? ?? '',
            'price':
                double.tryParse(journey['fare']?['total']?['value'] ?? '0.0') ??
                    0.0,
            'distance': distance,
            'from': publicTransportSection['from'],
            'to': publicTransportSection['to'],
          };

          allJourneys.add(journeyInfo);
        } catch (e) {
          // Continuer avec le prochain trajet en cas d'erreur
          continue;
        }
      }

      return allJourneys;
    } catch (e) {
      throw Exception('Erreur lors de la recherche des trajets: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTrainInfo(
    String trainNumber,
    DateTime date,
    String departureStationId,
    String arrivalStationId,
  ) async {
    try {
      final formattedDate =
          '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';

      final response = await get(
        '/coverage/sncf/journeys',
        queryParameters: {
          'from': departureStationId,
          'to': arrivalStationId,
          'datetime': formattedDate,
          'train_number': trainNumber,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final journeys = data['journeys'] as List;
      return journeys.map((journey) {
        final sections = journey['sections'] as List;
        final firstSection = sections.first;
        final lastSection = sections.last;

        return {
          'id': journey['id'],
          'departure_station': firstSection['from']['name'],
          'arrival_station': lastSection['to']['name'],
          'departure_time': firstSection['departure_date_time'],
          'arrival_time': lastSection['arrival_date_time'],
          'duration': journey['duration'],
          'type': firstSection['display_informations']['commercial_mode'],
          'train_number': firstSection['display_informations']['headsign'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Rayon de la Terre en kilomètres

    // Convertir les degrés en radians
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    // Formule de Haversine
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  double _toRadians(double degree) {
    return degree * (math.pi / 180);
  }

  // Méthodes de compatibilité pour les écrans existants
  Future<List<Map<String, dynamic>>> getStations(String query) async {
    return searchStations(query);
  }

  Future<List<Map<String, dynamic>>> searchJourneys(
    String departureStationId,
    String arrivalStationId,
    DateTime date, {
    Function(int count)? onJourneysAdded,
  }) async {
    final trips = await searchTrips(
      departureStation: departureStationId,
      arrivalStation: arrivalStationId,
      date: date,
    );

    // Appeler le callback pour chaque trajet ajouté
    for (int i = 0; i < trips.length; i++) {
      onJourneysAdded?.call(i + 1);
    }

    return trips;
  }

  Future<Map<String, dynamic>> getStationDetails(String stationId) async {
    try {
      final response = await get('/coverage/sncf/stop_areas/$stationId');

      final stopArea = response.data['stop_areas'][0];
      final adminRegions = stopArea['administrative_regions'] ?? [];
      final cityName =
          adminRegions.isNotEmpty ? adminRegions[0]['name'] : stopArea['label'];

      return {
        'name': stopArea['label'],
        'city': cityName,
        'coordinates': {
          'lat': double.parse(stopArea['coord']['lat'].toString()),
          'lon': double.parse(stopArea['coord']['lon'].toString()),
        },
      };
    } catch (e) {
      throw Exception('Erreur lors de la récupération des détails de la gare');
    }
  }
}
