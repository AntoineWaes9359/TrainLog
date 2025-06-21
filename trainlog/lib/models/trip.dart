import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'trip.g.dart';

@JsonSerializable()
class GeoPointConverter
    implements JsonConverter<GeoPoint, Map<String, dynamic>> {
  const GeoPointConverter();

  @override
  GeoPoint fromJson(Map<String, dynamic> json) {
    return GeoPoint(json['latitude'] as double, json['longitude'] as double);
  }

  @override
  Map<String, dynamic> toJson(GeoPoint geoPoint) {
    return {
      'latitude': geoPoint.latitude,
      'longitude': geoPoint.longitude,
    };
  }
}

class GeoPointListConverter
    implements JsonConverter<List<GeoPoint>, List<dynamic>> {
  const GeoPointListConverter();

  @override
  List<GeoPoint> fromJson(List<dynamic> json) {
    return json.map((item) {
      final map = item as Map<String, dynamic>;
      return GeoPoint(map['latitude'] as double, map['longitude'] as double);
    }).toList();
  }

  @override
  List<dynamic> toJson(List<GeoPoint> geoPoints) {
    return geoPoints
        .map((point) => {
              'latitude': point.latitude,
              'longitude': point.longitude,
            })
        .toList();
  }
}

@JsonSerializable()
class Trip {
  final String id;
  final String departureStation;
  final String arrivalStation;
  final String departureStationId;
  final String arrivalStationId;
  final String departureCityName;
  final String arrivalCityName;
  @GeoPointConverter()
  final GeoPoint departureCityGeo;
  @GeoPointConverter()
  final GeoPoint arrivalCityGeo;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String trainNumber;
  final String trainType;
  final double distance;
  final double price;
  final String? ticketNumber;
  final String? seatNumber;
  final String? notes;
  final bool isFavorite;
  @GeoPointListConverter()
  final List<GeoPoint> path;
  final String? company;
  final String? travelClass;
  final String? carNumber;
  final Duration? delay;
  final bool cancelled;
  final String tripType;
  final String? brand;

  Trip({
    required this.id,
    required this.departureStation,
    required this.arrivalStation,
    required this.departureStationId,
    required this.arrivalStationId,
    required this.departureCityName,
    required this.arrivalCityName,
    required this.departureCityGeo,
    required this.arrivalCityGeo,
    required this.departureTime,
    required this.arrivalTime,
    required this.trainNumber,
    required this.trainType,
    required this.distance,
    required this.price,
    this.ticketNumber,
    this.seatNumber,
    this.notes,
    this.isFavorite = false,
    required this.path,
    this.company,
    this.travelClass,
    this.carNumber,
    this.delay,
    this.cancelled = false,
    this.tripType = 'manual',
    this.brand,
  });

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
  Map<String, dynamic> toJson() => _$TripToJson(this);

  Duration get duration => arrivalTime.difference(departureTime);

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h${minutes.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    return DateFormat('dd/MM/yyyy').format(departureTime);
  }

  String get formattedTime {
    return DateFormat('HH:mm').format(departureTime);
  }

