import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glovoapotheka/data/models/product.dart';
import 'package:glovoapotheka/data/models/city.dart';
import 'package:glovoapotheka/features/packages_menu/view/packages_view.dart';
import 'dart:math' as math;

import 'package:glovoapotheka/features/search/cubit/search_cubit.dart';
import 'package:glovoapotheka/features/search/cubit/search_state.dart';

import 'package:glovoapotheka/domain/services/city_service.dart';

import 'package:glovoapotheka/features/search/widgets/presearch_window_widget.dart';


class UnifiedSearchBar extends StatefulWidget {
  final bool isCitySelector;
  final bool isNavBar;
  String? controllerText;
  final VoidCallback? onCityTap;
  final double? width;

  UnifiedSearchBar({
    super.key,
    this.isCitySelector = true,
    this.isNavBar = false,
    this.controllerText,
    this.onCityTap,
    this.width,
  });

  @override
  State<UnifiedSearchBar> createState() => _UnifiedSearchBarState();
}

class _UnifiedSearchBarState extends State<UnifiedSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _searchContainerKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        if (widget.controllerText != null) {
          _controller.text = widget.controllerText!;
          widget.controllerText = null;
        }
        _showOverlay();
      }
    });
  }

void _showOverlay() {
  if (_overlayEntry != null) return;

  _overlayEntry = OverlayEntry(
    builder: (context) => Stack(
      children: [
        // Instead of GestureDetector, use IgnorePointer trick
        Positioned.fill(
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) {
              _hideOverlay(); // closes overlay
            },
          ),
        ),

        // Overlay content
        Positioned(
          width: _getSearchBarWidth(),
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 65),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(widget.isNavBar ? 10 : 8),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 500),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(widget.isNavBar ? 10 : 8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: BlocBuilder<SearchCubit, SearchState>(
                  builder: (context, state) {
                    if (state is SearchLoading) {
                      return const SizedBox(
                        height: 100,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (state is SearchLoaded) {
                      if (state.results.isEmpty) {
                        return const SizedBox(
                          height: 60,
                          child: Center(child: Text('No products found.')),
                        );
                      }
                      return _buildSearchResults(state.results);
                    } else if (state is SearchError) {
                      return SizedBox(
                        height: 60,
                        child: Center(child: Text('Error: ${state.message}')),
                      );
                    } else {
                      return SizedBox(
                        child: SearchWidgetWindow(
                          focusNode: _focusNode,
                          onClose: _hideOverlay,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Overlay.of(context).insert(_overlayEntry!);
}


  Widget _buildSearchResults(List<ProductModel> products) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Products section
          if (products.isNotEmpty) ...[
            _buildSectionHeader('Products', Icons.medical_services),
            ...products.map((product) => _buildProductTile(product)),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTile(ProductModel product) {
    return InkWell(
      onTap: () {
        _hideOverlay();
        _focusNode.unfocus();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductPackagesPage(productId: product.productId),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey, width: 0.1),
          ),
        ),
        child: Row(
          children: [
            // Product icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.medication,
                color: Colors.blue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.displayName ?? product.innName ?? 'Unknown Product',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.form ?? 'Various forms'} • ${product.strength ?? "No strenght"}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Arrow indicator
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  double _getSearchBarWidth() {
    // Try to read the rendered width of the search container via the GlobalKey.
    try {
      final renderBox = _searchContainerKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        final w = renderBox.size.width;
        if (w.isFinite && w > 0) return w;
      }
    } catch (e) {
      // ignore and fallback
    }

    // Fallback to MediaQuery (screen width) or a safe default.
    final screenWidth = MediaQuery.of(context).size.width;
    if (widget.width != null) return widget.width!;
    if (widget.isNavBar) {
      // Prefer using full screen width as a fallback for navbar, but finite.
      return screenWidth;
    }
    return math.min(screenWidth * 0.8, 700);
  }

  void _showCitySelector(BuildContext context) async {
    // Hide the search overlay first to prevent z-index issues
    _hideOverlay();
    
    final cityService = context.read<CityService>();
    await cityService.loadCities();

    final availableCities = cityService.cities;

    if (!context.mounted) return;

    final selected = await showDialog<City>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text("Select Your City"),
          children: availableCities.map((city) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, city),
              child: Text(city.name),
            );
          }).toList(),
        );
      },
    );

    if (selected != null) {
      cityService.setCity(selected);
    }
    
    // After city selection, if search field still has focus, show overlay again
    if (_focusNode.hasFocus) {
      // Small delay to ensure dialog is fully closed
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_focusNode.hasFocus) {
          _showOverlay();
        }
      });
    }
  }

  @override
  void dispose() {
    _hideOverlay();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CityService _cityService = context.watch<CityService>();
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Determine container properties based on isNavBar
    final containerHeight = widget.isNavBar ? 50.0 : 60.0;
    final borderRadius = widget.isNavBar ? 10.0 : 15.0;
    final double? containerWidth = widget.width ??
        (widget.isNavBar ? null : math.min(screenWidth * 0.8, 700));

    final city = context.watch<CityService>().selectedCity;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        key: _searchContainerKey,
        width: containerWidth,
        height: containerHeight,
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Row(
          children: [
            // Search field container
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _focusNode.requestFocus();
                },
                child: Container(
                  alignment: Alignment.center,
                  height: containerHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: (query) {
                      context.read<SearchCubit>().search(query);
                    },
                    decoration: InputDecoration(
                      hintText: widget.controllerText ?? (
                          widget.isNavBar
                              ? 'Enter medication name...'
                              : 'Search for products...'
                      ),
                      suffixIcon: const Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: widget.isNavBar ? 20.0 : 16.0,
                        vertical: 12.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // City selector (if enabled)
            if (widget.isCitySelector) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  // Don't close overlay, just handle city selection
                  if (widget.onCityTap != null) {
                    widget.onCityTap!();
                  } else {
                    _showCitySelector(context);
                  }
                },
                child: Container(
                  width: 150,
                  height: containerHeight,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 130, 0),
                    borderRadius: BorderRadius.circular(borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on,
                          color: Color.fromARGB(255, 255, 255, 255)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          city.name,
                          style: const TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}