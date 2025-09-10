// lib/features/product_packages/cubit/product_packages_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glovoapotheka/domain/services/city_service.dart';
import 'package:glovoapotheka/domain/repositories/product_repository.dart';
import 'product_packages_state.dart';
import 'package:glovoapotheka/data/models/product.dart';

class ProductPackagesCubit extends Cubit<ProductPackagesState> {
  final ProductRepository _productRepository;
  final CityService _cityService;

  ProductPackagesCubit(this._productRepository, this._cityService) 
      : super(ProductPackagesInitial());

  Future<void> loadProductPackages(String productId) async {
    emit(ProductPackagesLoading());
    try {
      final city = _cityService.selectedCity;
      final lat = city.lat;
      final lng = city.lng;
      
      final productDetail = await _productRepository.getProductPackages(
        productId: productId,
        lat: lat,
        lng: lng,
        radiusKm: 120,
        onlyInStock: true,
      );
      
      emit(ProductPackagesLoaded(productDetail: productDetail, city: city));
    } catch (e) {
      emit(ProductPackagesError(message: "Failed to load packages: ${e.toString()}"));
    }
  }

  void updateBrandFilter(String brand) {
    final currentState = state;
    if (currentState is ProductPackagesLoaded) {
      emit(currentState.copyWith(selectedBrand: brand));
    }
  }

  void updateManufacturerFilter(String manufacturer) {
    final currentState = state;
    if (currentState is ProductPackagesLoaded) {
      emit(currentState.copyWith(selectedManufacturer: manufacturer));
    }
  }

  void updateStockFilter(bool onlyInStock) {
    final currentState = state;
    if (currentState is ProductPackagesLoaded) {
      emit(currentState.copyWith(onlyInStock: onlyInStock));
    }
  }

  void onPackageSelected(String packageId) {
    // Handle package selection - navigate to pharmacy list or package details
    print('Package selected: $packageId');
    // You can emit a navigation state or handle navigation in the UI
  }

  void onAddToCart(PackageAvailabilityInfo package) {
    // Handle add to cart functionality
    print('Added to cart: ${package.brandName}');
    // You can emit a success state or handle this in the UI
  }
}