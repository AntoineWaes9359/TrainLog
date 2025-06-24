import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trainlog/theme/colors.dart';
import '../providers/trip_provider_improved.dart';
import '../models/trip.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/sncf_service.dart';
import '../widgets/train_logo.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/api_keys.dart';
import '../utils/distance_calculator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uuid/uuid.dart';

class AddTripScreenV2 extends StatefulWidget {
  const AddTripScreenV2({super.key});

  @override
  State<AddTripScreenV2> createState() => _AddTripScreenV2State();
}

class _AddTripScreenV2State extends State<AddTripScreenV2> {
  final _formKey = GlobalKey<FormState>();
  final _departureStationController = TextEditingController();
  final _arrivalStationController = TextEditingController();
  final _trainNumberController = TextEditingController();
  final _trainTypeController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isManualMode = false;
  String _selectedCompany = 'SNCF';
  bool _isLoading = false;
  List<Map<String, dynamic>> _suggestedDepartureStations = [];
  List<Map<String, dynamic>> _suggestedArrivalStations = [];
  String? _departureStationId;
  String? _arrivalStationId;
  List<Map<String, dynamic>> _journeys = [];
  int _loadedJourneysCount = 0;

  // Variables pour le mode manuel
  TimeOfDay _departureTime = TimeOfDay.now();
  TimeOfDay _arrivalTime =
      TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));

  late SncfService _sncfService;

  @override
  void initState() {
    super.initState();
    _sncfService = SncfService(ApiKeys.sncfApiKey);
    _checkManualMode();
  }

  void _checkManualMode() {
    final now = DateTime.now();
    final selectedDateMidnight =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final todayMidnight = DateTime(now.year, now.month, now.day);

    setState(() {
      _isManualMode = selectedDateMidnight.isBefore(todayMidnight);
    });
  }

  @override
  void dispose() {
    _departureStationController.dispose();
    _arrivalStationController.dispose();
    _trainNumberController.dispose();
    _trainTypeController.dispose();
    super.dispose();
  }

  Future<void> _searchStations(String query, bool isDeparture) async {
    if (query.length < 2) return;

    try {
      final stations = await _sncfService.getStations(query);
      setState(() {
        if (isDeparture) {
          _suggestedDepartureStations = stations;
        } else {
          _suggestedArrivalStations = stations;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _searchJourneys() async {
    if (_departureStationId == null || _arrivalStationId == null) return;

    setState(() {
      _loadedJourneysCount = 0;
    });

    BuildContext? dialogContext;
    StateSetter? dialogSetState;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        dialogContext = context;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            dialogSetState = setDialogState;
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Recherche des trains en cours...'),
                  const SizedBox(height: 8),
                  Text(
                    _loadedJourneysCount > 0
                        ? '$_loadedJourneysCount ${_loadedJourneysCount == 1 ? 'trajet trouvé' : 'trajets trouvés'}'
                        : 'Aucun trajet trouvé pour le moment',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    try {
      final journeys = await _sncfService.searchJourneys(
        _departureStationId!,
        _arrivalStationId!,
        _selectedDate,
        onJourneysAdded: (count) {
          dialogSetState?.call(() {
            _loadedJourneysCount = count;
          });
        },
      );

      // Fermer la boîte de dialogue de chargement
      if (dialogContext != null && context.mounted) {
        Navigator.of(dialogContext!).pop();
      }
      setState(() {
        _journeys = journeys;
      });
    } catch (e) {
      // Fermer la boîte de dialogue de chargement
      if (dialogContext != null && context.mounted) {
        Navigator.of(dialogContext!).pop();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _checkManualMode();
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isDeparture) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isDeparture ? _departureTime : _arrivalTime,
    );
    if (picked != null) {
      setState(() {
        if (isDeparture) {
          _departureTime = picked;
        } else {
          _arrivalTime = picked;
        }
      });
    }
  }

  Widget _buildTrainLogo(String networkName, String trainType) {
    if (networkName.toUpperCase().contains('OUIGO')) {
      return SvgPicture.asset(
        'assets/images/logo_OUIGO.svg',
        height: 20,
        width: 20,
      );
    } else if (networkName.toUpperCase().contains('INOUI')) {
      return SvgPicture.asset(
        'assets/images/logo_TGV INOUI.svg',
        height: 20,
        width: 20,
      );
    } else if (trainType.toUpperCase().contains('TER')) {
      return SvgPicture.asset(
        'assets/images/logo_TER.svg',
        height: 20,
        width: 20,
      );
    } else {
      // Logo par défaut pour les autres cas
      return SvgPicture.asset(
        'assets/images/logo_SNCF.svg',
        height: 20,
        width: 20,
      );
    }
  }

  String _formatDateTime(String dateTimeStr) {
    final dateTime = DateTime.parse(dateTimeStr);
    return DateFormat('EEE d MMM, HH:mm', 'fr_FR').format(dateTime);
  }

  Future<void> _addManualTrip() async {
    if (_formKey.currentState!.validate()) {
      final departureDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _departureTime.hour,
        _departureTime.minute,
      );
      final arrivalDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _arrivalTime.hour,
        _arrivalTime.minute,
      );

      // Récupérer les détails des gares
      Map<String, dynamic>? departureDetails;
      Map<String, dynamic>? arrivalDetails;

      if (_departureStationId != null && _arrivalStationId != null) {
        try {
          departureDetails =
              await _sncfService.getStationDetails(_departureStationId!);
          arrivalDetails =
              await _sncfService.getStationDetails(_arrivalStationId!);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Erreur lors de la récupération des détails des gares'),
              ),
            );
          }
        }
      }

      // Calculer la distance si les coordonnées sont disponibles
      double distance = 0;
      GeoPoint departureCityGeo = const GeoPoint(0, 0);
      GeoPoint arrivalCityGeo = const GeoPoint(0, 0);
      List<GeoPoint> path = [];

      if (departureDetails != null && arrivalDetails != null) {
        departureCityGeo = GeoPoint(
          departureDetails['coordinates']['lat'],
          departureDetails['coordinates']['lon'],
        );
        arrivalCityGeo = GeoPoint(
          arrivalDetails['coordinates']['lat'],
          arrivalDetails['coordinates']['lon'],
        );

        distance = DistanceCalculator.calculateDistance(
          departureCityGeo,
          arrivalCityGeo,
        );

        // Créer un chemin simple avec les points de départ et d'arrivée
        path = [departureCityGeo, arrivalCityGeo];
      }

      final trip = Trip(
        id: const Uuid().v4(),
        departureStation: _departureStationController.text,
        arrivalStation: _arrivalStationController.text,
        departureStationId: _departureStationId ?? '',
        arrivalStationId: _arrivalStationId ?? '',
        departureCityName:
            departureDetails?['city'] ?? _departureStationController.text,
        arrivalCityName:
            arrivalDetails?['city'] ?? _arrivalStationController.text,
        departureCityGeo: departureCityGeo,
        arrivalCityGeo: arrivalCityGeo,
        departureTime: departureDateTime,
        arrivalTime: arrivalDateTime,
        trainNumber: _trainNumberController.text,
        trainType: _trainTypeController.text,
        distance: distance,
        price: 0,
        path: path,
      );

      await context.read<TripProvider>().addTrip(trip);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _addAutomaticTrip(Map<String, dynamic> journey) async {
    final tripProvider = context.read<TripProvider>();

    // Récupération des informations de la gare de départ
    final fromStation = journey['from']['stop_point'] as Map<String, dynamic>;
    final fromAdminRegion =
        (fromStation['administrative_regions'] as List<dynamic>).first
            as Map<String, dynamic>;
    final fromCoord = fromAdminRegion['coord'] as Map<String, dynamic>;

    // Récupération des informations de la gare d'arrivée
    final toStation = journey['to']['stop_point'] as Map<String, dynamic>;
    final toAdminRegion = (toStation['administrative_regions'] as List<dynamic>)
        .first as Map<String, dynamic>;
    final toCoord = toAdminRegion['coord'] as Map<String, dynamic>;

    // Récupération des coordonnées du trajet
    final geojson = journey['geojson'] as Map<String, dynamic>;
    final coordinates = (geojson['coordinates'] as List<dynamic>).map((coord) {
      final coordList = coord as List<dynamic>;
      return GeoPoint(
        coordList[1] as double, // latitude
        coordList[0] as double, // longitude
      );
    }).toList();

    await tripProvider.addTrip(
      Trip(
        id: const Uuid().v4(),
        departureStation: fromStation['label'] as String,
        arrivalStation: toStation['label'] as String,
        departureStationId: fromStation['id'] as String,
        arrivalStationId: toStation['id'] as String,
        departureCityName: fromAdminRegion['name'] as String,
        arrivalCityName: toAdminRegion['name'] as String,
        departureCityGeo: GeoPoint(
          double.parse(fromCoord['lat'] as String),
          double.parse(fromCoord['lon'] as String),
        ),
        arrivalCityGeo: GeoPoint(
          double.parse(toCoord['lat'] as String),
          double.parse(toCoord['lon'] as String),
        ),
        departureTime: DateTime.parse(journey['departure_time'] as String),
        arrivalTime: DateTime.parse(journey['arrival_time'] as String),
        trainNumber: journey['train_number'] as String,
        trainType: journey['type'] as String,
        distance: journey['distance'] as double,
        price: 0,
        path: coordinates,
      ),
    );
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Hero(
              tag: 'trainIcon',
              flightShuttleBuilder: (
                BuildContext flightContext,
                Animation<double> animation,
                HeroFlightDirection flightDirection,
                BuildContext fromHeroContext,
                BuildContext toHeroContext,
              ) {
                final curvedAnimation = CurvedAnimation(
                  parent: animation,
                  curve: Curves.elasticOut,
                );

                return AnimatedBuilder(
                  animation: curvedAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: Tween<double>(
                        begin: 1.0,
                        end: flightDirection == HeroFlightDirection.push
                            ? 1.2
                            : 0.8,
                      ).animate(curvedAnimation).value,
                      child: Transform.rotate(
                        angle: Tween<double>(
                          begin: 0.0,
                          end: 2 * 3.14159,
                        ).animate(curvedAnimation).value,
                        child: Opacity(
                          opacity: animation.value,
                          child: Icon(
                            Icons.train,
                            color: Colors.black,
                            size: 32,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: Icon(
                Icons.train,
                color: Colors.black,
                size: 32,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Ajouter un trajet'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCompany,
              decoration: const InputDecoration(
                labelText: 'Compagnie',
              ),
              items: const [
                DropdownMenuItem(
                  value: 'SNCF',
                  child: Text('SNCF'),
                ),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCompany = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            // Sélection de la date
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(_selectedDate),
              ),
              onTap: () => _selectDate(context),
            ),
            if (_isManualMode) ...[
              const SizedBox(height: 16),
              // Heure de départ
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Heure de départ'),
                subtitle: Text(_departureTime.format(context)),
                onTap: () => _selectTime(context, true),
              ),
              const SizedBox(height: 16),
              // Heure d'arrivée
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Heure d\'arrivée'),
                subtitle: Text(_arrivalTime.format(context)),
                onTap: () => _selectTime(context, false),
              ),
              const SizedBox(height: 16),
              // Numéro de train
              TextFormField(
                controller: _trainNumberController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de train',
                  icon: Icon(Icons.train),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un numéro de train';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Type de train
              TextFormField(
                controller: _trainTypeController,
                decoration: const InputDecoration(
                  labelText: 'Type de train',
                  icon: Icon(Icons.directions_railway),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un type de train';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _departureStationController,
              decoration: const InputDecoration(
                labelText: 'Gare de départ',
                icon: Icon(Icons.train),
              ),
              onChanged: (value) => _searchStations(value, true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une gare de départ';
                }
                return null;
              },
            ),
            if (_suggestedDepartureStations.isNotEmpty)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListView.builder(
                  itemCount: _suggestedDepartureStations.length,
                  itemBuilder: (context, index) {
                    final station = _suggestedDepartureStations[index];
                    return ListTile(
                      title: Text(station['name']),
                      subtitle: Text(station['city'] ?? ''),
                      onTap: () {
                        setState(() {
                          _departureStationController.text = station['name'];
                          _departureStationId = station['id'];
                          _suggestedDepartureStations = [];
                        });
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _arrivalStationController,
              decoration: const InputDecoration(
                labelText: 'Gare d\'arrivée',
                icon: Icon(Icons.train),
              ),
              onChanged: (value) => _searchStations(value, false),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une gare d\'arrivée';
                }
                return null;
              },
            ),
            if (_suggestedArrivalStations.isNotEmpty)
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListView.builder(
                  itemCount: _suggestedArrivalStations.length,
                  itemBuilder: (context, index) {
                    final station = _suggestedArrivalStations[index];
                    return ListTile(
                      title: Text(station['name']),
                      subtitle: Text(station['city'] ?? ''),
                      onTap: () {
                        setState(() {
                          _arrivalStationController.text = station['name'];
                          _arrivalStationId = station['id'];
                          _suggestedArrivalStations = [];
                        });
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
            if (!_isManualMode) ...[
              ElevatedButton(
                onPressed: _searchJourneys,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Rechercher mon train'),
              ),
              const SizedBox(height: 24),
              if (_journeys.isNotEmpty) ...[
                const Text(
                  'Trajets disponibles',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _journeys.length,
                  itemBuilder: (context, index) {
                    final journey = _journeys[index];
                    return Card(
                      child: ListTile(
                        leading: _buildTrainLogo(
                          journey['network_name'] ?? '',
                          journey['train_type'] ?? '',
                        ),
                        title: Text(
                          '${journey['type']} ${journey['train_number']}',
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_formatDateTime(journey['departure_time'])),
                            Text(_formatDateTime(journey['arrival_time'])),
                          ],
                        ),
                        onTap: () => _addAutomaticTrip(journey),
                      ),
                    );
                  },
                ),
              ],
            ] else ...[
              ElevatedButton(
                onPressed: _addManualTrip,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Ajouter le trajet'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
