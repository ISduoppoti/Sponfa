import 'package:glovoapotheka/data/models/cart_item.dart';
import 'package:glovoapotheka/data/models/product.dart';
import 'package:latlong2/latlong.dart';

class PharmacySearchState {
  final List<PharmacySearchResult> results;
  final List<CartItem> items;
  final bool loading;
  final String? errorMessage;
  final String? selectedPharmacyId;
  final String? hoveredPharmacyId;
  final List<String> packageIds;
  final double lat;
  final double lng;
  final int? radiusKm;
  final bool mustHaveAll;
  final String sortBy;
  final int limit;
  final double leftPanelRatio;
  final LatLng? userLocation;

  PharmacySearchState({
    this.results = const [],
    this.items = const [],
    this.loading = false,
    this.errorMessage,
    this.selectedPharmacyId,
    this.hoveredPharmacyId,
    this.packageIds = const [],
    this.lat = 48.1486, //Bratislava
    this.lng = 17.1077,
    this.radiusKm,
    this.mustHaveAll = true,
    this.sortBy = 'distance',
    this.limit = 20,
    this.leftPanelRatio = 0.4,
    this.userLocation,
  });

  PharmacySearchState copyWith({
    List<PharmacySearchResult>? results,
    final List<CartItem>? items,
    bool? loading,
    String? errorMessage,
    String? selectedPharmacyId,
    String? hoveredPharmacyId,
    List<String>? packageIds,
    double? lat,
    double? lng,
    int? radiusKm,
    bool? mustHaveAll,
    String? sortBy,
    int? limit,
    double? leftPanelRatio,
    LatLng? userLocation,
  }) {
    return PharmacySearchState(
      results: results ?? this.results,
      items: items ?? this.items,
      loading: loading ?? this.loading,
      errorMessage: errorMessage,
      selectedPharmacyId: selectedPharmacyId,
      hoveredPharmacyId: hoveredPharmacyId,
      packageIds: packageIds ?? this.packageIds,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      radiusKm: radiusKm ?? this.radiusKm,
      mustHaveAll: mustHaveAll ?? this.mustHaveAll,
      sortBy: sortBy ?? this.sortBy,
      limit: limit ?? this.limit,
      leftPanelRatio: leftPanelRatio ?? this.leftPanelRatio,
      userLocation: userLocation ?? this.userLocation,
    );
  }

  List<String> get ids => items.map((e) => e.id).toList();
  List<String> get names => items.map((e) => e.name).toList();
  List<String?> get descriptions => items.map((e) => e.description).toList();
  List<int> get quantity => items.map((e) => e.quantity).toList();
  List<List<String>> get allImageUrls =>
      items.map((e) => e.imageUrls ?? []).toList();
}