import 'package:geolocator/geolocator.dart';

class LocationModel {
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? country;

  LocationModel({
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.country,
  });

  factory LocationModel.fromPosition(Position position) {
    return LocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
