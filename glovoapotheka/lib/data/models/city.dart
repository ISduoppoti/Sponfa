class City {
  final String name;
  final double lat;
  final double lng;

  City({required this.name, required this.lat, required this.lng});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name'],
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }
}
