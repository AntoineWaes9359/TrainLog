import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trainlog/theme/app_theme.dart';
import 'package:trainlog/theme/colors.dart';
import 'package:trainlog/theme/typography.dart';
import '../providers/trip_provider_improved.dart';
import '../models/trip.dart';
import '../widgets/common/info_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).colorScheme.background,
            pinned: true,
            elevation: 0,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
              title: Text(
                l10n.statsTitle,
                style: AppTypography.displaySmall.copyWith(
                    color: Theme.of(context).colorScheme.onBackground),
              ),
              centerTitle: false,
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
                // Exemples d'utilisation du widget InfoCard
                _buildInfoCardsExample(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period) {
    final l10n = AppLocalizations.of(context)!;
    bool isSelected = _selectedPeriod == period;

    // Traduire 'ALL-TIME' en 'TOUT'
    String displayText = period == 'ALL-TIME' ? l10n.allTime : period;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          displayText,
          style: AppTypography.bodySmall.copyWith(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {
        final l10n = AppLocalizations.of(context)!;
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
            gradient: AppColors.linearPrimaryAccent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              )
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
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'PASSPORT • PASS • PASAPORTE',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.white.withOpacity(0.6),
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
                          Text(
                            l10n.trains,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.white.withOpacity(0.8),
                            ),
                          ),
                          Text(
                            '$totalTrips',
                            style: AppTypography.displayMedium.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$longDistanceTrips Long Distance',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.white.withOpacity(0.8),
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
                          Text(
                            l10n.distance,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.white.withOpacity(0.8),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '${totalDistance.toStringAsFixed(0)}',
                                style: AppTypography.displayMedium.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                l10n.kilometers,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _getRandomDistanceComparison(totalDistance),
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.white.withOpacity(0.8),
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
                          Text(
                            l10n.time,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.white.withOpacity(0.8),
                            ),
                          ),
                          Text(
                            _formatDuration(totalTime),
                            style: AppTypography.headlineSmall.copyWith(
                              color: AppColors.white,
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
                          Text(
                            l10n.stations,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.white.withOpacity(0.8),
                            ),
                          ),
                          Text(
                            '$stationsCount',
                            style: AppTypography.headlineSmall.copyWith(
                              color: AppColors.white,
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
                          Text(
                            l10n.companies,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.white.withOpacity(0.8),
                            ),
                          ),
                          Text(
                            '$companiesCount',
                            style: AppTypography.headlineSmall.copyWith(
                              color: AppColors.white,
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
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Toutes les statistiques',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
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
        final trips = _getTripsForPeriod(tripProvider.trips);
        final mostRidden = _getMostRiddenTrain(trips);

        if (mostRidden == null) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Train le plus emprunté',
                style: AppTypography.headlineMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.train,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mostRidden.type.toUpperCase(),
                          style: AppTypography.headlineSmall.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${mostRidden.count} voyage${mostRidden.count > 1 ? 's' : ''}',
                          style: AppTypography.bodyMedium.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCardsExample() {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Exemples InfoCard',
            style: AppTypography.headlineMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          InfoCard(
            icon: Icons.info,
            title: 'Information',
            subtitle: 'Ceci est un exemple d\'InfoCard',
            description: 'Description optionnelle pour plus de détails',
            onTap: () {
              // Action optionnelle
            },
          ),
          const SizedBox(height: 8),
          InfoCard(
            icon: Icons.warning,
            title: 'Attention',
            subtitle: 'InfoCard sans description',
            backgroundColor: Colors.orange.withOpacity(0.1),
            borderColor: Colors.orange.withOpacity(0.3),
            iconColor: Colors.orange,
          ),
        ],
      ),
    );
  }
}
