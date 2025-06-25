import 'package:flutter/material.dart';
import 'package:trainlog/theme/colors.dart';
import 'package:trainlog/theme/typography.dart';

class DisruptionDetailsModal extends StatelessWidget {
  final Map<String, dynamic> disruptionInfo;
  final String trainNumber;
  final String trainType;

  const DisruptionDetailsModal({
    super.key,
    required this.disruptionInfo,
    required this.trainNumber,
    required this.trainType,
  });

  /// Crée des données de test pour la modal
  static Map<String, dynamic> createTestData() {
    return {
      'disruptionType': 'reduced',
      'message': 'Incident sur un réseau ferré étranger',
      'impacted_objects': [
        {
          'pt_object': {
            'id': 'SNCF:2025-06-24:19709:1187:Train',
            'name': 'SNCF:2025-06-24:19709:1187:Train',
            'quality': 0,
            'trip': {'id': 'SNCF:2025-06-24:19709:1187:Train', 'name': '19709'},
            'embedded_type': 'trip'
          },
          'impacted_stops': [
            {
              'stop_point': {
                'id': 'stop_point:SNCF:87286005:Train',
                'name': 'Lille Flandres',
                'label': 'Lille Flandres (Lille)',
                'coord': {'lon': '3.06987', 'lat': '50.636577'},
                'links': [],
                'equipments': []
              },
              'base_arrival_time': '100900',
              'base_departure_time': '100900',
              'amended_arrival_time': '100900',
              'cause': 'Incident sur un réseau ferré étranger',
              'stop_time_effect': 'deleted',
              'departure_status': 'deleted',
              'arrival_status': 'unchanged',
              'is_detour': false
            },
            {
              'stop_point': {
                'id': 'stop_point:SNCF:87286732:Train',
                'name': 'Roubaix',
                'label': 'Roubaix (Roubaix)',
                'coord': {'lon': '3.16351', 'lat': '50.695557'},
                'links': [],
                'equipments': []
              },
              'base_arrival_time': '101800',
              'base_departure_time': '101900',
              'cause': 'Incident sur un réseau ferré étranger',
              'stop_time_effect': 'deleted',
              'departure_status': 'deleted',
              'arrival_status': 'deleted',
              'is_detour': false
            },
            {
              'stop_point': {
                'id': 'stop_point:SNCF:87286542:Train',
                'name': 'Tourcoing',
                'label': 'Tourcoing (Tourcoing)',
                'coord': {'lon': '3.168027', 'lat': '50.716826'},
                'links': [],
                'equipments': []
              },
              'base_arrival_time': '102300',
              'base_departure_time': '102400',
              'cause': 'Incident sur un réseau ferré étranger',
              'stop_time_effect': 'deleted',
              'departure_status': 'deleted',
              'arrival_status': 'deleted',
              'is_detour': false
            },
            {
              'stop_point': {
                'id': 'stop_point:SNCF:88857040:Train',
                'name': 'Mouscron',
                'label': 'Mouscron (Mouscron)',
                'coord': {'lon': '3.22746', 'lat': '50.74026'},
                'links': [],
                'equipments': []
              },
              'base_arrival_time': '102900',
              'base_departure_time': '103600',
              'amended_departure_time': '103600',
              'cause': 'Incident sur un réseau ferré étranger',
              'stop_time_effect': 'deleted',
              'departure_status': 'unchanged',
              'arrival_status': 'deleted',
              'is_detour': false
            },
            {
              'stop_point': {
                'id': 'stop_point:SNCF:88960080:Train',
                'name': 'Kortrijk',
                'label': 'Kortrijk (Kortrijk)',
                'coord': {'lon': '3.265676', 'lat': '50.824339'},
                'links': [],
                'equipments': []
              },
              'base_arrival_time': '104500',
              'base_departure_time': '104500',
              'amended_arrival_time': '104500',
              'amended_departure_time': '104500',
              'cause': '',
              'stop_time_effect': 'unchanged',
              'departure_status': 'unchanged',
              'arrival_status': 'unchanged',
              'is_detour': false
            }
          ]
        }
      ]
    };
  }

