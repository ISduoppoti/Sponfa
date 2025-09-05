import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;

import 'package:glovoapotheka/features/search/cubit/search_cubit.dart';
import 'package:glovoapotheka/features/search/cubit/search_state.dart';

import 'package:glovoapotheka/domain/services/city_service.dart';

import 'package:glovoapotheka/features/search/widgets/presearch_window_widget.dart';

class UnifiedSearchBar extends StatefulWidget {
  final bool isCitySelector;
  final bool isNavBar;
  final VoidCallback? onCityTap;
  final double? width;

  const UnifiedSearchBar({
    super.key,
    this.isCitySelector = true,
    this.isNavBar = false,
    this.onCityTap,
    this.width,
  });

  @override
  State<UnifiedSearchBar> createState() => _UnifiedSearchBarState();
}

class _UnifiedSearchBarState extends State<UnifiedSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  final GlobalKey _searchContainerKey = GlobalKey(); // Changed to wrap entire container

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showOverlay();
      }
    });
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    final RenderBox? renderBox = _searchContainerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            // close only when clicking outside overlay
            _focusNode.unfocus();
            _hideOverlay();
          },
          child: Stack(
            children: [
              Positioned(
                left: offset.dx,
                top: offset.dy + size.height + 5,
                width: size.width,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(widget.isNavBar ? 10 : 8),
                  child: GestureDetector(
                    behavior: HitTestBehavior.deferToChild,
                    onTap: () {print("Inside");}, // absorb taps inside overlay
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 500),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(widget.isNavBar ? 10 : 8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
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
                              child: Center(
                                child: CircularProgressIndicator(color: Colors.orange)),
                            );
                          } else if (state is SearchLoaded) {
                            if (state.results.isEmpty) {
                              return const SizedBox(
                                height: 60,
                                child: Center(child: Text('No products found.')),
                              );
                            }
                            return SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: state.results.map((product) {
                                  return ListTile(
                                    title: Text(product.displayName),
                                    subtitle: Text('${product.form} - ${product.lowestPriceFormatted}'),
                                    onTap: () {
                                      print('Selected product: ${product.displayName}');
                                      _controller.text = product.displayName;
                                      _hideOverlay();
                                      _focusNode.unfocus();
                                    },
                                  );
                                }).toList(),
                              ),
                            );
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
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showCitySelector(BuildContext context) async {
    final cityService = context.read<CityService>();
    await cityService.loadCities(); // ensure cities are loaded

    final availableCities = cityService.cities.map((c) => c.name).toList();

    if (!context.mounted) return;

    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text("Select Your City"),
          children: availableCities.map((city) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, city),
              child: Text(city),
            );
          }).toList(),
        );
      },
    );

    if (selected != null) {
      cityService.detectCityFromLocation();
      cityService.setCity(selected);
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
    final containerWidth = widget.width ?? 
        (widget.isNavBar ? double.infinity : math.min(screenWidth * 0.8, 700));

    final city = context.watch<CityService>().selectedCity;

    return Container(
      key: _searchContainerKey, // Moved key to outer container
      width: containerWidth,
      height: containerHeight,
      decoration: const BoxDecoration(
        color: Colors.transparent, // Transparent wrapper
      ),
      child: Row(
        children: [
          // Search field container
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Ensure focus happens when tapping the search container
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
                    hintText: widget.isNavBar
                        ? 'Enter medication name...'
                        : 'Search for products...',
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
            const SizedBox(width: 8), // spacing
            GestureDetector(
              onTap: widget.onCityTap ?? () => _showCitySelector(context),
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
                        city,
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
    );
  }
}