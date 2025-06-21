import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/trip.dart';
import '../providers/trip_provider.dart';

class AddTripScreen extends StatefulWidget {
  const AddTripScreen({super.key});

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _departureStationController = TextEditingController();
  final _arrivalStationController = TextEditingController();
  final _trainNumberController = TextEditingController();
  final _trainTypeController = TextEditingController();
  final _ticketNumberController = TextEditingController();
  final _seatNumberController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _departureTime = DateTime.now();
  DateTime _arrivalTime = DateTime.now().add(const Duration(hours: 1));
  double _distance = 0.0;
  double _price = 0.0;

  @override
  void dispose() {
    _departureStationController.dispose();
    _arrivalStationController.dispose();
    _trainNumberController.dispose();
    _trainTypeController.dispose();
    _ticketNumberController.dispose();
    _seatNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context, bool isDeparture) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isDeparture ? _departureTime : _arrivalTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          isDeparture ? _departureTime : _arrivalTime,
        ),
      );

      if (pickedTime != null) {
        setState(() {
          final dateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          if (isDeparture) {
            _departureTime = dateTime;
          } else {
            _arrivalTime = dateTime;
          }
        });
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final trip = Trip(
          id: const Uuid().v4(),
          departureStationId: '',
          arrivalStationId: '',
          departureCityName: '',
          arrivalCityName: '',
          path: [],
          departureCityGeo: const GeoPoint(0, 0),
          arrivalCityGeo: const GeoPoint(0, 0),
          departureStation: _departureStationController.text,
          arrivalStation: _arrivalStationController.text,
          departureTime: _departureTime,
          arrivalTime: _arrivalTime,
          trainNumber: _trainNumberController.text,
          trainType: _trainTypeController.text,
          distance: _distance,
          price: _price,
          ticketNumber: _ticketNumberController.text.isEmpty
              ? null
              : _ticketNumberController.text,
          seatNumber: _seatNumberController.text.isEmpty
              ? null
              : _seatNumberController.text,
          notes: _notesController.text.isEmpty ? null : _notesController.text);

      context.read<TripProvider>().addTrip(trip);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un trajet'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _departureStationController,
              decoration: const InputDecoration(
                labelText: 'Gare de départ',
                icon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une gare de départ';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _arrivalStationController,
              decoration: const InputDecoration(
                labelText: 'Gare d\'arrivée',
                icon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une gare d\'arrivée';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.departure_board),
              title: const Text('Date et heure de départ'),
              subtitle: Text(
                '${_departureTime.day}/${_departureTime.month}/${_departureTime.year} ${_departureTime.hour}:${_departureTime.minute.toString().padLeft(2, '0')}',
              ),
              onTap: () => _selectDateTime(context, true),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.train),
              title: const Text('Date et heure d\'arrivée'),
              subtitle: Text(
                '${_arrivalTime.day}/${_arrivalTime.month}/${_arrivalTime.year} ${_arrivalTime.hour}:${_arrivalTime.minute.toString().padLeft(2, '0')}',
              ),
              onTap: () => _selectDateTime(context, false),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _ticketNumberController,
              decoration: const InputDecoration(
                labelText: 'Numéro de billet (optionnel)',
                icon: Icon(Icons.confirmation_number),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _seatNumberController,
              decoration: const InputDecoration(
                labelText: 'Numéro de place (optionnel)',
                icon: Icon(Icons.event_seat),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optionnel)',
                icon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Distance (km)',
                icon: Icon(Icons.directions_railway),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une distance';
                }
                final distance = double.tryParse(value);
                if (distance == null || distance <= 0) {
                  return 'Veuillez entrer une distance valide';
                }
                return null;
              },
              onChanged: (value) {
                _distance = double.tryParse(value) ?? 0.0;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Prix (€)',
                icon: Icon(Icons.euro),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un prix';
                }
                final price = double.tryParse(value);
                if (price == null || price < 0) {
                  return 'Veuillez entrer un prix valide';
                }
                return null;
              },
              onChanged: (value) {
                _price = double.tryParse(value) ?? 0.0;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Ajouter le trajet'),
            ),
          ],
        ),
      ),
    );
  }
}