  @override
  Widget build(BuildContext context) {
    final impactedObjects = disruptionInfo['impacted_objects'] as List?;
    final stops = impactedObjects?.isNotEmpty == true
        ? (impactedObjects!.first['impacted_stops'] as List?) ?? []
        : <dynamic>[];

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // En-tête
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getDisruptionColor(
                        disruptionInfo['disruptionType'] as String)
                    .withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getDisruptionIcon(
                        disruptionInfo['disruptionType'] as String),
                    color: _getDisruptionColor(
                        disruptionInfo['disruptionType'] as String),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getDisruptionTitle(
                              disruptionInfo['disruptionType'] as String),
                          style: AppTypography.headlineMedium.copyWith(
                            color: _getDisruptionColor(
                                disruptionInfo['disruptionType'] as String),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$trainType $trainNumber',
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.gray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Message principal
            if (disruptionInfo['message'] != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Text(
                  disruptionInfo['message'] as String,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            // Liste des arrêts
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: stops.length,
                itemBuilder: (context, index) {
                  final stop = stops[index] as Map<String, dynamic>;
                  return _buildStopItem(
                      stop, index == 0, index == stops.length - 1);
                },
              ),
            ),

            // Bouton fermer
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getDisruptionColor(
                        disruptionInfo['disruptionType'] as String),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Fermer'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopItem(Map<String, dynamic> stop, bool isFirst, bool isLast) {
    final stopPoint = stop['stop_point'] as Map<String, dynamic>?;
    final stationName = stopPoint?['name'] as String? ?? 'Gare inconnue';
    final baseArrival = stop['base_arrival_time'] as String?;
    final baseDeparture = stop['base_departure_time'] as String?;
    final amendedArrival = stop['amended_arrival_time'] as String?;
    final amendedDeparture = stop['amended_departure_time'] as String?;
    final stopTimeEffect = stop['stop_time_effect'] as String?;
    final departureStatus = stop['departure_status'] as String?;
    final arrivalStatus = stop['arrival_status'] as String?;

    final isDeleted = stopTimeEffect == 'deleted' ||
        departureStatus == 'deleted' ||
        arrivalStatus == 'deleted';

    final hasDelay = (amendedArrival != null &&
            baseArrival != null &&
            amendedArrival != baseArrival) ||
        (amendedDeparture != null &&
            baseDeparture != null &&
            amendedDeparture != baseDeparture);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDeleted
            ? Colors.red.withValues(alpha: 0.1)
            : hasDelay
                ? Colors.orange.withValues(alpha: 0.1)
                : AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDeleted
              ? Colors.red.withValues(alpha: 0.3)
              : hasDelay
                  ? Colors.orange.withValues(alpha: 0.3)
                  : AppColors.light,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Indicateur de statut
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isDeleted
                  ? Colors.red
                  : hasDelay
                      ? Colors.orange
                      : Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),

          // Nom de la gare
          Expanded(
            child: Text(
              stationName,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: isDeleted ? Colors.red : AppColors.dark,
                decoration: isDeleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),

          // Horaires
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (baseArrival != null && baseArrival != baseDeparture)
                _buildTimeRow(
                  'Arrivée',
                  _formatTime(baseArrival),
                  amendedArrival != null ? _formatTime(amendedArrival) : null,
                  isDeleted || arrivalStatus == 'deleted',
                ),
              if (baseDeparture != null)
                _buildTimeRow(
                  'Départ',
                  _formatTime(baseDeparture),
                  amendedDeparture != null
                      ? _formatTime(amendedDeparture)
                      : null,
                  isDeleted || departureStatus == 'deleted',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRow(
      String label, String baseTime, String? amendedTime, bool isDeleted) {
    final hasChange = amendedTime != null && amendedTime != baseTime;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.gray,
            fontSize: 10,
          ),
        ),
        if (isDeleted)
          Text(
            baseTime,
            style: AppTypography.bodySmall.copyWith(
              color: Colors.red,
              decoration: TextDecoration.lineThrough,
            ),
          )
        else if (hasChange)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                baseTime,
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.orange,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '→',
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                amendedTime!,
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        else
          Text(
            baseTime,
            style: AppTypography.bodySmall.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  String _formatTime(String timeStr) {
    if (timeStr.length >= 4) {
      final hours = timeStr.substring(0, 2);
      final minutes = timeStr.substring(2, 4);
      return '$hours:$minutes';
    }
    return timeStr;
  }

  Color _getDisruptionColor(String type) {
    switch (type) {
      case 'blocking':
        return Colors.red;
      case 'delayed':
        return Colors.orange;
      case 'reduced':
        return Colors.amber;
      case 'info':
      default:
        return Colors.blue;
    }
  }

  IconData _getDisruptionIcon(String type) {
    switch (type) {
      case 'blocking':
        return Icons.block;
      case 'delayed':
        return Icons.schedule;
      case 'reduced':
        return Icons.reduce_capacity;
      case 'info':
      default:
        return Icons.info_outline;
    }
  }

  String _getDisruptionTitle(String type) {
    switch (type) {
      case 'blocking':
        return 'Trajet bloqué';
      case 'delayed':
        return 'Retard signalé';
      case 'reduced':
        return 'Service réduit';
      case 'info':
      default:
        return 'Information';
    }
  }
}
