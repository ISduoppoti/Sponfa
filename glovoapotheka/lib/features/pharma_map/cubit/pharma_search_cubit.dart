import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glovoapotheka/data/models/cart_item.dart';
import 'package:glovoapotheka/data/models/city.dart';
import 'package:glovoapotheka/domain/repositories/product_repository.dart';
import 'package:glovoapotheka/domain/services/city_service.dart';
import 'package:glovoapotheka/features/pharma_map/cubit/pharma_search_state.dart';

class PharmacySearchCubit extends Cubit<PharmacySearchState> {
  final ProductRepository _repository;
  final CityService _cityService;
  Timer? _debounceTimer;

  PharmacySearchCubit(this._repository, this._cityService) 
  : super(PharmacySearchState());

  void setPackages(List<CartItem> items) {
    if (state.items == items) return;
    print("STATE ITEMS SETTING ++++++++++++++++++++++++++++++++");
    print("${items.first.id}");

    emit(state.copyWith(items: items));
  }


  Future<void> loadPharmacies() async {
    print("LOADPHARMA ____________________________-");

    emit(state.copyWith(loading: true, errorMessage: null));

    print(state.packageIds);

    City city = _cityService.selectedCity;
    final lat = city.lat;
    final lng = city.lng;

    try {
      final results = await _repository.searchPharma(
        packageIds: state.ids, 
        lat: lat,
        lng: lng, 
        radiusKm: state.radiusKm, 
        mustHaveAll: state.mustHaveAll, 
        sortBy: state.sortBy,
        limit: state.limit,
      );
      emit(state.copyWith(loading: false, results: results));
    } catch (e) {
      emit(state.copyWith(loading: false, errorMessage: e.toString()));
    }
  }

  void setFilters({
    int? radiusKm,
    bool? mustHaveAll,
    String? sortBy,
  }) {
    emit(state.copyWith(
      radiusKm: radiusKm,
      mustHaveAll: mustHaveAll,
      sortBy: sortBy,
    ));

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), loadPharmacies);
  }

  void selectPharmacy(String pharmacyId) {
    emit(state.copyWith(selectedPharmacyId: pharmacyId));
  }

  void hoverPharmacy(String? pharmacyId) {
    emit(state.copyWith(hoveredPharmacyId: pharmacyId));
  }

  void clearHover() {
    if (state.hoveredPharmacyId != null) {
      emit(state.copyWith(hoveredPharmacyId: null));
    }
  }

  void setLeftPanelRatio(double ratio) {
    emit(state.copyWith(leftPanelRatio: ratio.clamp(0.15, 0.8)));
  }

  void refresh() {
    loadPharmacies();
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}