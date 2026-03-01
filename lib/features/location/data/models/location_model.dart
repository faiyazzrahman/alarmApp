import 'package:geocoding/geocoding.dart';
import '../../business/entities/location_entity.dart';

class LocationModel extends LocationEntity {
  const LocationModel({
    required super.latitude,
    required super.longitude,
    super.address,
    super.city,
    super.country,
    super.lastFetched,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      address: json['address'],
      city: json['city'],
      country: json['country'],
      lastFetched: json['lastFetched'] != null
          ? DateTime.parse(json['lastFetched'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'country': country,
      'lastFetched': lastFetched?.toIso8601String(),
    };
  }

  static Future<LocationModel> fromPosition(dynamic position) async {
    double lat = position.latitude;
    double lng = position.longitude;

    String? address;
    String? city;
    String? country;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        List<String> addressParts = [];
        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        if (place.country != null && place.country!.isNotEmpty) {
          addressParts.add(place.country!);
        }
        address = addressParts.join(', ');

        city =
            place.locality ??
            place.subAdministrativeArea ??
            place.administrativeArea;
        country = place.country;
      }
    } catch (e) {
      // Geocoding failed, use basic coordinates
    }

    return LocationModel(
      latitude: lat,
      longitude: lng,
      address: address,
      city: city,
      country: country,
      lastFetched: DateTime.now(),
    );
  }

  LocationEntity toEntity() {
    return LocationEntity(
      latitude: latitude,
      longitude: longitude,
      address: address,
      city: city,
      country: country,
      lastFetched: lastFetched,
    );
  }

  factory LocationModel.fromEntity(LocationEntity entity) {
    return LocationModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
      address: entity.address,
      city: entity.city,
      country: entity.country,
      lastFetched: entity.lastFetched,
    );
  }
}
