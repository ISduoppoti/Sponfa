import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glovoapotheka/data/models/cart_item.dart';
import 'package:glovoapotheka/data/providers/cart_provider.dart';
import 'package:glovoapotheka/features/package_details/cubit/package_details_state.dart';
import 'package:glovoapotheka/data/models/product.dart';

class PackageDetailCubit extends Cubit<PackageDetailState> {
  final CartProvider _cartProvider;

  PackageDetailCubit({
    required CartProvider cartProvider,
  })  : _cartProvider = cartProvider,
        super(PackageDetailInitial());

  void initializeWithPackage(PackageAvailabilityInfo package, String descr, String strength, String form) {
    emit(PackageDetailLoaded(
      package: package,
      descr: descr,
      strength: strength,
      form: form,
      cartQuantity: 1,
    ));
  }

  void updateQuantity(int quantity) {
    final state = this.state;
    if (state is PackageDetailLoaded && quantity > 0) {
      emit(state.copyWith(cartQuantity: quantity));
    }
  }

  void addToCart() {
    final state = this.state;
    if (state is PackageDetailLoaded) {
      try {
        _cartProvider.addItem(CartItem(
          id: state.package.packageId,
          name: state.package.displayName,
        ));
        // You might want to show a success message here
      } catch (e) {
        // Handle error
        print('Failed to add to cart: $e');
      }
    }
  }
}