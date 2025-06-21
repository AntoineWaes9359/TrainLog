import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

abstract class TrainCompanyService {
  Future<List<Map<String, dynamic>>> getStations(String query);
  Future<Map<String, dynamic>> getStationDetails(String stationId);
  Future<List<Map<String, dynamic>>> searchJourneys(
    String departureStationId,
    String arrivalStationId,
    DateTime date, {
    required void Function(int) onJourneysAdded,
  });
  Future<Map<String, dynamic>?> processTicket(XFile image);
  String get companyName;
  String get companyLogoPath;
  String get companyServices;
}
