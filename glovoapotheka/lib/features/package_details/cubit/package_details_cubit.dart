import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glovoapotheka/domain/repositories/product_repository.dart';
import 'package:glovoapotheka/domain/services/cart_service.dart';
import 'package:glovoapotheka/features/package_details/cubit/package_details_state.dart';

class PackageDetailCubit extends Cubit<PackageDetailState> {
  final ProductRepository _productService;
  final CartService _cartService;

  PackageDetailCubit({
    required ProductRepository productService,
    required CartService cartService,
  })  : _productService = productService,
        _cartService = cartService,
        super(PackageDetailInitial());

  Future<void> loadPackageDetail(String productId) async {
    emit(PackageDetailLoading());

    try {
      final product = await _productService.getProductPackages(productId);
      final images = await _productService.getProductImages(productId);
      
      // Select first available package by default
      String? selectedPackageId;
      if (product.availablePackages.isNotEmpty) {
        selectedPackageId = product.availablePackages.first.packageId;
      }

      emit(PackageDetailLoaded(
        product: product,
        selectedPackageId: selectedPackageId,
        images: images,
      ));
    } catch (e) {
      emit(PackageDetailError('Failed to load product details: ${e.toString()}'));
    }
  }

  void selectPackage(String packageId) {
    final state = this.state;
    if (state is PackageDetailLoaded) {
      emit(state.copyWith(selectedPackageId: packageId));
    }
  }

  void selectImage(int index) {
    final state = this.state;
    if (state is PackageDetailLoaded) {
      emit(state.copyWith(selectedImageIndex: index));
    }
  }

  void updateQuantity(int quantity) {
    final state = this.state;
    if (state is PackageDetailLoaded && quantity > 0) {
      emit(state.copyWith(cartQuantity: quantity));
    }
  }

  Future<void> addToCart() async {
    final state = this.state;
    if (state is PackageDetailLoaded && state.selectedPackage != null) {
      try {
        await _cartService.addToCart(
          packageId: state.selectedPackageId!,
          quantity: state.cartQuantity,
        );
        // You might want to show a success message here
      } catch (e) {
        // Handle error
        print('Failed to add to cart: $e');
      }
    }
  }
}