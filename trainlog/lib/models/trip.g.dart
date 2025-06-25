// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Trip _$TripFromJson(Map<String, dynamic> json) => Trip(
      id: json['id'] as String,
      departureStation: json['departureStation'] as String,
      arrivalStation: json['arrivalStation'] as String,
      departureStationId: json['departureStationId'] as String,
      arrivalStationId: json['arrivalStationId'] as String,
      departureCityName: json['departureCityName'] as String,
      arrivalCityName: json['arrivalCityName'] as String,
      departureCityGeo: const GeoPointConverter()
          .fromJson(json['departureCityGeo'] as Map<String, dynamic>),
      arrivalCityGeo: const GeoPointConverter()
          .fromJson(json['arrivalCityGeo'] as Map<String, dynamic>),
      departureTime: DateTime.parse(json['departureTime'] as String),
      arrivalTime: DateTime.parse(json['arrivalTime'] as String),
      trainNumber: json['trainNumber'] as String,
      trainType: json['trainType'] as String,
      distance: (json['distance'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      ticketNumber: json['ticketNumber'] as String?,
      seatNumber: json['seatNumber'] as String?,
      notes: json['notes'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      path: const GeoPointListConverter().fromJson(json['path'] as List),
      company: json['company'] as String?,
      travelClass: json['travelClass'] as String?,
      carNumber: json['carNumber'] as String?,
      delay: json['delay'] == null
          ? null
          : Duration(microseconds: (json['delay'] as num).toInt()),
      cancelled: json['cancelled'] as bool? ?? false,
      tripType: json['tripType'] as String? ?? 'manual',
      brand: json['brand'] as String?,
    );

Map<String, dynamic> _$TripToJson(Trip instance) => <String, dynamic>{
      'id': instance.id,
      'departureStation': instance.departureStation,
      'arrivalStation': instance.arrivalStation,
      'departureStationId': instance.departureStationId,
      'arrivalStationId': instance.arrivalStationId,
      'departureCityName': instance.departureCityName,
      'arrivalCityName': instance.arrivalCityName,
      'departureCityGeo':
          const GeoPointConverter().toJson(instance.departureCityGeo),
      'arrivalCityGeo':
          const GeoPointConverter().toJson(instance.arrivalCityGeo),
      'departureTime': instance.departureTime.toIso8601String(),
      'arrivalTime': instance.arrivalTime.toIso8601String(),
      'trainNumber': instance.trainNumber,
      'trainType': instance.trainType,
      'distance': instance.distance,
      'price': instance.price,
      'ticketNumber': instance.ticketNumber,
      'seatNumber': instance.seatNumber,
      'notes': instance.notes,
      'isFavorite': instance.isFavorite,
      'path': const GeoPointListConverter().toJson(instance.path),
      'company': instance.company,
      'travelClass': instance.travelClass,
      'carNumber': instance.carNumber,
      'delay': instance.delay?.inMicroseconds,
      'cancelled': instance.cancelled,
      'tripType': instance.tripType,
      'brand': instance.brand,
    };
