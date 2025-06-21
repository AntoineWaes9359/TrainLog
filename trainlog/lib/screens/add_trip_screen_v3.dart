import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../services/sncf_service.dart';
import '../services/sncb_service.dart';
import '../services/trenitalia_service.dart';
import '../services/train_company_service.dart';
import '../config/api_keys.dart';
import '../models/trip.dart';
import '../providers/trip_provider.dart';
import '../utils/distance_calculator.dart';
import '../services/ticket_scanner_service.dart';
import 'dart:convert';
import 'package:trainlog/widgets/scan_loading.dart';
import 'package:image_picker/image_picker.dart';

enum AddTripStep {
  selectCompany,
  selectDate,
  enterDeparture,
  enterArrival,
  enterTrainNumber,
  confirmation
}

class AddTripScreenV3 extends StatefulWidget {
  final String? initialImagePath;

  const AddTripScreenV3({
    super.key,
    this.initialImagePath,
  });

  @override
  State<AddTripScreenV3> createState() => _AddTripScreenV3State();
}

class _AddTripScreenV3State extends State<AddTripScreenV3> {
  AddTripStep _currentStep = AddTripStep.selectCompany;
  String? _selectedCompany;
  DateTime? _selectedDate;
  String? _departureStationId;
  String? _arrivalStationId;
  String? _departureStation;
  String? _arrivalStation;
  List<Map<String, dynamic>> _suggestedStations = [];
  List<Map<String, dynamic>> _journeys = [];
  int _loadedJourneysCount = 0;
  final TextEditingController _stationController = TextEditingController();
  final TextEditingController _trainNumberController = TextEditingController();
  final TextEditingController _trainTypeController = TextEditingController();
  final TextEditingController _ticketNumberController = TextEditingController();
  final TextEditingController _seatNumberController = TextEditingController();
  final TextEditingController _carNumberController = TextEditingController();
  String? _selectedClass;
  late SncfService _sncfService;
  late SncbService _sncbService;
  late TrenitaliaService _trenitaliaService;
  late dynamic _currentService;
  bool _isManualMode = false;
  TimeOfDay _departureTime = TimeOfDay.now();
  TimeOfDay _arrivalTime =
      TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));
  final _ticketScanner = TicketScannerService();

  final Map<String, String> _companies = {
    'SNCF': 'assets/images/logo_SNCF.svg',
    'Trenitalia': 'assets/images/logo_Trenitalia.svg',
    'SNCB': 'assets/images/logo_SNCB.svg',
    'DB': 'assets/images/logo_DB.svg',
  };

  final Map<String, String> _companyServices = {
    'SNCF': 'TGV InOui, Ouigo, TER, Lyria',
    'Trenitalia': 'Frecciarossa, Frecciargento',
    'SNCB': 'IC, L, S',
    'DB': 'ICE, IC, RE',
  };

  @override
  void initState() {
    super.initState();
    _sncfService = SncfService(ApiKeys.sncfApiKey);
    _sncbService = SncbService(ApiKeys.sncbApiKey);
    _trenitaliaService = TrenitaliaService(ApiKeys.trenitaliaApiKey);
    _currentService = _sncfService; // Service par défaut

    // Si une image initiale est fournie, la traiter directement
    if (widget.initialImagePath != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _processInitialImage();
      });
    }
  }

  @override
  void dispose() {
    _stationController.dispose();
    _trainNumberController.dispose();
    _trainTypeController.dispose();
    _ticketNumberController.dispose();
    _seatNumberController.dispose();
    _carNumberController.dispose();
    _ticketScanner.dispose();
    super.dispose();
  }

  void _checkManualMode() {
    if (_selectedDate == null) return;

    final now = DateTime.now();
    final selectedDateMidnight =
        DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
    final todayMidnight = DateTime(now.year, now.month, now.day);

    setState(() {
      _isManualMode = selectedDateMidnight.isBefore(todayMidnight);
    });
  }

  void _selectCompany(String company) {
    setState(() {
      _selectedCompany = company;
      switch (company) {
        case 'SNCB':
          _currentService = _sncbService;
          break;
        case 'Trenitalia':
          _currentService = _trenitaliaService;
          break;
        default:
          _currentService = _sncfService;
      }
      _currentStep = AddTripStep.selectDate;
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _checkManualMode();
      _currentStep = AddTripStep.enterDeparture;
    });
  }

  void _selectStation(Map<String, dynamic> station) {
    setState(() {
      if (_currentStep == AddTripStep.enterDeparture) {
        _departureStation = station['name'];
        _departureStationId = station['id'];
        _currentStep = AddTripStep.enterArrival;
        _stationController.text = _arrivalStation ?? '';
        _searchStations(_arrivalStation ?? '');
      } else {
        _arrivalStation = station['name'];
        _arrivalStationId = station['id'];
        _currentStep = AddTripStep.enterTrainNumber;
      }
      _suggestedStations = [];
    });
  }

  Future<void> _searchStations(String query) async {
    if (query.length < 2) {
      setState(() {
        _suggestedStations = [];
      });
      return;
    }

    try {
      final stations = await _currentService.getStations(query);
      setState(() {
        _suggestedStations = stations;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  Future<void> _searchJourneys() async {
    if (_departureStationId == null ||
        _arrivalStationId == null ||
        _selectedDate == null) return;

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
      final journeys = await _currentService.searchJourneys(
        _departureStationId!,
        _arrivalStationId!,
        _selectedDate!,
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

      if (_journeys.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucun trajet trouvé pour cette recherche.'),
            ),
          );
        }
      } else {
        _showJourneysBottomSheet();
      }
    } catch (e) {
      // Fermer la boîte de dialogue de chargement en cas d'erreur
      if (dialogContext != null && context.mounted) {
        Navigator.of(dialogContext!).pop();
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  void _showJourneysBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_journeys.length} ${_journeys.length == 1 ? 'trajet disponible' : 'trajets disponibles'}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _journeys.length,
                itemBuilder: (context, index) {
                  final journey = _journeys[index];
                  final departureTime =
                      DateTime.parse(journey['departure_time']);
                  final arrivalTime = DateTime.parse(journey['arrival_time']);
                  final duration = arrivalTime.difference(departureTime);

                  return Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () => _addAutomaticTrip(journey),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${journey['type']} ${journey['train_number']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${duration.inHours}h${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('HH:mm')
                                            .format(departureTime),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _departureStation!,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('HH:mm').format(arrivalTime),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _arrivalStation!,
                                        style: TextStyle(
                                          color: Colors.grey[600],
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
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
      Navigator.pop(context); // Fermer la bottom sheet
      Navigator.pop(context); // Retourner à l'écran principal
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

  Future<void> _addManualTrip() async {
    if (_selectedDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une date'),
          ),
        );
      }
      return;
    }

    final departureDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _departureTime.hour,
      _departureTime.minute,
    );
    final arrivalDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _arrivalTime.hour,
      _arrivalTime.minute,
    );

    // Récupérer les détails des gares
    Map<String, dynamic>? departureDetails;
    Map<String, dynamic>? arrivalDetails;

    if (_departureStationId != null && _arrivalStationId != null) {
      try {
        departureDetails =
            await _currentService.getStationDetails(_departureStationId!);
        arrivalDetails =
            await _currentService.getStationDetails(_arrivalStationId!);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Erreur lors de la récupération des détails des gares'),
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
      departureStation: _departureStation!,
      arrivalStation: _arrivalStation!,
      departureStationId: _departureStationId ?? '',
      arrivalStationId: _arrivalStationId ?? '',
      departureCityName: departureDetails?['city'] ?? _departureStation!,
      arrivalCityName: arrivalDetails?['city'] ?? _arrivalStation!,
      departureCityGeo: departureCityGeo,
      arrivalCityGeo: arrivalCityGeo,
      departureTime: departureDateTime,
      arrivalTime: arrivalDateTime,
      trainNumber: _trainNumberController.text,
      trainType: _trainTypeController.text,
      distance: distance,
      price: 0,
      path: path,
      ticketNumber: _ticketNumberController.text.isEmpty
          ? null
          : _ticketNumberController.text,
      seatNumber: _seatNumberController.text.isEmpty
          ? null
          : _seatNumberController.text,
      carNumber:
          _carNumberController.text.isEmpty ? null : _carNumberController.text,
      travelClass: _selectedClass,
    );

    await context.read<TripProvider>().addTrip(trip);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _scanTicket() async {
    final XFile? image = await _ticketScanner.pickImage();
    if (image != null) {
      // Afficher l'écran de chargement
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanLoading(
            image: image,
            status: 'Analyse du billet en cours...',
          ),
        ),
      );

      // Effectuer l'OCR et l'analyse en arrière-plan
      final ticketInfo = await _ticketScanner.processImage(image);

      // Fermer l'écran de chargement
      if (mounted) {
        Navigator.pop(context);
      }

      if (ticketInfo != null) {
        try {
          final Map<String, dynamic> jsonData = jsonDecode(ticketInfo);

          // Fonction utilitaire pour nettoyer et valider les chaînes de caractères
          String? cleanString(String? value) {
            if (value == null || value.isEmpty) return null;
            return value.trim();
          }

          // Fonction utilitaire pour parser les dates
          DateTime? parseDate(String? dateStr) {
            if (dateStr == null || dateStr.isEmpty) return null;

            try {
              // Essayer d'abord le format ISO 8601
              try {
                return DateTime.parse(dateStr);
              } catch (e) {
                // Continuer avec les autres formats si le format ISO échoue
              }

              // Essayer différents formats de date
              final formats = [
                'yyyy-MM-dd HH:mm',
                'dd/MM/yyyy HH:mm',
                'dd MMMM yyyy HH:mm',
                'EEEE dd MMMM yyyy HH:mm',
                'EEEE dd MMMM yyyy HH\'h\'mm',
              ];

              for (final format in formats) {
                try {
                  return DateFormat(format, 'fr_FR').parse(dateStr);
                } catch (e) {
                  continue;
                }
              }

              // Si aucun format ne fonctionne, essayer de nettoyer la chaîne
              final cleanedDate = dateStr
                  .replaceAll('h', ':')
                  .replaceAll('H', ':')
                  .replaceAll('min', '')
                  .trim();

              return DateFormat('EEEE dd MMMM yyyy HH:mm', 'fr_FR')
                  .parse(cleanedDate);
            } catch (e) {
              print('Erreur lors du parsing de la date: $dateStr');
              return null;
            }
          }

          // Vérifier que les dates sont valides
          final departureDateTime = parseDate(jsonData['departureDateTime']);
          final arrivalDateTime = parseDate(jsonData['arrivalDateTime']);

          if (departureDateTime == null || arrivalDateTime == null) {
            throw Exception('Impossible de lire les dates du billet');
          }

          setState(() {
            // Gestion de la gare de départ
            final departureStation = cleanString(jsonData['departureStation']);
            if (departureStation != null) {
              _departureStation = departureStation;
              _stationController.text = _departureStation!;
              _currentStep = AddTripStep.enterDeparture;
              _searchStations(_departureStation!);
            }

            // Gestion de la gare d'arrivée
            final arrivalStation = cleanString(jsonData['arrivalStation']);
            if (arrivalStation != null) {
              _arrivalStation = arrivalStation;
            }

            // Gestion du numéro de train
            final trainNumber = cleanString(jsonData['trainNumber']);
            if (trainNumber != null) {
              _trainNumberController.text = trainNumber;
            }

            // Gestion du type de train
            final trainType = cleanString(jsonData['trainType']);
            if (trainType != null) {
              _trainTypeController.text = trainType;
            }

            // Gestion du numéro de dossier
            final ticketNumber = cleanString(jsonData['ticketNumber']);
            if (ticketNumber != null) {
              _ticketNumberController.text = ticketNumber;
            }

            // Gestion du numéro de voiture
            final carNumber = cleanString(jsonData['carNumber']);
            if (carNumber != null) {
              _carNumberController.text = carNumber;
            }

            // Gestion du numéro de siège
            final seatNumber = cleanString(jsonData['seatNumber']);
            if (seatNumber != null) {
              _seatNumberController.text = seatNumber;
            }

            // Gestion de la classe
            final travelClass = cleanString(jsonData['travelClass']);
            if (travelClass != null) {
              _selectedClass = travelClass;
            }

            // Gestion des dates
            _selectedDate = departureDateTime;
            _departureTime = TimeOfDay.fromDateTime(departureDateTime);
            _arrivalTime = TimeOfDay.fromDateTime(arrivalDateTime);

            _isManualMode = true;
          });
        } catch (e) {
          print('Erreur lors du décodage du JSON: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Erreur lors de la lecture du billet. Veuillez réessayer ou saisir manuellement.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      }
    }
  }

  Future<void> _processInitialImage() async {
    if (widget.initialImagePath == null) return;

    // Afficher l'écran de chargement
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScanLoading(
          image: XFile(widget.initialImagePath!),
          status: 'Analyse du billet en cours...',
        ),
      ),
    );

    // Effectuer l'OCR et l'analyse en arrière-plan
    final ticketInfo =
        await _ticketScanner.processImage(XFile(widget.initialImagePath!));

    // Fermer l'écran de chargement
    if (mounted) {
      Navigator.pop(context);
    }

    if (ticketInfo != null) {
      try {
        final Map<String, dynamic> jsonData = jsonDecode(ticketInfo);

        // Fonction utilitaire pour nettoyer et valider les chaînes de caractères
        String? cleanString(String? value) {
          if (value == null || value.isEmpty) return null;
          return value.trim();
        }

        // Fonction utilitaire pour parser les dates
        DateTime? parseDate(String? dateStr) {
          if (dateStr == null || dateStr.isEmpty) return null;

          try {
            // Essayer d'abord le format ISO 8601
            try {
              return DateTime.parse(dateStr);
            } catch (e) {
              // Continuer avec les autres formats si le format ISO échoue
            }

            // Essayer différents formats de date
            final formats = [
              'yyyy-MM-dd HH:mm',
              'dd/MM/yyyy HH:mm',
              'dd MMMM yyyy HH:mm',
              'EEEE dd MMMM yyyy HH:mm',
              'EEEE dd MMMM yyyy HH\'h\'mm',
            ];

            for (final format in formats) {
              try {
                return DateFormat(format, 'fr_FR').parse(dateStr);
              } catch (e) {
                continue;
              }
            }

            // Si aucun format ne fonctionne, essayer de nettoyer la chaîne
            final cleanedDate = dateStr
                .replaceAll('h', ':')
                .replaceAll('H', ':')
                .replaceAll('min', '')
                .trim();

            return DateFormat('EEEE dd MMMM yyyy HH:mm', 'fr_FR')
                .parse(cleanedDate);
          } catch (e) {
            print('Erreur lors du parsing de la date: $dateStr');
            return null;
          }
        }

        // Vérifier que les dates sont valides
        final departureDateTime = parseDate(jsonData['departureDateTime']);
        final arrivalDateTime = parseDate(jsonData['arrivalDateTime']);

        if (departureDateTime == null || arrivalDateTime == null) {
          throw Exception('Impossible de lire les dates du billet');
        }

        setState(() {
          // Gestion de la gare de départ
          final departureStation = cleanString(jsonData['departureStation']);
          if (departureStation != null) {
            _departureStation = departureStation;
            _stationController.text = _departureStation!;
            _currentStep = AddTripStep.enterDeparture;
            _searchStations(_departureStation!);
          }

          // Gestion de la gare d'arrivée
          final arrivalStation = cleanString(jsonData['arrivalStation']);
          if (arrivalStation != null) {
            _arrivalStation = arrivalStation;
          }

          // Gestion du numéro de train
          final trainNumber = cleanString(jsonData['trainNumber']);
          if (trainNumber != null) {
            _trainNumberController.text = trainNumber;
          }

          // Gestion du type de train
          final trainType = cleanString(jsonData['trainType']);
          if (trainType != null) {
            _trainTypeController.text = trainType;
          }

          // Gestion du numéro de dossier
          final ticketNumber = cleanString(jsonData['ticketNumber']);
          if (ticketNumber != null) {
            _ticketNumberController.text = ticketNumber;
          }

          // Gestion du numéro de voiture
          final carNumber = cleanString(jsonData['carNumber']);
          if (carNumber != null) {
            _carNumberController.text = carNumber;
          }

          // Gestion du numéro de siège
          final seatNumber = cleanString(jsonData['seatNumber']);
          if (seatNumber != null) {
            _seatNumberController.text = seatNumber;
          }

          // Gestion de la classe
          final travelClass = cleanString(jsonData['travelClass']);
          if (travelClass != null) {
            _selectedClass = travelClass;
          }

          // Gestion des dates
          _selectedDate = departureDateTime;
          _departureTime = TimeOfDay.fromDateTime(departureDateTime);
          _arrivalTime = TimeOfDay.fromDateTime(arrivalDateTime);

          _isManualMode = true;
        });
      } catch (e) {
        print('Erreur lors du décodage du JSON: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Erreur lors de la lecture du billet. Veuillez réessayer ou saisir manuellement.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Widget _buildSelectionPills() {
    if (_currentStep == AddTripStep.selectCompany) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (_selectedCompany != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      padding: const EdgeInsets.all(2),
                      child: SvgPicture.asset(
                        _companies[_selectedCompany]!,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _selectedCompany!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            if (_selectedDate != null) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[700],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('dd/MM/yy', 'fr_FR').format(_selectedDate!),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_departureStation != null) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.train,
                      size: 16,
                      color: Colors.grey[700],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _departureStation!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_arrivalStation != null) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.train,
                      size: 16,
                      color: Colors.grey[700],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _arrivalStation!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompanySelection() {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _companies.length,
      itemBuilder: (context, index) {
        final company = _companies.keys.elementAt(index);
        final logoPath = _companies[company]!;
        final services = _companyServices[company]!;
        final isDisabled = company == 'DB'; // On active maintenant Trenitalia

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : () => _selectCompany(company),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: isDisabled ? Colors.grey[100] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(8),
                    child: SvgPicture.asset(
                      logoPath,
                      colorFilter: isDisabled
                          ? ColorFilter.mode(Colors.grey[400]!, BlendMode.srcIn)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    company,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDisabled ? Colors.grey[400] : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    services,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDisabled ? Colors.grey[400] : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _currentStep = AddTripStep.selectCompany;
                  });
                },
              ),
              const SizedBox(width: 8),
              const Text(
                'Date de départ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDateOption(
                'Aujourd\'hui',
                Icons.today,
                DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                ),
              ),
              const SizedBox(height: 16),
              _buildDateOption(
                'Demain',
                Icons.add,
                DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                ).add(const Duration(days: 1)),
              ),
              const SizedBox(height: 16),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      final dateAt00 =
                          DateTime(date.year, date.month, date.day);
                      _selectDate(dateAt00);
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.calendar_month,
                            size: 24,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Choisir une date',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Sélectionner une date spécifique',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Séparateur "OU"
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.grey[300],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OU',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Bouton Scanner
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _scanTicket,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.document_scanner,
                            size: 24,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Scanner mon billet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'BETA',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Wallet Apple ou capture d\'écran',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateOption(String label, IconData icon, DateTime date) {
    final formattedDate = DateFormat('E, d MMM', 'fr_FR').format(date);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectDate(date),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStationSelection(bool isDeparture) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.arrow_back),
                ),
                onPressed: () {
                  setState(() {
                    _currentStep = isDeparture
                        ? AddTripStep.selectDate
                        : AddTripStep.enterDeparture;
                    _stationController.clear();
                    _suggestedStations = [];
                  });
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _stationController,
                  autofocus: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    hintText:
                        isDeparture ? 'Gare de départ' : 'Gare d\'arrivée',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 20,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                  onChanged: _searchStations,
                ),
              ),
            ],
          ),
        ),
        if (_suggestedStations.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: _suggestedStations.length,
              itemBuilder: (context, index) {
                final station = _suggestedStations[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _selectStation(station),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.train,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  station['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (station['city'] != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    station['city'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSearchTrainStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.arrow_back),
                  ),
                  onPressed: () {
                    setState(() {
                      _currentStep = AddTripStep.enterArrival;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Résumé du trajet
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Date
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('EEEE d MMMM yyyy', 'fr_FR')
                            .format(_selectedDate!),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Gare de départ
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.train, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Départ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _departureStation!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                    child: Container(
                      width: 2,
                      height: 24,
                      color: Colors.grey[300],
                    ),
                  ),
                  // Gare d'arrivée
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.train, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Arrivée',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _arrivalStation!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
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
            if (_isManualMode) ...[
              const SizedBox(height: 24),
              // Heure de départ
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Heure de départ'),
                subtitle: Text(_departureTime.format(context)),
                onTap: () => _selectTime(context, true),
                tileColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),
              // Heure d'arrivée
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Heure d\'arrivée'),
                subtitle: Text(_arrivalTime.format(context)),
                onTap: () => _selectTime(context, false),
                tileColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),
              // Numéro de train
              TextField(
                controller: _trainNumberController,
                decoration: InputDecoration(
                  labelText: 'Numéro de train',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.train),
                ),
              ),
              const SizedBox(height: 16),
              // Type de train
              TextField(
                controller: _trainTypeController,
                decoration: InputDecoration(
                  labelText: 'Type de train',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.directions_railway),
                ),
              ),
              const SizedBox(height: 16),
              // Numéro de dossier
              TextField(
                controller: _ticketNumberController,
                decoration: InputDecoration(
                  labelText: 'Numéro de dossier',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.confirmation_number),
                ),
              ),
              const SizedBox(height: 16),
              // Voiture
              TextField(
                controller: _carNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Voiture',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.train),
                ),
              ),
              const SizedBox(height: 16),
              // Siège
              TextField(
                controller: _seatNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Siège',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.chair),
                ),
              ),
              const SizedBox(height: 16),
              // Classe
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.class_, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Classe',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          ['Seconde', 'Première', 'Business'].map((option) {
                        final isSelected = _selectedClass == option;
                        return InkWell(
                          onTap: () {
                            setState(() => _selectedClass = option);
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
                                    : const Color(0xFFE5E5E5),
                              ),
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
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: FilledButton(
                onPressed: _isManualMode ? _addManualTrip : _searchJourneys,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _isManualMode ? 'Ajouter le trajet' : 'Rechercher mon train',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ajouter un trajet',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _getStepTitle(),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.close),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        toolbarHeight: 80,
      ),
      body: Column(
        children: [
          _buildSelectionPills(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildCurrentStep(),
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case AddTripStep.selectCompany:
        return 'Sélectionnez une compagnie';
      case AddTripStep.selectDate:
        return 'Sélectionnez une date';
      case AddTripStep.enterDeparture:
        return 'D\'où partez-vous ?';
      case AddTripStep.enterArrival:
        return 'Où allez-vous ?';
      case AddTripStep.enterTrainNumber:
        return 'Numéro du train';
      case AddTripStep.confirmation:
        return 'Confirmation';
    }
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case AddTripStep.selectCompany:
        return _buildCompanySelection();
      case AddTripStep.selectDate:
        return _buildDateSelection();
      case AddTripStep.enterDeparture:
        return _buildStationSelection(true);
      case AddTripStep.enterArrival:
        return _buildStationSelection(false);
      case AddTripStep.enterTrainNumber:
        return _buildSearchTrainStep();
      default:
        return const SizedBox.shrink();
    }
  }
}
