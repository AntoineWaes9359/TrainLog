import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:trainlog/config/api_keys.example.dart';

class SncfRealtimeService {
  static const String _baseUrl = 'https://api.navitia.io/v1/coverage/sncf';

  // Clé API SNCF depuis la configuration
  static const String _apiKey = ApiKeys.sncfApiKey;

  /// Construit l'URL du journey pour l'API SNCF
  static String _buildJourneyUrl(
      String trainNumber, DateTime departureDate, String trainType) {
    final dateStr = DateFormat('yyyy-MM-dd').format(departureDate);
    // Extraire seulement les chiffres du numéro de train (ex: "TGV 6942" -> "6942")
    final cleanTrainNumber = trainNumber.replaceAll(RegExp(r'[^0-9]'), '');

    // Déterminer le type de train pour l'API SNCF
    final apiTrainType = _getApiTrainType(trainType);

    final journeyId =
        'vehicle_journey:SNCF:$dateStr:$cleanTrainNumber:1187:$apiTrainType';
    return '$_baseUrl/vehicle_journeys/$journeyId/?';
  }

  /// Détermine le type de train pour l'API SNCF
  static String _getApiTrainType(String trainType) {
    final typeUpper = trainType.toUpperCase();

    // Trains longue distance
    if (typeUpper.contains('TGV') ||
        typeUpper.contains('INOUI') ||
        typeUpper.contains('LYRIA') ||
        typeUpper.contains('OUIGO') ||
        typeUpper.contains('EUROSTAR') ||
        typeUpper.contains('THALYS')) {
      return 'LongDistanceTrain';
    }

    // Trains régionaux et autres
    if (typeUpper.contains('TER') ||
        typeUpper.contains('INTERCITES') ||
        typeUpper.contains('CORAIL') ||
        typeUpper.contains('LUNEA')) {
      return 'Train';
    }

    // Par défaut, utiliser Train pour les autres types
    return 'Train';
  }

  /// Récupère les informations en temps réel pour un trajet
  static Future<Map<String, dynamic>?> getRealtimeInfo(
      String trainNumber, DateTime departureDate, String trainType) async {
    try {
      final url = _buildJourneyUrl(trainNumber, departureDate, trainType);
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_apiKey:'))}',
          'Content-Type': 'application/json',
        },
      );

      print('Basic ${base64Encode(utf8.encode('$_apiKey:'))}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseRealtimeData(data);
      } else {
        print('Erreur API SNCF: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération des infos temps réel: $e');
      return null;
    }
  }

  /// Parse les données de l'API SNCF
  static Map<String, dynamic>? _parseRealtimeData(Map<String, dynamic> data) {
    try {
      // Les perturbations sont directement dans le champ disruptions à la racine
      final disruptions = data['disruptions'] as List?;

      // Si pas de perturbations, retourner null
      if (disruptions == null || disruptions.isEmpty) {
        return null;
      }

      // Analyser la première perturbation
      final disruption = disruptions.first as Map<String, dynamic>;

      // Extraire le message principal
      final messages = disruption['messages'] as List?;
      String message = 'Perturbation signalée';
      if (messages != null && messages.isNotEmpty) {
        final firstMessage = messages.first as Map<String, dynamic>;
        message = firstMessage['text'] as String? ?? message;
      }

      // Extraire la sévérité
      final severity = disruption['severity'] as Map<String, dynamic>?;
      final severityName = severity?['name'] as String? ?? 'unknown';
      final severityEffect = severity?['effect'] as String? ?? 'unknown';

      // Extraire la cause
      final cause = disruption['cause'] as String? ?? '';

      // Analyser les impacts pour détecter les suppressions/annulations
      bool hasDeletedStops = false;
      bool isFullyCancelled = false;
      int? delayMinutes;

      final impactedObjects = disruption['impacted_objects'] as List?;
      if (impactedObjects != null && impactedObjects.isNotEmpty) {
        final firstObject = impactedObjects.first as Map<String, dynamic>;
        final impactedStops = firstObject['impacted_stops'] as List?;

        if (impactedStops != null && impactedStops.isNotEmpty) {
          int deletedStopsCount = 0;
          int totalStopsCount = impactedStops.length;

          for (final stop in impactedStops) {
            final stopData = stop as Map<String, dynamic>;
            final stopTimeEffect = stopData['stop_time_effect'] as String?;
            final departureStatus = stopData['departure_status'] as String?;
            final arrivalStatus = stopData['arrival_status'] as String?;

            // Vérifier si l'arrêt est supprimé
            if (stopTimeEffect == 'deleted' ||
                departureStatus == 'deleted' ||
                arrivalStatus == 'deleted') {
              deletedStopsCount++;
              hasDeletedStops = true;
            }

            // Calculer le retard seulement pour le premier arrêt non supprimé
            if (delayMinutes == null &&
                stopTimeEffect != 'deleted' &&
                departureStatus != 'deleted') {
              final baseDeparture = stopData['base_departure_time'] as String?;
              final amendedDeparture =
                  stopData['amended_departure_time'] as String?;

              if (baseDeparture != null && amendedDeparture != null) {
                try {
                  final baseTime = _parseTimeString(baseDeparture);
                  final amendedTime = _parseTimeString(amendedDeparture);
                  delayMinutes = amendedTime.difference(baseTime).inMinutes;
                } catch (e) {
                  // Ignorer les erreurs de parsing du temps
                }
              }
            }
          }

          // Si tous les arrêts sont supprimés, le train est complètement annulé
          if (deletedStopsCount == totalStopsCount) {
            isFullyCancelled = true;
          }
        }
      }

      // Déterminer le type de perturbation
      String disruptionType = _getDisruptionType(severityName, severityEffect);

      // Ajuster le type selon les suppressions détectées
      if (isFullyCancelled) {
        disruptionType = 'blocking';
      } else if (hasDeletedStops) {
        disruptionType = 'reduced';
      }

      return {
        'hasDisruption': true,
        'message': message,
        'severity': severityName,
        'severityEffect': severityEffect,
        'cause': cause,
        'delayMinutes': delayMinutes,
        'hasDeletedStops': hasDeletedStops,
        'isFullyCancelled': isFullyCancelled,
        'disruptionType': disruptionType,
        'impacted_objects': impactedObjects,
      };
    } catch (e) {
      print('Erreur lors du parsing des données: $e');
      return null;
    }
  }

  /// Parse une chaîne de temps au format HHMMSS
  static DateTime _parseTimeString(String timeStr) {
    if (timeStr.length >= 4) {
      final hours = int.parse(timeStr.substring(0, 2));
      final minutes = int.parse(timeStr.substring(2, 4));
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hours, minutes);
    }
    return DateTime.now();
  }

  /// Détermine le type de perturbation basé sur la sévérité
  static String _getDisruptionType(String severity, String severityEffect) {
    final severityLower = severity.toLowerCase();
    final effectLower = severityEffect.toLowerCase();

    if (severityLower.contains('blocking') ||
        effectLower.contains('no_service')) {
      return 'blocking';
    } else if (severityLower.contains('delayed') ||
        effectLower.contains('significant_delays')) {
      return 'delayed';
    } else if (severityLower.contains('reduced') ||
        effectLower.contains('reduced_service')) {
      return 'reduced';
    } else if (severityLower.contains('information') ||
        effectLower.contains('information')) {
      return 'info';
    } else {
      return 'info';
    }
  }
}
