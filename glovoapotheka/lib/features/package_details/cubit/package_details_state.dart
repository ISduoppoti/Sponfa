// product_detail_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:glovoapotheka/data/models/product.dart';

// States
abstract class PackageDetailState extends Equatable {
  const PackageDetailState();

  @override
  List<Object?> get props => [];
}

class PackageDetailInitial extends PackageDetailState {}

class PackageDetailLoading extends PackageDetailState {}

class PackageDetailLoaded extends PackageDetailState {
  final ProductDetailModel product;
  final String? selectedPackageId;
  final List<String> images;
  final int selectedImageIndex;
  final int cartQuantity;

  const PackageDetailLoaded({
    required this.product,
    this.selectedPackageId,
    this.images = const [],
    this.selectedImageIndex = 0,
    this.cartQuantity = 1,
  });

  PackageDetailLoaded copyWith({
    ProductDetailModel? product,
    String? selectedPackageId,
    List<String>? images,
    int? selectedImageIndex,
    int? cartQuantity,
  }) {
    return PackageDetailLoaded(
      product: product ?? this.product,
      selectedPackageId: selectedPackageId ?? this.selectedPackageId,
      images: images ?? this.images,
      selectedImageIndex: selectedImageIndex ?? this.selectedImageIndex,
      cartQuantity: cartQuantity ?? this.cartQuantity,
    );
  }

  PackageAvailabilityInfo? get selectedPackage {
    if (selectedPackageId == null) return null;
    try {
      return product.availablePackages
          .firstWhere((pkg) => pkg.packageId == selectedPackageId);
    } catch (e) {
      return null;
    }
  }

  @override
  List<Object?> get props => [
        product,
        selectedPackageId,
        images,
        selectedImageIndex,
        cartQuantity,
      ];
}

class PackageDetailError extends PackageDetailState {
  final String message;

  const PackageDetailError(this.message);

  @override
  List<Object> get props => [message];
}