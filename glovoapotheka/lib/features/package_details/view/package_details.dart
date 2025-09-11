// package_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glovoapotheka/data/models/product.dart';
import 'package:glovoapotheka/data/providers/cart_provider.dart';
import 'package:glovoapotheka/domain/repositories/product_repository.dart';
import 'package:glovoapotheka/domain/services/city_service.dart';
import 'package:glovoapotheka/features/package_details/cubit/package_details_cubit.dart';
import 'package:glovoapotheka/features/package_details/cubit/package_details_state.dart';
import 'package:glovoapotheka/features/packages_menu/cubit/product_packages_cubit.dart';

class ProductDetailPage extends StatelessWidget {
  final String productId;

  const ProductDetailPage({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductPackagesCubit(
          context.read<ProductRepository>(),
          context.read<CityService>(),
      )..loadProductPackages(productId),
      child: const ProductDetailView(),
    );
  }
}

class ProductDetailView extends StatelessWidget {
  const ProductDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black87),
            onPressed: () {
              // Implement share functionality
            },
          ),
        ],
      ),
      body: BlocBuilder<PackageDetailCubit, PackageDetailState>(
        builder: (context, state) {
          if (state is PackageDetailLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF8C42),
              ),
            );
          }

          if (state is PackageDetailError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading product',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          if (state is PackageDetailLoaded) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Images Section
                  _PackageImageCarousel(
                    images: state.images,
                    selectedIndex: state.selectedImageIndex,
                  ),
                  
                  // Product Info Section
                  Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PackageHeader(product: state.product),
                        const Divider(height: 1),
                        _PackageSelector(
                          packages: state.product.availablePackages,
                          selectedPackageId: state.selectedPackageId,
                        ),
                        if (state.selectedPackage != null) ...[
                          const Divider(height: 1),
                          _PriceAndCartSection(
                            package: state.selectedPackage!,
                            quantity: state.cartQuantity,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description Section
                  if (state.product.description != null)
                    _DescriptionSection(description: state.product.description!),
                  
                  const SizedBox(height: 16),
                  
                  // Pharmacy Locations Section
                  if (state.selectedPackage != null)
                    _PharmacyLocationsSection(package: state.selectedPackage!),
                    
                  const SizedBox(height: 100), // Bottom padding for floating button
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: BlocBuilder<PackageDetailCubit, PackageDetailState>(
        builder: (context, state) {
          if (state is PackageDetailLoaded && state.selectedPackage != null) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              height: 56,
              child: FloatingActionButton.extended(
                onPressed: () => context.read<PackageDetailCubit>().addToCart(),
                backgroundColor: const Color(0xFFFF8C42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Add to Cart • ${state.selectedPackage!.lowestPriceFormatted}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// Package Image Carousel Widget
class _PackageImageCarousel extends StatelessWidget {
  final List<String> images;
  final int selectedIndex;

  const _PackageImageCarousel({
    required this.images,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        height: 300,
        color: Colors.white,
        child: Center(
          child: Icon(
            Icons.medication,
            size: 80,
            color: Colors.grey[300],
          ),
        ),
      );
    }

    return Container(
      height: 300,
      color: Colors.white,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: images.length,
            onPageChanged: (index) {
              context.read<PackageDetailCubit>().selectImage(index);
            },
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Image.network(
                  images[index],
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.medication,
                      size: 80,
                      color: Colors.grey[300],
                    );
                  },
                ),
              );
            },
          ),
          if (images.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: images.asMap().entries.map((entry) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: entry.key == selectedIndex
                          ? const Color(0xFFFF8C42)
                          : Colors.grey[400],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

// Package Header Widget
class _PackageHeader extends StatelessWidget {
  final ProductDetailModel product;

  const _PackageHeader({required this.product});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          if (product.strength != null || product.form != null)
            const SizedBox(height: 4),
          if (product.strength != null || product.form != null)
            Text(
              [product.strength, product.form]
                  .where((e) => e != null)
                  .join(' • '),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          if (product.brandNames.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: product.brandNames.take(3).map((brand) {
                return Chip(
                  label: Text(
                    brand,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: const Color(0xFFFF8C42).withOpacity(0.1),
                  side: const BorderSide(
                    color: Color(0xFFFF8C42),
                    width: 1,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// Package Selector Widget
class _PackageSelector extends StatelessWidget {
  final List<PackageAvailabilityInfo> packages;
  final String? selectedPackageId;

  const _PackageSelector({
    required this.packages,
    required this.selectedPackageId,
  });

  @override
  Widget build(BuildContext context) {
    if (packages.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Available Packages',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        ...packages.map((package) {
          final isSelected = package.packageId == selectedPackageId;
          return InkWell(
            onTap: () {
              context.read<PackageDetailCubit>().selectPackage(package.packageId);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? const Color(0xFFFF8C42) : Colors.grey[300]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                    ? const Color(0xFFFF8C42).withOpacity(0.05)
                    : Colors.transparent,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.displayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? const Color(0xFFFF8C42) : Colors.black87,
                          ),
                        ),
                        if (package.manufacturer != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            package.manufacturer!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.local_pharmacy,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${package.pharmacyCount} pharmacies',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.inventory,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${package.totalStock} in stock',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        package.lowestPriceFormatted,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? const Color(0xFFFF8C42) : Colors.black87,
                        ),
                      ),
                      Text(
                        'from',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

// Price and Cart Section Widget
class _PriceAndCartSection extends StatelessWidget {
  final PackageAvailabilityInfo package;
  final int quantity;

  const _PriceAndCartSection({
    required this.package,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quantity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      onPressed: quantity > 1
                          ? () => context.read<PackageDetailCubit>().updateQuantity(quantity - 1)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      quantity.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    _QuantityButton(
                      icon: Icons.add,
                      onPressed: () => context.read<PackageDetailCubit>().updateQuantity(quantity + 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                package.lowestPrice != null
                    ? '€${((package.lowestPrice! * quantity) / 100).toStringAsFixed(2)}'
                    : 'Price not available',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF8C42),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Quantity Button Widget
class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QuantityButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, size: 18),
        onPressed: onPressed,
        color: onPressed != null ? const Color(0xFFFF8C42) : Colors.grey[400],
      ),
    );
  }
}

// Description Section Widget
class _DescriptionSection extends StatelessWidget {
  final String description;

  const _DescriptionSection({required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

// Pharmacy Locations Section Widget
class _PharmacyLocationsSection extends StatelessWidget {
  final PackageAvailabilityInfo package;

  const _PharmacyLocationsSection({required this.package});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available at ${package.pharmacyCount} Pharmacies',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...package.pharmacyLocations.take(5).map((pharmacy) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8C42).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.local_pharmacy,
                      color: Color(0xFFFF8C42),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pharmacy.pharmacyName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pharmacy.fullAddress,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (pharmacy.stockQuantity > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${pharmacy.stockQuantity} in stock',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        pharmacy.priceFormatted,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF8C42),
                        ),
                      ),
                      if (pharmacy.hasCoordinates)
                        TextButton(
                          onPressed: () {
                            // Open map or navigation
                          },
                          child: const Text(
                            'Directions',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFFF8C42),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
          if (package.pharmacyLocations.length > 5)
            Center(
              child: TextButton(
                onPressed: () {
                  // Show all pharmacies
                },
                child: Text(
                  'View all ${package.pharmacyLocations.length} pharmacies',
                  style: const TextStyle(
                    color: Color(0xFFFF8C42),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}