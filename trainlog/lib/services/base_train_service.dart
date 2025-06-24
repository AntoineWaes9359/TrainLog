import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract class BaseTrainService {
  final Dio _dio = Dio();

  // Configuration de base
  String get baseUrl;
  String get apiKey;
  Map<String, String> get defaultHeaders;

  BaseTrainService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers.addAll(defaultHeaders);
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // Intercepteur pour la gestion d'erreur
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        _handleError(error);
        handler.next(error);
      },
    ));
  }

  // Méthodes abstraites à implémenter
  Future<List<Map<String, dynamic>>> searchStations(String query);
  Future<List<Map<String, dynamic>>> searchTrips({
    required String departureStation,
    required String arrivalStation,
    required DateTime date,
  });

  // Méthodes utilitaires communes
  Future<Response> get(String endpoint,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(endpoint, queryParameters: queryParameters);
    } catch (e) {
      throw _handleRequestError(e, 'GET', endpoint);
    }
  }

  Future<Response> post(String endpoint, {dynamic data}) async {
    try {
      return await _dio.post(endpoint, data: data);
    } catch (e) {
      throw _handleRequestError(e, 'POST', endpoint);
    }
  }

  // Gestion d'erreur centralisée
  Exception _handleRequestError(dynamic error, String method, String endpoint) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return Exception('Timeout de connexion pour $method $endpoint');
        case DioExceptionType.sendTimeout:
          return Exception('Timeout d\'envoi pour $method $endpoint');
        case DioExceptionType.receiveTimeout:
          return Exception('Timeout de réception pour $method $endpoint');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          return Exception('Erreur HTTP $statusCode pour $method $endpoint');
        case DioExceptionType.cancel:
          return Exception('Requête annulée pour $method $endpoint');
        case DioExceptionType.connectionError:
          return Exception('Erreur de connexion pour $method $endpoint');
        case DioExceptionType.badCertificate:
          return Exception('Certificat invalide pour $method $endpoint');
        case DioExceptionType.unknown:
          return Exception(
              'Erreur inconnue pour $method $endpoint: ${error.message}');
      }
    }
    return Exception('Erreur pour $method $endpoint: $error');
  }

  void _handleError(DioException error) {
    // Log l'erreur pour le debugging
    debugPrint('Erreur API: ${error.message}');
  }

  // Méthodes utilitaires pour le parsing
  List<Map<String, dynamic>> parseStationsResponse(dynamic response) {
    // Implémentation par défaut - peut être surchargée
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    } else if (response is Map<String, dynamic> &&
        response.containsKey('stations')) {
      return (response['stations'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  List<Map<String, dynamic>> parseTripsResponse(dynamic response) {
    // Implémentation par défaut - peut être surchargée
    if (response is List) {
      return response.cast<Map<String, dynamic>>();
    } else if (response is Map<String, dynamic> &&
        response.containsKey('trips')) {
      return (response['trips'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Validation des paramètres
  void validateSearchParams({
    required String departureStation,
    required String arrivalStation,
    required DateTime date,
  }) {
    if (departureStation.isEmpty) {
      throw ArgumentError('Station de départ requise');
    }
    if (arrivalStation.isEmpty) {
      throw ArgumentError('Station d\'arrivée requise');
    }
    if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      throw ArgumentError('La date ne peut pas être dans le passé');
    }
  }
}
