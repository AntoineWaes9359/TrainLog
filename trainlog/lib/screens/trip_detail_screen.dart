import 'package:flip_board/flip_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:trainlog/models/trip.dart';
import 'package:trainlog/providers/trip_provider_improved.dart';
import 'package:provider/provider.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'package:trainlog/widgets/common/custom_flip_board.dart';
import 'dart:io' show Platform;
import 'dart:ui' as ui;
import 'package:trainlog/widgets/train_logo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:trainlog/theme/typography.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:trainlog/widgets/carbon_footprint_card.dart';
import 'package:trainlog/services/sncf_realtime_service.dart';
import 'package:trainlog/widgets/common/info_card.dart';
import 'package:trainlog/widgets/disruption_details_modal.dart';

class TripDetailScreen extends StatefulWidget {
  final Trip trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen>
    with SingleTickerProviderStateMixin {
  Trip get trip => widget.trip;
  late String _ticketNumber;
  late String _seatNumber;
  late AnimationController _trainAnimationController;
  late Animation<double> _trainAnimation;
  late List<Color> _flipEndColors;

  // Variables pour les informations en temps réel
  Map<String, dynamic>? _realtimeInfo;
  bool _isLoadingRealtime = false;
  String? _realtimeError;

  @override
  void initState() {
    super.initState();
    _ticketNumber = trip.ticketNumber ?? '';
    _seatNumber = trip.seatNumber ?? '';

    // Initialisation de l'animation
    _trainAnimationController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    );

    _trainAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _trainAnimationController,
      curve: Curves.easeInOut,
    ));

    // Démarrer l'animation avec répétition
    _trainAnimationController.repeat(reverse: true);

    // Récupérer les informations en temps réel pour les trajets futurs
    _fetchRealtimeInfo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Mettre à jour les couleurs du flip board selon le thème
    _flipEndColors = [
      Theme.of(context).colorScheme.background,
      Theme.of(context).colorScheme.primary.withOpacity(0.1)
    ];
  }

  @override
  void dispose() {
    _trainAnimationController.dispose();
    super.dispose();
  }

  /// Récupère les informations en temps réel pour le trajet
  Future<void> _fetchRealtimeInfo() async {
    // Afficher pour les trajets futurs ET jusqu'à 6h après le départ prévu
    final now = DateTime.now();
    final sixHoursAfterDeparture =
        trip.departureTime.add(const Duration(hours: 6));

    if (now.isAfter(sixHoursAfterDeparture)) {
      return;
    }

    setState(() {
      _isLoadingRealtime = true;
      _realtimeError = null;
    });

    try {
      // Utiliser l'API réelle
      final info = await SncfRealtimeService.getRealtimeInfo(
        trip.trainNumber,
        trip.departureTime,
        trip.trainType,
      );

      if (mounted) {
        setState(() {
          _realtimeInfo = info;
          _isLoadingRealtime = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRealtime = false;
          _realtimeError =
              'Impossible de récupérer les informations en temps réel';
        });
      }
    }
  }

  /// Rafraîchit les informations en temps réel
  Future<void> _refreshRealtimeInfo() async {
    await _fetchRealtimeInfo();
  }

  /// Obtient le titre de la perturbation
  String _getDisruptionTitle(String disruptionType) {
    switch (disruptionType) {
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

  /// Obtient la description de la perturbation
  String _getDisruptionDescription(Map<String, dynamic> disruptionInfo) {
    final delayMinutes = disruptionInfo['delayMinutes'] as int?;
    final cause = disruptionInfo['cause'] as String?;
    final hasDeletedStops = disruptionInfo['hasDeletedStops'] as bool?;
    final isFullyCancelled = disruptionInfo['isFullyCancelled'] as bool?;

    List<String> parts = [];

    if (isFullyCancelled == true) {
      parts.add('Train complètement annulé');
    } else if (hasDeletedStops == true) {
      parts.add('Certains arrêts supprimés');
    }

    if (delayMinutes != null && delayMinutes > 0) {
      parts.add('Retard de $delayMinutes minutes');
    }

    if (cause != null && cause.isNotEmpty) {
      parts.add('Cause: $cause');
    }

    return parts.join(' • ');
  }

  /// Obtient l'icône de la perturbation
  IconData _getDisruptionIcon(String disruptionType) {
    switch (disruptionType) {
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

  /// Obtient la couleur de l'icône
  Color _getDisruptionColor(String disruptionType) {
    switch (disruptionType) {
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

  /// Obtient la couleur de fond
  Color _getDisruptionBackgroundColor(String disruptionType) {
    switch (disruptionType) {
      case 'blocking':
        return Colors.red.withOpacity(0.1);
      case 'delayed':
        return Colors.orange.withOpacity(0.1);
      case 'reduced':
        return Colors.amber.withOpacity(0.1);
      case 'info':
      default:
        return Colors.blue.withOpacity(0.1);
    }
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.copiedToClipboard),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData?.text != null && mounted) {
      final tripProvider = context.read<TripProvider>();
      setState(() {
        _ticketNumber = clipboardData!.text!;
      });
      final updatedTrip = trip.copyWith(ticketNumber: _ticketNumber);
      await tripProvider.updateTrip(updatedTrip);
    }
  }

  Future<void> _editSeat() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String tempSeatNumber = _seatNumber;
        return AlertDialog(
          title: Text(l10n.editSeatTitle),
          content: TextField(
            controller: TextEditingController(text: tempSeatNumber),
            decoration: InputDecoration(
              labelText: l10n.seatNumberLabel,
              hintText: l10n.seatNumberHint,
            ),
            onChanged: (value) => tempSeatNumber = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancelButton),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, tempSeatNumber),
              child: Text(l10n.saveButton),
            ),
          ],
        );
      },
    );

    if (result != null && mounted) {
      final tripProvider = context.read<TripProvider>();
      setState(() {
        _seatNumber = result;
      });
      final updatedTrip = trip.copyWith(seatNumber: _seatNumber);
      await tripProvider.updateTrip(updatedTrip);
    }
  }

  int _getDaysUntil(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(now) ? 0 : date.difference(now).inDays;
  }

  Future<BitmapDescriptor> _createCustomMarkerIcon(bool isDeparture) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double size = 100;

    final Color mainColor = isDeparture
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.secondary;

    final Paint shadowPaint = Paint()
      ..color = Theme.of(context).colorScheme.onSurface.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(
        const Offset(size / 2, size / 2 + 4), size / 2.5, shadowPaint);

    final Paint circlePaint = Paint()
      ..color = Theme.of(context).colorScheme.background;
    canvas.drawCircle(
        const Offset(size / 2, size / 2), size / 2.2, circlePaint);

    final Paint borderPaint = Paint()
      ..color = mainColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(
        const Offset(size / 2, size / 2), size / 2.2, borderPaint);

    final IconData icon =
        isDeparture ? Icons.train_outlined : Icons.flag_outlined;
    final TextPainter textPainter =
        TextPainter(textDirection: ui.TextDirection.ltr)
          ..text = TextSpan(
            text: String.fromCharCode(icon.codePoint),
            style: TextStyle(
              fontSize: 40,
              fontFamily: icon.fontFamily,
              color: mainColor,
              package: icon.fontPackage,
            ),
          )
          ..layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    final image = await pictureRecorder
        .endRecording()
        .toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  Widget _buildMap() {
    if (!Platform.isIOS) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<BitmapDescriptor>>(
      future: Future.wait([
        _createCustomMarkerIcon(true), // Icône de départ
        _createCustomMarkerIcon(false), // Icône d'arrivée
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final departureIcon = snapshot.data![0];
        final arrivalIcon = snapshot.data![1];
        final l10n = AppLocalizations.of(context)!;

        // Créer un set de marqueurs pour le départ et l'arrivée
        final Set<Annotation> markers = {
          Annotation(
            annotationId: AnnotationId('departure'),
            position: LatLng(
              trip.departureCityGeo.latitude,
              trip.departureCityGeo.longitude,
            ),
            icon: departureIcon,
            infoWindow: InfoWindow(
              title: trip.departureStation,
              snippet:
                  '${l10n.departureLabel} ${DateFormat('HH:mm').format(trip.departureTime)}',
              anchor: const Offset(0.5, 0.0),
            ),
            onTap: () {},
            zIndex: 2.0,
          ),
          Annotation(
            annotationId: AnnotationId('arrival'),
            position: LatLng(
              trip.arrivalCityGeo.latitude,
              trip.arrivalCityGeo.longitude,
            ),
            icon: arrivalIcon,
            infoWindow: InfoWindow(
              title: trip.arrivalStation,
              snippet:
                  '${l10n.arrivalLabel} ${DateFormat('HH:mm').format(trip.arrivalTime)}',
              anchor: const Offset(0.5, 0.0),
            ),
            onTap: () {},
            zIndex: 2.0,
          ),
        };

        // Créer la Polyline pour le trajet
        Set<Polyline> polylines = {};
        List<LatLng> boundPoints = [
          LatLng(
              trip.departureCityGeo.latitude, trip.departureCityGeo.longitude),
          LatLng(trip.arrivalCityGeo.latitude, trip.arrivalCityGeo.longitude),
        ];

        // Si path est nul ou vide, créer un chemin simple entre les gares
        if (trip.path == null || trip.path.isEmpty) {
          // Polyline "glow"
          polylines.add(
            Polyline(
              polylineId: PolylineId('route_glow'),
              points: boundPoints,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.18),
              width: 16,
              polylineCap: Cap.roundCap,
            ),
          );
          // Polyline principale
          polylines.add(
            Polyline(
              polylineId: PolylineId('route'),
              points: boundPoints,
              color: Theme.of(context).colorScheme.secondary,
              width: 8,
              polylineCap: Cap.roundCap,
            ),
          );
        } else {
          final List<LatLng> polylinePoints = trip.path
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();

          // Polyline "glow"
          polylines.add(
            Polyline(
              polylineId: PolylineId('route_glow'),
              points: polylinePoints,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.18),
              width: 16,
              polylineCap: Cap.roundCap,
            ),
          );
          // Polyline principale
          polylines.add(
            Polyline(
              polylineId: PolylineId('route'),
              points: polylinePoints,
              color: Theme.of(context).colorScheme.secondary,
              width: 8,
              polylineCap: Cap.roundCap,
            ),
          );

          boundPoints = polylinePoints;
        }

        // Calculer les limites de la carte pour inclure les points nécessaires
        final minLat = boundPoints.map((p) => p.latitude).reduce(min);
        final maxLat = boundPoints.map((p) => p.latitude).reduce(max);
        final minLng = boundPoints.map((p) => p.longitude).reduce(min);
        final maxLng = boundPoints.map((p) => p.longitude).reduce(max);

        // Ajouter un petit padding aux bounds pour éviter que les marqueurs soient collés aux bords
        final latPadding = (maxLat - minLat) * 0.1;
        final lngPadding = (maxLng - minLng) * 0.1;

        final bounds = LatLngBounds(
          southwest: LatLng(
            minLat - latPadding,
            minLng - lngPadding,
          ),
          northeast: LatLng(
            maxLat + latPadding,
            maxLng + lngPadding,
          ),
        );

        // Calculer le centre du trajet
        final centerLat = (minLat + maxLat) / 2;
        final centerLng = (minLng + maxLng) / 2;

        return SizedBox(
          height: 300,
          child: AppleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(centerLat, centerLng),
              zoom: 6, // Zoom par défaut
            ),
            annotations: markers,
            polylines: polylines,
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
            onMapCreated: (AppleMapController controller) {
              // Attendre un peu avant de déplacer la caméra pour s'assurer que la carte est prête
              Future.delayed(const Duration(milliseconds: 100), () {
                controller.moveCamera(
                  CameraUpdate.newLatLngBounds(
                    bounds,
                    50.0, // padding en pixels
                  ),
                );
              });
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final sixHoursAfterDeparture =
        trip.departureTime.add(const Duration(hours: 6));
    final shouldShowRealtime = now.isBefore(sixHoursAfterDeparture);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
              title: Container(
                  // padding:
                  //     const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  // decoration: BoxDecoration(
                  //   color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                  //   borderRadius: BorderRadius.circular(12),
                  //   border: Border.all(
                  //     color: Theme.of(context)
                  //         .colorScheme
                  //         .onSurface
                  //         .withOpacity(0.1),
                  //     width: 1,
                  //   ),
                  // ),
                  // child: Text(
                  //   "${trip.departureCityName} → ${trip.arrivalCityName}",
                  //   style: AppTypography.displaySmall.copyWith(
                  //     color: Theme.of(context).colorScheme.onSurface,
                  //     fontWeight: FontWeight.w600,
                  //     fontSize: 10,
                  //   ),
                  // ),
                  ),
              centerTitle: false,
              background: _buildMap(),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(0.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildTripTimeline(),
                  const SizedBox(height: 24),
                  // Informations en temps réel (si disponibles)
                  if (shouldShowRealtime && _realtimeInfo != null)
                    InfoCard(
                      title: _getDisruptionTitle(
                          _realtimeInfo!['disruptionType'] as String),
                      subtitle: _realtimeInfo!['message'] as String,
                      description: _getDisruptionDescription(_realtimeInfo!),
                      icon: _getDisruptionIcon(
                          _realtimeInfo!['disruptionType'] as String),
                      iconColor: _getDisruptionColor(
                          _realtimeInfo!['disruptionType'] as String),
                      backgroundColor: _getDisruptionBackgroundColor(
                          _realtimeInfo!['disruptionType'] as String),
                      borderColor: _getDisruptionColor(
                              _realtimeInfo!['disruptionType'] as String)
                          .withOpacity(0.3),
                      titleColor: _getDisruptionColor(
                          _realtimeInfo!['disruptionType'] as String),
                      subtitleColor: Theme.of(context).colorScheme.onSurface,
                      descriptionColor: _getDisruptionColor(
                          _realtimeInfo!['disruptionType'] as String),
                      onTap: _showDisruptionDetails,
                    ),
                  if (shouldShowRealtime && _isLoadingRealtime)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Vérification des informations en temps réel...',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (shouldShowRealtime && _realtimeError != null)
                    Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.orange),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _realtimeError!,
                                style: AppTypography.bodyMedium
                                    .copyWith(color: Colors.orange),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh, size: 20),
                              onPressed: _refreshRealtimeInfo,
                              color: Colors.orange,
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (shouldShowRealtime && _realtimeInfo != null ||
                      shouldShowRealtime && _isLoadingRealtime ||
                      shouldShowRealtime && _realtimeError != null)
                    const SizedBox(height: 24),
                  if (shouldShowRealtime) _buildCountdownCard(l10n),
                  if (shouldShowRealtime) const SizedBox(height: 24),
                  _buildJourneyInfoCard(l10n),
                  const SizedBox(height: 16),
                  _buildTicketInfoCard(l10n),
                  const SizedBox(height: 16),
                  _buildCarbonFootprintCard(l10n),
                  const SizedBox(height: 16),
                  _buildTripStatsCard(l10n),
                  const SizedBox(height: 24),
                  _buildDeleteButton(l10n),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TrainLogo(trainType: trip.trainType, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trip.trainType.toUpperCase(),
                    style: AppTypography.labelLarge.copyWith(
                        color: Theme.of(context).colorScheme.onSurface)),
                Text(
                  "${trip.departureCityName} → ${trip.arrivalCityName}",
                  style: AppTypography.headlineMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(trip.trainNumber,
                style: AppTypography.trainNumber.copyWith(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSecondary)),
          )
        ],
      ),
    );
  }

  Widget _buildTripTimeline() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeColumn(trip.departureTime, trip.departureStation),
          _buildTimelineGraphic(),
          _buildTimeColumn(trip.arrivalTime, trip.arrivalStation,
              isArrival: true),
        ],
      ),
    );
  }

  Widget _buildTimeColumn(DateTime time, String station,
      {bool isArrival = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment:
            isArrival ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          _flipFraseBoard(
            '${DateFormat('HH').format(time)}H${DateFormat('mm').format(time)}',
          ),
          const SizedBox(height: 8),
          Text(station,
              style: AppTypography.bodyMedium
                  .copyWith(color: Theme.of(context).colorScheme.onSurface),
              textAlign: isArrival ? TextAlign.right : TextAlign.left),
        ],
      ),
    );
  }

  Widget _buildTimelineGraphic() {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: LayoutBuilder(builder: (context, constraints) {
              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Layer 1: Dots and Line
                  Row(
                    children: [
                      Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle)),
                      Expanded(
                        child: Container(
                            height: 2,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.3)),
                      ),
                      Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              shape: BoxShape.circle)),
                    ],
                  ),
                  // Layer 2: Animated Train on top
                  AnimatedBuilder(
                    animation: _trainAnimation,
                    builder: (context, child) {
                      return Positioned(
                        left: _trainAnimation.value * constraints.maxWidth - 10,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.train_outlined,
                              color: Theme.of(context).colorScheme.primary,
                              size: 16),
                        ),
                      );
                    },
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 4),
          Text(
            "${trip.duration.inHours}h ${trip.duration.inMinutes.remainder(60)}min",
            style: AppTypography.labelMedium
                .copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownCard(AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Départ dans',
                  style: AppTypography.headlineSmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCountdownUnit(_getDaysUntil(trip.departureTime), 'JOURS'),
                _buildCountdownUnit(
                    trip.departureTime
                        .difference(DateTime.now())
                        .inHours
                        .remainder(24),
                    'HEURES'),
                _buildCountdownUnit(
                    trip.departureTime
                        .difference(DateTime.now())
                        .inMinutes
                        .remainder(60),
                    'MINUTES'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownUnit(int value, String label) {
    return Column(
      children: [
        Text(value.toString(), style: AppTypography.displayMedium),
        Text(label.toUpperCase(),
            style: AppTypography.labelMedium
                .copyWith(color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }

  Widget _buildJourneyInfoCard(AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.route,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Informations du trajet',
                  style: AppTypography.headlineSmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Distance', '${trip.distance.toStringAsFixed(0)} km'),
            _buildInfoRow('Durée', trip.formattedDuration),
            _buildInfoRow(
                'Prix',
                trip.price > 0
                    ? '${trip.price.toStringAsFixed(2)} €'
                    : 'Non renseigné'),
            if (trip.company != null && trip.company!.isNotEmpty)
              _buildInfoRow('Compagnie', trip.company!),
            if (trip.brand != null && trip.brand!.isNotEmpty)
              _buildInfoRow('Marque', trip.brand!),
            if (trip.notes != null && trip.notes!.isNotEmpty)
              _buildInfoRow('Notes', trip.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketInfoCard(AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.confirmation_number,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Informations du billet',
                  style: AppTypography.headlineSmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildEditableInfoRow(
              'Numéro de billet',
              _ticketNumber.isEmpty ? 'Non renseigné' : _ticketNumber,
              Icons.copy,
              () => _copyToClipboard(_ticketNumber),
              isEnabled: _ticketNumber.isNotEmpty,
            ),
            _buildEditableInfoRow(
              'Siège',
              _seatNumber.isEmpty ? 'Non renseigné' : _seatNumber,
              Icons.edit,
              _editSeat,
            ),
            _buildInfoRow('Voiture', trip.carNumber ?? 'Non renseigné'),
            _buildInfoRow('Classe', trip.travelClass ?? 'Non renseigné'),
          ],
        ),
      ),
    );
  }

  Widget _buildCarbonFootprintCard(AppLocalizations l10n) {
    // Calcul de l'empreinte carbone (approximatif)
    final trainFootprint = trip.distance * 0.014; // kg CO2/km pour le train
    final carFootprint = trip.distance * 0.21; // kg CO2/km pour la voiture
    final planeFootprint = trip.distance * 0.255; // kg CO2/km pour l'avion

    // Calcul d'équivalents concrets
    final treesNeeded =
        (trainFootprint / 22).round(); // 1 arbre absorbe ~22kg CO2/an
    final smartphoneCharges =
        (trainFootprint / 0.05).round(); // 1 charge = ~0.05kg CO2
    final kmEnVoiture = (trainFootprint / 0.21).round();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.eco,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Impact environnemental',
                  style: AppTypography.headlineSmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Empreinte carbone',
                        style: AppTypography.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${trainFootprint.toStringAsFixed(1)} kg CO₂',
                        style: AppTypography.headlineSmall.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.eco,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Équivalent voiture',
                '${carFootprint.toStringAsFixed(1)} kg CO₂'),
            _buildInfoRow('Équivalent avion',
                '${planeFootprint.toStringAsFixed(1)} kg CO₂'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cela correspond à :',
                    style: AppTypography.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• ${treesNeeded} arbre(s) pour absorber ce CO₂ en 1 an',
                    style: AppTypography.bodySmall.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.8),
                    ),
                  ),
                  Text(
                    '• ${smartphoneCharges} charge(s) de smartphone',
                    style: AppTypography.bodySmall.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.8),
                    ),
                  ),
                  Text(
                    '• ${kmEnVoiture} km en voiture',
                    style: AppTypography.bodySmall.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripStatsCard(AppLocalizations l10n) {
    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {
        final allTrips = tripProvider.trips;
        final sameRouteTrips = allTrips
            .where((t) =>
                t.departureStation == trip.departureStation &&
                t.arrivalStation == trip.arrivalStation)
            .length;

        final sameRouteDistance = allTrips
            .where((t) =>
                t.departureStation == trip.departureStation &&
                t.arrivalStation == trip.arrivalStation)
            .fold(0.0, (sum, t) => sum + t.distance);

        final avgPrice = allTrips
            .where((t) =>
                t.departureStation == trip.departureStation &&
                t.arrivalStation == trip.arrivalStation)
            .where((t) => t.price > 0)
            .fold(0.0, (sum, t) => sum + t.price);

        final priceCount = allTrips
            .where((t) =>
                t.departureStation == trip.departureStation &&
                t.arrivalStation == trip.arrivalStation)
            .where((t) => t.price > 0)
            .length;

        return Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Statistiques de cette route',
                      style: AppTypography.headlineSmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Effectué', '$sameRouteTrips fois'),
                _buildInfoRow('Distance totale',
                    '${sameRouteDistance.toStringAsFixed(0)} km'),
                if (priceCount > 0)
                  _buildInfoRow('Prix moyen',
                      '${(avgPrice / priceCount).toStringAsFixed(2)} €'),
                _buildInfoRow('Dernière fois', _getLastTripDate(allTrips)),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getLastTripDate(List<Trip> allTrips) {
    final sameRouteTrips = allTrips
        .where((t) =>
            t.departureStation == trip.departureStation &&
            t.arrivalStation == trip.arrivalStation)
        .toList();

    if (sameRouteTrips.isEmpty) return 'Première fois';

    final lastTrip = sameRouteTrips
        .reduce((a, b) => a.departureTime.isAfter(b.departureTime) ? a : b);

    final now = DateTime.now();
    final difference = now.difference(lastTrip.departureTime);

    if (difference.inDays == 0) return 'Aujourd\'hui';
    if (difference.inDays == 1) return 'Hier';
    if (difference.inDays < 7) return 'Il y a ${difference.inDays} jours';
    if (difference.inDays < 30)
      return 'Il y a ${(difference.inDays / 7).round()} semaines';
    if (difference.inDays < 365)
      return 'Il y a ${(difference.inDays / 30).round()} mois';
    return 'Il y a ${(difference.inDays / 365).round()} an(s)';
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableInfoRow(
      String label, String value, IconData icon, VoidCallback onTap,
      {bool isEnabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(icon, size: 18),
                onPressed: isEnabled ? onTap : null,
                color: isEnabled
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(AppLocalizations l10n) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.error,
        side: BorderSide(color: Theme.of(context).colorScheme.error),
        minimumSize: const Size(double.infinity, 50),
      ),
      icon: const Icon(Icons.delete_outline),
      label: Text(l10n.deleteTripButton),
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.deleteConfirmationTitle),
            content: Text(l10n.deleteConfirmationMessage),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.cancelButton)),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.deleteButton,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            ],
          ),
        );

        if (confirm == true && mounted) {
          await context.read<TripProvider>().deleteTrip(trip.id);
          Navigator.pop(context);
        }
      },
    );
  }

  Widget _flipFraseBoard(String frase) => CustomFlipFraseBoard(
        flipType: FlipType.spinFlip,
        axis: Axis.vertical,
        startLetter: 'A',
        endFrase: frase,
        fontSize: 12,
        fontFamily: 'Inter',
        flipLetterHeight: 25,
        flipLetterWidth: 18,
        hingeWidth: 0.4,
        hingeColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
        startColors: [Theme.of(context).colorScheme.primary],
        letterColors: [Theme.of(context).colorScheme.onPrimary],
        borderColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.3),
        endColors: [Theme.of(context).colorScheme.primary],
        letterSpacing: 1,
        minFlipDelay: 50,
        maxFlipDelay: 130,
      );

  /// Affiche la modal avec les détails des perturbations
  void _showDisruptionDetails() {
    if (_realtimeInfo != null) {
      showDialog(
        context: context,
        builder: (context) => DisruptionDetailsModal(
          disruptionInfo: _realtimeInfo!,
          trainNumber: trip.trainNumber,
          trainType: trip.trainType,
        ),
      );
    }
  }
}

class DottedLinePainter extends CustomPainter {
  final Color color;

  DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    const dashWidth = 3;
    const dashSpace = 3;
    double startX = 0;
    final y = size.height / 2;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + dashWidth, y),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
