import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'train_company_service.dart';
import '../services/ticket_scanner_service.dart';
import '../utils/distance_calculator.dart';

class SncbService implements TrainCompanyService {
  final String _apiKey;
  final _ticketScanner = TicketScannerService();

  SncbService(this._apiKey);

  @override
  String get companyName => 'SNCB';

  @override
  String get companyLogoPath => 'assets/images/logo_SNCB.svg';

  @override
  String get companyServices => 'IC, L, S';

  @override
  Future<List<Map<String, dynamic>>> getStations(String query) async {
    try {
      final response = await http.get(
        Uri.parse('https://irail.be/stations/NMBS?q=$query'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Erreur lors de la récupération des gares: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final stations = data['@graph'] as List<dynamic>;

      // Transformer les données dans le format attendu
      final formattedStations = stations.map((station) {
        // Extraire l'ID de l'URL
        final id = station['@id'].toString().split('/').last;

        return {
          'id': id,
          'name': station['name'],
          'city': '${station['latitude']}, ${station['longitude']}',
          'latitude': double.parse(station['latitude']),
          'longitude': double.parse(station['longitude']),
          'country': station['country'],
          'avgStopTimes': double.parse(station['avgStopTimes']),
          'alternative': station['alternative'] != null
              ? (station['alternative'] as List)
                  .map((alt) => alt['@value'])
                  .toList()
              : null,
        };
      }).toList();

      return formattedStations;
    } catch (e) {
      print('Erreur lors de la recherche des gares: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getStationDetails(String stationId) async {
    // TODO: Implémenter l'appel API SNCB pour les détails d'une gare
    throw UnimplementedError('SNCB API not implemented yet');
  }

  @override
  Future<List<Map<String, dynamic>>> searchJourneys(
    String departureStationId,
    String arrivalStationId,
    DateTime date, {
    required void Function(int) onJourneysAdded,
  }) async {
    try {
      // Formater la date au format YYMMDD
      final formattedDate = DateFormat('ddMMyy').format(date);
      // Formater l'heure au format HHmm
      final formattedTime = DateFormat('HHmm').format(date);

      final response = await http.get(
        Uri.parse(
          'https://irail.be/route?from=$departureStationId&to=$arrivalStationId&date=$formattedDate&time=$formattedTime&timeSel=depart',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final connections = jsonData['connection'] as List<dynamic>;

        // Filtrer les connexions pour ne garder que celles sans arrêts intermédiaires
        final directConnections = connections.where((connection) {
          final stops =
              connection['departure']['stops'] as Map<String, dynamic>;
          return stops['number'] == '0' && (stops['stop'] as List).isEmpty;
        }).toList();

        // Transformer les connexions en format attendu par l'application
        final journeys = directConnections.map((connection) {
          final departure = connection['departure'];
          final arrival = connection['arrival'];
          final vehicleInfo = departure['vehicleinfo'];
          final departureStationInfo = departure['stationinfo'];
          final arrivalStationInfo = arrival['stationinfo'];

          // Calculer la distance entre les gares
          final departureGeo = GeoPoint(
            double.parse(departureStationInfo['locationY']),
            double.parse(departureStationInfo['locationX']),
          );
          final arrivalGeo = GeoPoint(
            double.parse(arrivalStationInfo['locationY']),
            double.parse(arrivalStationInfo['locationX']),
          );
          final distance = DistanceCalculator.calculateDistance(
            departureGeo,
            arrivalGeo,
          );

          return {
            'departure_time': DateTime.fromMillisecondsSinceEpoch(
              int.parse(departure['time']) * 1000,
            ).toIso8601String(),
            'arrival_time': DateTime.fromMillisecondsSinceEpoch(
              int.parse(arrival['time']) * 1000,
            ).toIso8601String(),
            'train_number': vehicleInfo['number'],
            'type': vehicleInfo['type'],
            'from': {
              'stop_point': {
                'id': departureStationInfo['id'],
                'label': departureStationInfo['name'],
                'administrative_regions': [
                  {
                    'name': departureStationInfo['name'],
                    'coord': {
                      'lat': departureStationInfo['locationY'],
                      'lon': departureStationInfo['locationX'],
                    },
                  },
                ],
              },
            },
            'to': {
              'stop_point': {
                'id': arrivalStationInfo['id'],
                'label': arrivalStationInfo['name'],
                'administrative_regions': [
                  {
                    'name': arrivalStationInfo['name'],
                    'coord': {
                      'lat': arrivalStationInfo['locationY'],
                      'lon': arrivalStationInfo['locationX'],
                    },
                  },
                ],
              },
            },
            'distance': distance,
            'delay': {
              'departure': int.parse(departure['delay']),
              'arrival': int.parse(arrival['delay']),
            },
            'platform': {
              'departure': departure['platform'],
              'arrival': arrival['platform'],
            },
            'canceled': {
              'departure': departure['canceled'] == '1',
              'arrival': arrival['canceled'] == '1',
            },
            'direction': departure['direction']['name'],
            'geojson': {
              'type': 'LineString',
              'coordinates':
                  [], // L'API iRail ne fournit pas les coordonnées du trajet
            },
          };
        }).toList();

        onJourneysAdded(journeys.length);
        return journeys;
      } else {
        throw Exception(
            'Erreur lors de la récupération des trajets: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur lors de la recherche des trajets: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> processTicket(XFile image) async {
    final ticketInfo = await _ticketScanner.processImage(image);
    if (ticketInfo == null) return null;

    try {
      final Map<String, dynamic> jsonData = jsonDecode(ticketInfo);

      // Fonction utilitaire pour nettoyer et valider les chaînes de caractères
      String? cleanString(String? value) {
        if (value == null || value.isEmpty) return null;
        return value.trim();
      }

      // Fonction utilitaire pour parser les dates
      DateTime? parseDate(String? dateStr) {
        if (dateStr == null || dateStr.isEmpty) return null;

        try {
          // Essayer d'abord le format ISO 8601
          try {
            return DateTime.parse(dateStr);
          } catch (e) {
            // Continuer avec les autres formats si le format ISO échoue
          }

          // Essayer différents formats de date
          final formats = [
            'yyyy-MM-dd HH:mm',
            'dd/MM/yyyy HH:mm',
            'dd MMMM yyyy HH:mm',
            'EEEE dd MMMM yyyy HH:mm',
            'EEEE dd MMMM yyyy HH\'h\'mm',
          ];

          for (final format in formats) {
            try {
              return DateFormat(format, 'fr_FR').parse(dateStr);
            } catch (e) {
              continue;
            }
          }

          // Si aucun format ne fonctionne, essayer de nettoyer la chaîne
          final cleanedDate = dateStr
              .replaceAll('h', ':')
              .replaceAll('H', ':')
              .replaceAll('min', '')
              .trim();

          return DateFormat('EEEE dd MMMM yyyy HH:mm', 'fr_FR')
              .parse(cleanedDate);
        } catch (e) {
          print('Erreur lors du parsing de la date: $dateStr');
          return null;
        }
      }

      // Vérifier que les dates sont valides
      final departureDateTime = parseDate(jsonData['departureDateTime']);
      final arrivalDateTime = parseDate(jsonData['arrivalDateTime']);

      if (departureDateTime == null || arrivalDateTime == null) {
        throw Exception('Impossible de lire les dates du billet');
      }

      return {
        'departureStation': cleanString(jsonData['departureStation']),
        'arrivalStation': cleanString(jsonData['arrivalStation']),
        'trainNumber': cleanString(jsonData['trainNumber']),
        'trainType': cleanString(jsonData['trainType']),
        'departureDateTime': departureDateTime,
        'arrivalDateTime': arrivalDateTime,
        'ticketNumber': cleanString(jsonData['ticketNumber']),
        'seatNumber': cleanString(jsonData['seatNumber']),
        'carNumber': cleanString(jsonData['carNumber']),
        'travelClass': cleanString(jsonData['travelClass']),
        'company': companyName,
      };
    } catch (e) {
      print('Erreur lors du décodage du JSON: $e');
      return null;
    }
  }
}
