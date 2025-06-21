import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trainlog/theme/colors.dart';
import '../providers/trip_provider.dart';
import 'package:intl/intl.dart';
import '../models/trip.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String _selectedPeriod = 'ALL-TIME';
  final List<String> _periods = [
    'ALL-TIME',
    '2025',
    '2024',
    '2023',
    '2022',
    '2021',
  ];

  final List<({String label, double distance})> _distanceComparisons = [
    (label: 'la France', distance: 1000.0),
    (label: 'la Terre à la Lune', distance: 384400.0),
    (label: 'le tour du monde', distance: 40075.0),
    (label: 'l\'Allemagne', distance: 800.0),
    (label: 'l\'Espagne', distance: 1000.0),
    (label: 'l\'Italie', distance: 1000.0),
    (label: 'la Suisse', distance: 350.0),
    (label: 'la Belgique', distance: 200.0),
    (label: 'les Pays-Bas', distance: 300.0),
    (label: 'le Royaume-Uni', distance: 1000.0),
    (label: 'le Portugal', distance: 600.0),
    (label: 'la Suède', distance: 1500.0),
    (label: 'la Norvège', distance: 1700.0),
    (label: 'la Finlande', distance: 1200.0),
    (label: 'le Danemark', distance: 400.0),
  ];

  String _getRandomDistanceComparison(double totalDistance) {
    final random = _distanceComparisons[
        DateTime.now().millisecondsSinceEpoch % _distanceComparisons.length];
    final ratio = totalDistance / random.distance;
    return '${ratio.toStringAsFixed(1)}x ${random.label}';
  }

  List<Trip> _getTripsForPeriod(List<Trip> allTrips) {
    if (_selectedPeriod == 'ALL-TIME') {
      return allTrips;
    }

    final year = int.parse(_selectedPeriod);
    return allTrips.where((trip) {
      return trip.departureTime.year == year;
    }).toList();
  }

  int _getTotalTrips(List<Trip> trips) {
    return trips.length;
  }

  int _getLongDistanceTrips(List<Trip> trips) {
    return trips.where((trip) => trip.distance >= 500).length;
  }

  double _getTotalDistance(List<Trip> trips) {
    return trips.fold(0.0, (sum, trip) => sum + trip.distance);
  }

  Duration _getTotalTime(List<Trip> trips) {
    return trips.fold(
      Duration.zero,
      (sum, trip) => sum + trip.arrivalTime.difference(trip.departureTime),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (minutes == 0) {
      return '${hours}h';
    }
    return '${hours}h${minutes}m';
  }

  int _getUniqueStationsCount(List<Trip> trips) {
    final Set<String> stations = {};
    for (final trip in trips) {
      stations.add(trip.departureStation);
      stations.add(trip.arrivalStation);
    }
    return stations.length;
  }

  int _getUniqueCompaniesCount(List<Trip> trips) {
    // Pour l'instant, nous n'avons que SNCF
    return trips.isEmpty ? 0 : 1;
  }

  ({String type, int count})? _getMostRiddenTrain(List<Trip> trips) {
    if (trips.isEmpty) return null;

    final Map<String, int> trainTypeCounts = {};
    for (final trip in trips) {
      trainTypeCounts[trip.trainType] =
          (trainTypeCounts[trip.trainType] ?? 0) + 1;
    }

    String mostRiddenType =
        trainTypeCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return (type: mostRiddenType, count: trainTypeCounts[mostRiddenType]!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 24,
                top: 60,
                bottom: 5,
              ),
              child: Text(
                'Statistiques',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _periods.length,
                itemBuilder: (context, index) {
                  return _buildPeriodButton(_periods[index]);
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildStatsCard(),
                _buildMostRiddenTrainCard(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period) {
    bool isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.light,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          period,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.dark,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {
        final List<Trip> tripsForPeriod =
            _getTripsForPeriod(tripProvider.trips);
        final int totalTrips = _getTotalTrips(tripsForPeriod);
        final int longDistanceTrips = _getLongDistanceTrips(tripsForPeriod);
        final double totalDistance = _getTotalDistance(tripsForPeriod);
        final Duration totalTime = _getTotalTime(tripsForPeriod);
        final int stationsCount = _getUniqueStationsCount(tripsForPeriod);
        final int companiesCount = _getUniqueCompaniesCount(tripsForPeriod);

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(40, 75, 99, 1), // Couleur principale
                Color.fromRGBO(30, 58, 79, 1), // Légèrement plus foncée
                Color.fromRGBO(40, 75, 99, 1), // Couleur principale
                Color.fromRGBO(50, 91, 122, 1), // Légèrement plus claire
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.dark.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Titre
                Text(
                  '$_selectedPeriod TRAINLOG PASSPORT',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const Text(
                  'PASSPORT • PASS • PASAPORTE',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 20),
                // Première ligne : Trains et Distance
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre de trains
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TRAINS',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '$totalTrips',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$longDistanceTrips Long Distance',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Distance
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DISTANCE',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 14,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${totalDistance.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'km',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _getRandomDistanceComparison(totalDistance),
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Deuxième ligne : Temps, Gares et Compagnies
                Row(
                  children: [
                    // Temps de train
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TEMPS',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _formatDuration(totalTime),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Nombre de gares
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'GARES',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '$stationsCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Nombre de compagnies
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'COMPAGNIES',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '$companiesCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Bouton Voir toutes les statistiques
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Toutes les statistiques',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.white,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMostRiddenTrainCard() {
    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {
        final List<Trip> tripsForPeriod =
            _getTripsForPeriod(tripProvider.trips);
        final mostRiddenTrain = _getMostRiddenTrain(tripsForPeriod);

        if (mostRiddenTrain == null) {
          return Container(); // Ne rien afficher s'il n'y a pas de trajets
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.dark.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Train le plus fréquenté',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  mostRiddenTrain.type,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${mostRiddenTrain.count} ${mostRiddenTrain.count > 1 ? 'trajets' : 'trajet'}',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                // Bouton voir toutes les statistiques
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      onTap: () {
                        // Action à ajouter
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tous les trains',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.primary,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
