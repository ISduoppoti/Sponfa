// lib/domain/services/city_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:glovoapotheka/data/models/city.dart';

class CityService extends ChangeNotifier {
  City? _selectedCity; // Always hold a City object (or null if not selected)
  City? _autoDetectedCity; // Stores auto-detected city (not forced)
  List<City> _cities = [];

  /// Default city if nothing else applies
  final City _defaultCity = City(name: "Bratislava", lat: 48.1486, lng: 17.1077);

  List<City> get cities => _cities;

  City get selectedCity => _selectedCity ?? _defaultCity;
  City? get autoDetectedCity => _autoDetectedCity;

  /// Manual city selection (always overrides auto)
  void setCity(City city) {
    _selectedCity = city;
    notifyListeners();
  }

  /// Fetch cities from backend
  Future<void> loadCities() async {
    _cities = [
      City(name: "Bratislava", lat: 48.1486, lng: 17.1077),
      City(name: "Berlin", lat: 52.5200, lng: 13.4050),
    ];

    /*
    try {
      final response = await http.get(Uri.parse("https://example.com/cities"));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _cities = data.map((e) => City.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Error loading cities: $e");
    }
    */

    notifyListeners();
  }

  /// Fetch user location and suggest nearest city (does not override manual!)
  Future<void> detectCityFromLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        ),
      );

      if (_cities.isEmpty) {
        await loadCities();
      }

      final nearest = _findNearestCity(_cities, position.latitude, position.longitude);

      // Save as auto-detected suggestion
      _autoDetectedCity = nearest;

      // Only apply if user hasn't chosen manually yet
      _selectedCity ??= nearest;

      // Edge case: nearest is not supported (shouldn’t happen if _findNearestCity runs on supported list)
      // But if cities list didn’t contain user’s real city -> fallback to default
      _selectedCity ??= _defaultCity;

      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching location: $e");
    }
  }

  /// Force update city from user’s current location
  Future<void> forceSetCityFromLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
        ),
      );

      if (_cities.isEmpty) {
        await loadCities();
      }

      final nearest = _findNearestCity(
        _cities,
        position.latitude,
        position.longitude,
      );

      _autoDetectedCity = nearest;
      _selectedCity = nearest; // overwrite manual choice
      notifyListeners();
    } catch (e) {
      debugPrint("Error forcing city from location: $e");
    }
  }

  /// Find nearest city from supported list
  City _findNearestCity(List<City> cities, double lat, double lng) {
    City nearest = cities.first;
    double minDistance = double.infinity;

    for (var city in cities) {
      final dist = Geolocator.distanceBetween(lat, lng, city.lat, city.lng);
      if (dist < minDistance) {
        minDistance = dist;
        nearest = city;
      }
    }

    return nearest;
  }

  /// Human-readable string for UI
  String get cityLabel {
    if (_selectedCity != null) return _selectedCity!.name;
    if (_autoDetectedCity != null) {
      return "${_autoDetectedCity!.name} (detected)";
    }
    return _defaultCity.name; // fallback
  }
}
