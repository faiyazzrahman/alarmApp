import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';

abstract class LocationLocalDataSource {
  Future<void> saveLastLocation(LocationModel location);
  Future<LocationModel?> getLastLocation();
  Future<void> clearLastLocation();
}

class LocationLocalDataSourceImpl implements LocationLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _kLastLocationKey = 'last_location';

  LocationLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveLastLocation(LocationModel location) async {
    final jsonString = jsonEncode(location.toJson());
    await sharedPreferences.setString(_kLastLocationKey, jsonString);
  }

  @override
  Future<LocationModel?> getLastLocation() async {
    final jsonString = sharedPreferences.getString(_kLastLocationKey);
    if (jsonString == null) return null;

    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return LocationModel.fromJson(jsonMap);
  }

  @override
  Future<void> clearLastLocation() async {
    await sharedPreferences.remove(_kLastLocationKey);
  }
}
