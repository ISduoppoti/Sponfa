// package_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glovoapotheka/core/widgets/top_navigation_bar.dart';
import 'package:glovoapotheka/data/models/product.dart';
import 'package:glovoapotheka/data/providers/cart_provider.dart';
import 'package:glovoapotheka/features/package_details/cubit/package_details_cubit.dart';
import 'package:glovoapotheka/features/package_details/cubit/package_details_state.dart';

class PackageDetailsPage extends StatelessWidget {
  final PackageAvailabilityInfo package;
  final String descr;
  final String strength;
  final String form;

  const PackageDetailsPage({
    Key? key,
    required this.package,
    required this.descr,
    required this.strength,
    required this.form,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PackageDetailCubit(
        cartProvider: context.read<CartProvider>(),
      )..initializeWithPackage(package, descr, strength, form),
      child: const PackageDetailsView(),
    );
  }
}

class PackageDetailsView extends StatelessWidget {
  const PackageDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<PackageDetailCubit, PackageDetailState>(
        builder: (context, state) {
          if (state is PackageDetailError) {
            return Column(
              children: [ 
                TopNavigationBar(isMobile: false, screenWidth: screenWidth, isSearchBar: true, isTextMenu: false, color: Color(0xFFFFF3E0)),
                Center(
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
                        'Error loading package',
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
                ),
              ],
            );
          }

          if (state is PackageDetailLoaded) {
            return Column(
              children: [
                TopNavigationBar(isMobile: false, screenWidth: screenWidth, isSearchBar: true, isTextMenu: false, color: Color(0xFFFFF3E0), isShadow: true,),
                SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left side - Images
                          Expanded(
                            flex: 1,
                            child: _PackageImageCarousel(package: state.package),
                          ),
                          
                          const SizedBox(width: 24),
                          
                          // Right side - Product Info
                          Expanded(
                            flex: 2,
                            child: _PackageInfoSection(
                              package: state.package,
                              quantity: state.cartQuantity,
                              descr: state.descr,
                              strength: state.strength,
                              form: state.form,

                            ),
                          ),

                          // Price container
                          Expanded(
                            flex: 1,
                            child: Container(
                              margin: const EdgeInsets.all(50),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, -2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Price section
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        "From ${state.package.lowestPriceFormatted}",
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFF8C42),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Quantity selector
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey[300]!),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          //mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove, size: 20),
                                              onPressed: state.cartQuantity > 1
                                                  ? () => context.read<PackageDetailCubit>().updateQuantity(state.cartQuantity - 1)
                                                  : null,
                                              color: state.cartQuantity > 1 ? Colors.black87 : Colors.grey[400],
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 16),
                                              child: Text(
                                                state.cartQuantity.toString(),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add, size: 20),
                                              onPressed: () => context.read<PackageDetailCubit>().updateQuantity(state.cartQuantity + 1),
                                              color: Colors.black87,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      // Add to Cart button
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => context.read<PackageDetailCubit>().addToCart(),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFFF8C42),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.shopping_cart_outlined, size: 20),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Add to Cart • ${_getTotalPrice(state.package, state.cartQuantity)}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          )
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

  String _getTotalPrice(PackageAvailabilityInfo package, int quantity) {
    if (package.lowestPrice != null) {
      final total = (package.lowestPrice! * quantity) / 100;
      return '$quantity pcs';
      //return '€${total.toStringAsFixed(2)}';
    }
    return 'Price N/A';
  }
}

// Package Image Carousel Widget
class _PackageImageCarousel extends StatefulWidget {
  final PackageAvailabilityInfo package;

  const _PackageImageCarousel({required this.package});

  @override
  State<_PackageImageCarousel> createState() => _PackageImageCarouselState();
}

class _PackageImageCarouselState extends State<_PackageImageCarousel> {
  int selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.package.imageUrls ?? [];
    final hasMultipleImages = images.length > 1;

    return Column(
      children: [
        // Main image display
        Container(
          height: 400,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: images.isNotEmpty
                ? Image.network(
                    images[selectedImageIndex],
                    headers: {'User-Agent': 'Mozilla/5.0'},
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[50],
                        child: const Icon(
                          Icons.medication,
                          size: 120,
                          color: Colors.grey,
                        ),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[50],
                    child: const Icon(
                      Icons.medication,
                      size: 120,
                      color: Colors.grey,
                    ),
                  ),
          ),
        ),
        
        if (hasMultipleImages) ...[
          const SizedBox(height: 12),
          // Thumbnail row
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = index == selectedImageIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedImageIndex = index;
                    });
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFFF8C42) : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        images[index],
                        headers: {'User-Agent': 'Mozilla/5.0'},
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.medication,
                            size: 30,
                            color: Colors.grey,
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

// Package Info Section Widget
class _PackageInfoSection extends StatelessWidget {
  final String descr;
  final String strength;
  final String form;
  final PackageAvailabilityInfo package;
  final int quantity;

  const _PackageInfoSection({
    required this.descr,
    required this.strength,
    required this.form,
    required this.package,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product name
        Text(
          package.displayName,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.2,
          ),
        ),
        
        const SizedBox(height: 8),

        // Brand name if available
        if (package.manufacturer != null) ...[
          Text(
            package.manufacturer!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],

        const SizedBox(height: 16),
        
        Text(
          'Strength: $strength',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Form: $form',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Availability info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'In stock',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Product details
        _ProductDetailItem(
          icon: Icons.local_pharmacy,
          label: 'Available at',
          value: '${package.pharmacyCount} pharmacies',
        ),
        
        _ProductDetailItem(
          icon: Icons.inventory_2_outlined,
          label: 'Total stock',
          value: '${package.totalStock} units',
        ),
        
        if (package.countryCode != null)
          _ProductDetailItem(
            icon: Icons.flag_outlined,
            label: 'Origin',
            value: package.countryCode!.toUpperCase(),
          ),
        
        const SizedBox(height: 20),
        
        // Additional info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                color: Colors.blue[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'FREE shipping over €50.00',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        Text(
          descr,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}

// Product Detail Item Widget
class _ProductDetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProductDetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}