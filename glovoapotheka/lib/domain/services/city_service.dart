// lib/domain/services/city_service.dart

import 'package:flutter/foundation.dart';

class CityService extends ChangeNotifier {
  String _selectedCity = "Select City";

  String get selectedCity => _selectedCity;

  void setCity(String city) {
    _selectedCity = city;
    notifyListeners(); // tells widgets to rebuild
  }

  Future<List<String>> getAvailableCities() async {
    // Should be fetched from server
    return ["Vienna", "Berlin", "Prague", "London", "Paris", "Rome"];
  }
}
