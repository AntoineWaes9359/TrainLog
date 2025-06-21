import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trip.dart';
import '../providers/trip_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'dart:io' show Platform;
import 'trip_detail_screen.dart';
import '../widgets/train_logo.dart';
import '../theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final Set<Polyline> _polylines = {};
  bool _isLoadingPaths = false;

  Color _getColorForTrainType(String trainType) {
    /* final type = trainType.toUpperCase();
    if (type.contains('TGV')) {
      return AppColors.tgv;
    } else if (type.contains('OUIGO')) {
      return AppColors.ouigo;
    } else if (type.contains('TER')) {
      return AppColors.ter;
    }
    return AppColors.other; */
    return AppColors.blueElectric;
  }

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

    setState(() {
      _isLoadingPaths = true;
    });

    for (final trip in trips) {
      if (trip.path != null && trip.path!.isNotEmpty) {
        final List<LatLng> points = trip.path!.map((point) {
          return LatLng(point.latitude, point.longitude);
        }).toList();

        if (points.isNotEmpty) {
          // Polyline "glow" (large, transparente)
          setState(() {
            _polylines.add(
              Polyline(
                polylineId: PolylineId('trip_glow_${trip.id}'),
                points: points,
                color: AppColors.primary.withOpacity(0.18),
                width: 7,
                polylineCap: Cap.roundCap,
              ),
            );
          });
          // Polyline principale (fine, vive)
          setState(() {
            _polylines.add(
              Polyline(
                polylineId: PolylineId('trip_${trip.id}'),
                points: points,
                color: AppColors.secondary,
                width: 3,
                polylineCap: Cap.roundCap,
              ),
            );
          });
        }
      }
    }

    setState(() {
      _isLoadingPaths = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
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
                  const Icon(
                    Icons.history,
                    size: 64,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun trajet dans l\'historique',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vos trajets passés apparaîtront ici',
                    style: TextStyle(
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 400.0,
                pinned: false,
                backgroundColor: Colors.transparent,
                iconTheme: const IconThemeData(color: AppColors.primary),
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildMap(),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 24,
                    top: 10,
                    bottom: 5,
                  ),
                  child: Text(
                    'Historique',
                    style: GoogleFonts.nunito(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index.isOdd) {
                      return const Divider(
                        height: 1,
                        thickness: 0.5,
                        color: AppColors.light,
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
                        padding: const EdgeInsets.only(
                          left: 22,
                          right: 22,
                          top: 10,
                          bottom: 10,
                        ),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Informations du trajet
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w300,
                                            color: AppColors.dark,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
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
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.white,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          DateFormat('dd/MM/yyyy', 'fr_FR')
                                              .format(trip.departureTime),
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: AppColors.ter,
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
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.dark,
                                          ),
                                        ),
                                        Text(
                                          ' → ',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w300,
                                            color: AppColors.dark,
                                          ),
                                        ),
                                        Text(
                                          trip.arrivalCityName,
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.dark,
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
                  childCount: trips.length * 2 - 1,
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMap() {
    if (!Platform.isIOS) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        AppleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(46.603354, 1.888334), // Centre de la France
            zoom: 1, // Vue globale du globe
          ),
          polylines: _polylines,
          mapType: MapType.standard,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          rotateGesturesEnabled: true,
          gestureRecognizers: {
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
          onMapCreated: (controller) {
            // Attendre que la carte soit chargée
            Future.delayed(const Duration(milliseconds: 500), () {
              // Animer le zoom vers la France
              controller.animateCamera(
                CameraUpdate.newCameraPosition(
                  const CameraPosition(
                    target: LatLng(46.603354, 1.888334),
                    zoom: 5,
                  ),
                ),
              );
            });
          },
        ),
        if (_isLoadingPaths)
          const Positioned.fill(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
