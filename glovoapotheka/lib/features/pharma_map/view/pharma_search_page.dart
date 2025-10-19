import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:glovoapotheka/core/widgets/top_navigation_bar.dart';
import 'package:glovoapotheka/data/models/cart_item.dart';
import 'package:glovoapotheka/data/providers/cart_provider.dart';
import 'package:glovoapotheka/domain/repositories/product_repository.dart';
import 'package:glovoapotheka/domain/services/city_service.dart';
import 'package:glovoapotheka/features/auth/cart/view/cart_view.dart';
import 'package:glovoapotheka/features/package_details/view/package_details.dart';
import 'package:glovoapotheka/features/pharma_map/cubit/pharma_search_cubit.dart';
import 'package:glovoapotheka/features/pharma_map/cubit/pharma_search_state.dart';
import 'package:glovoapotheka/features/search/view/search_bar_widget.dart';
import 'package:glovoapotheka/data/models/product.dart';
import 'package:latlong2/latlong.dart';

class PharmacySearchPage extends StatelessWidget {
  final List<CartItem> packages;


  const PharmacySearchPage({
    Key? key,
    required this.packages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) { 
        final cubit = PharmacySearchCubit(
          context.read<ProductRepository>(),
          context.read<CityService>(),
      );
      cubit.setPackages(packages);
      cubit.loadPharmacies();
      return cubit;
      },
      child: const PharmacySearchView(),
    );
  }
}


