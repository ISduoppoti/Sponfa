// lib/features/pakages_menu/packages_view_mobile.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glovoapotheka/core/widgets/top_navigation_bar.dart';
import 'package:glovoapotheka/data/models/cart_item.dart';
import 'package:glovoapotheka/data/providers/cart_provider.dart';
import 'package:glovoapotheka/domain/repositories/product_repository.dart';
import 'package:glovoapotheka/domain/services/city_service.dart';
import 'package:go_router/go_router.dart';
import '../cubit/product_packages_cubit.dart';
import '../cubit/product_packages_state.dart';
import 'package:glovoapotheka/data/models/product.dart';

class ProductPackagesPageMobile extends StatelessWidget {
  final String productId;

  const ProductPackagesPageMobile({
    super.key,
    required this.productId,
  });

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
      child: ProductPackagesViewMobile(productId: productId),
    );
  }
}

class ProductPackagesViewMobile extends StatefulWidget {
  final String productId;

  const ProductPackagesViewMobile({
    super.key,
    required this.productId,
  });

  @override
  State<ProductPackagesViewMobile> createState() => _ProductPackagesViewMobileState();
}

class _ProductPackagesViewMobileState extends State<ProductPackagesViewMobile> {
  bool _isFiltersExpanded = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0), // Light orange background
      body: BlocBuilder<ProductPackagesCubit, ProductPackagesState>(
        builder: (context, state) {
          if (state is ProductPackagesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProductPackagesError) {
            return _buildError(state.message, context);
          }
          if (state is ProductPackagesLoaded) {
            return Column(
              children: [
                TopNavigationBar(
                  isMobile: true,
                  screenWidth: screenWidth,
                  isSearchBar: true,
                  isTextMenu: true,
                  controllerText: state.productDetail.displayName,
                ),

                // Main content - scrollable
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product header
                          _buildProductHeader(context, state),
                          const SizedBox(height: 16),

                          // Filter section
                          _buildFilterSection(context, state),
                          const SizedBox(height: 16),

                          // Packages grid
                          _buildContent(context, state),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProductHeader(BuildContext context, ProductPackagesLoaded state) {
    final currentCity = state.city;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.productDetail.displayName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E2E2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${state.productDetail.strength} • ${state.productDetail.form}",
            style: const TextStyle(
              fontSize: 14,
              color: Color.fromARGB(255, 66, 66, 66),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                'Available in ${currentCity.name}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message, BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: const TextStyle(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Retry handled by cubit
                  // context.read<ProductPackagesCubit>().reload(); # TODO:
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, ProductPackagesLoaded state) {
    final allBrands = {
      'All',
      ...state.productDetail.availablePackages
          .where((p) => p.brandName != null)
          .map((p) => p.brandName!)
          .toSet()
    };

    final allManufacturers = {
      'All',
      ...state.productDetail.availablePackages
          .where((p) => p.manufacturer != null)
          .map((p) => p.manufacturer!)
          .toSet()
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Filter header with expand button
          InkWell(
            onTap: () {
              setState(() {
                _isFiltersExpanded = !_isFiltersExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Filters",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                  Row(
                    children: [
                      // Active filters indicator
                      if (state.selectedBrand != 'All' ||
                          state.selectedManufacturer != 'All' ||
                          state.onlyInStock)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getActiveFiltersCount(state).toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Icon(
                        _isFiltersExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expandable filter content
          if (_isFiltersExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 12),

                  // Brand filter
                  DropdownButtonFormField<String>(
                    value: state.selectedBrand,
                    decoration: InputDecoration(
                      labelText: 'Brand',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.orange, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    items: allBrands
                        .map((brand) => DropdownMenuItem(
                              value: brand,
                              child: Text(brand),
                            ))
                        .toList(),
                    onChanged: (value) {
                      context.read<ProductPackagesCubit>().updateBrandFilter(value!);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Manufacturer filter
                  DropdownButtonFormField<String>(
                    value: state.selectedManufacturer,
                    decoration: InputDecoration(
                      labelText: 'Manufacturer',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.orange, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    items: allManufacturers
                        .map((manufacturer) => DropdownMenuItem(
                              value: manufacturer,
                              child: Text(manufacturer),
                            ))
                        .toList(),
                    onChanged: (value) {
                      context
                          .read<ProductPackagesCubit>()
                          .updateManufacturerFilter(value!);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Stock filter
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: CheckboxListTile(
                      value: state.onlyInStock,
                      onChanged: (value) {
                        context.read<ProductPackagesCubit>().updateStockFilter(value!);
                      },
                      title: const Text(
                        'Only in stock',
                        style: TextStyle(fontSize: 14),
                      ),
                      dense: true,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  int _getActiveFiltersCount(ProductPackagesLoaded state) {
    int count = 0;
    if (state.selectedBrand != 'All') count++;
    if (state.selectedManufacturer != 'All') count++;
    if (state.onlyInStock) count++;
    return count;
  }

  Widget _buildContent(BuildContext context, ProductPackagesLoaded state) {
    final packages = state.filteredPackages;

    if (packages.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'No packages found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: packages.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.5, // Taller cards for mobile
      ),
      itemBuilder: (context, index) {
        return _buildPackageCard(
          context,
          packages[index],
          state.productDetail.description,
          state.productDetail.strength,
          state.productDetail.form,
        );
      },
    );
  }

  Widget _buildPackageCard(
    BuildContext context,
    PackageAvailabilityInfo package,
    descr,
    strength,
    form,
  ) {
    final cart = context.read<CartProvider>();
    final imageUrl = (package.imageUrls != null && package.imageUrls!.isNotEmpty)
        ? package.imageUrls![0]
        : "https://thumb.ac-illust.com/b1/b170870007dfa419295d949814474ab2_t.jpeg";

    final lowestPrice = package.pharmacyLocations
        .where((loc) => loc.priceCents != null)
        .map((loc) => loc.priceCents! / 100.0)
        .fold<double?>(
            null, (prev, curr) => prev == null ? curr : (curr < prev ? curr : prev));

    final totalStock = package.pharmacyLocations
        .map((loc) => loc.stockQuantity)
        .fold(0, (prev, curr) => prev + curr);

    return _HoverablePackageCardMobile(
      onTap: () {
        context.go(
          '/packages/${widget.productId}/package_details/${package.packageId}?descr=${Uri.encodeComponent(descr)}&strength=${Uri.encodeComponent(strength)}&form=${Uri.encodeComponent(form)}',
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.network(
                    imageUrl,
                    headers: {'User-Agent': 'Mozilla/5.0'},
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, color: Colors.grey);
                    },
                  ),
                ),
              ),
            ),

            // Information section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand name
                    Text(
                      package.brandName ?? 'Generic',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E2E2E),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Pack size and manufacturer
                    if (package.packSize != null || package.manufacturer != null)
                      Text(
                        [
                          if (package.packSize != null) '${package.packSize} units',
                          if (package.manufacturer != null) package.manufacturer!,
                        ].join(' • '),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    // Price and stock
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (lowestPrice != null)
                          Text(
                            'From €${lowestPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        Text(
                          '$totalStock available',
                          style: TextStyle(
                            fontSize: 10,
                            color: totalStock > 0
                                ? Colors.green.shade600
                                : Colors.red.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    // Add to cart button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          cart.addItem(CartItem(
                            id: package.packageId,
                            name: package.displayName,
                            imageUrls: package.imageUrls,
                            price: package.lowestPrice,
                          ));
                          cart.showCartPopup(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Add to cart",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoverablePackageCardMobile extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _HoverablePackageCardMobile({
    required this.child,
    required this.onTap,
  });

  @override
  State<_HoverablePackageCardMobile> createState() =>
      _HoverablePackageCardMobileState();
}

class _HoverablePackageCardMobileState extends State<_HoverablePackageCardMobile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
        widget.onTap();
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isPressed ? 0.08 : 0.04),
                blurRadius: _isPressed ? 8 : 4,
                offset: Offset(0, _isPressed ? 4 : 2),
              ),
            ],
            borderRadius: BorderRadius.circular(12),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}