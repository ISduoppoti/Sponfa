// lib/features/product_packages/cubit/product_packages_state.dart
import 'package:equatable/equatable.dart';
import 'package:glovoapotheka/data/models/product.dart';
import 'package:glovoapotheka/data/models/city.dart';

abstract class ProductPackagesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductPackagesInitial extends ProductPackagesState {}

class ProductPackagesLoading extends ProductPackagesState {}

class ProductPackagesLoaded extends ProductPackagesState {
  final ProductDetailModel productDetail;
  final String selectedBrand;
  final String selectedManufacturer;
  final bool onlyInStock;
  final City city;

  ProductPackagesLoaded({
    required this.productDetail,
    required this.city,
    this.selectedBrand = 'All',
    this.selectedManufacturer = 'All',
    this.onlyInStock = true,
  });

  ProductPackagesLoaded copyWith({
    ProductDetailModel? productDetail,
    String? selectedBrand,
    String? selectedManufacturer,
    bool? onlyInStock,
    City? city,
  }) {
    return ProductPackagesLoaded(
      productDetail: productDetail ?? this.productDetail,
      city: city?? this.city,
      selectedBrand: selectedBrand ?? this.selectedBrand,
      selectedManufacturer: selectedManufacturer ?? this.selectedManufacturer,
      onlyInStock: onlyInStock ?? this.onlyInStock,
    );
  }

  List<PackageAvailabilityInfo> get filteredPackages {
    return productDetail.availablePackages.where((package) {
      // Brand filter
      if (selectedBrand != 'All' && package.brandName != selectedBrand) {
        return false;
      }

      // Manufacturer filter
      if (selectedManufacturer != 'All' && package.manufacturer != selectedManufacturer) {
        return false;
      }

      // Stock filter
      if (onlyInStock && package.pharmacyLocations.isEmpty) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  List<Object?> get props => [
        productDetail,
        city,
        selectedBrand,
        selectedManufacturer,
        onlyInStock,
      ];
}

class ProductPackagesError extends ProductPackagesState {
  final String message;

  ProductPackagesError({required this.message});

  @override
  List<Object?> get props => [message];
}