import 'package:flip_board/flip_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:trainlog/theme/colors.dart';
import '../models/trip.dart';
import '../providers/trip_provider.dart';
import 'package:provider/provider.dart';
import 'package:apple_maps_flutter/apple_maps_flutter.dart';
import 'dart:io' show Platform;
import 'dart:math';
import 'dart:ui' as ui;
import '../widgets/train_logo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flip_board/flip_board.dart';

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
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _trainAnimationController,
      curve: Curves.easeInOut,
    ));

    // Démarrer l'animation avec répétition
    _trainAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _trainAnimationController.dispose();
    super.dispose();
  }

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copié dans le presse-papier'),
        duration: Duration(seconds: 2),
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
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String tempSeatNumber = _seatNumber;
        return AlertDialog(
          title: const Text('Modifier le siège'),
          content: TextField(
            controller: TextEditingController(text: tempSeatNumber),
            decoration: const InputDecoration(
              labelText: 'Numéro de siège',
              hintText: 'Ex: 12A',
            ),
            onChanged: (value) => tempSeatNumber = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, tempSeatNumber),
              child: const Text('Enregistrer'),
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
    final difference = date.difference(now);
    return difference.inDays;
  }

  Future<BitmapDescriptor> _createCustomMarkerIcon(bool isDeparture) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double size = 80;

    // Couleur principale
    final Color mainColor =
        isDeparture ? AppColors.primary : AppColors.secondary;

    // Ombre portée
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(
        const Offset(size / 2, size / 2), size / 2.2, shadowPaint);

    // Cercle principal
    final Paint circlePaint = Paint()
      ..color = mainColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
        const Offset(size / 2, size / 2), size / 2.5, circlePaint);

    // Contour blanc épais
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(
        const Offset(size / 2, size / 2), size / 2.5, borderPaint);

    // Icône centrale
    final IconData icon = isDeparture ? Icons.train : Icons.flag;
    final TextPainter textPainter =
        TextPainter(textDirection: ui.TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: 36,
        fontFamily: icon.fontFamily,
        color: Colors.white,
        package: icon.fontPackage,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      ),
    );

    final image = await pictureRecorder.endRecording().toImage(
          size.toInt(),
          size.toInt(),
        );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List imageData = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(imageData);
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
                  'Départ ${DateFormat('HH:mm').format(trip.departureTime)}',
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
                  'Arrivée ${DateFormat('HH:mm').format(trip.arrivalTime)}',
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
              color: AppColors.primary.withOpacity(0.18),
              width: 16,
              polylineCap: Cap.roundCap,
            ),
          );
          // Polyline principale
          polylines.add(
            Polyline(
              polylineId: PolylineId('route'),
              points: boundPoints,
              color: AppColors.secondary,
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
              color: AppColors.primary.withOpacity(0.18),
              width: 16,
              polylineCap: Cap.roundCap,
            ),
          );
          // Polyline principale
          polylines.add(
            Polyline(
              polylineId: PolylineId('route'),
              points: polylinePoints,
              color: AppColors.secondary,
              width: 8,
              polylineCap: Cap.roundCap,
            ),
          );

          boundPoints = polylinePoints;
        }

        // Calculer les limites de la carte pour inclure les points nécessaires
        final bounds = LatLngBounds(
          southwest: LatLng(
            boundPoints.map((p) => p.latitude).reduce(min),
            boundPoints.map((p) => p.longitude).reduce(min),
          ),
          northeast: LatLng(
            boundPoints.map((p) => p.latitude).reduce(max),
            boundPoints.map((p) => p.longitude).reduce(max),
          ),
        );

        return SizedBox(
          height: 300,
          child: AppleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                trip.departureCityGeo.latitude,
                trip.departureCityGeo.longitude,
              ),
              zoom: 6,
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
              controller.moveCamera(
                CameraUpdate.newLatLngBounds(
                  bounds,
                  50.0, // padding en pixels
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {
        final currentTrip =
            tripProvider.trips.firstWhere((t) => t.id == widget.trip.id);
        final daysUntil = _getDaysUntil(currentTrip.departureTime);
        final isUpcoming = daysUntil >= 0;

        return Scaffold(
          backgroundColor: AppColors.white,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                iconTheme: const IconThemeData(color: Color(0xFF284B63)),
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildMap(),
                ),
                actions: [],
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête avec logo et informations du trajet
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          TrainLogo(
                            trainType: currentTrip.trainType,
                            size: 30,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentTrip.trainType,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  'Train ${currentTrip.trainNumber}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isUpcoming)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '$daysUntil jours',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 1,
                      color: AppColors.light,
                    ),
                    const SizedBox(height: 16),

                    // Gare de départ
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          FlipFraseBoard(
                            flipType: FlipType.spinFlip,
                            axis: Axis.vertical,
                            startLetter: 'A',
                            endFrase:
                                '${DateFormat('HH').format(currentTrip.departureTime)}H${DateFormat('mm').format(currentTrip.departureTime)}',
                            fontSize: 12,
                            flipLetterHeight: 18,
                            flipLetterWidth: 15,
                            hingeWidth: 0.9,
                            hingeColor: Color(0xFF3C6E71),
                            borderColor: Color(0xFF284B63),
                            endColors: [Color(0xFF284B63)],
                            letterSpacing: 1,
                            minFlipDelay: 10,
                            maxFlipDelay: 100,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              currentTrip.departureStation,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF3C6E71),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              currentTrip.formattedDuration,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF353535),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '• ${currentTrip.distance.toStringAsFixed(0)} km',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF353535),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: CustomPaint(
                                painter: DottedLinePainter(),
                                size: const Size(double.infinity, 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Gare d'arrivée
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            FlipFraseBoard(
                              flipType: FlipType.spinFlip,
                              axis: Axis.vertical,
                              startLetter: 'A',
                              endFrase:
                                  '${DateFormat('HH').format(currentTrip.arrivalTime)}H${DateFormat('mm').format(currentTrip.arrivalTime)}',
                              fontSize: 12,
                              flipLetterHeight: 18,
                              flipLetterWidth: 15,
                              hingeWidth: 0.9,
                              hingeColor: Color(0xFF3C6E71),
                              borderColor: Color(0xFF284B63),
                              endColors: [Color(0xFF284B63)],
                              letterSpacing: 1,
                              minFlipDelay: 10,
                              maxFlipDelay: 100,
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                currentTrip.arrivalStation,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF3C6E71),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Cartes de réservation et siège
                    const Divider(
                      height: 1,
                      color: AppColors.light,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          // Première rangée : Dossier et Siège
                          Row(
                            children: [
                              // Dossier
                              Expanded(
                                child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFFE5E5E5)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                12, 12, 0, 12),
                                            child: const Icon(
                                              Icons.folder,
                                              size: 24,
                                              color: Color(0xFF284B63),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Text(
                                            'Dossier',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF3C6E71),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          SizedBox(
                                            width: 60,
                                            height: 30,
                                            child: TextButton(
                                              onPressed: () async {
                                                if (_ticketNumber.isNotEmpty) {
                                                  await _copyToClipboard(
                                                      _ticketNumber);
                                                } else {
                                                  await _pasteFromClipboard();
                                                }
                                              },
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFFF5F5F5),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: Text(
                                                _ticketNumber.isNotEmpty
                                                    ? 'COPIER'
                                                    : 'COLLER',
                                                style: const TextStyle(
                                                  color: Color(0xFF284B63),
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          _ticketNumber.isNotEmpty
                                              ? _ticketNumber
                                              : 'N/A',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: _ticketNumber.isNotEmpty
                                                ? const Color(0xFF284B63)
                                                : const Color(0xFF3C6E71),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Siège
                              Expanded(
                                child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFFE5E5E5)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _editBookingDetails('seat'),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.chair,
                                                  size: 24,
                                                  color: Color(0xFF284B63),
                                                ),
                                                const SizedBox(width: 8),
                                                const Text(
                                                  'Siège',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF3C6E71),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Spacer(),
                                            Text(
                                              currentTrip.seatNumber != null &&
                                                      currentTrip.seatNumber!
                                                          .isNotEmpty
                                                  ? currentTrip.seatNumber!
                                                  : 'Tap to Edit',
                                              style: TextStyle(
                                                fontSize:
                                                    currentTrip.seatNumber !=
                                                                null &&
                                                            currentTrip
                                                                .seatNumber!
                                                                .isNotEmpty
                                                        ? 18
                                                        : 12,
                                                fontWeight:
                                                    currentTrip.seatNumber !=
                                                                null &&
                                                            currentTrip
                                                                .seatNumber!
                                                                .isNotEmpty
                                                        ? FontWeight.w600
                                                        : FontWeight.w400,
                                                color: currentTrip.seatNumber !=
                                                            null &&
                                                        currentTrip.seatNumber!
                                                            .isNotEmpty
                                                    ? const Color(0xFF284B63)
                                                    : const Color(0xFF3C6E71)
                                                        .withOpacity(0.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Deuxième rangée : Classe et Voiture
                          Row(
                            children: [
                              // Classe
                              Expanded(
                                child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFFE5E5E5)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _editBookingDetails('class'),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons
                                                      .airline_seat_recline_extra,
                                                  size: 24,
                                                  color: Color(0xFF284B63),
                                                ),
                                                const SizedBox(width: 8),
                                                const Text(
                                                  'Classe',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF3C6E71),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Spacer(),
                                            Text(
                                              currentTrip.travelClass != null &&
                                                      currentTrip.travelClass!
                                                          .isNotEmpty
                                                  ? currentTrip.travelClass!
                                                  : 'Tap to Edit',
                                              style: TextStyle(
                                                fontSize:
                                                    currentTrip.travelClass !=
                                                                null &&
                                                            currentTrip
                                                                .travelClass!
                                                                .isNotEmpty
                                                        ? 18
                                                        : 12,
                                                fontWeight:
                                                    currentTrip.travelClass !=
                                                                null &&
                                                            currentTrip
                                                                .travelClass!
                                                                .isNotEmpty
                                                        ? FontWeight.w600
                                                        : FontWeight.w400,
                                                color: currentTrip
                                                                .travelClass !=
                                                            null &&
                                                        currentTrip.travelClass!
                                                            .isNotEmpty
                                                    ? const Color(0xFF284B63)
                                                    : const Color(0xFF3C6E71)
                                                        .withOpacity(0.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Voiture
                              Expanded(
                                child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFFE5E5E5)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _editBookingDetails('car'),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.directions_railway,
                                                  size: 24,
                                                  color: Color(0xFF284B63),
                                                ),
                                                const SizedBox(width: 8),
                                                const Text(
                                                  'Voiture',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF3C6E71),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Spacer(),
                                            Text(
                                              currentTrip.carNumber != null &&
                                                      currentTrip
                                                          .carNumber!.isNotEmpty
                                                  ? currentTrip.carNumber!
                                                  : 'Tap to Edit',
                                              style: TextStyle(
                                                fontSize:
                                                    currentTrip.carNumber !=
                                                                null &&
                                                            currentTrip
                                                                .carNumber!
                                                                .isNotEmpty
                                                        ? 18
                                                        : 12,
                                                fontWeight:
                                                    currentTrip.carNumber !=
                                                                null &&
                                                            currentTrip
                                                                .carNumber!
                                                                .isNotEmpty
                                                        ? FontWeight.w600
                                                        : FontWeight.w400,
                                                color: currentTrip.carNumber !=
                                                            null &&
                                                        currentTrip.carNumber!
                                                            .isNotEmpty
                                                    ? const Color(0xFF284B63)
                                                    : const Color(0xFF3C6E71)
                                                        .withOpacity(0.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Color(0xFFD9D9D9)),
                    // Section "Good to Know"
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informations',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF284B63),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            clipBehavior: Clip.none,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Ligne verticale
                                Positioned(
                                  left: 6,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 1.5,
                                    color: const Color(0xFFE5E5E5),
                                  ),
                                ),
                                // Contenu principal
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildTimelineItem(
                                      icon: Icons.train,
                                      title: 'Train',
                                      value:
                                          '${currentTrip.trainType} ${currentTrip.trainNumber}',
                                    ),
                                    const SizedBox(height: 32),
                                    _buildTimelineItem(
                                      icon: Icons.calendar_today,
                                      title: 'Date',
                                      value: DateFormat(
                                              'EEEE d MMMM y', 'fr_FR')
                                          .format(currentTrip.departureTime),
                                    ),
                                    const SizedBox(height: 32),
                                    _buildTimelineItem(
                                      icon: Icons.access_time,
                                      title: 'Durée',
                                      value: currentTrip.formattedDuration,
                                    ),
                                    const SizedBox(height: 32),
                                    _buildTimelineItem(
                                      icon: Icons.place,
                                      title: 'Distance',
                                      value:
                                          '${currentTrip.distance.toStringAsFixed(0)} km',
                                    ),
                                  ],
                                ),
                                // Train animé (au-dessus de tout)
                                AnimatedBuilder(
                                  animation: _trainAnimation,
                                  builder: (context, child) {
                                    return Positioned(
                                      left: -8,
                                      top: _trainAnimation.value * 300,
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF284B63),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.train,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFD9D9D9)),

                    // Section "My History"
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mon historique sur ce trajet',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF284B63),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${currentTrip.departureStation} → ${currentTrip.arrivalStation}',
                            style: const TextStyle(
                              color: Color(0xFF3C6E71),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Consumer<TripProvider>(
                            builder: (context, tripProvider, child) {
                              // Calculer les statistiques
                              final similarTrips = tripProvider.trips
                                  .where((t) =>
                                      t.departureStationId ==
                                          currentTrip.departureStationId &&
                                      t.arrivalStationId ==
                                          currentTrip.arrivalStationId)
                                  .toList();

                              final totalTrips = similarTrips.length;
                              final totalDistance = similarTrips.fold<double>(
                                  0, (sum, trip) => sum + trip.distance);

                              // Calculer la durée totale en minutes
                              final totalDurationMinutes =
                                  similarTrips.fold<int>(
                                0,
                                (sum, trip) => sum + trip.duration.inMinutes,
                              );

                              // Convertir en heures et minutes
                              final hours = totalDurationMinutes ~/ 60;
                              final minutes = totalDurationMinutes % 60;
                              final formattedTotalDuration =
                                  '${hours}h${minutes.toString().padLeft(2, '0')}';

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatColumn(
                                    icon: Icons.train,
                                    value: totalTrips.toString(),
                                    label: 'Trajets',
                                  ),
                                  _buildStatColumn(
                                    icon: Icons.speed,
                                    value:
                                        '${totalDistance.toStringAsFixed(0)} km',
                                    label: 'Distance',
                                  ),
                                  _buildStatColumn(
                                    icon: Icons.access_time,
                                    value: formattedTotalDuration,
                                    label: 'Temps de trajet',
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFD9D9D9)),
                    // Section Notes
                    // Padding(
                    //   padding: const EdgeInsets.all(16.0),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       const Text(
                    //         'Notes',
                    //         style: TextStyle(
                    //           fontSize: 24,
                    //           fontWeight: FontWeight.bold,
                    //           color: Color(0xFF284B63),
                    //         ),
                    //       ),
                    //       const SizedBox(height: 16),
                    //       Container(
                    //         padding: const EdgeInsets.all(16),
                    //         decoration: BoxDecoration(
                    //           color: AppColors.light,
                    //           borderRadius: BorderRadius.circular(12),
                    //         ),
                    //         child: Text(
                    //           currentTrip.notes ?? 'Aucune note',
                    //           style: TextStyle(
                    //             color: currentTrip.notes != null
                    //                 ? AppColors.dark
                    //                 : AppColors.secondary,
                    //             fontSize: 16,
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // const Divider(height: 1, color: Color(0xFFD9D9D9)),
                    // Bouton de suppression
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Supprimer le trajet'),
                                content: const Text(
                                    'Êtes-vous sûr de vouloir supprimer ce trajet ?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Supprimer'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmed == true && mounted) {
                            await context
                                .read<TripProvider>()
                                .deleteTrip(currentTrip.id);
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Supprimer le trajet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF3C6E71),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF284B63),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF284B63)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppColors.secondary),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF284B63),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF3C6E71),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        // Point sur la ligne
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF284B63),
              width: 1.5,
            ),
          ),
        ),
        const SizedBox(width: 20),
        // Contenu
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: const Color(0xFF284B63),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF3C6E71),
                      ),
                    ),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF284B63),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _editBookingDetails(String type) async {
    final currentTrip = context
        .read<TripProvider>()
        .trips
        .firstWhere((t) => t.id == widget.trip.id);
    String? tempTicketNumber = currentTrip.ticketNumber;
    String? tempSeatNumber = currentTrip.seatNumber;
    String? tempTravelClass = currentTrip.travelClass;
    String? tempCarNumber = currentTrip.carNumber;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Détails de réservation',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF284B63),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text(
                              'Annuler',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Dossier - Champ texte
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Dossier',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF284B63),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: TextEditingController(
                                    text: tempTicketNumber),
                                onChanged: (value) => tempTicketNumber = value,
                                decoration: InputDecoration(
                                  hintText: 'Numéro de dossier',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE5E5E5)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Siège - Champ numérique
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Siège',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF284B63),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller:
                                    TextEditingController(text: tempSeatNumber),
                                onChanged: (value) => tempSeatNumber = value,
                                decoration: InputDecoration(
                                  hintText: 'Numéro de siège (ex: 12A)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE5E5E5)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Classe
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Classe',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF284B63),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: ['Seconde', 'Première', 'Business']
                                    .map((option) {
                                  final isSelected = tempTravelClass == option;
                                  return InkWell(
                                    onTap: () {
                                      setState(() => tempTravelClass = option);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF284B63)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                            color: isSelected
                                                ? const Color(0xFF284B63)
                                                : const Color(0xFFE5E5E5)),
                                      ),
                                      child: Text(
                                        option,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF284B63),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Voiture
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Voiture',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF284B63),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: List.generate(
                                        15, (index) => (index + 1).toString())
                                    .map((option) {
                                  final isSelected = tempCarNumber == option;
                                  return InkWell(
                                    onTap: () {
                                      setState(() => tempCarNumber = option);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF284B63)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                            color: isSelected
                                                ? const Color(0xFF284B63)
                                                : const Color(0xFFE5E5E5)),
                                      ),
                                      child: Text(
                                        option,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF284B63),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
                        top: 16,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final tripProvider = context.read<TripProvider>();
                            final updatedTrip = currentTrip.copyWith(
                              ticketNumber: tempTicketNumber?.isNotEmpty == true
                                  ? tempTicketNumber
                                  : null,
                              seatNumber: tempSeatNumber?.isNotEmpty == true
                                  ? tempSeatNumber
                                  : null,
                              carNumber: tempCarNumber?.isNotEmpty == true
                                  ? tempCarNumber
                                  : null,
                              travelClass: tempTravelClass?.isNotEmpty == true
                                  ? tempTravelClass
                                  : null,
                            );
                            await tripProvider.updateTrip(updatedTrip);
                            if (mounted) {
                              Navigator.pop(context, true);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF284B63),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Sauvegarder',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );

    if (result == true && mounted) {
      setState(() {
        _ticketNumber = tempTicketNumber ?? '';
      });
    }
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.light
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