  Trip copyWith({
    String? id,
    String? departureStation,
    String? arrivalStation,
    String? departureStationId,
    String? arrivalStationId,
    String? departureCityName,
    String? arrivalCityName,
    GeoPoint? departureCityGeo,
    GeoPoint? arrivalCityGeo,
    DateTime? departureTime,
    DateTime? arrivalTime,
    String? trainNumber,
    String? trainType,
    double? distance,
    double? price,
    String? ticketNumber,
    String? seatNumber,
    String? notes,
    bool? isFavorite,
    List<GeoPoint>? path,
    String? company,
    String? travelClass,
    String? carNumber,
    Duration? delay,
    bool? cancelled,
    String? tripType,
    String? brand,
  }) {
    return Trip(
      id: id ?? this.id,
      departureStation: departureStation ?? this.departureStation,
      arrivalStation: arrivalStation ?? this.arrivalStation,
      departureStationId: departureStationId ?? this.departureStationId,
      arrivalStationId: arrivalStationId ?? this.arrivalStationId,
      departureCityName: departureCityName ?? this.departureCityName,
      arrivalCityName: arrivalCityName ?? this.arrivalCityName,
      departureCityGeo: departureCityGeo ?? this.departureCityGeo,
      arrivalCityGeo: arrivalCityGeo ?? this.arrivalCityGeo,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      trainNumber: trainNumber ?? this.trainNumber,
      trainType: trainType ?? this.trainType,
      distance: distance ?? this.distance,
      price: price ?? this.price,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      seatNumber: seatNumber ?? this.seatNumber,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
      path: path ?? this.path,
      company: company ?? this.company,
      travelClass: travelClass ?? this.travelClass,
      carNumber: carNumber ?? this.carNumber,
      delay: delay ?? this.delay,
      cancelled: cancelled ?? this.cancelled,
      tripType: tripType ?? this.tripType,
      brand: brand ?? this.brand,
    );
  }

  // Convertir un Trip en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'departureStation': departureStation,
      'arrivalStation': arrivalStation,
      'departureStationId': departureStationId,
      'arrivalStationId': arrivalStationId,
      'departureCityName': departureCityName,
      'arrivalCityName': arrivalCityName,
      'departureCityGeo': departureCityGeo,
      'arrivalCityGeo': arrivalCityGeo,
      'departureTime': Timestamp.fromDate(departureTime),
      'arrivalTime': Timestamp.fromDate(arrivalTime),
      'trainNumber': trainNumber,
      'trainType': trainType,
      'distance': distance,
      'price': price,
      'isFavorite': isFavorite,
      'ticketNumber': ticketNumber,
      'seatNumber': seatNumber,
      'notes': notes,
      'path': path
          .map((point) => {
                'latitude': point.latitude,
                'longitude': point.longitude,
              })
          .toList(),
      'company': company,
      'travelClass': travelClass,
      'carNumber': carNumber,
      'delay': delay?.inMinutes,
      'cancelled': cancelled,
      'tripType': tripType,
      'brand': brand,
    };
  }

  // Créer un Trip à partir d'une Map de Firestore
  factory Trip.fromMap(Map<String, dynamic> map, String id) {
    List<GeoPoint> path = [];
    if (map['path'] != null) {
      final pathData = map['path'] as List<dynamic>;
      path = pathData.map((point) {
        final pointMap = point as Map<String, dynamic>;
        return GeoPoint(
          pointMap['latitude'] as double,
          pointMap['longitude'] as double,
        );
      }).toList();
    }

    return Trip(
      id: id,
      departureStation: map['departureStation'] as String,
      arrivalStation: map['arrivalStation'] as String,
      departureStationId: map['departureStationId'] as String,
      arrivalStationId: map['arrivalStationId'] as String,
      departureCityName: map['departureCityName'] as String,
      arrivalCityName: map['arrivalCityName'] as String,
      departureCityGeo: map['departureCityGeo'] as GeoPoint,
      arrivalCityGeo: map['arrivalCityGeo'] as GeoPoint,
      departureTime: (map['departureTime'] as Timestamp).toDate(),
      arrivalTime: (map['arrivalTime'] as Timestamp).toDate(),
      trainNumber: map['trainNumber'] as String,
      trainType: map['trainType'] as String,
      distance: (map['distance'] as num).toDouble(),
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      isFavorite: map['isFavorite'] as bool? ?? false,
      ticketNumber: map['ticketNumber'] as String?,
      seatNumber: map['seatNumber'] as String?,
      notes: map['notes'] as String?,
      path: path,
      company: map['company'] as String?,
      travelClass: map['travelClass'] as String?,
      carNumber: map['carNumber'] as String?,
      delay:
          map['delay'] != null ? Duration(minutes: map['delay'] as int) : null,
      cancelled: map['cancelled'] as bool? ?? false,
      tripType: map['tripType'] as String? ?? 'manual',
      brand: map['brand'] as String?,
    );
  }
}
