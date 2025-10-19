import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glovoapotheka/data/models/product.dart';
import 'package:glovoapotheka/features/search/cubit/search_cubit.dart';
import 'package:glovoapotheka/features/search/cubit/search_state.dart';
import 'package:go_router/go_router.dart';

class MobileSearchSheet extends StatefulWidget {
  final String? initialText;

  const MobileSearchSheet({super.key, this.initialText});

  @override
  State<MobileSearchSheet> createState() => _MobileSearchSheetState();
}

class _MobileSearchSheetState extends State<MobileSearchSheet> {
  late TextEditingController _searchController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialText ?? '');
    _focusNode = FocusNode();
    
    // Auto-focus when sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Search Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  // Search Input
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _focusNode.hasFocus 
                              ? Color(0xFFFF6B35) 
                              : Colors.grey[300]!,
                          width: _focusNode.hasFocus ? 2 : 1,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: "Search products...",
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 22),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, size: 20),
                                  color: Colors.grey[600],
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        onChanged: (query) {
                          setState(() {});
                          context.read<SearchCubit>().search(query);
                        },
                        onSubmitted: (query) {
                          // Handle search submission
                          print('Search submitted: $query');
                        },
                      ),
                    ),
                  ),

                  SizedBox(width: 12),

                  // Close Button
                  IconButton(
                    icon: Icon(Icons.close),
                    color: Colors.grey[700],
                    iconSize: 24,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.all(8),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Search Results Area
          Expanded(
            child: _searchController.text.isEmpty
                ? _buildEmptyState()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16),
          Text(
            "Start typing to search",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder<SearchCubit, SearchState>(
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
          return _buildProductList(state.results);
        } else if (state is SearchError) {
          return SizedBox(
            height: 60,
            child: Center(child: Text('Error: ${state.message}')),
          );
        } else {
          return Text('An error occurred.');
        }
      },
    );
  }

  Widget _buildProductList(List<ProductSearchItem> products) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProductCard(product);
        }, 
      ),
    );
  }

  Widget _buildProductCard(ProductSearchItem product) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade800.withValues(alpha: 0.1),
            width: 1,
          )
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to product detail or handle selection
            context.go('/packages/${product.productId}');
          },
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey[600], size: 20),
                    SizedBox(width: 8),
                    // Display Name
                    Text(
                      product.displayName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 0, 0, 0),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [              
                    // Strength and Form Row
                    if (product.strength != null) ...[
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Color(0xFFFF6B35).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Color(0xFFFF6B35).withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          product.strength!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFFF6B35),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                    ],
                        
                    if (product.form != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.blue[400]!.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.blue[400]!.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          product.form!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[300],
                          ),
                        ),
                      ),
                  ],
                ),  
              ],
            ),
          ),
        ),
      ),
    );
  }
}