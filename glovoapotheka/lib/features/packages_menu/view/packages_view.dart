// lib/features/pakages_menu/packages_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glovoapotheka/core/widgets/top_navigation_bar.dart';
import 'package:glovoapotheka/data/models/cart_item.dart';
import 'package:glovoapotheka/data/models/package_details_page_args.dart';
import 'package:glovoapotheka/data/providers/cart_provider.dart';
import 'package:glovoapotheka/domain/repositories/product_repository.dart';
import 'package:glovoapotheka/domain/services/city_service.dart';
import 'package:glovoapotheka/features/auth/cart/view/cart_view.dart';
import 'package:glovoapotheka/features/package_details/view/package_details.dart';
import 'package:glovoapotheka/features/packages_menu/view/packages_view_desktop.dart';
import 'package:glovoapotheka/features/packages_menu/view/packages_view_mobile.dart';
import 'package:glovoapotheka/features/search/view/search_bar_widget.dart';
import 'package:go_router/go_router.dart';
import '../cubit/product_packages_cubit.dart';
import '../cubit/product_packages_state.dart';
import 'package:glovoapotheka/data/models/product.dart';

class ProductPackagesPage extends StatelessWidget {
  final String productId;

  const ProductPackagesPage({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = ProductPackagesCubit(
          context.read<ProductRepository>(),
          context.read<CityService>(),
        );
        cubit.loadProductPackages(productId);
        return cubit;
      },
      child: ProductPackagesView(productId: productId),
    );
  }
}

class ProductPackagesView extends StatelessWidget {
  final String productId;

  const ProductPackagesView({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductPackagesCubit, ProductPackagesState>(
      builder: (context, state) {
        final double screenWidth = MediaQuery.of(context).size.width;
        const double mobileBreakpoint = 768.0;
        final bool isMobile = screenWidth < mobileBreakpoint;

        if (isMobile) {
          return ProductPackagesPageMobile(productId: productId);
        } else {
          return ProductPackagesPageDesktop(productId: productId); // Desktop
        }
      },
    );
  }
}