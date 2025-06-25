import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'train_company_service.dart';
import '../services/ticket_scanner_service.dart';

class TrenitaliaService implements TrainCompanyService {
  final _ticketScanner = TicketScannerService();

  TrenitaliaService();

  @override
  String get companyName => 'Trenitalia';

  @override
  String get companyLogoPath => 'assets/images/logo_Trenitalia.svg';

  @override
  String get companyServices => 'Frecciarossa, Frecciargento';

  @override
  Future<List<Map<String, dynamic>>> getStations(String query) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://www.viaggiatreno.it/infomobilita/resteasy/viaggiatreno/cercaStazione/$query'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((station) {
          return {
            'name': station['nomeLungo'],
            'id': station['id'],
            'city': station['label'],
          };
        }).toList();
      } else {
        throw Exception('Erreur lors de la récupération des stations');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des stations: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getStationDetails(String stationId) async {
    // TODO: Implémenter l'appel API Trenitalia pour les détails d'une gare
    throw UnimplementedError('Trenitalia API not implemented yet');
  }

  @override
  Future<List<Map<String, dynamic>>> searchJourneys(
    String departureStationId,
    String arrivalStationId,
    DateTime date, {
    required void Function(int) onJourneysAdded,
  }) async {
    try {
      // Formater la date au format YYYY-MM-DD
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      // Formater l'heure au format HH:mm
      final formattedTime = DateFormat('HH:mm').format(date);

      final response = await http.get(
        Uri.parse(
          'https://www.lefrecce.it/msite/api/solutions?origin=$departureStationId&destination=$arrivalStationId&arflag=A&adate=$formattedDate&atime=$formattedTime&adultno=1&childno=0&direction=A&frecce=false&onlyRegional=false',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final solutions = jsonData['solutions'] as List<dynamic>;

        // Transformer les solutions en format attendu par l'application
        final journeys = solutions.map((solution) {
          final departure = solution['departure'];
          final arrival = solution['arrival'];
          final train = solution['trainlist']
              [0]; // On prend le premier train de la solution

          return {
            'departure_time': departure['time'],
            'arrival_time': arrival['time'],
            'train_number': train['trainidentifier'],
            'type': train['trainacronym'],
            'from': {
              'stop_point': {
                'id': departureStationId,
                'label': departure['station'],
                'administrative_regions': [
                  {
                    'name': departure['station'],
                    'coord': {
                      'lat': '0', // L'API ne fournit pas les coordonnées
                      'lon': '0',
                    },
                  },
                ],
              },
            },
            'to': {
              'stop_point': {
                'id': arrivalStationId,
                'label': arrival['station'],
                'administrative_regions': [
                  {
                    'name': arrival['station'],
                    'coord': {
                      'lat': '0', // L'API ne fournit pas les coordonnées
                      'lon': '0',
                    },
                  },
                ],
              },
            },
            'distance': 0, // L'API ne fournit pas la distance
            'delay': {
              'departure': int.parse(departure['delay'] ?? '0'),
              'arrival': int.parse(arrival['delay'] ?? '0'),
            },
            'platform': {
              'departure': departure['platform'],
              'arrival': arrival['platform'],
            },
            'canceled': {
              'departure': departure['canceled'] ?? false,
              'arrival': arrival['canceled'] ?? false,
            },
            'direction': train['direction'],
            'geojson': {
              'type': 'LineString',
              'coordinates':
                  [], // L'API ne fournit pas les coordonnées du trajet
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
