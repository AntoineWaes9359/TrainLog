import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trainlog/theme/colors.dart';
import 'package:trainlog/theme/typography.dart';
import '../providers/trip_provider_improved.dart';
import 'trip_detail_screen.dart';
import 'package:intl/intl.dart';
import '../widgets/train_logo.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import '../widgets/common/time_station_block.dart';
import '../widgets/common/info_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../utils/date_formatter.dart';

class UpcomingScreen extends StatefulWidget {
  const UpcomingScreen({super.key});

  @override
  State<UpcomingScreen> createState() => _UpcomingScreenState();
}

class _UpcomingScreenState extends State<UpcomingScreen> {
  final Map<int, StreamController<String>> _flipControllers = {};
  final Map<int, bool> _hasAnimated = {};

  String _getTimeUntil(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    final hours = difference.inHours;
    final days = difference.inDays;

    if (days < 1) {
      return hours.toString();
    }
    return days.toString();
  }

  String _getTimeUnit(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    final days = difference.inDays;

    if (days < 1) {
      return AppLocalizations.of(context)!.timeUnitHours;
    }
    return AppLocalizations.of(context)!.timeUnitDays;
  }

  @override
  void dispose() {
    for (final controller in _flipControllers.values) {
      controller.close();
    }
    super.dispose();
  }

  void _animateFlipToValue(int tripIndex, String target) async {
    if (_hasAnimated[tripIndex] == true) return;
    _hasAnimated[tripIndex] = true;
    int start = 20;
    int end = int.tryParse(target) ?? 0;
    for (int i = start; i >= end; i--) {
      await Future.delayed(const Duration(milliseconds: 120));
      _flipControllers[tripIndex]?.add(i.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Consumer<TripProvider>(
          builder: (context, tripProvider, child) {
            if (tripProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final trips = tripProvider.upcomingTrips;
            final nextTrip = tripProvider.getNextTrip();

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Theme.of(context).colorScheme.background,
                  pinned: true,
                  elevation: 0,
                  expandedHeight: 120,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                    title: Text(
                      l10n.upcomingTitle,
                      style: AppTypography.displaySmall.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    centerTitle: false,
                  ),
                ),
                // Affichage du prochain trajet en évidence si disponible
                if (nextTrip != null)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index.isOdd) {
                          return const Divider(
                            height: 1,
                            thickness: 0.5,
                            color: AppColors.light,
                            indent: 80,
                            endIndent: 16,
                          );
                        }

                        final trip = trips[index ~/ 2];
                        final tripIndex = index ~/ 2;
                        final timeUntil = _getTimeUntil(trip.departureTime);
                        _flipControllers.putIfAbsent(tripIndex,
                            () => StreamController<String>.broadcast());
                        _hasAnimated.putIfAbsent(tripIndex, () => false);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _animateFlipToValue(tripIndex, timeUntil);
                        });

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TripDetailScreen(trip: trip),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Bloc du nombre de jours/heures restantes
                                  SizedBox(
                                    width: 80,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _getTimeUntil(trip.departureTime),
                                          style: AppTypography.button.copyWith(
                                            fontSize: 35,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                          ),
                                        ),
                                        Text(
                                          _getTimeUnit(
                                              context, trip.departureTime),
                                          style:
                                              AppTypography.labelSmall.copyWith(
                                            color: AppColors.gray,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Bloc des villes
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Numéro de train et compagnie
                                        Row(
                                          children: [
                                            TrainLogo(
                                              trainType: trip.trainType,
                                              size: 10,
                                            ),
                                            const SizedBox(width: 16),
                                            Text(
                                              trip.trainType,
                                              style: AppTypography.bodySmall
                                                  .copyWith(
                                                fontWeight: FontWeight.w300,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onBackground,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.secondary,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                trip.trainNumber,
                                                style: AppTypography.trainNumber
                                                    .copyWith(
                                                  color: AppColors.secondaryFg,
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              DateFormatter.formatShortDate(
                                                  context, trip.departureTime),
                                              style: AppTypography.bodySmall
                                                  .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onBackground,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        // Trajet
                                        Row(
                                          children: [
                                            Text(
                                              trip.departureCityName,
                                              style: AppTypography.stationName
                                                  .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onBackground,
                                              ),
                                            ),
                                            Text(
                                              ' → ',
                                              style: AppTypography.bodyLarge
                                                  .copyWith(
                                                fontWeight: FontWeight.w300,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onBackground,
                                              ),
                                            ),
                                            Text(
                                              trip.arrivalCityName,
                                              style: AppTypography.stationName
                                                  .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onBackground,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        // Horaires
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  // Départ
                                                  Expanded(
                                                    flex: 2,
                                                    child: TimeStationBlock(
                                                      time: trip.departureTime,
                                                      station:
                                                          trip.departureStation,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  // Arrivée
                                                  Expanded(
                                                    flex: 2,
                                                    child: TimeStationBlock(
                                                      time: trip.arrivalTime,
                                                      station:
                                                          trip.arrivalStation,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: trips.length * 2,
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