class PharmacySearchView extends StatelessWidget {
  const PharmacySearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocBuilder<PharmacySearchCubit, PharmacySearchState>(
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 768;
              
              if (isMobile) {
                return _PharmacySearchMobile();
              } else {
                return _buildDesktopLayout(context, state);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, PharmacySearchState state) {
    return ResizableSplit(
      leftPanelRatio: state.leftPanelRatio,
      onRatioChanged: (ratio) => context.read<PharmacySearchCubit>().setLeftPanelRatio(ratio),
      leftChild: const LeftPanel(),
      rightChild: const MapWidget(),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Stack(
      children: [
        const MapWidget(),
        DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.15,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // GestureDetector here to make gray line respond
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragUpdate: (details) {
                      scrollController.jumpTo(
                        scrollController.offset - details.delta.dy,
                      );
                    },
                    child: Container(
                      height: 20,
                      alignment: Alignment.center,
                      child: Container(
                        height: 4,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: const LeftPanel(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

      ],
    );
  }
}


class _PharmacySearchMobile extends StatefulWidget {
  const _PharmacySearchMobile();

  @override
  State<_PharmacySearchMobile> createState() => _PharmacySearchMobileState();
}

class _PharmacySearchMobileState extends State<_PharmacySearchMobile> {
  final DraggableScrollableController sheetController = DraggableScrollableController();
  bool _isDragging = false;


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const MapWidget(),
        DraggableScrollableSheet(
          controller: sheetController,
          initialChildSize: 0.4,
          minChildSize: 0.15,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // this drag handle moves the whole sheet
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragStart: (_) => setState(() => _isDragging = true),
                    onVerticalDragEnd: (_) => setState(() => _isDragging = false),
                    onVerticalDragUpdate: (details) {
                      final current = sheetController.size;
                      final newSize = current - details.primaryDelta! / MediaQuery.of(context).size.height;
                      sheetController.animateTo(
                        newSize.clamp(0.15, 0.85),
                        duration: Duration.zero,
                        curve: Curves.linear,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      height: _isDragging ? 26 : 20, // little "lift"
                      alignment: Alignment.center,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 4,
                        width: _isDragging ? 50 : 40, // slight widen when drag starts
                        decoration: BoxDecoration(
                          color: _isDragging ? Colors.grey[400] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: _isDragging
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: const LeftPanel(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}


class ResizableSplit extends StatefulWidget {
  final double leftPanelRatio;
  final ValueChanged<double> onRatioChanged;
  final Widget leftChild;
  final Widget rightChild;

  const ResizableSplit({
    super.key,
    required this.leftPanelRatio,
    required this.onRatioChanged,
    required this.leftChild,
    required this.rightChild,
  });

  @override
  State<ResizableSplit> createState() => _ResizableSplitState();
}

class _ResizableSplitState extends State<ResizableSplit> {
  bool isDragging = false;
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left panel
        Expanded(
          flex: (widget.leftPanelRatio * 100).round(),
          child: widget.leftChild,
        ),
        // Draggable divider
        GestureDetector(
          onPanUpdate: (details) {
            final totalWidth = MediaQuery.of(context).size.width;
            final newRatio = (details.globalPosition.dx / totalWidth).clamp(0.15, 0.8);
            widget.onRatioChanged(newRatio);
          },
          onPanStart: (_) => setState(() => isDragging = true),
          onPanEnd: (_) => setState(() => isDragging = false),
          onDoubleTap: () {
            final newRatio = widget.leftPanelRatio < 0.25 ? 0.4 : 0.2;
            widget.onRatioChanged(newRatio);
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            onEnter: (_) => setState(() => isHovering = true),
            onExit: (_) => setState(() => isHovering = false),
            child: Container(
              width: 16,
              color: Colors.transparent,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: isDragging ? 6 : (isHovering ? 4 : 2),
                  height: isDragging ? 80 : (isHovering ? 60 : 40),
                  decoration: BoxDecoration(
                    color: isDragging 
                        ? Colors.orange.shade400
                        : (isHovering 
                            ? Colors.grey.shade600 
                            : Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: isDragging || isHovering ? [
                      BoxShadow(
                        color: (isDragging ? Colors.orange : Colors.black)
                            .withOpacity(0.2),
                        blurRadius: isDragging ? 8 : 4,
                        spreadRadius: isDragging ? 2 : 1,
                      ),
                    ] : null,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Right panel
        Expanded(
          flex: ((1 - widget.leftPanelRatio) * 100).round(),
          child: widget.rightChild,
        ),
      ],
    );
  }
}

class LeftPanel extends StatelessWidget {
  final ScrollController? scrollController;

  const LeftPanel({super.key, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProductsSummary(),
          const Divider(height: 1),
          const FiltersSection(),
          const Divider(height: 1),
          PharmacyResultsList(scrollController: scrollController),
        ],
      ),
    );
  }
}

class ProductsSummary extends StatelessWidget {
  const ProductsSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PharmacySearchCubit, PharmacySearchState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Selected Products (${state.ids.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                children: state.items.map((product) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.medication, color: Colors.orange),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              product.id,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
              if (state.radiusKm != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Text(
                    'Within ${state.radiusKm!.toStringAsFixed(1)} km',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class FiltersSection extends StatelessWidget {
  const FiltersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PharmacySearchCubit, PharmacySearchState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.tune, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => context.read<PharmacySearchCubit>().refresh(),
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Sort by
              Text('Sort by:', style: TextStyle(color: Colors.grey[700])),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildSortButton('Price', 'price', state.sortBy, context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSortButton('Distance', 'distance', state.sortBy, context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSortButton('Name', 'name', state.sortBy, context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Must have all toggle
              SwitchListTile(
                title: const Text('Must have all products'),
                subtitle: const Text('Only show pharmacies with all selected items'),
                activeColor: Colors.orange,
                value: state.mustHaveAll,
                onChanged: (value) => context.read<PharmacySearchCubit>().setFilters(
                  mustHaveAll: value,
                ),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              // Radius slider
              Text('Search radius: ${state.radiusKm?.toStringAsFixed(1) ?? 'All'} km'),
              Slider(
                value: (state.radiusKm?.toDouble() ?? 50.0),
                min: 0.5,
                max: 50.0,
                divisions: 99,
                activeColor: Colors.orange,
                onChanged: (value) => context.read<PharmacySearchCubit>().setFilters(
                  radiusKm: value.round(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortButton(String label, String value, String currentSort, BuildContext context) {
    final isSelected = currentSort == value;
    return GestureDetector(
      onTap: () => context.read<PharmacySearchCubit>().setFilters(sortBy: value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class PharmacyResultsList extends StatelessWidget {
  final ScrollController? scrollController;

  const PharmacyResultsList({super.key, this.scrollController});

  void showPopUpReserve(BuildContext context, List<CartItem> items, PharmacySearchResult pharmacy) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Container(
            width: 600,
            constraints: const BoxConstraints(maxHeight: 600),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Booking Confirmation',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Items List - Limited to 2.2 items height
                Container(
                  height: 180, // Height for approximately 2.2 items
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final priceInDollars = (item.price ?? 0) / 100;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            // Product Image
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: item.imageUrls != null && item.imageUrls!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        item.imageUrls!.first,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.image, color: Colors.grey);
                                        },
                                      ),
                                    )
                                  : const Icon(Icons.image, color: Colors.grey),
                            ),
                            const SizedBox(width: 12),
                            
                            // Product Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (item.description != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      item.description!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            
                            // Quantity and Price
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.delete_outline, 
                                        color: Colors.grey, size: 20),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${priceInDollars.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Pharmacy Information
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.brown.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.brown.shade600,
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
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            pharmacy.address!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Working hours: 08:00-20:00',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '\$${(pharmacy.totalPriceCents! / 100).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Reserve Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Add your booking logic here
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Reserve Order',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PharmacySearchCubit, PharmacySearchState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Searching pharmacies...'),
              ],
            ),
          );
        }

        if (state.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error: ${state.errorMessage}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<PharmacySearchCubit>().refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state.results.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('No pharmacies found'),
                Text('Try adjusting your search filters'),
              ],
            ),
          );
        }

        // Used for mobile
        if (scrollController == null) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: state.results.map((pharmacy) {
                return PharmacyCard(
                  key: ValueKey(pharmacy.pharmacyId),
                  pharmacy: pharmacy,
                  isSelected: state.selectedPharmacyId == pharmacy.pharmacyId,
                  isHovered: state.hoveredPharmacyId == pharmacy.pharmacyId,
                  onTap: () => context.read<PharmacySearchCubit>().selectPharmacy(pharmacy.pharmacyId),
                  onHover: (isHovering) {
                    if (isHovering) {
                      context.read<PharmacySearchCubit>().hoverPharmacy(pharmacy.pharmacyId);
                    } else {
                      context.read<PharmacySearchCubit>().clearHover();
                    }
                  },
                  onChoose: () {
                    showPopUpReserve(context, state.items, pharmacy);
                  },
                );
              }).toList(),
            ),
          );
        }

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: state.results.length,
          itemBuilder: (context, index) {
            final pharmacy = state.results[index];
            return PharmacyCard(
              key: ValueKey(pharmacy.pharmacyId),
              pharmacy: pharmacy,
              isSelected: state.selectedPharmacyId == pharmacy.pharmacyId,
              isHovered: state.hoveredPharmacyId == pharmacy.pharmacyId,
              onTap: () => context.read<PharmacySearchCubit>().selectPharmacy(pharmacy.pharmacyId),
              onHover: (isHovering) {
                if (isHovering) {
                  context.read<PharmacySearchCubit>().hoverPharmacy(pharmacy.pharmacyId);
                } else {
                  context.read<PharmacySearchCubit>().clearHover();
                }
              },
              onChoose: () {
                  showPopUpReserve(context, state.items, pharmacy);
              },
            );
          },
        );
      },
    );
  }
}

class PharmacyCard extends StatefulWidget {
  final PharmacySearchResult pharmacy;
  final bool isSelected;
  final bool isHovered;
  final VoidCallback onTap;
  final ValueChanged<bool> onHover;
  final VoidCallback onChoose;

  const PharmacyCard({
    super.key,
    required this.pharmacy,
    required this.isSelected,
    required this.isHovered,
    required this.onTap,
    required this.onHover,
    required this.onChoose,
  });

  @override
  State<PharmacyCard> createState() => _PharmacyCardState();
}

class _PharmacyCardState extends State<PharmacyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false; 

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PharmacyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHovered && !oldWidget.isHovered) {
      _animationController.forward();
    } else if (!widget.isHovered && oldWidget.isHovered) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => widget.onHover(true),
      onExit: (_) => widget.onHover(false),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                elevation: widget.isHovered ? 8 : 2,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: widget.onTap,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: widget.isSelected
                          ? Border.all(color: Colors.blue, width: 2)
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.pharmacy.pharmacyName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.pharmacy.address?? "Adress not found",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${widget.pharmacy.city}, ${widget.pharmacy.country}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (widget.pharmacy.distanceKm != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[50],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${widget.pharmacy.distanceKm!.toStringAsFixed(1)} km',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                if (widget.pharmacy.minPriceCents != null)
                                  Text(
                                    '€${(widget.pharmacy.totalPriceCents! / 100).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${widget.pharmacy.pkgCount} items',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.orange[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isExpanded = !_isExpanded;
                                });
                              },
                              icon: Icon(
                                _isExpanded ? Icons.expand_less : Icons.expand_more,
                                size: 16,
                              ),
                              label: Text(
                                _isExpanded ? 'Show less' : 'Show details',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: widget.onChoose,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text(
                                'Make reservation',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        if (_isExpanded) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          Text(
                            'Available products:',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...widget.pharmacy.packages.map((package) {
                            final productName = package.brandName;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.medication,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      productName,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  if (package.priceCents != null)
                                    Text(
                                      '€${(package.priceCents! / 100).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: package.stockQuantity! > 5
                                          ? Colors.green[50]
                                          : Colors.orange[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${package.stockQuantity} in stock',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: package.stockQuantity! > 5
                                            ? Colors.green[700]
                                            : Colors.orange[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          if (widget.pharmacy.totalPriceCents != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    'Total for all items:',
                                    style: TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '€${(widget.pharmacy.totalPriceCents! / 100).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with TickerProviderStateMixin {
  late MapController _mapController;
  late AnimationController _markerAnimationController;
  String? _animatingMarkerId;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _markerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _markerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PharmacySearchCubit, PharmacySearchState>(
      listenWhen: (previous, current) {
        return previous.selectedPharmacyId != current.selectedPharmacyId ||
               previous.hoveredPharmacyId != current.hoveredPharmacyId;
      },
      listener: (context, state) {
        if (state.selectedPharmacyId != null) {
          final pharmacy = state.results.firstWhere(
            (p) => p.pharmacyId == state.selectedPharmacyId,
          );
          if (pharmacy.lat != null && pharmacy.lng != null) {
            final latLngPosition = LatLng(pharmacy.lat!, pharmacy.lng!);
            _mapController.move(latLngPosition, 15.0);
          }
        }
        
        if (state.hoveredPharmacyId != null && 
            state.hoveredPharmacyId != _animatingMarkerId) {
          setState(() {
            _animatingMarkerId = state.hoveredPharmacyId;
          });
          _markerAnimationController.forward().then((_) {
            _markerAnimationController.reverse();
          });
        }
      },
      child: BlocBuilder<PharmacySearchCubit, PharmacySearchState>(
        builder: (context, state) {
          final LatLng center = LatLng(context.read<CityService>().selectedCity.lat, context.read<CityService>().selectedCity.lng);
          
          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 12.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.pharmacy_search',
                maxNativeZoom: 19,
              ),
              MarkerLayer(
                markers: [
                  // User location marker
                  if (state.userLocation != null)
                    Marker(
                      point: state.userLocation!,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  // Pharmacy markers
                  ...state.results
                      .where((pharmacy) => (pharmacy.lat != null && pharmacy.lng != null))
                      .map((pharmacy) => _buildPharmacyMarker(pharmacy, state)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Marker _buildPharmacyMarker(PharmacySearchResult pharmacy, PharmacySearchState state) {
    final isSelected = state.selectedPharmacyId == pharmacy.pharmacyId;
    final isHovered = state.hoveredPharmacyId == pharmacy.pharmacyId;
    final isAnimating = _animatingMarkerId == pharmacy.pharmacyId;

    return Marker(
      point: LatLng(pharmacy.lat!, pharmacy.lng!),
      width: isSelected || isHovered ? 50 : 40,
      height: isSelected || isHovered ? 60 : 50,
      child: GestureDetector(
        onTap: () {
          context.read<PharmacySearchCubit>().selectPharmacy(pharmacy.pharmacyId);
        },
        child: AnimatedBuilder(
          animation: _markerAnimationController,
          builder: (context, child) {
            final scale = isAnimating 
                ? 1.0 + (_markerAnimationController.value * 0.3)
                : 1.0;
            
            return Transform.scale(
              scale: scale,
              child: Column(
                children: [
                  // Info popup for selected pharmacy
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            pharmacy.pharmacyName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          if (pharmacy.minPriceCents != null)
                            Text(
                              'From €${(pharmacy.minPriceCents! / 100).toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                  // Marker pin
                  Container(
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Colors.blue 
                          : isHovered 
                              ? Colors.orange 
                              : Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_pharmacy,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}