// lib/domain/services/city_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:glovoapotheka/data/models/city.dart';

class CityService extends ChangeNotifier {
  String _selectedCity = "Select City";
  double _latitude = 48.1486; // Default to Bratislava
  double _longitude = 17.1077;
  List<City> _cities = [];

  String get selectedCity => _selectedCity;
  double get latitude => _latitude;
  double get longitude => _longitude;
  List<City> get cities => _cities;

  /// Manual city selection
  void setCity(String city) {
    _selectedCity = city;

    // If city exists in list, set lat/lng too (should exist)
    final match = _cities.firstWhere(
      (c) => c.name == city,
      orElse: () => City(name: "Bratislava", lat: 48.1486, lng: 17.1077), // default if not found
    );
    _latitude = match.lat;
    _longitude = match.lng;

    notifyListeners();
  }

  /// Fetch cities from backend
  Future<void> loadCities() async {
    _cities = [City(name: "Bratislava", lat: 48.1486, lng: 17.1077), City(name: "Berlin", lat: 52.5200, lng: 13.4050)];
    notifyListeners();

    /*
    final response = await http.get(Uri.parse("https://example.com/cities"));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      _cities = data.map((e) => City.fromJson(e)).toList();
      notifyListeners();
    } else {
      _cities = [City(name: "Bratislava", lat: 48.1486, lng: 17.1077), City(name: "Berlin", lat: 52.5200, lng: 13.4050)];
      notifyListeners();
    }
    */
  }

  /// Fetch user location and set nearest city
  Future<void> detectCityFromLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100, // update when moved 100 meters, optional for now
        ),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      print("User location: $_latitude, $_longitude");


      if (_cities.isEmpty) {
        await loadCities();
      }

      final nearest = _findNearestCity(_cities, _latitude, _longitude);
      _selectedCity = nearest.name;
      //_latitude = nearest.lat;
      //_longitude = nearest.lng;
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching location: $e");
    }
  }

  /// Find nearest city based on coordinates
  City _findNearestCity(List<City> cities, double lat, double lng) {
    City nearest = cities.first;
    double minDistance = double.infinity;

    for (var city in cities) {
      final dist = Geolocator.distanceBetween(
        lat,
        lng,
        city.lat,
        city.lng,
      );
      if (dist < minDistance) {
        minDistance = dist;
        nearest = city;
      }
    }

    return nearest;
  }
}
