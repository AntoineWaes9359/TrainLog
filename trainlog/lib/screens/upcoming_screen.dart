import 'package:flip_board/flip_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trainlog/screens/add_trip_screen_v2.dart';
import 'package:trainlog/theme/colors.dart';
import '../providers/trip_provider.dart';
import 'trip_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/train_logo.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';
import 'package:flip_board/flip_board.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class AutoMarquee extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double width;

  const AutoMarquee({
    super.key,
    required this.text,
    required this.style,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 20,
      child: text.length > 35
          ? Marquee(
              text: text,
              style: style,
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              blankSpace: 20.0,
              velocity: 30.0,
              pauseAfterRound: const Duration(seconds: 2),
              startPadding: 0.0,
              accelerationDuration: const Duration(seconds: 1),
              accelerationCurve: Curves.linear,
              decelerationDuration: const Duration(milliseconds: 500),
              decelerationCurve: Curves.easeOut,
              showFadingOnlyWhenScrolling: true,
              fadingEdgeStartFraction: 0.1,
              fadingEdgeEndFraction: 0.1,
            )
          : Text(
              text,
              style: style,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
    );
  }
}

class TimeStationBlock extends StatelessWidget {
  final DateTime time;
  final String station;

  const TimeStationBlock({
    super.key,
    required this.time,
    required this.station,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          DateFormat('HH:mm').format(time),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const Text(' '),
        Expanded(
          child: SizedBox(
            height: 20,
            child: Marquee(
              text: station,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.ter,
              ),
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              blankSpace: 20.0,
              velocity: 30.0,
              pauseAfterRound: const Duration(seconds: 2),
              startPadding: 0.0,
              accelerationDuration: const Duration(seconds: 1),
              accelerationCurve: Curves.linear,
              decelerationDuration: const Duration(milliseconds: 500),
              decelerationCurve: Curves.easeOut,
              showFadingOnlyWhenScrolling: true,
              fadingEdgeStartFraction: 0.1,
              fadingEdgeEndFraction: 0.1,
            ),
          ),
        ),
      ],
    );
  }
}

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

  String _getTimeUnit(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    final days = difference.inDays;

    if (days < 1) {
      return 'HEURES';
    }
    return 'JOURS';
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Consumer<TripProvider>(
          builder: (context, tripProvider, child) {
            if (tripProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final trips = tripProvider.upcomingTrips;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 24,
                      top: 60,
                      bottom: 5,
                    ),
                    child: Text(
                      'À venir',
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _getTimeUntil(trip.departureTime),
                                        style: GoogleFonts.inter(
                                          fontSize: 35,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      Text(
                                        _getTimeUnit(trip.departureTime),
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          color: AppColors.secondary,
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
                                            DateFormat('E d MMM', 'fr_FR')
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
