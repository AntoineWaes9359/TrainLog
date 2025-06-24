import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:trainlog/providers/trip_provider_improved.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'dart:io' show Platform;
import 'package:trainlog/screens/trip_detail_screen.dart';
import 'package:trainlog/widgets/train_logo.dart';
import 'package:trainlog/theme/typography.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:trainlog/utils/date_formatter.dart';
import 'package:trainlog/widgets/common/time_station_block.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Set<Polyline> _polylines = {};
  bool _isLoadingPaths = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTripPaths();
    });
  }

  Future<void> _loadTripPaths() async {
    if (!Platform.isIOS) return;

    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final trips = tripProvider.pastTrips;

    setState(() => _isLoadingPaths = true);

    final newPolylines = <Polyline>{};
    for (final trip in trips) {
      if (trip.path != null && trip.path!.isNotEmpty) {
        final List<LatLng> points = trip.path!
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        if (points.isNotEmpty) {
          // Polyline "glow" (large, transparente)
          newPolylines.add(
            Polyline(
              polylineId: PolylineId('trip_glow_${trip.id}'),
              points: points,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
              width: 10,
              polylineCap: Cap.roundCap,
            ),
          );
          // Polyline principale (fine, vive)
          newPolylines.add(
            Polyline(
              polylineId: PolylineId('trip_${trip.id}'),
              points: points,
              color: Theme.of(context).colorScheme.primary,
              width: 4,
              polylineCap: Cap.roundCap,
            ),
          );
        }
      }
    }

    if (mounted) {
      setState(() {
        _polylines.addAll(newPolylines);
        _isLoadingPaths = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Consumer<TripProvider>(
        builder: (context, tripProvider, child) {
          if (tripProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final trips = tripProvider.pastTrips;

          if (trips.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history,
                      size: 64, color: Theme.of(context).colorScheme.onSurface),
                  const SizedBox(height: 16),
                  Text(l10n.noTripsInHistory,
                      style: AppTypography.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    l10n.pastTripsWillAppearHere,
                    style: AppTypography.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 500.0,
                pinned: true,
                floating: false,
                backgroundColor: Theme.of(context).colorScheme.background,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                  title: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surface
                              .withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          l10n.historyTitle,
                          style: AppTypography.displaySmall.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  centerTitle: false,
                  background: _buildMap(),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index.isOdd) {
                      return Divider(
                        height: 1,
                        thickness: 1,
                        color: Theme.of(context).colorScheme.surface,
                        indent: 16,
                        endIndent: 16,
                      );
                    }

                    final trip = trips[index ~/ 2];

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TripDetailScreen(trip: trip),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              // Informations du trajet
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Row 1: Train info
                                    Row(
                                      children: [
                                        TrainLogo(
                                            trainType: trip.trainType,
                                            size: 12),
                                        const SizedBox(width: 8),
                                        Text(
                                          trip.trainType.toUpperCase(),
                                          style: AppTypography.labelMedium
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            trip.trainNumber,
                                            style: AppTypography.trainNumber
                                                .copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSecondary),
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
                                                      .onSurface),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Row 2: Trip cities
                                    Row(
                                      children: [
                                        Text(trip.departureCityName,
                                            style: AppTypography.stationName),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Icon(Icons.arrow_forward,
                                              size: 16,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground),
                                        ),
                                        Text(trip.arrivalCityName,
                                            style: AppTypography.stationName),
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
                  childCount: trips.length * 2 - 1,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMap() {
    if (!Platform.isIOS) {
      return Container(
        color: Theme.of(context).colorScheme.surface,
        child: Center(
          child: Text(
            'Map is only available on iOS for now.',
            style: AppTypography.bodyMedium
                .copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
      );
    }
    return AppleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(46.61, 2.35), // Center on France
        zoom: 4.5,
      ),
      polylines: _polylines,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      gestureRecognizers: {
        Factory<OneSequenceGestureRecognizer>(
          () => EagerGestureRecognizer(),
        ),
      },
    );
  }
}
