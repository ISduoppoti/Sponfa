// lib/features/pakages_menu/packages_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glovoapotheka/core/widgets/top_navigation_bar.dart';
import 'package:glovoapotheka/data/models/cart_item.dart';
import 'package:glovoapotheka/data/providers/cart_provider.dart';
import 'package:glovoapotheka/domain/repositories/product_repository.dart';
import 'package:glovoapotheka/domain/services/city_service.dart';
import 'package:glovoapotheka/features/auth/cart/view/cart_view.dart';
import 'package:glovoapotheka/features/search/view/search_bar_widget.dart';
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
      child: const ProductPackagesView(),
    );
  }
}

class ProductPackagesView extends StatelessWidget {
  const ProductPackagesView({super.key});




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
                  isMobile: false, 
                  screenWidth: screenWidth, 
                  isSearchBar: true, 
                  isTextMenu: true, 
                  controllerText: state.productDetail.displayName
                ),

                // The main content (Row) - Expanded to take remaining vertical space
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main content area - takes 3/4 of the available horizontal space
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product name and city header
                              _buildProductHeader(context, state),
                              const SizedBox(height: 20),
                              
                              // Main packages content island
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.08),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(24),
                                  child: _buildContent(context, state),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 20),

                        // Filters on the right - now as an island
                        Container(
                          width: 280,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(24),
                          child: _buildFilterSection(context, state),
                        ),
                      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                state.productDetail.displayName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E2E2E),
                ),
              ),
              Text(
                " • ${state.productDetail.strength}",
                style: const TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 66, 66, 66),
                ),
              ),
              Text(
                " • ${state.productDetail.form}",
                style: const TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 66, 66, 66),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                'Available in ${currentCity.name}',
                style: TextStyle(
                  fontSize: 16,
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
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: const TextStyle(color: Colors.red, fontSize: 16)),
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
    );
  }

  Widget _buildFilterSection(BuildContext context, ProductPackagesLoaded state) {
    final allBrands = {'All', ...state.productDetail.availablePackages
        .where((p) => p.brandName != null)
        .map((p) => p.brandName!)
        .toSet()};

    final allManufacturers = {'All', ...state.productDetail.availablePackages
        .where((p) => p.manufacturer != null)
        .map((p) => p.manufacturer!)
        .toSet()};

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Filters",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E2E2E))),
          const SizedBox(height: 24),

          // Brand filter
          DropdownButtonFormField<String>(
            value: state.selectedBrand,
            decoration: InputDecoration(
              labelText: 'Brand',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.orange, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            items: allBrands
                .map((brand) =>
                    DropdownMenuItem(value: brand, child: Text(brand)))
                .toList(),
            onChanged: (value) {
              context.read<ProductPackagesCubit>().updateBrandFilter(value!);
            },
          ),
          const SizedBox(height: 20),

          // Manufacturer filter
          DropdownButtonFormField<String>(
            value: state.selectedManufacturer,
            decoration: InputDecoration(
              labelText: 'Manufacturer',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.orange, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            items: allManufacturers
                .map((manufacturer) =>
                    DropdownMenuItem(value: manufacturer, child: Text(manufacturer)))
                .toList(),
            onChanged: (value) {
              context.read<ProductPackagesCubit>().updateManufacturerFilter(value!);
            },
          ),
          const SizedBox(height: 20),

          // Stock filter
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: CheckboxListTile(
              value: state.onlyInStock,
              onChanged: (value) {
                context.read<ProductPackagesCubit>().updateStockFilter(value!);
              },
              title: const Text('Only in stock', style: TextStyle(fontSize: 14)),
              dense: true,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Colors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProductPackagesLoaded state) {
    final packages = state.filteredPackages;

    if (packages.isEmpty) {
      return const Center(
        child: Text(
          'No packages found',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1; // Start with 1 column for the new horizontal layout
        if (constraints.maxWidth > 900) crossAxisCount = 3;
        if (constraints.maxWidth > 1400) crossAxisCount = 4;

        return GridView.builder(
          itemCount: packages.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.9, // Wider aspect ratio for horizontal layout
          ),
          itemBuilder: (context, index) {
            return _buildPackageCard(context, packages[index]);
          },
        );
      },
    );
  }

  Widget _buildPackageCard(BuildContext context, PackageAvailabilityInfo package) {
    final cart = context.watch<CartProvider>();

    final lowestPrice = package.pharmacyLocations
        .where((loc) => loc.priceCents != null)
        .map((loc) => loc.priceCents! / 100.0)
        .fold<double?>(null, (prev, curr) => prev == null ? curr : (curr < prev ? curr : prev));

    final totalStock = package.pharmacyLocations
        .map((loc) => loc.stockQuantity)
        .fold(0, (prev, curr) => prev + curr);

    return _HoverablePackageCard(
      onTap: () {
        context.read<ProductPackagesCubit>().onPackageSelected(package.packageId);
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  // Left side - Image
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.medical_services_outlined,
                      size: 150,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Right side - Information
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand name
                        Text(
                          package.brandName ?? 'Generic',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2E2E2E),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // Pack size and manufacturer
                        Row(
                          children: [
                            if (package.packSize != null) ...[
                              Text(
                                '${package.packSize} units',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              if (package.manufacturer != null) ...[
                                Text(
                                  ' • ',
                                  style: TextStyle(color: Colors.grey.shade400),
                                ),
                              ],
                            ],
                            if (package.manufacturer != null)
                              Expanded(
                                child: Text(
                                  package.manufacturer!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Price and stock info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (lowestPrice != null)
                                  Text(
                                    'From €${lowestPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                Text(
                                  '$totalStock available',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: totalStock > 0 ? Colors.green.shade600 : Colors.red.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Look pharmacies button
                        ElevatedButton(
                          onPressed: () {
                            // context.read<ProductPackagesCubit>().onAddToCart(package);
                            cart.addItem(CartItem(id: package.packageId, name: package.displayName, imageUrl: "someURL", price: package.lowestPrice));
                            cart.showCartPopup(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Add to cart",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),


            ],
          ),
        ),
      ),
    );
  }
}

class _HoverablePackageCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _HoverablePackageCard({
    required this.child,
    required this.onTap,
  });

  @override
  State<_HoverablePackageCard> createState() => _HoverablePackageCardState();
}

class _HoverablePackageCardState extends State<_HoverablePackageCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 4.0,
      end: 12.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
        _animationController.forward();
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
        _animationController.reverse();
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: _isHovered ? 0.12 : 0.04),
                      blurRadius: _elevationAnimation.value,
                      offset: Offset(0, _elevationAnimation.value / 3),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ColorFiltered(
                    colorFilter: _isHovered
                        ? ColorFilter.mode(
                            Colors.orange.withValues(alpha: 0.02),
                            BlendMode.overlay,
                          )
                        : const ColorFilter.mode(
                            Colors.transparent,
                            BlendMode.overlay,
                          ),
                    child: widget.child,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}